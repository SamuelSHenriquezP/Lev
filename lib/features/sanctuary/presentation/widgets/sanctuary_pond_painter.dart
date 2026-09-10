import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/sanctuary_state.dart';
import 'living_seed_spirit_painter.dart';

/// Lienzo del Espacio de Lev sobre fondo crema puro botánico.
/// Sin distracciones ni sobrecargas: Lev como protagonista absoluto en el centro,
/// con su suave sombra de levitación física reactiva, sus 8 etapas de crecimiento
/// y transiciones de animación armónicas continuas.
class SanctuaryPondPainter extends CustomPainter {
  final double animationValue; // 0.0 a 1.0 (tiempo continuo a 60 FPS)
  final SanctuaryTimeOfDay timeOfDay;
  final LevEmotion emotion;
  final int bloomingFlowers;
  final int careDrops;
  final bool isPetting;
  final LevGrowthStage growthStage;
  final double growthFactor;

  // Parámetros de transición continua entre animaciones
  final double leafWrapProgress;
  final double sleepProgress;
  final double happyProgress;
  final double breathingProgress;
  final double jumpProgress;
  final double curiousProgress;
  final double sadProgress;
  final double anxiousProgress;
  final double tiredProgress;
  final double celebrateProgress;

  SanctuaryPondPainter({
    required this.animationValue,
    required this.timeOfDay,
    required this.emotion,
    required this.bloomingFlowers,
    required this.careDrops,
    required this.isPetting,
    this.growthStage = LevGrowthStage.youngPlant,
    this.growthFactor = 0.0,
    this.leafWrapProgress = 0.0,
    this.sleepProgress = 0.0,
    this.happyProgress = 0.0,
    this.breathingProgress = 0.0,
    this.jumpProgress = 0.0,
    this.curiousProgress = 0.0,
    this.sadProgress = 0.0,
    this.anxiousProgress = 0.0,
    this.tiredProgress = 0.0,
    this.celebrateProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Fondo Crema Botánico Cálido con iluminación suave
    _drawCreamBackground(canvas, rect);

    // 2. Sombra de levitación suave en el suelo crema que respira físicamente
    _drawLevitationShadow(canvas, size);

    // 3. Lev: El personaje en el centro absoluto con su etapa y animaciones
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

    // Escala de sombra adaptada a la etapa de crecimiento
    var baseShadowWidth = 115.0;
    switch (growthStage) {
      case LevGrowthStage.seed:
        baseShadowWidth = 75.0;
        break;
      case LevGrowthStage.sprout:
        baseShadowWidth = 88.0;
        break;
      case LevGrowthStage.seedling:
        baseShadowWidth = 100.0;
        break;
      case LevGrowthStage.youngPlant:
        baseShadowWidth = 115.0;
        break;
      case LevGrowthStage.vibrantPlant:
        baseShadowWidth = 122.0;
        break;
      case LevGrowthStage.youngTree:
        baseShadowWidth = 135.0;
        break;
      case LevGrowthStage.adultTree:
        baseShadowWidth = 145.0;
        break;
      case LevGrowthStage.forestSpirit:
        baseShadowWidth = 160.0;
        break;
    }

    // Efecto de sombra durante el salto (se reduce al elevarse y se expande al aterrizar)
    var jumpShadowScale = 1.0;
    var jumpShadowAlpha = 1.0;
    if (jumpProgress > 0.0 && jumpProgress <= 1.0) {
      if (jumpProgress < 0.20) {
        jumpShadowScale = 1.15; // Anticipación en suelo
      } else if (jumpProgress < 0.75) {
        jumpShadowScale = 0.55; // Alto en el aire
        jumpShadowAlpha = 0.40;
      } else {
        jumpShadowScale = 1.10; // Impacto
      }
    }

    final shadowWidth = (baseShadowWidth + (floatShift * 10.0)) * jumpShadowScale;
    final shadowAlpha = (0.12 - (floatShift * 0.03)) * jumpShadowAlpha;

    final shadowPaint = Paint()
      ..color = const Color(0xFF4A5568).withValues(alpha: shadowAlpha.clamp(0.02, 0.22))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.86),
        width: shadowWidth,
        height: 22 * jumpShadowScale,
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
      growthStage: growthStage,
      growthFactor: growthFactor,
      leafWrapProgress: leafWrapProgress,
      sleepProgress: sleepProgress,
      happyProgress: happyProgress,
      breathingProgress: breathingProgress,
      jumpProgress: jumpProgress,
      curiousProgress: curiousProgress,
      sadProgress: sadProgress,
      anxiousProgress: anxiousProgress,
      tiredProgress: tiredProgress,
      celebrateProgress: celebrateProgress,
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
        oldDelegate.growthStage != growthStage ||
        oldDelegate.growthFactor != growthFactor ||
        oldDelegate.leafWrapProgress != leafWrapProgress ||
        oldDelegate.sleepProgress != sleepProgress ||
        oldDelegate.happyProgress != happyProgress ||
        oldDelegate.breathingProgress != breathingProgress ||
        oldDelegate.jumpProgress != jumpProgress ||
        oldDelegate.curiousProgress != curiousProgress ||
        oldDelegate.sadProgress != sadProgress ||
        oldDelegate.anxiousProgress != anxiousProgress ||
        oldDelegate.tiredProgress != tiredProgress ||
        oldDelegate.celebrateProgress != celebrateProgress;
  }
}
