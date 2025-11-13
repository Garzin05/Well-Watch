import 'package:flutter/material.dart';

class HealthDataEntryDialog extends StatelessWidget {
  final String title;
  final List<Widget> formFields;
  final VoidCallback onSave;

  const HealthDataEntryDialog({
    super.key,
    required this.title,
    required this.formFields,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: formFields,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            onSave();
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
