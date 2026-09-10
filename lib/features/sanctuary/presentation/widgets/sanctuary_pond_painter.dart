import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/sanctuary_state.dart';
import 'living_seed_spirit_painter.dart';

/// Lienzo del Espacio de Lev sobre fondo crema puro.
/// Sin distracciones, sin estanques ni agua: solo el personaje protagonista
/// con su suave sombra de levitación y transiciones orgánicas continuas.
class SanctuaryPondPainter extends CustomPainter {
  final double animationValue; // 0.0 a 1.0 (tiempo continuo a 60 FPS)
  final SanctuaryTimeOfDay timeOfDay;
  final LevEmotion emotion;
  final int bloomingFlowers;
  final int careDrops;
  final bool isPetting;

  // Parámetros de transición continua entre animaciones
  final double leafWrapProgress;
  final double sleepProgress;
  final double happyProgress;
  final double breathingProgress;
  final double jumpProgress;

  SanctuaryPondPainter({
    required this.animationValue,
    required this.timeOfDay,
    required this.emotion,
    required this.bloomingFlowers,
    required this.careDrops,
    required this.isPetting,
    this.leafWrapProgress = 0.0,
    this.sleepProgress = 0.0,
    this.happyProgress = 0.0,
    this.breathingProgress = 0.0,
    this.jumpProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Fondo Crema Botánico Cálido
    _drawCreamBackground(canvas, rect);

    // 2. Sombra de levitación suave en el suelo crema
    _drawLevitationShadow(canvas, size);

    // 3. Lev: El personaje en el centro absoluto con transiciones
    _drawLevCharacter(canvas, size);

    // 4. Efecto de corazoncitos al acariciar con fade suave
    final affectionWeight = max(happyProgress, isPetting ? 1.0 : 0.0);
    if (affectionWeight > 0.05) {
      _drawAffectionParticles(canvas, size, affectionWeight);
    }
  }

  /// Fondo crema botánico cálido suave (#FAF8F5 a #F5EFE6 sutil)
  void _drawCreamBackground(Canvas canvas, Rect rect) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFCFBF9),
          Color(0xFFFAF8F5),
          Color(0xFFF4EFE6),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    // Halo muy sutil y amplio de calidez detrás de Lev
    final warmGlowPaint = Paint()
      ..color = const Color(0xFFFFF3D6).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(Offset(rect.width * 0.5, rect.height * 0.48), 120, warmGlowPaint);
  }

  /// Sombra etérea de suspensión sobre el suelo crema que respira con la altura de Lev
  void _drawLevitationShadow(Canvas canvas, Size size) {
    final cycle = animationValue * 2 * pi;
    final floatShift = sin(cycle);
    final shadowWidth = 115.0 + (floatShift * 10.0);
    final shadowAlpha = 0.12 - (floatShift * 0.03);

    final shadowPaint = Paint()
      ..color = const Color(0xFF4A5568).withValues(alpha: shadowAlpha.clamp(0.04, 0.20))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.86),
        width: shadowWidth,
        height: 22,
      ),
      shadowPaint,
    );
  }

  /// Dibuja a Lev con escala protagónica y parámetros de transición suaves
  void _drawLevCharacter(Canvas canvas, Size size) {
    final spiritPainter = LivingSeedSpiritPainter(
      animationValue: animationValue,
      emotion: emotion,
      isPetting: isPetting,
      sizeScale: 1.22,
      leafWrapProgress: leafWrapProgress,
      sleepProgress: sleepProgress,
      happyProgress: happyProgress,
      breathingProgress: breathingProgress,
      jumpProgress: jumpProgress,
    );
    spiritPainter.paint(canvas, size);
  }

  /// Corazoncitos tiernos al acariciar con atenuación suave
  void _drawAffectionParticles(Canvas canvas, Size size, double opacity) {
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.45;
    final heartPaint = Paint()..color = const Color(0xFFF4A28C).withValues(alpha: (0.90 * opacity).clamp(0.0, 1.0));

    for (int i = 0; i < 3; i++) {
      final angle = (i * 0.65) - 0.65;
      final distance = 50.0 + (i * 22.0) + (sin(animationValue * pi) * 15);
      final pX = centerX + sin(angle) * distance;
      final pY = centerY - 45 - cos(angle) * distance;

      _drawMiniHeart(canvas, Offset(pX, pY), 11.0, heartPaint);
    }
  }

  void _drawMiniHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final width = size;
    final height = size;

    path.moveTo(center.dx, center.dy + height * 0.35);
    path.cubicTo(
      center.dx + width * 0.6,
      center.dy - height * 0.35,
      center.dx + width * 0.9,
      center.dy + height * 0.4,
      center.dx,
      center.dy + height * 0.9,
    );
    path.cubicTo(
      center.dx - width * 0.9,
      center.dy + height * 0.4,
      center.dx - width * 0.6,
      center.dy - height * 0.35,
      center.dx,
      center.dy + height * 0.35,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SanctuaryPondPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.timeOfDay != timeOfDay ||
        oldDelegate.emotion != emotion ||
        oldDelegate.bloomingFlowers != bloomingFlowers ||
        oldDelegate.careDrops != careDrops ||
        oldDelegate.isPetting != isPetting ||
        oldDelegate.leafWrapProgress != leafWrapProgress ||
        oldDelegate.sleepProgress != sleepProgress ||
        oldDelegate.happyProgress != happyProgress ||
        oldDelegate.breathingProgress != breathingProgress ||
        oldDelegate.jumpProgress != jumpProgress;
  }
}
