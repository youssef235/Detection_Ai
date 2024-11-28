import 'package:flutter/material.dart';

class ObjectDetectionPainter extends CustomPainter {
  final List<dynamic>? recognitions;
  final double cameraWidth;
  final double cameraHeight;

  ObjectDetectionPainter(this.recognitions, this.cameraWidth, this.cameraHeight);

  @override
  void paint(Canvas canvas, Size size) {
    if (recognitions == null) return;

    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPaint = TextStyle(
      color: Colors.white,
      backgroundColor: Colors.black.withOpacity(0.6), // To make the text more visible
      fontSize: 16,
    );

    for (var recognition in recognitions!) {
      final rect = recognition['rect'];
      final left = rect['x'] * size.width;
      final top = rect['y'] * size.height;
      final right = rect['w'] * size.width + left;
      final bottom = rect['h'] * size.height + top;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

      final label = recognition['detectedClass'];
      final confidence = recognition['confidenceInClass'];
      final labelText = "$label ${(confidence * 100).toStringAsFixed(0)}%";

      final textSpan = TextSpan(text: labelText, style: textPaint);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final labelX = left;
      final labelY = top - textPainter.height - 5;
      final adjustedY = labelY < 0 ? 0 : labelY;

      textPainter.paint(canvas, Offset(labelX, adjustedY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
