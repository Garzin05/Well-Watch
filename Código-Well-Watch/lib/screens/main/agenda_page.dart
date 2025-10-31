import 'package:flutter/material.dart';
import 'package:projetowell/screens/main/calendar_base_page.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarBasePage(
      title: 'Agenda',
      dataDisplay: const Center(child: Text('Eventos para a data selecionada')),
      actionButton: null,
    );
  }
}
