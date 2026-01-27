import 'package:flutter/material.dart';


class AnimatedBorderContainer extends StatefulWidget {
  final Widget child;
  const AnimatedBorderContainer({super.key, required this.child});

  @override
  State<AnimatedBorderContainer> createState() =>
      _AnimatedBorderContainerState();
}

class _AnimatedBorderContainerState extends State<AnimatedBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BorderPainter(_controller.value),
          child: Container(
            padding: const EdgeInsets.all(3), // Border thickness
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _BorderPainter extends CustomPainter {
  final double animationValue;
  _BorderPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: const [Colors.orange, Colors.grey, Colors.white],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment(-1.0 + 2 * animationValue, 0),
        end: Alignment(1.0 + 2 * animationValue, 0),
        tileMode: TileMode.mirror,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
