import 'package:flutter/material.dart';
import 'package:projetowell/models/app_data.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String filter = 'Todas';
  List<_Notif> get items => appData.notifications
      .map((n) => _Notif(n.title, n.subtitle, n.icon, n.color))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'Todas', label: Text('Todas'), icon: Icon(Icons.notifications_none_rounded)),
                ButtonSegment(value: 'Alertas', label: Text('Alertas'), icon: Icon(Icons.warning_amber_rounded)),
                ButtonSegment(value: 'Consultas', label: Text('Consultas'), icon: Icon(Icons.event_rounded)),
              ],
              selected: {filter},
              onSelectionChanged: (v) => setState(() => filter = v.first),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = items[index];
                if (filter == 'Alertas' && n.icon != Icons.warning_amber_rounded && n.icon != Icons.monitor_heart_rounded) return const SizedBox.shrink();
                if (filter == 'Consultas' && n.icon != Icons.event_rounded) return const SizedBox.shrink();
                return ListTile(
                  leading: CircleAvatar(backgroundColor: n.color.withValues(alpha: 0.12), child: Icon(n.icon, color: n.color)),
                  title: Text(n.title),
                  subtitle: Text(n.subtitle),
                  trailing: IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Notif {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _Notif(this.title, this.subtitle, this.icon, this.color);
}
