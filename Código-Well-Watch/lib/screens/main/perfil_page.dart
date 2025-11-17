import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _allergies = TextEditingController();
  final _medications = TextEditingController();
  final _age = TextEditingController();
  final _bloodType = TextEditingController();

  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse("http://localhost/WellWatchAPI/get_patient_profile.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": auth.userId}),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        final d = data["data"];
        _name.text = d["name"] ?? "";
        _email.text = d["email"] ?? "";
        _phone.text = d["telefone"] ?? "";
        _address.text = d["endereco"] ?? "";
        _allergies.text = d["alergias"] ?? "";
        _medications.text = d["medicacoes_atuais"] ?? "";
        _age.text = d["idade"]?.toString() ?? "";
        _bloodType.text = d["tipo_sanguineo"] ?? "";
      }
    } catch (e) {
      debugPrint("Erro ao carregar perfil: $e");
    }

    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (_newPassword.text.isNotEmpty) {
      if (_confirmPassword.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Confirme a nova senha.")),
        );
        return;
      }
      if (_newPassword.text != _confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("As senhas não coincidem.")),
        );
        return;
      }
    }

    setState(() => _saving = true);

    final auth = Provider.of<AuthService>(context, listen: false);

    final body = {
      "user_id": auth.userId,
      "name": _name.text.trim(),
      "email": _email.text.trim(),
      "telefone": _phone.text.trim(),
      "endereco": _address.text.trim(),
      "alergias": _allergies.text.trim(),
      "medicacoes_atuais": _medications.text.trim(),
      "idade": int.tryParse(_age.text.trim()) ?? 0,
      "tipo_sanguineo": _bloodType.text.trim(),
    };

    if (_newPassword.text.isNotEmpty) {
      body["password"] = _newPassword.text.trim();
    }

    try {
      final res = await http.post(
        Uri.parse("http://localhost/WellWatchAPI/update_patient.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (data["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Erro ao atualizar")),
        );
      }
    } catch (e) {
      debugPrint("Erro ao salvar: $e");
    }

    setState(() => _saving = false);
  }

  void _logout(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    auth.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? type, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label),
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
      appBar: AppBar(
        title: const Text("Perfil do Paciente"),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              "Salvar",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => _logout(context),
            child: const Text(
              "Sair",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field("Nome", _name),
              _field("E-mail", _email, type: TextInputType.emailAddress),
              _field("Telefone", _phone),
              _field("Endereço", _address),
              _field("Alergias", _allergies),
              _field("Medicações", _medications),
              _field("Idade", _age, type: TextInputType.number),
              _field("Tipo sanguíneo", _bloodType),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "Alterar senha (opcional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _field("Nova senha", _newPassword, obscure: true),
              _field("Confirmar nova senha", _confirmPassword, obscure: true),
            ],
          ),
        ),
      ),
    );
  }
}
