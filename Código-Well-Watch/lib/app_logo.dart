import 'package:flutter/material.dart';

/// Custom widget for the app logo
class AppLogo extends StatelessWidget {
  final double size;
  final Color color;

  const AppLogo({
    super.key,
    this.size = 64,
    this.color = const Color(0xFF39D2C0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: LogoPainter(color: color)),
    );
  }
}

/// Custom painter to draw the Well Watch logo
class LogoPainter extends CustomPainter {
  final Color color;

  LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06
          ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width * 0.4;

    // Draw the circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw the heartbeat line
    final Path heartbeatPath = Path();

    // Starting point (left side of the circle)
    final double startX = centerX - radius * 0.9;
    final double lineY = centerY;

    heartbeatPath.moveTo(startX, lineY);

    // First part of the heartbeat line
    heartbeatPath.lineTo(centerX - radius * 0.5, lineY);

    // The peak
    heartbeatPath.lineTo(centerX - radius * 0.3, lineY - radius * 0.5);
    heartbeatPath.lineTo(centerX, lineY);
    heartbeatPath.lineTo(centerX + radius * 0.3, lineY + radius * 0.5);

    // End part of the heartbeat line
    heartbeatPath.lineTo(centerX + radius * 0.5, lineY);
    heartbeatPath.lineTo(centerX + radius * 0.9, lineY);

    canvas.drawPath(heartbeatPath, paint);

    // Draw the small dot at the top
    final Paint dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY - radius - size.height * 0.08),
      size.width * 0.05,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
