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
  final Set<SanctuaryDecorItem> activeDecors;

  // Parámetros de transición continua entre animaciones
  final double? leafWrapProgress;
  final double? sleepProgress;
  final double? happyProgress;
  final double? breathingProgress;
  final double jumpProgress;
  final double? curiousProgress;
  final double? sadProgress;
  final double? anxiousProgress;
  final double? tiredProgress;
  final double? celebrateProgress;

  SanctuaryPondPainter({
    required this.animationValue,
    required this.timeOfDay,
    required this.emotion,
    required this.bloomingFlowers,
    required this.careDrops,
    required this.isPetting,
    this.growthStage = LevGrowthStage.youngPlant,
    this.growthFactor = 0.0,
    this.activeDecors = const {},
    this.leafWrapProgress,
    this.sleepProgress,
    this.happyProgress,
    this.breathingProgress,
    this.jumpProgress = 0.0,
    this.curiousProgress,
    this.sadProgress,
    this.anxiousProgress,
    this.tiredProgress,
    this.celebrateProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Fondo Crema Botánico Cálido con iluminación suave
    _drawCreamBackground(canvas, rect);

    // 1.5. Decoraciones activas desbloqueadas en el Santuario
    _drawActiveDecorations(canvas, size);

    // 2. Sombra de levitación suave en el suelo crema que respira físicamente
    _drawLevitationShadow(canvas, size);

    // 3. Lev: El personaje en el centro absoluto con su etapa y animaciones
    _drawLevCharacter(canvas, size);

    // 4. Efecto de corazoncitos al acariciar con fade suave
    final affectionWeight = happyProgress ?? (isPetting ? 1.0 : (emotion == LevEmotion.happy ? 1.0 : 0.0));
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

  /// Dibuja los elementos del entorno desbloqueados y activos
  void _drawActiveDecorations(Canvas canvas, Size size) {
    if (activeDecors.isEmpty) return;

    final centerX = size.width * 0.5;

    // 1. Estanque de Loto
    if (activeDecors.contains(SanctuaryDecorItem.lotusPond)) {
      final pondY = size.height * 0.85;
      final pondPaint = Paint()
        ..color = const Color(0xFFD4EAE8).withValues(alpha: 0.60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(centerX, pondY), width: size.width * 0.72, height: 60),
        pondPaint,
      );

      final ripplePulse = animationValue * 2 * pi;
      final ripplePaint = Paint()
        ..color = const Color(0xFFB2DFDB).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, pondY),
          width: size.width * 0.52 + sin(ripplePulse) * 7,
          height: 38 + sin(ripplePulse) * 3,
        ),
        ripplePaint,
      );

      // Nenúfares
      final padPaint = Paint()..color = const Color(0xFF81C784);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 95, pondY + 4), width: 32, height: 16), padPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX + 85, pondY - 6), width: 26, height: 13), padPaint);

      // Flor de loto pequeña
      final lotusPetalPaint = Paint()..color = const Color(0xFFF8BBD0);
      canvas.drawCircle(Offset(centerX - 95, pondY + 2), 5, lotusPetalPaint);
      canvas.drawCircle(Offset(centerX + 85, pondY - 8), 4, lotusPetalPaint);
    }

    // 2. Rocas de Jardín Zen
    if (activeDecors.contains(SanctuaryDecorItem.zenStones)) {
      final stoneBaseY = size.height * 0.84;
      final stonePaint1 = Paint()..color = const Color(0xFFB0BEC5);
      final stonePaint2 = Paint()..color = const Color(0xFF90A4AE);
      final stonePaint3 = Paint()..color = const Color(0xFF78909C);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 105, stoneBaseY), width: 30, height: 13), stonePaint1);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 105, stoneBaseY - 6), width: 22, height: 10), stonePaint2);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 105, stoneBaseY - 12), width: 14, height: 7), stonePaint3);
    }

    // 3. Musgo Bioluminiscente
    if (activeDecors.contains(SanctuaryDecorItem.bioMoss)) {
      final mossPaint = Paint()
        ..color = const Color(0xFFA5D6A7).withValues(alpha: 0.60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      final sporePaint = Paint()
        ..color = const Color(0xFFE8F5E9).withValues(alpha: 0.85);

      for (int i = 0; i < 6; i++) {
        final x = size.width * 0.22 + (i * 48);
        final y = size.height * 0.86 + sin(i * 1.7) * 7;
        final pulse = (sin(animationValue * 2 * pi + (i * 0.8)) + 1.0) * 0.5;
        canvas.drawCircle(Offset(x, y), 5.5 + pulse * 2.5, mossPaint);
        canvas.drawCircle(Offset(x, y - pulse * 10), 1.8, sporePaint);
      }
    }

    // 4. Campanillas de Bambú
    if (activeDecors.contains(SanctuaryDecorItem.windChimes)) {
      final sway = sin(animationValue * 2 * pi * 0.8) * 4.0;
      final chimePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      final startX = size.width - 45.0;
      const startY = 16.0;

      canvas.drawLine(Offset(startX, startY), Offset(startX + sway * 0.3, startY + 26), chimePaint);
      for (int i = 0; i < 3; i++) {
        final bx = startX + (i - 1) * 7.0 + sway * 0.5;
        final by = startY + 26.0;
        final length = 28.0 + (i % 2) * 8.0;
        canvas.drawLine(Offset(bx, by), Offset(bx + sway * 0.8, by + length), chimePaint);
      }
    }
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
        oldDelegate.activeDecors != activeDecors ||
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
