import 'dart:math';
import 'package:flutter/material.dart';

class PetalCelebrationOverlay extends StatefulWidget {
  final Widget child;
  final bool showCelebration;

  const PetalCelebrationOverlay({
    super.key,
    this.child = const SizedBox.shrink(),
    this.showCelebration = true,
  });

  @override
  State<PetalCelebrationOverlay> createState() => _PetalCelebrationOverlayState();
}

class _PetalCelebrationOverlayState extends State<PetalCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_PetalParticle> _petals = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _spawnPetals();
    if (widget.showCelebration) {
      _controller.forward(from: 0.0);
    }
  }

  void _spawnPetals() {
    _petals.clear();
    for (int i = 0; i < 32; i++) {
      _petals.add(
        _PetalParticle(
          x: _rand.nextDouble(),
          y: -0.15 - (_rand.nextDouble() * 0.4),
          speedY: 0.22 + (_rand.nextDouble() * 0.22),
          speedX: (_rand.nextDouble() - 0.5) * 0.16,
          rotation: _rand.nextDouble() * 2 * pi,
          rotationSpeed: (_rand.nextDouble() - 0.5) * 3,
          size: 11 + (_rand.nextDouble() * 11),
          color: _rand.nextBool()
              ? const Color(0xFFF9D0C4) // Melocotón suave
              : const Color(0xFFE2D9F3), // Lavanda zen
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant PetalCelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCelebration && !oldWidget.showCelebration) {
      _spawnPetals();
      _controller.forward(from: 0.0);
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
        if (_controller.value > 0.0 && _controller.value < 1.0)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PetalsPainter(
                  petals: _petals,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PetalParticle {
  final double x;
  final double y;
  final double speedY;
  final double speedX;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;

  _PetalParticle({
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _PetalsPainter extends CustomPainter {
  final List<_PetalParticle> petals;
  final double progress;

  _PetalsPainter({required this.petals, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final currentY = (p.y + (p.speedY * progress)) * size.height;
      final currentX = (p.x + (sin(progress * 4 + p.rotation) * p.speedX)) * size.width;
      final currentRot = p.rotation + (p.rotationSpeed * progress);

      // Desvanecer suavemente hacia cero en el último tercio
      final alpha = ((1.0 - progress) / 0.35).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRot);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.90)
        ..style = PaintingStyle.fill;

      // Dibujar pétalo orgánico ovalado
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.55,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalsPainter oldDelegate) => true;
}

