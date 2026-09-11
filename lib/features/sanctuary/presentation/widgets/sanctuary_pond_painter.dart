import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/lev_theme.dart';
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

  /// Obtiene la posición en píxeles de un objeto del entorno (personalizada o por defecto)
  Offset _resolveItemPos(SanctuaryDecorItem item, Size size) {
    final norm = decorPositions[item] ?? item.defaultNormalizedPosition;
    return Offset(norm.dx * size.width, norm.dy * size.height);
  }

  /// Dibuja una sombra difusa de contacto en el suelo para anclar visualmente los objetos
  void _drawContactShadow(Canvas canvas, double width, double height, {double yOffset = 0.0, double blur = 4.0, double alpha = 0.12}) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: alpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, yOffset), width: width, height: height),
      shadowPaint,
    );
  }

  /// Dibuja los elementos del entorno situados detrás de Lev (paredes, cielo, fondo)
  void _drawActiveDecorationsBackground(Canvas canvas, Size size) {
    if (activeDecors.isEmpty) return;

    // 1. Farolillo de Papel Japonés (Colgante con cuerda hasta el techo)
    if (activeDecors.contains(SanctuaryDecorItem.paperLantern)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.paperLantern, size);
      final sway = sin(animationValue * 2 * pi * 0.7) * 3.5;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // Cuerda conectada desde el borde superior de la pantalla hasta el farolillo
      final ropePaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 1.3;
      canvas.drawLine(Offset(0, -pos.dy), Offset(sway, 0), ropePaint);

      // Resplandor cálido
      final lanternGlow = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.38 + sin(animationValue * 2 * pi) * 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(Offset(sway, 20), 26, lanternGlow);

      // Cuerpo del farolillo
      final bodyRect = Rect.fromCenter(center: Offset(sway, 20), width: 24, height: 32);
      final bodyPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF9C4), Color(0xFFFFE082), Color(0xFFFFCC80)],
        ).createShader(bodyRect);
      canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), bodyPaint);

      // Varillas de bambú / textura del papel
      final ribPaint = Paint()
        ..color = const Color(0xFFFFB74D).withValues(alpha: 0.6)
        ..strokeWidth = 0.9;
      canvas.drawLine(Offset(sway - 10, 14), Offset(sway + 10, 14), ribPaint);
      canvas.drawLine(Offset(sway - 11, 20), Offset(sway + 11, 20), ribPaint);
      canvas.drawLine(Offset(sway - 10, 26), Offset(sway + 10, 26), ribPaint);

      // Tapas superior e inferior
      final capPaint = Paint()..color = const Color(0xFF3E2723);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(sway, 4), width: 18, height: 3.5), const Radius.circular(2)), capPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(sway, 36), width: 18, height: 3.5), const Radius.circular(2)), capPaint);

      // Borla roja colgante
      final tasselPaint = Paint()
        ..color = const Color(0xFFC62828)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(sway, 38), Offset(sway + sway * 0.4, 52), tasselPaint);
      canvas.drawCircle(Offset(sway + sway * 0.4, 53), 2.0, tasselPaint);

      canvas.restore();
    }

    // 2. Campanillas de Bambú (Colgante con oscilación de viento)
    if (activeDecors.contains(SanctuaryDecorItem.windChimes)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.windChimes, size);
      final sway = sin(animationValue * 2 * pi * 0.8) * 4.0;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final chimeRopePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(0, -pos.dy), Offset(sway * 0.2, 0), chimeRopePaint);

      // Varilla horizontal
      final barPaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(-16 + sway * 0.3, 0), Offset(16 + sway * 0.3, 0), barPaint);

      // 3 cañas de bambú oscilantes
      final chimePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 3; i++) {
        final bx = (i - 1) * 8.0 + sway * 0.4;
        final length = 26.0 + (i % 2) * 8.0;
        canvas.drawLine(Offset(bx, 2), Offset(bx + sway * 0.6, length), chimePaint);
      }

      // Clapper central / atrapasueños
      canvas.drawCircle(Offset(sway * 0.5, 18), 2.8, Paint()..color = const Color(0xFFA1887F));
      final sailPaint = Paint()..color = const Color(0xFF81C784);
      canvas.drawRect(Rect.fromCenter(center: Offset(sway * 0.7, 30), width: 6, height: 12), sailPaint);

      canvas.restore();
    }

    // 3. Pajarito Cantor en Rama
    if (activeDecors.contains(SanctuaryDecorItem.zenBird)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.zenBird, size);
      final bob = sin(animationValue * 2 * pi * 0.9) * 1.6;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // Rama orgánica
      final branchPaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      final branchPath = Path()
        ..moveTo(24, 6)
        ..quadraticBezierTo(0, 10, -28, 14);
      canvas.drawPath(branchPath, branchPaint);

      // Florecita de cerezo y brotes
      canvas.drawCircle(const Offset(-14, 10), 3.2, Paint()..color = const Color(0xFFF8BBD0));
      canvas.drawOval(Rect.fromCenter(center: const Offset(12, 5), width: 7, height: 3), Paint()..color = const Color(0xFF81C784));

      // Pajarito azul
      final birdY = bob;
      final birdBodyPaint = Paint()..color = const Color(0xFF4FC3F7);
      canvas.drawOval(Rect.fromCenter(center: Offset(0, birdY), width: 17, height: 12), birdBodyPaint);

      // Pecho blanco suave
      final bellyPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawOval(Rect.fromCenter(center: Offset(-3, birdY + 2), width: 10, height: 7), bellyPaint);

      // Cabeza
      canvas.drawCircle(Offset(-7, birdY - 3), 4.6, birdBodyPaint);

      // Piquito
      final beakPaint = Paint()..color = const Color(0xFFFFB300);
      final beakPath = Path()
        ..moveTo(-11, birdY - 4)
        ..lineTo(-16, birdY - 2.5)
        ..lineTo(-11, birdY - 1)
        ..close();
      canvas.drawPath(beakPath, beakPaint);

      // Ojo con brillo
      canvas.drawCircle(Offset(-8, birdY - 4), 1.0, Paint()..color = const Color(0xFF263238));
      canvas.drawCircle(Offset(-8.3, birdY - 4.3), 0.4, Paint()..color = Colors.white);

      // Patitas
      final feetPaint = Paint()..color = const Color(0xFFFFB300)..strokeWidth = 1.0;
      canvas.drawLine(Offset(-2, birdY + 6), const Offset(-2, 10), feetPaint);
      canvas.drawLine(Offset(2, birdY + 6), const Offset(2, 9), feetPaint);

      canvas.restore();
    }

    // 4. Biombo de Bambú Vivo
    if (activeDecors.contains(SanctuaryDecorItem.bambooPartition)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.bambooPartition, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 42, 10, yOffset: 22, alpha: 0.12);

      final stalkPaint = Paint()
        ..color = const Color(0xFF689F38)
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round;
      final leafPaint = Paint()..color = const Color(0xFF8BC34A);
      final nodePaint = Paint()..color = const Color(0xFF33691E)..strokeWidth = 1.1;

      for (int i = 0; i < 4; i++) {
        final bx = -14.0 + (i * 9.0);
        final topY = -40.0 + (i % 2) * 8.0;
        const botY = 20.0;

        canvas.drawLine(Offset(bx, topY), Offset(bx, botY), stalkPaint);

        for (double ny = topY + 12; ny < botY; ny += 18) {
          canvas.drawLine(Offset(bx - 3, ny), Offset(bx + 3, ny), nodePaint);
        }

        if (i % 2 == 0) {
          canvas.drawOval(Rect.fromCenter(center: Offset(bx + 6, topY + 14), width: 10, height: 4), leafPaint);
        }
      }

      canvas.restore();
    }

    // 5. Estanque de Loto
    if (activeDecors.contains(SanctuaryDecorItem.lotusPond)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.lotusPond, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final pondW = (size.width * 0.65).clamp(160.0, 300.0);
      final pondPaint = Paint()
        ..color = const Color(0xFFD4EAE8).withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: pondW, height: 54), pondPaint);

      final ripplePulse = animationValue * 2 * pi;
      final ripplePaint = Paint()
        ..color = const Color(0xFFB2DFDB).withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: pondW * 0.70 + sin(ripplePulse) * 8,
          height: 34 + sin(ripplePulse) * 4,
        ),
        ripplePaint,
      );

      // Nenúfares
      final padPaint = Paint()..color = const Color(0xFF81C784);
      canvas.drawOval(Rect.fromCenter(center: const Offset(-50, 4), width: 30, height: 14), padPaint);
      canvas.drawOval(Rect.fromCenter(center: const Offset(45, -5), width: 26, height: 12), padPaint);

      // Flores de loto
      final lotusPetalPaint = Paint()..color = const Color(0xFFF8BBD0);
      final centerPaint = Paint()..color = const Color(0xFFFFF9C4);
      canvas.drawCircle(const Offset(-50, 2), 5.5, lotusPetalPaint);
      canvas.drawCircle(const Offset(-50, 2), 2.0, centerPaint);
      canvas.drawCircle(const Offset(45, -7), 4.5, lotusPetalPaint);
      canvas.drawCircle(const Offset(45, -7), 1.6, centerPaint);

      canvas.restore();
    }

    // 6. Rocas de Jardín Zen
    if (activeDecors.contains(SanctuaryDecorItem.zenStones)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.zenStones, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 36, 12, yOffset: 6, alpha: 0.14);

      final stonePaint1 = Paint()..color = const Color(0xFFB0BEC5);
      final stonePaint2 = Paint()..color = const Color(0xFF90A4AE);
      final stonePaint3 = Paint()..color = const Color(0xFF78909C);

      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 32, height: 14), stonePaint1);
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, -6), width: 24, height: 11), stonePaint2);
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, -12), width: 16, height: 8), stonePaint3);

      // Musgo entre rocas
      final mossPaint = Paint()..color = const Color(0xFF81C784);
      canvas.drawCircle(const Offset(-10, -2), 2.5, mossPaint);
      canvas.drawCircle(const Offset(8, -8), 2.0, mossPaint);

      canvas.restore();
    }

    // 7. Musgo Bioluminiscente
    if (activeDecors.contains(SanctuaryDecorItem.bioMoss)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.bioMoss, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final mossGlow = Paint()
        ..color = const Color(0xFFA5D6A7).withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      final sporePaint = Paint()..color = const Color(0xFFE8F5E9).withValues(alpha: 0.90);

      for (int i = 0; i < 5; i++) {
        final x = -30.0 + (i * 15.0);
        final y = sin(i * 1.8) * 5.0;
        final pulse = (sin(animationValue * 2 * pi + (i * 0.8)) + 1.0) * 0.5;
        canvas.drawCircle(Offset(x, y), 6.0 + pulse * 2.5, mossGlow);
        canvas.drawCircle(Offset(x, y - pulse * 12), 1.8, sporePaint);
      }

      canvas.restore();
    }

    // 8. Bonsái Ancestral
    if (activeDecors.contains(SanctuaryDecorItem.bonsaiTree)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.bonsaiTree, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 44, 12, yOffset: 16, alpha: 0.15);

      // Peana de madera
      canvas.drawRect(Rect.fromCenter(center: const Offset(0, 14), width: 42, height: 3.5), Paint()..color = const Color(0xFF4E342E));

      // Maceta de barro cocido
      final potRect = Rect.fromCenter(center: const Offset(0, 8), width: 36, height: 12);
      canvas.drawRRect(RRect.fromRectAndRadius(potRect, const Radius.circular(3)), Paint()..color = const Color(0xFF8D6E63));

      // Tronco retorcido de bonsái
      final trunkPaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      final trunkPath = Path()
        ..moveTo(0, 3)
        ..cubicTo(-6, -8, 8, -16, 2, -26);
      canvas.drawPath(trunkPath, trunkPaint);

      // Copas verdes jade
      final leaves1 = Paint()..color = const Color(0xFF2E7D32);
      final leaves2 = Paint()..color = const Color(0xFF43A047);
      canvas.drawCircle(const Offset(2, -28), 12, leaves1);
      canvas.drawCircle(const Offset(-8, -20), 9, leaves2);
      canvas.drawCircle(const Offset(11, -18), 8, leaves1);

      canvas.restore();
    }

    // 9. Jarrón de Sakura
    if (activeDecors.contains(SanctuaryDecorItem.sakuraVase)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.sakuraVase, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 26, 8, yOffset: 16, alpha: 0.12);

      // Jarrón blanco esmaltado
      final vaseRect = Rect.fromCenter(center: const Offset(0, 4), width: 22, height: 26);
      canvas.drawRRect(RRect.fromRectAndRadius(vaseRect, const Radius.circular(8)), Paint()..color = const Color(0xFFECEFF1));
      canvas.drawRect(Rect.fromCenter(center: const Offset(0, -10), width: 9, height: 6), Paint()..color = const Color(0xFFECEFF1));

      // Ramas
      final branchPaint = Paint()..color = const Color(0xFF6D4C41)..strokeWidth = 1.6..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(0, -10), const Offset(-9, -26), branchPaint);
      canvas.drawLine(const Offset(0, -10), const Offset(10, -30), branchPaint);

      // Flores de sakura
      final petalPaint = Paint()..color = const Color(0xFFF8BBD0);
      final pinkCenter = Paint()..color = const Color(0xFFEC407A);
      for (final p in [
        const Offset(-9, -26), const Offset(10, -30), const Offset(2, -22), const Offset(-14, -20),
      ]) {
        canvas.drawCircle(p, 4.4, petalPaint);
        canvas.drawCircle(p, 1.3, pinkCenter);
      }
      // Pétalo caído
      canvas.drawOval(Rect.fromCenter(center: const Offset(-12, 14), width: 4.5, height: 2.2), petalPaint);

      canvas.restore();
    }

    // 10. Rincón de Libros Botánicos
    if (activeDecors.contains(SanctuaryDecorItem.readingBooks)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.readingBooks, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 38, 10, yOffset: 8, alpha: 0.12);

      // Libros apilados
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 4), width: 34, height: 7), const Radius.circular(1.5)), Paint()..color = const Color(0xFF81C784));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(2, -3), width: 30, height: 6.5), const Radius.circular(1.5)), Paint()..color = const Color(0xFFFFD54F));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-1, -10), width: 26, height: 6), const Radius.circular(1.5)), Paint()..color = const Color(0xFFCE93D8));

      // Marcapáginas
      final ribbonPaint = Paint()..color = const Color(0xFFE57373)..strokeWidth = 1.5;
      canvas.drawLine(const Offset(11, -7), const Offset(15, 2), ribbonPaint);

      // Tacita con té
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(18, 4), width: 10, height: 9), const Radius.circular(2)), Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(18, 2), 2.2, Paint()..color = const Color(0xFF81C784));

      canvas.restore();
    }

    // 11. Hongos Bioluminiscentes
    if (activeDecors.contains(SanctuaryDecorItem.magicMushrooms)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.magicMushrooms, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 30, 8, yOffset: 4, alpha: 0.12);

      final stalkPaint = Paint()..color = const Color(0xFFE0E0E0)..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(0, 2), const Offset(0, -10), stalkPaint);
      canvas.drawLine(const Offset(-8, 3), const Offset(-7, -7), stalkPaint);
      canvas.drawLine(const Offset(8, 4), const Offset(7, -9), stalkPaint);

      // Resplandor
      final glowPaint = Paint()
        ..color = const Color(0xFF80DEEA).withValues(alpha: 0.45 + sin(animationValue * 2 * pi) * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
      canvas.drawCircle(const Offset(0, -12), 11, glowPaint);

      // Sombreros turquesa
      canvas.drawArc(Rect.fromCenter(center: const Offset(0, -11), width: 17, height: 13), pi, pi, true, Paint()..color = const Color(0xFF26C6DA));
      canvas.drawArc(Rect.fromCenter(center: const Offset(-7, -7), width: 12, height: 9), pi, pi, true, Paint()..color = const Color(0xFF4DD0E1));
      canvas.drawArc(Rect.fromCenter(center: const Offset(7, -9), width: 13, height: 10), pi, pi, true, Paint()..color = const Color(0xFF80CBC4));

      // Moteado blanco
      canvas.drawCircle(const Offset(-3, -14), 1.0, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(2, -13), 1.0, Paint()..color = Colors.white);

      canvas.restore();
    }

    // 12. Fuente de Caña Shishi-Odoshi
    if (activeDecors.contains(SanctuaryDecorItem.waterFountain)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.waterFountain, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 40, 14, yOffset: 16, alpha: 0.15);

      // Cuenco de piedra
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 12), width: 38, height: 16), Paint()..color = const Color(0xFF78909C));
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 11), width: 30, height: 10), Paint()..color = const Color(0xFF80DEEA).withValues(alpha: 0.72));

      // Poste vertical
      final postPaint = Paint()..color = const Color(0xFF558B2F)..strokeWidth = 3.2..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-8, 12), const Offset(-8, -14), postPaint);

      // Caña oscilante
      final tilt = sin(animationValue * 2 * pi * 0.6) * 4.0;
      final spoutPaint = Paint()..color = const Color(0xFF689F38)..strokeWidth = 3.2..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(-14, -10 - tilt * 0.4), Offset(6, -6 + tilt), spoutPaint);

      // Gota de agua cayendo
      final dropY = -2 + ((animationValue * 3) % 1.0) * 13.0;
      canvas.drawCircle(Offset(6, dropY), 1.6, Paint()..color = const Color(0xFFB2EBF2));

      canvas.restore();
    }
  }

  /// Dibuja los elementos en primer plano (frente a Lev, compañeros, fuego vivo, confort)
  void _drawActiveDecorationsForeground(Canvas canvas, Size size) {
    if (activeDecors.isEmpty) return;

    // 13. Cojín Zafu de Meditación
    if (activeDecors.contains(SanctuaryDecorItem.meditationCushion)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.meditationCushion, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 42, 14, yOffset: 7, alpha: 0.14);

      final cushionRect = Rect.fromCenter(center: Offset.zero, width: 38, height: 19);
      final cushionPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA5D6A7), Color(0xFF81C784), Color(0xFF66BB6A)],
        ).createShader(cushionRect);
      canvas.drawOval(cushionRect, cushionPaint);

      // Pliegues y botón
      final foldPaint = Paint()..color = const Color(0xFF388E3C).withValues(alpha: 0.35)..strokeWidth = 1.0;
      for (int i = 0; i < 6; i++) {
        final angle = i * pi / 3;
        canvas.drawLine(Offset.zero, Offset(cos(angle) * 15, sin(angle) * 7), foldPaint);
      }
      canvas.drawCircle(Offset.zero, 2.6, Paint()..color = const Color(0xFFFFF9C4));

      canvas.restore();
    }

    // 14. Mesa de Té Matcha con Vapor Animado
    if (activeDecors.contains(SanctuaryDecorItem.matchaTable)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.matchaTable, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 46, 12, yOffset: 14, alpha: 0.14);

      // Mesa de madera
      final tablePaint = Paint()..color = const Color(0xFF795548);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 4), width: 44, height: 8), const Radius.circular(2)), tablePaint);
      canvas.drawRect(Rect.fromCenter(center: const Offset(-15, 10), width: 3.5, height: 7), tablePaint);
      canvas.drawRect(Rect.fromCenter(center: const Offset(15, 10), width: 3.5, height: 7), tablePaint);

      // Cuenco y té matcha
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, -3), width: 18, height: 11), Paint()..color = const Color(0xFF3E2723));
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, -4), width: 14, height: 7), Paint()..color = const Color(0xFF4CAF50));

      // Vapor animado ondeante
      final steamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.52)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      for (int i = 0; i < 2; i++) {
        final sx = -3.0 + (i * 6.0);
        final steamPath = Path()..moveTo(sx, -9);
        final cycle = animationValue * 4 * pi + (i * pi);
        steamPath.cubicTo(
          sx + sin(cycle) * 3, -17,
          sx - sin(cycle) * 3, -25,
          sx + sin(cycle) * 2, -33,
        );
        canvas.drawPath(steamPath, steamPaint);
      }

      canvas.restore();
    }

    // 15. Vela Aromática con Llama Viva
    if (activeDecors.contains(SanctuaryDecorItem.aromaCandle)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.aromaCandle, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 18, 6, yOffset: 10, alpha: 0.12);

      // Vaso de cristal con cera lavanda
      final glassPaint = Paint()..color = const Color(0xFFD1C4E9).withValues(alpha: 0.88);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 3), width: 14, height: 14), const Radius.circular(2)), glassPaint);

      // Mecha
      canvas.drawLine(const Offset(0, -4), const Offset(0, -7), Paint()..color = const Color(0xFF3E2723)..strokeWidth = 1.0);

      // Llama animada oscilante
      final flameFlicker = sin(animationValue * 8 * pi) * 1.0;
      final flamePath = Path()
        ..moveTo(0, -7)
        ..quadraticBezierTo(2.5 + flameFlicker, -11, flameFlicker * 0.5, -16)
        ..quadraticBezierTo(-2.5 + flameFlicker, -11, 0, -7)
        ..close();

      // Resplandor
      final flameGlow = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawCircle(const Offset(0, -11), 9, flameGlow);

      canvas.drawPath(flamePath, Paint()..color = const Color(0xFFFFB74D));
      canvas.drawCircle(const Offset(0, -9), 1.6, Paint()..color = const Color(0xFFFFF9C4));

      canvas.restore();
    }

    // 16. Lámpara de Sal del Himalaya
    if (activeDecors.contains(SanctuaryDecorItem.saltLamp)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.saltLamp, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 26, 8, yOffset: 12, alpha: 0.14);

      // Resplandor ámbar cálido
      final saltGlow = Paint()
        ..color = const Color(0xFFFFAB91).withValues(alpha: 0.42 + sin(animationValue * 2 * pi) * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(const Offset(0, 0), 18, saltGlow);

      // Base de madera
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 9), width: 22, height: 6), Paint()..color = const Color(0xFF4E342E));

      // Cristal facetado
      final crystalPath = Path()
        ..moveTo(-8, 8)
        ..lineTo(-9, -3)
        ..lineTo(-4, -12)
        ..lineTo(5, -13)
        ..lineTo(8, -4)
        ..lineTo(7, 8)
        ..close();
      final crystalPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFCCBC), Color(0xFFFF8A65), Color(0xFFD84315)],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: 18, height: 22));
      canvas.drawPath(crystalPath, crystalPaint);

      canvas.restore();
    }

    // 17. Gatito Curvado en Siesta
    if (activeDecors.contains(SanctuaryDecorItem.cozyCat)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.cozyCat, size);
      final breath = sin(animationValue * 2 * pi * 0.5) * 1.2;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      _drawContactShadow(canvas, 32, 10, yOffset: 9, alpha: 0.12);

      // Cuerpo acurrucado que respira
      final catPaint = Paint()..color = const Color(0xFFFFB74D);
      canvas.drawOval(Rect.fromCenter(center: Offset(0, breath * 0.5), width: 24, height: 16 + breath), catPaint);

      // Cabeza
      canvas.drawCircle(const Offset(-7, 2), 6.5, catPaint);

      // Orejitas
      final earPaint = Paint()..color = const Color(0xFFFF8A65);
      final ear1 = Path()..moveTo(-11, -2)..lineTo(-9, -8)..lineTo(-6, -3)..close();
      final ear2 = Path()..moveTo(-6, -3)..lineTo(-3, -8)..lineTo(-2, -2)..close();
      canvas.drawPath(ear1, earPaint);
      canvas.drawPath(ear2, earPaint);

      // Cola curvada envolviendo el cuerpo
      final tailPaint = Paint()
        ..color = const Color(0xFFFFA726)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCenter(center: const Offset(8, 2), width: 12, height: 12), -pi * 0.2, pi * 1.1, false, tailPaint);

      // Micro Zzz
      final zAlpha = ((sin(animationValue * 2 * pi * 0.7) + 1.0) * 0.45).clamp(0.1, 0.9);
      final zPaint = Paint()..color = LevTheme.levMatchaDark.withValues(alpha: zAlpha);
      canvas.drawCircle(const Offset(-14, -10), 1.2, zPaint);
      canvas.drawCircle(const Offset(-18, -14), 1.6, zPaint);

      canvas.restore();
    }

    // 18. Mariposa de Cristal
    if (activeDecors.contains(SanctuaryDecorItem.spiritButterfly)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.spiritButterfly, size);
      final flap = (cos(animationValue * 8 * pi)).abs();
      final hoverX = sin(animationValue * 2 * pi) * 6.0;
      final hoverY = cos(animationValue * 2 * pi) * 4.0;

      canvas.save();
      canvas.translate(pos.dx + hoverX, pos.dy + hoverY);

      // Halo de luz suave
      final glowPaint = Paint()
        ..color = const Color(0xFF80E8CB).withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawCircle(Offset.zero, 9, glowPaint);

      // Alas esmeralda translúcidas moduladas por el aleteo
      final wingPaint = Paint()..color = const Color(0xFF64FFDA).withValues(alpha: 0.78);
      final wingW = 7.5 * flap.clamp(0.2, 1.0);

      canvas.drawOval(Rect.fromCenter(center: Offset(-wingW * 0.8, -3), width: wingW, height: 9), wingPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(wingW * 0.8, -3), width: wingW, height: 9), wingPaint);

      // Cuerpo fino
      canvas.drawLine(const Offset(0, -6), const Offset(0, 4), Paint()..color = const Color(0xFF004D40)..strokeWidth = 1.0);

      canvas.restore();
    }

    // 19. Enjambre de Luciérnagas
    if (activeDecors.contains(SanctuaryDecorItem.fireflies)) {
      final pos = _resolveItemPos(SanctuaryDecorItem.fireflies, size);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final glowPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final corePaint = Paint()..color = const Color(0xFFFFFF8D);

      const fireflySeeds = [
        [-42.0, -35.0, 0.8, 22.0],
        [38.0, -28.0, 1.1, 26.0],
        [-20.0, 24.0, 0.9, 28.0],
        [44.0, 30.0, 1.3, 24.0],
        [0.0, -18.0, 0.7, 30.0],
        [-38.0, 36.0, 1.2, 20.0],
        [22.0, 12.0, 0.85, 25.0],
      ];

      for (int i = 0; i < fireflySeeds.length; i++) {
        final seed = fireflySeeds[i];
        final speed = seed[2];
        final radius = seed[3];
        final fx = seed[0] + sin(animationValue * 2 * pi * speed + i) * radius * 0.4;
        final fy = seed[1] + cos(animationValue * 2 * pi * speed * 1.2 + i * 1.5) * radius * 0.3;

        final pulse = (sin(animationValue * 4 * pi * speed + i * 2.0) + 1.0) * 0.5;
        glowPaint.color = const Color(0xFFC6FF00).withValues(alpha: 0.25 + pulse * 0.45);

        canvas.drawCircle(Offset(fx, fy), 4.5 + pulse * 2.5, glowPaint);
        canvas.drawCircle(Offset(fx, fy), 1.4, corePaint);
      }

      canvas.restore();
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
        oldDelegate.weather != weather ||
        oldDelegate.isWatering != isWatering;
  }
}
