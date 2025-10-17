import 'package:flutter/material.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String userType;
  final String userName;

  const RegistrationSuccessScreen({
    super.key,
    required this.userType,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro Realizado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'Bem-vindo, $userName!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Seu cadastro como $userType foi realizado com sucesso.'),
          ],
        ),
      ),
    );
  }
}
