import 'dart:math';
import 'package:flutter/material.dart';

class CircularGauge extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final Color color;
  final Color trackColor;
  final Color textColor;
  final String valueSuffix;

  const CircularGauge({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
    required this.trackColor,
    required this.textColor,
    this.valueSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: CustomPaint(
            painter: _CircularGaugePainter(
              value: value,
              maxValue: maxValue,
              color: color,
              trackColor: trackColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${value.toStringAsFixed(0)}$valueSuffix',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;
  final Color trackColor;

  _CircularGaugePainter({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 6.0;

    final paintTrack = Paint()
      ..color = trackColor
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final paintArc = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw background track ring
    canvas.drawCircle(center, radius, paintTrack);

    // Draw active arc based on values
    final double sweepAngle = (value / maxValue).clamp(0.0, 1.0) * 2 * pi;
    
    // Draw glowing shadow under active arc
    paintArc.style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paintArc..imageFilter = null,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
