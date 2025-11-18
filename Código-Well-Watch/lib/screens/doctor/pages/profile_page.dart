import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _crm = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _birth = TextEditingController();
  final _cep = TextEditingController();
  final _hospital = TextEditingController();
  final _phone = TextEditingController();
  final _specialty = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  // ===========================================================
  // 🔵 CARREGA PERFIL DO MÉDICO (CORRIGIDO — NÃO APAGA DADOS)
  // ===========================================================
  Future<void> _loadDoctorProfile() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.userId;

    if (userId == null) {
      setState(() => _loading = false);
      print("User ID é nulo");
      return;
    }

    const url = "http://localhost/WellWatchAPI/get_doctor_profile.php";

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      final data = jsonDecode(res.body);

      if (data["status"] == true) {
        final d = data["data"];

        // 🔵 SOMENTE sobrescreve se vier valor válido
        if (d["name"] != null) _name.text = d["name"];
        if (d["email"] != null) _email.text = d["email"];
        if (d["crm"] != null) _crm.text = d["crm"];
        if (d["data_nascimento"] != null) _birth.text = d["data_nascimento"];
        if (d["cep"] != null) _cep.text = d["cep"];
        if (d["hospital_afiliado"] != null) _hospital.text = d["hospital_afiliado"];
        if (d["telefone"] != null) _phone.text = d["telefone"];
        if (d["especialidade"] != null) _specialty.text = d["especialidade"];

        // 🔵 Atualiza AuthService sem apagar valores antigos
        if (d["name"] != null) auth.username = d["name"];
        if (d["email"] != null) auth.email = d["email"];
        if (d["crm"] != null) auth.crm = d["crm"];
        if (d["telefone"] != null) auth.phone = d["telefone"];
        if (d["especialidade"] != null) auth.specialty = d["especialidade"];
        if (d["hospital_afiliado"] != null) auth.hospital = d["hospital_afiliado"];

        await auth.saveLocal();
      }
    } catch (e) {
      debugPrint("Erro ao carregar perfil: $e");
    }

    setState(() => _loading = false);
  }

  // ===========================================================
  // 🔵 SALVA PERFIL DO MÉDICO
  // ===========================================================
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final auth = Provider.of<AuthService>(context, listen: false);
    const url = "http://localhost/WellWatchAPI/update_doctor.php";

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": auth.userId,
          "name": _name.text.trim(),
          "email": _email.text.trim(),
          "crm": _crm.text.trim(),
          "telefone": _phone.text.trim(),
          "especialidade": _specialty.text.trim(),
          "data_nascimento": _birth.text.trim(),
          "cep": _cep.text.trim(),
          "hospital": _hospital.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (data["status"] == true) {
        // Atualiza AuthService localmente
        auth.username = _name.text.trim();
        auth.email = _email.text.trim();
        auth.crm = _crm.text.trim();
        auth.phone = _phone.text.trim();
        auth.specialty = _specialty.text.trim();
        auth.hospital = _hospital.text.trim();
        await auth.saveLocal();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Erro ao salvar")),
        );
      }
    } catch (e) {
      debugPrint("Erro ao salvar perfil: $e");
    }

    setState(() => _saving = false);
  }

  // ===========================================================
  // LOGOUT
  // ===========================================================
  void _logout() {
    final auth = Provider.of<AuthService>(context, listen: false);
    auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  Widget _field(String label, TextEditingController controller,
      {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (required && (v == null || v.isEmpty)) {
            return "Obrigatório";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil do Médico")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 40),
                ),
              ),
              const SizedBox(height: 20),

              _field("CRM", _crm),
              _field("Nome completo", _name),
              _field("E-mail", _email),
              _field("Especialidade", _specialty, required: false),
              _field("Data de nascimento", _birth, required: false),
              _field("CEP", _cep, required: false),
              _field("Hospital afiliado", _hospital, required: false),
              _field("Telefone", _phone, required: false),

              const SizedBox(height: 20),

              _saving
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text("Salvar"),
                    ),

              const SizedBox(height: 30),

              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Sair do App",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
