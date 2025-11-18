import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projetowell/screens/main/calendar_base_page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final List<String> _eventos = [];
  final TextEditingController _controller = TextEditingController();

  void _adicionarEvento() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1214),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Novo Evento',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF39D2C0)),
          ),
          content: TextField(
            controller: _controller,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zá-ú0-9\s\-]')),
            ],
            style: const TextStyle(
                color: Color(0xFF39D2C0), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Digite o nome do evento',
              hintStyle:
                  TextStyle(color: const Color(0xFF39D2C0).withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF39D2C0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF39D2C0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color(0xFF39D2C0), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF39D2C0)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  setState(() {
                    _eventos.add(_controller.text.trim());
                  });
                  _controller.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39D2C0),
                foregroundColor: const Color(0xFF0B1214),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _removerEvento(int index) {
    setState(() {
      _eventos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarBasePage(
      title: 'Agenda',
      dataDisplay: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: _eventos.isEmpty
            ? Center(
                child: Text(
                  'Nenhum evento cadastrado',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _eventos.length,
                itemBuilder: (context, index) {
                  final evento = _eventos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white,
                    shadowColor: Colors.teal.withOpacity(0.3),
                    child: ListTile(
                      leading: const Icon(Icons.event_note,
                          color: Color(0xFF00796B)),
                      title: Text(
                        evento,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () => _removerEvento(index),
                      ),
                    ),
                  );
                },
              ),
      ),
      actionButton: FloatingActionButton.extended(
        onPressed: _adicionarEvento,
        backgroundColor: const Color(0xFF00796B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Evento',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
