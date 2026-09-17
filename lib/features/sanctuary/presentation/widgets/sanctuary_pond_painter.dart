import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/lev_theme.dart';
import '../../domain/sanctuary_state.dart';
import 'living_seed_spirit_painter.dart';
import 'painters/sanctuary_decor_painter.dart';

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
  final Map<SanctuaryDecorItem, Offset> decorPositions;
  final LevAccessory activeAccessory;
  final Offset? touchNormalizedOffset;
  final Offset? touchLocalPosition;
  final bool isFingerActive;
  final double touchDistance;

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
  final double? prayProgress;
  final SanctuaryWeather weather;
  final bool isWatering;

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
    this.decorPositions = const {},
    this.activeAccessory = LevAccessory.none,
    this.touchNormalizedOffset,
    this.touchLocalPosition,
    this.isFingerActive = false,
    this.touchDistance = 999.0,
    this.weather = SanctuaryWeather.calm,
    this.isWatering = false,
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
    this.prayProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Fondo Crema Botánico Cálido con iluminación suave
    _drawCreamBackground(canvas, rect);

    // 1.1 Clima dinámico de fondo (estrellas si starry o noche)
    _drawWeatherBackground(canvas, size);

    // 1.2. Ondas y estela reactivas al arrastrar el dedo en la pantalla
    if (isFingerActive && touchLocalPosition != null) {
      _drawTouchWaterRipples(canvas, touchLocalPosition!);
    }

    // 1.5. Decoraciones de fondo del Santuario (detrás de Lev)
    _drawActiveDecorationsBackground(canvas, size);

    // 2. Sombra de levitación suave en el suelo crema que respira físicamente
    _drawLevitationShadow(canvas, size);

    // 3. Lev: El personaje en el centro absoluto con su etapa y animaciones
    _drawLevCharacter(canvas, size);

    // 3.2 Animación de Riego (gota que cae y chispas doradas)
    if (isWatering) {
      _drawWateringAnimation(canvas, size);
    }

    // 3.5. Decoraciones de primer plano (frente a Lev, compañeros, luces vivas)
    _drawActiveDecorationsForeground(canvas, size);

    // 3.8 Clima dinámico de primer plano (lluvia o brisa de pétalos)
    _drawWeatherForeground(canvas, size);

    // 4. Efecto de corazoncitos al acariciar con fade suave
    final affectionWeight = happyProgress ?? (isPetting ? 1.0 : (emotion == LevEmotion.happy ? 1.0 : 0.0));
    if (affectionWeight > 0.05) {
      _drawAffectionParticles(canvas, size, affectionWeight);
    }
  }

  void _drawWeatherBackground(Canvas canvas, Size size) {
    if (weather == SanctuaryWeather.starry || timeOfDay == SanctuaryTimeOfDay.night) {
      final starPaint = Paint()..color = Colors.white;
      final rand = Random(777);
      for (int i = 0; i < 35; i++) {
        final sx = rand.nextDouble() * size.width;
        final sy = rand.nextDouble() * size.height * 0.45;
        final phase = (animationValue + rand.nextDouble()) % 1.0;
        final twinkle = (0.2 + 0.8 * sin(phase * 2 * pi).abs()).clamp(0.1, 1.0);
        final r = (1.0 + rand.nextDouble() * 1.5);
        starPaint.color = Colors.white.withValues(alpha: twinkle * 0.7);
        canvas.drawCircle(Offset(sx, sy), r, starPaint);
      }

      // Estrella fugaz ocasional
      final shootPhase = (animationValue * 1.5) % 1.0;
      if (shootPhase < 0.25) {
        final p = shootPhase / 0.25;
        final start = Offset(size.width * 0.15 + p * size.width * 0.7, size.height * 0.05 + p * size.height * 0.15);
        final end = Offset(start.dx - 28, start.dy - 12);
        final shootPaint = Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withValues(alpha: (1.0 - p) * 0.8), Colors.transparent],
          ).createShader(Rect.fromPoints(start, end))
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(start, end, shootPaint);
      }
    }
  }

  void _drawWeatherForeground(Canvas canvas, Size size) {
    if (weather == SanctuaryWeather.rain) {
      final rainPaint = Paint()
        ..color = (timeOfDay == SanctuaryTimeOfDay.night ? const Color(0xFF80E2BF) : const Color(0xFF6B9B88)).withValues(alpha: 0.35)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;

      final rand = Random(1234);
      for (int i = 0; i < 40; i++) {
        final rx = rand.nextDouble() * size.width;
        final speed = 0.8 + rand.nextDouble() * 0.4;
        final ry = ((animationValue * speed * 2.0 + rand.nextDouble()) % 1.0) * size.height;
        canvas.drawLine(Offset(rx, ry), Offset(rx - 3, ry + 16), rainPaint);

        // Salpicadura suave en el tercio inferior
        if (ry > size.height * 0.70 && rand.nextDouble() < 0.3) {
          final ripplePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = rainPaint.color.withValues(alpha: 0.25);
          final ripR = (animationValue * 14.0) % 14.0;
          canvas.drawOval(
            Rect.fromCenter(center: Offset(rx, ry), width: ripR * 2.0, height: ripR * 0.8),
            ripplePaint,
          );
        }
      }
    } else if (weather == SanctuaryWeather.breeze) {
      final petalPaint = Paint()..style = PaintingStyle.fill;
      final rand = Random(4321);
      for (int i = 0; i < 22; i++) {
        final baseSpeed = 0.6 + rand.nextDouble() * 0.4;
        final pProgress = (animationValue * baseSpeed + rand.nextDouble()) % 1.0;
        final px = (pProgress * (size.width + 60)) - 30;
        final sway = sin((animationValue + rand.nextDouble()) * 2 * pi) * 20.0;
        final py = rand.nextDouble() * size.height * 0.85 + sway;

        final isSakura = i % 2 == 0;
        petalPaint.color = (isSakura ? const Color(0xFFFFB7B2) : LevTheme.levMatcha)
            .withValues(alpha: 0.45);

        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(animationValue * 2 * pi + i);
        canvas.drawOval(
          const Rect.fromLTWH(-5, -3, 10, 6),
          petalPaint,
        );
        canvas.restore();
      }
    }
  }

  void _drawWateringAnimation(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;
    final targetY = size.height * 0.48;

    // Gota de rocío brillante que desciende suavemente hacia Lev
    final dropProgress = (animationValue * 2.0) % 1.0;
    final dropY = (targetY - 180) + dropProgress * 170;

    final dropPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          LevTheme.levMatchaDark.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, dropY), radius: 10));

    // Estela de luz
    final trailPaint = Paint()
      ..color = LevTheme.levMatchaLight.withValues(alpha: (1.0 - dropProgress) * 0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX, dropY - 24), Offset(centerX, dropY), trailPaint);

    // Gota
    canvas.drawCircle(Offset(centerX, dropY), 6.5, dropPaint);

    // Chispas botánicas doradas/verdes que irradian de Lev
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 14; i++) {
      final angle = (i / 14) * 2 * pi + (animationValue * pi);
      final dist = 30.0 + (dropProgress * 65.0);
      final sx = centerX + cos(angle) * dist;
      final sy = targetY + sin(angle) * (dist * 0.75);
      final sparkAlpha = ((1.0 - dropProgress) * 0.8).clamp(0.0, 1.0);
      sparkPaint.color = (i % 2 == 0 ? const Color(0xFFFFD54F) : const Color(0xFF80E2BF))
          .withValues(alpha: sparkAlpha);
      canvas.drawCircle(Offset(sx, sy), 2.5, sparkPaint);
    }
  }

  /// Fondo crema botánico cálido suave adaptado al ciclo circadiano natural
  void _drawCreamBackground(Canvas canvas, Rect rect) {
    final List<Color> bgColors;
    final Color glowColor;

    switch (timeOfDay) {
      case SanctuaryTimeOfDay.morning:
        bgColors = const [
          Color(0xFFFFF9EE),
          Color(0xFFFBF4E6),
          Color(0xFFF2E7D5),
        ];
        glowColor = const Color(0xFFFFE8BA).withValues(alpha: 0.50);
        break;
      case SanctuaryTimeOfDay.afternoon:
        bgColors = const [
          Color(0xFFFCFBF9),
          Color(0xFFFAF8F5),
          Color(0xFFF4EFE6),
        ];
        glowColor = const Color(0xFFFFF3D6).withValues(alpha: 0.45);
        break;
      case SanctuaryTimeOfDay.dusk:
        bgColors = const [
          Color(0xFFFDF1EA),
          Color(0xFFF7E6DF),
          Color(0xFFEBE0EA),
        ];
        glowColor = const Color(0xFFFFD5C2).withValues(alpha: 0.48);
        break;
      case SanctuaryTimeOfDay.night:
        bgColors = const [
          Color(0xFF131C24),
          Color(0xFF192530),
          Color(0xFF1E2E3B),
        ];
        glowColor = const Color(0xFF2E4657).withValues(alpha: 0.40);
        break;
    }

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: bgColors,
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    // Halo muy sutil y amplio de calidez detrás de Lev
    final warmGlowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(Offset(rect.width * 0.5, rect.height * 0.48), 120, warmGlowPaint);

    // Si es de noche, dibujamos cielo estrellado sereno sin luz azul y luna creciente
    if (timeOfDay == SanctuaryTimeOfDay.night) {
      _drawNightStarsAndMoon(canvas, rect);
    }
  }

  /// Dibuja estrellas titilantes suaves y una luna creciente botánica para noche relajante
  void _drawNightStarsAndMoon(Canvas canvas, Rect rect) {
    // 1. Luna creciente suave en la esquina superior derecha
    final moonCenter = Offset(rect.width * 0.82, rect.height * 0.12);
    final moonGlow = Paint()
      ..color = const Color(0xFFFFFCE8).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(moonCenter, 24, moonGlow);

    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: 17));
    final cutPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter.translate(-7, -4), radius: 15));
    final crescent = Path.combine(PathOperation.difference, moonPath, cutPath);

    final moonPaint = Paint()..color = const Color(0xFFFFF9E0);
    canvas.drawPath(crescent, moonPaint);

    // 2. Doce estrellas titilantes en el cielo nocturno
    const stars = [
      Offset(0.12, 0.08), Offset(0.24, 0.15), Offset(0.38, 0.07),
      Offset(0.55, 0.12), Offset(0.70, 0.06), Offset(0.88, 0.22),
      Offset(0.18, 0.28), Offset(0.48, 0.22), Offset(0.64, 0.26),
      Offset(0.08, 0.20), Offset(0.32, 0.32), Offset(0.78, 0.34),
    ];

    for (var i = 0; i < stars.length; i++) {
      final s = stars[i];
      final twinkle = (sin(animationValue * 2 * pi * (1.2 + i * 0.3) + i * 0.9) + 1.0) * 0.5;
      final starAlpha = 0.20 + 0.65 * twinkle;
      final starRadius = 1.1 + 0.9 * twinkle;
      final starPaint = Paint()
        ..color = const Color(0xFFFFFDF2).withValues(alpha: starAlpha);
      canvas.drawCircle(Offset(rect.width * s.dx, rect.height * s.dy), starRadius, starPaint);
    }
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
        baseShadowWidth = 125.0;
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

    final shadowBaseColor = timeOfDay == SanctuaryTimeOfDay.night
        ? const Color(0xFF090E14)
        : const Color(0xFF4A5568);

    final shadowPaint = Paint()
      ..color = shadowBaseColor.withValues(alpha: shadowAlpha.clamp(0.02, 0.25))
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
      activeAccessory: activeAccessory,
      touchNormalizedOffset: touchNormalizedOffset,
      isFingerActive: isFingerActive,
      touchDistance: touchDistance,
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
      prayProgress: prayProgress,
    );
    spiritPainter.paint(canvas, size);
  }

  /// Ondas concéntricas de agua botánica y estela de esporas luminosas que nacen interactivamente bajo el dedo
  void _drawTouchWaterRipples(Canvas canvas, Offset touchPos) {
    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final phase = (animationValue * 2.2 + i * 0.33) % 1.0;
      final radius = 10.0 + phase * 46.0;
      final opacity = ((1.0 - phase) * 0.45).clamp(0.0, 1.0);
      ripplePaint
        ..strokeWidth = (2.2 * (1.0 - phase)).clamp(0.6, 2.5)
        ..color = LevTheme.levMatchaLight.withValues(alpha: opacity);
      canvas.drawCircle(touchPos, radius, ripplePaint);
    }

    // Halo central de rocío botánico
    final corePaint = Paint()
      ..color = LevTheme.levMatcha.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(touchPos, 7.0, corePaint);

    // Estela de esporas y chispas de rocío siguiendo dinámicamente al dedo
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (int p = 0; p < 5; p++) {
      final pAngle = (p * 2.0 * pi / 5.0) + animationValue * 3.5;
      final pDist = 14.0 + sin(animationValue * 5.0 + p) * 8.0;
      final px = touchPos.dx + cos(pAngle) * pDist;
      final py = touchPos.dy + sin(pAngle) * pDist;
      sparkPaint.color = const Color(0xFF80E2BF).withValues(alpha: 0.55);
      canvas.drawCircle(Offset(px, py), 2.2, sparkPaint);
    }
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

  void _drawActiveDecorationsBackground(Canvas canvas, Size size) {
    SanctuaryDecorPainter(
      activeDecors: activeDecors,
      decorPositions: decorPositions,
      animationValue: animationValue,
    ).drawBackground(canvas, size);
  }

  void _drawActiveDecorationsForeground(Canvas canvas, Size size) {
    SanctuaryDecorPainter(
      activeDecors: activeDecors,
      decorPositions: decorPositions,
      animationValue: animationValue,
    ).drawForeground(canvas, size);
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
        oldDelegate.decorPositions != decorPositions ||
        oldDelegate.touchNormalizedOffset != touchNormalizedOffset ||
        oldDelegate.touchLocalPosition != touchLocalPosition ||
        oldDelegate.isFingerActive != isFingerActive ||
        oldDelegate.touchDistance != touchDistance ||
        oldDelegate.leafWrapProgress != leafWrapProgress ||
        oldDelegate.sleepProgress != sleepProgress ||
        oldDelegate.happyProgress != happyProgress ||
        oldDelegate.breathingProgress != breathingProgress ||
        oldDelegate.jumpProgress != jumpProgress ||
        oldDelegate.curiousProgress != curiousProgress ||
        oldDelegate.sadProgress != sadProgress ||
        oldDelegate.anxiousProgress != anxiousProgress ||
        oldDelegate.tiredProgress != tiredProgress ||
        oldDelegate.celebrateProgress != celebrateProgress ||
        oldDelegate.prayProgress != prayProgress ||
        oldDelegate.weather != weather ||
        oldDelegate.isWatering != isWatering;
  }
}
