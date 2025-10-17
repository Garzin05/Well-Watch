import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;
  final String? tooltip;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 20,
    this.tooltip,
  });

  /// Botão predefinido para login com Facebook
  static SocialLoginButton facebook({required VoidCallback onPressed}) =>
      SocialLoginButton(
        icon: FontAwesomeIcons.facebookF,
        color: const Color(0xFF1877F2),
        onPressed: onPressed,
        tooltip: 'Entrar com Facebook',
      );

  /// Botão predefinido para login com Instagram
  static SocialLoginButton instagram({required VoidCallback onPressed}) =>
      SocialLoginButton(
        icon: FontAwesomeIcons.instagram,
        color: const Color(0xFFE4405F),
        onPressed: onPressed,
        tooltip: 'Entrar com Instagram',
      );

  /// Botão predefinido para login com Google
  static SocialLoginButton google({required VoidCallback onPressed}) =>
      SocialLoginButton(
        icon: FontAwesomeIcons.google,
        color: const Color(0xFFDB4437),
        onPressed: onPressed,
        tooltip: 'Entrar com Google',
      );

  /// Botão predefinido para login com Microsoft
  static SocialLoginButton microsoft({required VoidCallback onPressed}) =>
      SocialLoginButton(
        icon: FontAwesomeIcons.microsoft,
        color: const Color(0xFF0078D4),
        onPressed: onPressed,
        tooltip: 'Entrar com Microsoft',
      );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip ?? 'Botão de login social',
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }
}
