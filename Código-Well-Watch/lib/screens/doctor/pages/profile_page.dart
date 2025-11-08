import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final crm = TextEditingController(text: 'CRM 0000');
  final name = TextEditingController(text: 'Dr(a). Médico(a)');
  final email = TextEditingController(text: 'medico@hospital.com');
  final birth = TextEditingController(text: '01/01/1980');
  final cep = TextEditingController(text: '00000-000');
  final hospital = TextEditingController(text: 'Hospital Central');
  final phone = TextEditingController(text: '+55 (11) 99999-9999');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Médico')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 36, backgroundColor: scheme.primary.withValues(alpha: 0.1), child: const Icon(Icons.person, size: 36)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Atualizar Foto')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: Column(
                children: [
                  _field('CRM', crm),
                  _field('Nome completo', name),
                  _field('E-mail', email),
                  _field('Data de nascimento', birth),
                  _field('CEP', cep),
                  _field('Hospital afiliado', hospital),
                  _field('Telefone', phone),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Salvar')),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
      ),
    );
  }

  void _save() {
    if (formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado localmente.')));
    }
  }
}
