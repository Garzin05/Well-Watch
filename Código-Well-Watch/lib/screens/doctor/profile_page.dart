import 'package:flutter/material.dart';
import './doctor_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _crmController;
  late TextEditingController _specialtyController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _crmController = TextEditingController();
    _specialtyController = TextEditingController();

    // TODO: Carregar dados do médico
    _loadDoctorData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _crmController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _loadDoctorData() {
    // TODO: Implementar carregamento dos dados
    _nameController.text = 'Dr. Silva';
    _emailController.text = 'dr.silva@example.com';
    _phoneController.text = '(11) 99999-9999';
    _crmController.text = 'CRM/SP 123456';
    _specialtyController.text = 'Cardiologista';
  }

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
                      'Perfil',
                      style: DoctorTheme.titleStyle,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isEditing) {
                            // TODO: Salvar alterações
                          }
                          _isEditing = !_isEditing;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Foto de perfil
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: DoctorTheme.primaryBlue,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: DoctorTheme.primaryBlue,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            color: Colors.white,
                            onPressed: () {
                              // TODO: Implementar upload de foto
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Informações do perfil
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Informações Pessoais'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nome Completo',
                          icon: Icons.person_outline,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: 'E-mail',
                          icon: Icons.email_outlined,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Telefone',
                          icon: Icons.phone_outlined,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Informações Profissionais'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _crmController,
                          label: 'CRM',
                          icon: Icons.badge_outlined,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _specialtyController,
                          label: 'Especialidade',
                          icon: Icons.medical_services_outlined,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 24),
                        if (!_isEditing) ...[
                          _buildSectionTitle('Estatísticas'),
                          const SizedBox(height: 16),
                          _buildStatsGrid(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: DoctorTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Pacientes',
          value: '42',
          icon: Icons.people_outline,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Consultas',
          value: '156',
          icon: Icons.calendar_today_outlined,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Avaliação',
          value: '4.8',
          icon: Icons.star_outline,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Anos de Exp.',
          value: '15',
          icon: Icons.work_outline,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
