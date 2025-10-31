import 'package:flutter/material.dart';
import 'package:projetowell/theme.dart';

class MensagemPage extends StatefulWidget {
  const MensagemPage({super.key});

  @override
  State<MensagemPage> createState() => _MensagemPageState();
}

class _MensagemPageState extends State<MensagemPage> {
  final List<Map<String, String>> _conversations = [
    {'name': 'Dra. Ana', 'last': 'Tudo bem com sua medicação?'},
    {'name': 'Dr. Carlos', 'last': 'Agende consulta'},
    {'name': 'Suporte', 'last': 'Bem-vindo ao Well Watch'},
  ];

  void _openChat(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(partner: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: AppColors.darkBlueBackground,
      ),
      body: ListView.separated(
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final c = _conversations[index];
          return ListTile(
            leading: CircleAvatar(child: Text(c['name']![0])),
            title: Text(c['name']!),
            subtitle: Text(c['last']!),
            onTap: () => _openChat(c['name']!),
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String partner;
  const ChatPage({super.key, required this.partner});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _messages = [
    {'from': 'them', 'text': 'Olá! Como posso ajudar?'}
  ];
  final TextEditingController _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'me', 'text': text});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.partner),
          backgroundColor: AppColors.darkBlueBackground),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = m['from'] == 'me';
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isMe ? AppColors.lightBlueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m['text']!),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                            hintText: 'Escreva uma mensagem...')),
                  ),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
