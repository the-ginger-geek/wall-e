import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CachedTexturePainter extends CustomPainter {
  final ui.Image? texture;
  
  const CachedTexturePainter(this.texture);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (texture != null) {
      canvas.drawImageRect(
        texture!,
        Rect.fromLTWH(0, 0, texture!.width.toDouble(), texture!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
    }
  }
  
  @override
  bool shouldRepaint(CachedTexturePainter oldDelegate) {
    return oldDelegate.texture != texture;
  }
}