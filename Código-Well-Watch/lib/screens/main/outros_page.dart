import 'package:flutter/material.dart';
import 'package:projetowell/theme.dart';

class OutrosPage extends StatelessWidget {
  const OutrosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outros'),
        backgroundColor: AppColors.darkBlueBackground,
      ),
      body: const Center(
        child: Text('Tela Outros - em desenvolvimento'),
      ),
    );
  }
}
