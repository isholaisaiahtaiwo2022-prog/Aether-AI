
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AnimatedOrb extends StatefulWidget {
  const AnimatedOrb({
    super.key,
    this.size = 240,
  });

  final double size;

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
        final progress = _controller.value * 2 * math.pi;

        return Transform.translate(
          offset: Offset(0, math.sin(progress) * 5),
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _OrbPainter(progress),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;
    final sphereRect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    // Soft orange atmosphere behind the sphere.
    canvas.drawCircle(
      center,
      radius * 1.08,
      Paint()
        ..color = const Color(0x55FF7A24)
        ..maskFilter = const MaskFilter.blur(
          ui.BlurStyle.normal,
          32,
        ),
    );

    final spherePath = Path()
      ..addOval(sphereRect);

    canvas.save();
    canvas.clipPath(spherePath);

    // Deep, warm base color.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          radius: 1.2,
          colors: [
            Color(0xFFFFC078),
            Color(0xFFFF8A3D),
            Color(0xFFD94D16),
            Color(0xFF35160F),
          ],
          stops: [0.0, 0.34, 0.68, 1.0],
        ).createShader(sphereRect),
    );

    // Moving pools of color create the rolling effect.
    _drawBlob(
      canvas,
      center: Offset(
        center.dx + math.cos(progress) * radius * 0.42,
        center.dy + math.sin(progress) * radius * 0.48,
      ),
      radius: radius * 0.82,
      colors: const [
        Color(0xFFFFD18D),
        Color(0xFFFF8A3D),
        Color(0x00FF8A3D),
      ],
    );

    _drawBlob(
      canvas,
      center: Offset(
        center.dx + math.cos(progress + 2.2) * radius * 0.52,
        center.dy + math.sin(progress + 2.2) * radius * 0.46,
      ),
      radius: radius * 0.76,
      colors: const [
        Color(0xFFFF5C20),
        Color(0xFFB52D12),
        Color(0x00B52D12),
      ],
    );

    _drawBlob(
      canvas,
      center: Offset(
        center.dx + math.cos(progress + 4.1) * radius * 0.48,
        center.dy + math.sin(progress + 4.1) * radius * 0.42,
      ),
      radius: radius * 0.65,
      colors: const [
        Color(0xFFFFB04A),
        Color(0xFFEF6A22),
        Color(0x00EF6A22),
      ],
    );

    // Glossy highlight near the upper-left edge.
    canvas.drawCircle(
      Offset(
        center.dx - radius * 0.32,
        center.dy - radius * 0.42,
      ),
      radius * 0.22,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x99FFFFFF),
            const Color(0x22FFFFFF),
            const Color(0x00FFFFFF),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              center.dx - radius * 0.32,
              center.dy - radius * 0.42,
            ),
            radius: radius * 0.22,
          ),
        ),
    );

    // Subtle dark edge gives the sphere more depth.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x00000000),
            const Color(0x00000000),
            const Color(0x55000000),
          ],
          stops: const [0.55, 0.78, 1.0],
        ).createShader(sphereRect),
    );

    canvas.restore();
  }

  void _drawBlob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required List<Color> colors,
  }) {
    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: colors,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
