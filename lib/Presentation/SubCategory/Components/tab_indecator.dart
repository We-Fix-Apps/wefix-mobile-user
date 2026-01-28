import 'package:flutter/material.dart';

class RoundedTabIndicator extends Decoration {
  final Color color;
  final double radius;

  const RoundedTabIndicator({required this.color, this.radius = 12});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedTabPainter(color: color, radius: radius);
  }
}

class _RoundedTabPainter extends BoxPainter {
  final Color color;
  final double radius;

  _RoundedTabPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Rect rect = Offset(offset.dx, offset.dy) &
        Size(config.size!.width, config.size!.height);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(rRect, paint);
  }
}
