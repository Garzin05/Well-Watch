import 'package:flutter/material.dart';
import 'package:projetowell/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _editing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Apenas placeholders visuais, sem lógica real
    _emailController.text = 'usuario@exemplo.com';
    _specialtyController.text = 'Endocrinologia';
    _heightController.text = '1.75';
    _weightController.text = '72.0';
    _ageController.text = '34';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// HEADER DO PERFIL
  Widget _buildProfileHeader(AuthService auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlueBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  (auth.username ?? "U").substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueBackground,
                  ),
                ),
              ),
              if (!_editing)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.darkBlueBackground,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    color: AppColors.darkBlueBackground,
                    onPressed: () => setState(() => _editing = true),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            auth.username ?? "Usuário",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: auth.role == "doctor"
                  ? Colors.orangeAccent
                  : AppColors.lightBlueAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              auth.role == "doctor" ? "MÉDICO" : "PACIENTE",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CARD DE INFORMAÇÕES
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkBlueBackground),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  /// CAMPOS EDITÁVEIS
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: _editing,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          suffix: suffix != null ? Text(suffix) : null,
          border: _editing ? const OutlineInputBorder() : InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // Preenche com o nome do usuário real
    _nameController.text = auth.username ?? '';

    final isDoctor = auth.role == "doctor";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        elevation: 0,
        backgroundColor: AppColors.darkBlueBackground,
        actions: [
          if (_editing)
            TextButton(
              onPressed: () async {
                /// Atualiza apenas o nome do usuário
                auth.username = _nameController.text;

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("auth_username", auth.username ?? "");

                setState(() => _editing = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Perfil atualizado com sucesso!"),
                  ),
                );
              },
              child: const Text(
                "Salvar",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(auth),

            const SizedBox(height: 20),

            /// Informações Pessoais
            _buildInfoCard(
              title: "Informações Pessoais",
              icon: Icons.person,
              children: [
                _buildEditableField(
                  label: "Nome Completo",
                  controller: _nameController,
                ),
                _buildEditableField(
                  label: "E-mail",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),

            /// Informações do Médico
            if (isDoctor)
              _buildInfoCard(
                title: "Informações Profissionais",
                icon: Icons.medical_services,
                children: [
                  _buildEditableField(
                    label: "Especialidade",
                    controller: _specialtyController,
                  ),
                ],
              ),

            /// Informações do Paciente
            if (!isDoctor)
              _buildInfoCard(
                title: "Dados de Saúde",
                icon: Icons.favorite,
                children: [
                  _buildEditableField(
                    label: "Idade",
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    suffix: "anos",
                  ),
                  _buildEditableField(
                    label: "Altura",
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    suffix: "m",
                  ),
                  _buildEditableField(
                    label: "Peso",
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    suffix: "kg",
                  ),
                ],
              ),

            const SizedBox(height: 20),

            /// BOTÃO DE LOGOUT
            if (!_editing)
              TextButton.icon(
                onPressed: () {
                  auth.signOut();
                  Navigator.pushReplacementNamed(context, "/login");
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text(
                  "Sair",
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
