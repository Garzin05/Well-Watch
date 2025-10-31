import 'package:flutter/material.dart';
import './doctor_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  String _selectedTheme = 'Sistema';
  String _selectedLanguage = 'Português';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: DoctorTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizada
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Configurações',
                      style: DoctorTheme.titleStyle,
                    ),
                  ],
                ),
              ),
              // Conteúdo
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildSectionHeader('Notificações'),
                      _buildSwitchTile(
                        title: 'Notificações push',
                        subtitle: 'Receber alertas no dispositivo',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                      _buildSwitchTile(
                        title: 'Notificações por e-mail',
                        subtitle: 'Receber resumos diários',
                        value: _emailNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _emailNotificationsEnabled = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Aparência'),
                      _buildDropdownTile(
                        title: 'Tema',
                        value: _selectedTheme,
                        items: const ['Sistema', 'Claro', 'Escuro'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedTheme = value);
                          }
                        },
                      ),
                      _buildDropdownTile(
                        title: 'Idioma',
                        value: _selectedLanguage,
                        items: const ['Português', 'English', 'Español'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedLanguage = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Conta'),
                      _buildActionTile(
                        title: 'Alterar senha',
                        subtitle: 'Altere sua senha de acesso',
                        icon: Icons.lock_outline,
                        onTap: () {
                          // TODO: Implementar alteração de senha
                        },
                      ),
                      _buildActionTile(
                        title: 'Dados pessoais',
                        subtitle: 'Edite suas informações',
                        icon: Icons.person_outline,
                        onTap: () {
                          // TODO: Implementar edição de dados
                        },
                      ),
                      _buildActionTile(
                        title: 'Sair',
                        subtitle: 'Encerrar sessão',
                        icon: Icons.exit_to_app,
                        isDestructive: true,
                        onTap: () {
                          // TODO: Implementar logout
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Sobre'),
                      _buildActionTile(
                        title: 'Termos de uso',
                        subtitle: 'Leia os termos e condições',
                        icon: Icons.description_outlined,
                        onTap: () {
                          // TODO: Abrir termos de uso
                        },
                      ),
                      _buildActionTile(
                        title: 'Política de privacidade',
                        subtitle: 'Saiba como seus dados são protegidos',
                        icon: Icons.privacy_tip_outlined,
                        onTap: () {
                          // TODO: Abrir política de privacidade
                        },
                      ),
                      _buildActionTile(
                        title: 'Versão do aplicativo',
                        subtitle: '1.0.0',
                        icon: Icons.info_outline,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: DoctorTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: DoctorTheme.primaryBlue,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : DoctorTheme.primaryBlue,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : DoctorTheme.textPrimary,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
