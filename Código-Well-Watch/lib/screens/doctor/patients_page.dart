import 'package:flutter/material.dart';
import './doctor_theme.dart';
import '../../models/patient_model.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Patient> _patients = []; // TODO: Carregar da base de dados

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
                      'Meus Pacientes',
                      style: DoctorTheme.titleStyle,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      onPressed: () {
                        // TODO: Navegar para adicionar paciente
                      },
                    ),
                  ],
                ),
              ),
              // Campo de busca
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: DoctorTheme.searchDecoration,
                  onChanged: (value) {
                    // TODO: Implementar filtro de busca
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Lista de pacientes
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _patients.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _patients.length,
                          itemBuilder: (context, index) {
                            final patient = _patients[index];
                            return _buildPatientCard(patient);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar para adicionar paciente
        },
        backgroundColor: DoctorTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum paciente cadastrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione um novo paciente clicando no botão +',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: DoctorTheme.lightBlue,
          child: Text(
            patient.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${patient.age} anos • ${patient.gender}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Última consulta: ${patient.appointments.isNotEmpty ? patient.appointments.last.date : 'Nenhuma'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // TODO: Navegar para detalhes do paciente
          },
        ),
      ),
    );
  }
}
