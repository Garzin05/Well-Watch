import 'package:flutter/material.dart';

class PressureLineChart extends StatelessWidget {
  final List<double> systolic;   // sistólica ex: 120
  final List<double> diastolic;  // diastólica ex: 80

  const PressureLineChart({
    super.key,
    required this.systolic,
    required this.diastolic,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 220),
      painter: _PressureChartPainter(systolic, diastolic),
    );
  }
}

class _PressureChartPainter extends CustomPainter {
  final List<double> s;
  final List<double> d;

  _PressureChartPainter(this.s, this.d);

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 1;

    final paintSystolic = Paint()
      ..color = const Color(0xFF00D1FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintDiastolic = Paint()
      ..color = const Color(0xFFFF4E8A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final double stepX = size.width / (s.length - 1);

    /// draw grid
    for (var i = 0; i < 5; i++) {
      final y = size.height / 5 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    Path systolicPath = Path();
    Path diastolicPath = Path();

    for (int i = 0; i < s.length; i++) {
      final x = i * stepX;

      final yS = size.height - (s[i] / 200 * size.height);
      final yD = size.height - (d[i] / 200 * size.height);

      if (i == 0) {
        systolicPath.moveTo(x, yS);
        diastolicPath.moveTo(x, yD);
      } else {
        systolicPath.lineTo(x, yS);
        diastolicPath.lineTo(x, yD);
      }
    }

    canvas.drawPath(systolicPath, paintSystolic);
    canvas.drawPath(diastolicPath, paintDiastolic);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
