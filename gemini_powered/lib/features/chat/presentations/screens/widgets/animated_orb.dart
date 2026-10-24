
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AnimatedOrb extends StatefulWidget {
  const AnimatedOrb({
    super.key,
    this.size = 340,
  });

  final double size;

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentProgram? _program;
  Object? _shaderError;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'lib/shader/aether_orb.frag',
      );

      if (!mounted) return;

      setState(() {
        _program = program;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _shaderError = error;
      });

      debugPrint('Aether orb shader failed to load: $error');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shaderProgram = _program;

    if (shaderProgram == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF8A3D),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ShaderOrbPainter(
              program: shaderProgram,
              time: _controller.value * 12.0,
            ),
          );
        },
      ),
    );
  }
}

class _ShaderOrbPainter extends CustomPainter {
  _ShaderOrbPainter({
    required this.program,
    required this.time,
  });

  final ui.FragmentProgram program;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time);

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.srcOver;

    // Soft glow behind the orb.
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.49;

    canvas.drawCircle(
      center,
      radius * 0.92,
      Paint()
        ..color = const Color(0x33FF6A22)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          38,
        ),
    );

    // The shader draws the orb inside this canvas.
    canvas.drawRect(
      Offset.zero & size,
      paint,
    );

    shader.dispose();
  }

  @override
  bool shouldRepaint(covariant _ShaderOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.program != program;
  }
}
