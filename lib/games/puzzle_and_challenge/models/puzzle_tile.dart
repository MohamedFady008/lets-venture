import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

class PuzzleTile {
  final int index;
  final ui.Image image;
  final Rect region;
  late final Widget _cached;

  PuzzleTile({required this.index, required this.image, required this.region}) {
    _cached = _buildWidget();
  }

  Widget build() => _cached;

  Widget _buildWidget() {
    return CustomPaint(
      size: Size(region.width, region.height),
      painter: _PuzzlePainter(image, region),
    );
  }
}

class _PuzzlePainter extends CustomPainter {
  final ui.Image image;
  final Rect region;

  _PuzzlePainter(this.image, this.region);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImageRect(
      image,
      region,
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
