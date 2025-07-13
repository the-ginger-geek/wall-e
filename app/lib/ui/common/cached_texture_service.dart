import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'rust_texture_painter.dart';

class CachedTextureService {
  static CachedTextureService? _instance;
  static CachedTextureService get instance => _instance ??= CachedTextureService._();
  
  CachedTextureService._();
  
  ui.Image? _cachedTexture;
  Size? _cachedSize;
  
  Future<ui.Image> getTexture(Size size) async {
    if (_cachedTexture != null && _cachedSize == size) {
      return _cachedTexture!;
    }
    
    _cachedTexture = await _generateTexture(size);
    _cachedSize = size;
    return _cachedTexture!;
  }
  
  Future<ui.Image> _generateTexture(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final painter = RustTexturePainter();
    painter.paint(canvas, size);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    picture.dispose();
    
    return image;
  }
  
  void clearCache() {
    _cachedTexture?.dispose();
    _cachedTexture = null;
    _cachedSize = null;
  }
}