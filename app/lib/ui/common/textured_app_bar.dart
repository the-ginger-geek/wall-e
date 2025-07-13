import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'cached_texture_service.dart';
import 'cached_texture_painter.dart';

class TexturedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const TexturedAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  State<TexturedAppBar> createState() => _TexturedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(150);
}

class _TexturedAppBarState extends State<TexturedAppBar> {
  ui.Image? _texture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_texture == null) {
      _loadTexture();
    }
  }

  Future<void> _loadTexture() async {
    final texture = await CachedTextureService.instance.getTexture(
      Size(MediaQuery.of(context).size.width, 150),
    );
    if (mounted) {
      setState(() {
        _texture = texture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: CachedTexturePainter(_texture),
        child: AppBar(
          title: widget.title,
          actions: widget.actions,
          leading: widget.leading,
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}