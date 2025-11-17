// lib/screens/doctor/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:projetowell/models/app_data.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String filter = 'Todas';

  /// Converte dinamicamente qualquer item vindo de appData.notifications
  /// para o modelo local Notif, com proteções.
  Notif _toNotif(dynamic n) {
    // valores padrão
    String title = 'Notificação';
    String subtitle = '';
    IconData icon = Icons.notifications_none_rounded;
    Color color = Colors.blue;

    try {
      if (n == null) {
        // keep defaults
      } else if (n is NotificationItem) {
        // se for o tipo do app_data.dart
        title = (n.title ?? '').toString();
        subtitle = (n.subtitle ?? '').toString();
        // usamos 'as dynamic' para evitar erro se o campo faltar em versões diferentes
        final dyn = n as dynamic;
        try {
          if (dyn.icon is IconData) icon = dyn.icon as IconData;
        } catch (_) {}
        try {
          if (dyn.color is Color) color = dyn.color as Color;
        } catch (_) {}
      } else if (n is Map) {
        title = (n['title'] ?? n['titulo'] ?? title).toString();
        subtitle = (n['subtitle'] ?? n['subtitulo'] ?? subtitle).toString();

        final iconRaw = n['icon'] ?? n['icone'];
        if (iconRaw is IconData) {
          icon = iconRaw;
        } else if (iconRaw is String) {
          icon = _iconFromString(iconRaw);
        }

        final colorRaw = n['color'] ?? n['cor'];
        color = _colorFromDynamic(colorRaw, fallback: color);
      } else {
        // tentativa genérica via campos dinâmicos
        final dyn = n as dynamic;
        try {
          final t = dyn.title ?? dyn.titulo;
          if (t != null) title = t.toString();
        } catch (_) {}
        try {
          final s = dyn.subtitle ?? dyn.subtitulo;
          if (s != null) subtitle = s.toString();
        } catch (_) {}
        try {
          final iconRaw = dyn.icon ?? dyn.icone;
          if (iconRaw is IconData) icon = iconRaw;
          else if (iconRaw is String) icon = _iconFromString(iconRaw);
        } catch (_) {}
        try {
          final colorRaw = dyn.color ?? dyn.cor;
          color = _colorFromDynamic(colorRaw, fallback: color);
        } catch (_) {}
      }
    } catch (_) {
      // qualquer falha -> keep defaults
    }

    return Notif(title, subtitle, icon, color);
  }

  IconData _iconFromString(String s) {
    final key = s.toLowerCase();
    if (key.contains('warning') || key.contains('alert')) return Icons.warning_amber_rounded;
    if (key.contains('heart') || key.contains('monitor_heart')) return Icons.monitor_heart_rounded;
    if (key.contains('event')) return Icons.event_rounded;
    if (key.contains('active') || key.contains('notifications_active')) return Icons.notifications_active_outlined;
    return Icons.notifications_none_rounded;
  }

  Color _colorFromDynamic(dynamic raw, {required Color fallback}) {
    try {
      if (raw == null) return fallback;
      if (raw is Color) return raw;
      if (raw is int) return Color(raw);
      if (raw is String) {
        var s = raw.trim();
        if (s.startsWith('#')) {
          s = s.substring(1);
          if (s.length == 6) s = 'FF$s';
          return Color(int.parse('0x$s'));
        }
        if (s.startsWith('0x')) return Color(int.parse(s));
        final v = int.tryParse(s);
        if (v != null) return Color(v);
      }
    } catch (_) {}
    return fallback;
  }

  List<Notif> get items {
    final raw = appData.notifications;
    return raw.map((n) => _toNotif(n)).toList();
  }

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

                // filtros simples
                if (filter == 'Alertas' &&
                    n.icon != Icons.warning_amber_rounded &&
                    n.icon != Icons.monitor_heart_rounded) {
                  return const SizedBox.shrink();
                }
                if (filter == 'Consultas' && n.icon != Icons.event_rounded) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: n.color.withOpacity(0.12),
                    child: Icon(n.icon, color: n.color),
                  ),
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

/// Modelo local usado apenas nesta tela
class Notif {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  Notif(this.title, this.subtitle, this.icon, this.color);
}
