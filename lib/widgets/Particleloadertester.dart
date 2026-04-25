import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

// YOUR ORIGINAL LOADER WIDGET
class LoaderTester extends StatefulWidget {
  final double size;
  final List<Color> gradientColors;
  final int particleCount;

  const LoaderTester({
    Key? key,
    this.size = 190.0,
    this.gradientColors = const [
      Colors.cyan,
      Colors.indigo,
      Colors.red,
      Colors.yellow
    ],
    this.particleCount = 730,
  }) : super(key: key);

  @override
  _LoaderTesterState createState() => _LoaderTesterState();
}

class _LoaderTesterState extends State<LoaderTester>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: ParticleBurstPainter(
          progress: _animation,
          gradientColors: widget.gradientColors,
          particleCount: widget.particleCount,
          maxRadius: widget.size / 2,
        ),
      ),
    );
  }
}

class ParticleBurstPainter extends CustomPainter {
  final Animation<double> progress;
  final List<Color> gradientColors;
  final int particleCount;
  final double maxRadius;

  ParticleBurstPainter({
    required this.progress,
    required this.gradientColors,
    required this.particleCount,
    required this.maxRadius,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(0);
    final gradient = LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    for (int i = 0; i < particleCount; i++) {
      final particleProgress = (progress.value + i / particleCount) % 1.0;
      final angle = 2 * math.pi * (i / particleCount);
      final distance = maxRadius * particleProgress;
      final scale = 1.0 - particleProgress;
      final opacity = 1.0 - particleProgress;

      final position = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );

      final paint = Paint()
        ..shader = gradient
            .createShader(Rect.fromCircle(center: position, radius: 3 * scale))
        ..style = PaintingStyle.fill;

      paint.color = paint.color.withOpacity(opacity);

      canvas.drawCircle(position, 3 * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.particleCount != particleCount ||
        oldDelegate.maxRadius != maxRadius;
  }
}

// THE CUSTOMIZATION SCREEN
