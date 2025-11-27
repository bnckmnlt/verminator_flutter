import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(),
      child: child,
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topLeftRect = Rect.fromLTWH(
      -size.width / 2,
      -size.width / 2,
      size.width,
      size.width,
    );

    final bottomLeftRect = Rect.fromLTWH(
      size.width / 2 - 100,
      size.height - size.width * 0.75,
      size.width,
      size.width,
    );

    _drawCircleGradient(canvas, topLeftRect);
    _drawCircleGradient(canvas, bottomLeftRect);
  }

  void _drawCircleGradient(Canvas canvas, Rect rect) {
    final paint = Paint();

    paint.shader = RadialGradient(
      colors: [
        Colors.lightBlueAccent.withValues(alpha: 0.025),
        Colors.blueAccent.withValues(alpha: 0.025),
        Colors.indigoAccent.withValues(alpha: 0.025),
      ],
      center: const Alignment(0.2, 0.2),
    ).createShader(rect);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 82);

    canvas.drawCircle(
      rect.center,
      rect.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
