import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;

  const CustomScaffold({super.key, 
    required this.body,
    required this.title,
    this.showBackButton = true, required Null Function() onBackPressed, // Por padrão, o botão de voltar será exibido
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // Retorna para a tela anterior
                },
              )
            : null,
      ),
      body: body,
    );
  }
}
