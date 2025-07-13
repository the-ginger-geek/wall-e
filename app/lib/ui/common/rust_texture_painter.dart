import 'dart:math';
import 'package:flutter/material.dart';

class RustTexturePainter extends CustomPainter {
  final Random _random = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final baseYellowPaint = Paint()
      ..color = const Color(0xFFE6B84A)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, baseYellowPaint);

    _drawRustSpots(canvas, size);
    _drawTextureNoise(canvas, size);
  }

  void _drawRustSpots(Canvas canvas, Size size) {
    final rustColors = [
      const Color(0xFF8B4513).withValues(alpha: 0.6),
      const Color(0xFFA0522D).withValues(alpha: 0.45),
      const Color(0xFF654321).withValues(alpha: 0.8),
      const Color(0xFF7B3F00).withValues(alpha: 0.65),
    ];

    final spotCount = (size.width * size.height / 2000).round();
    
    for (int i = 0; i < spotCount; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 15 + 5;
      final color = rustColors[_random.nextInt(rustColors.length)];
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final path = Path();
      final centerX = x;
      final centerY = y;
      
      for (int j = 0; j < 8; j++) {
        final angle = (j / 8) * 2 * pi;
        final variance = _random.nextDouble() * 0.5 + 0.7;
        final pointRadius = radius * variance;
        final pointX = centerX + cos(angle) * pointRadius;
        final pointY = centerY + sin(angle) * pointRadius;
        
        if (j == 0) {
          path.moveTo(pointX, pointY);
        } else {
          path.lineTo(pointX, pointY);
        }
      }
      path.close();
      
      canvas.drawPath(path, paint);
      
      if (_random.nextDouble() > 0.6) {
        final smallSpots = _random.nextInt(3) + 1;
        for (int k = 0; k < smallSpots; k++) {
          final smallX = x + (_random.nextDouble() - 0.5) * radius * 2;
          final smallY = y + (_random.nextDouble() - 0.5) * radius * 2;
          final smallRadius = _random.nextDouble() * 3 + 1;
          
          canvas.drawCircle(
            Offset(smallX, smallY),
            smallRadius,
            Paint()
              ..color = color.withValues(alpha: color.a * 0.8)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  void _drawTextureNoise(Canvas canvas, Size size) {
    final noiseCount = (size.width * size.height / 50).round();
    
    for (int i = 0; i < noiseCount; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final opacity = _random.nextDouble() * 0.1 + 0.05;
      
      final isDark = _random.nextBool();
      final color = isDark 
        ? Colors.black.withValues(alpha: opacity)
        : Colors.white.withValues(alpha: opacity * 0.5);
      
      canvas.drawCircle(
        Offset(x, y),
        0.5,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}