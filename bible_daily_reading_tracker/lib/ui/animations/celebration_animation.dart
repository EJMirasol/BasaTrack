import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

/// Celebration animation widget for achievements
class CelebrationAnimation extends StatefulWidget {
  final Widget child;
  final bool show;

  const CelebrationAnimation({
    super.key,
    required this.child,
    this.show = false,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });

    if (widget.show) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(CelebrationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _particles.clear();
    final random = math.Random();
    
    // Create particles
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: 0,
        vx: (random.nextDouble() - 0.5) * 2,
        vy: random.nextDouble() * 2 + 1,
        color: _getRandomColor(random),
        size: random.nextDouble() * 8 + 4,
      ));
    }
    
    _controller.forward(from: 0);
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      AppColors.secondary,
      AppColors.primary,
      AppColors.success,
      AppColors.primaryLight,
      AppColors.secondaryLight,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.y += particle.vy * 0.01;
      particle.x += particle.vx * 0.01;
      particle.vy += 0.05; // Gravity
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.show && _particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ParticlePainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.y >= 0 && particle.y <= 1) {
        final paint = Paint()
          ..color = particle.color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            particle.x * size.width,
            particle.y * size.height,
          ),
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
