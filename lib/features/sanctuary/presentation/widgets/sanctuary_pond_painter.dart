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
  final LevAccessory activeAccessory;

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
    this.activeAccessory = LevAccessory.none,
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

    // 1.5. Decoraciones de fondo del Santuario (detrás de Lev)
    _drawActiveDecorationsBackground(canvas, size);

    // 2. Sombra de levitación suave en el suelo crema que respira físicamente
    _drawLevitationShadow(canvas, size);

    // 3. Lev: El personaje en el centro absoluto con su etapa y animaciones
    _drawLevCharacter(canvas, size);

    // 3.5. Decoraciones de primer plano (frente a Lev, compañeros, luces vivas)
    _drawActiveDecorationsForeground(canvas, size);

    // 4. Efecto de corazoncitos al acariciar con fade suave
    final affectionWeight = happyProgress ?? (isPetting ? 1.0 : (emotion == LevEmotion.happy ? 1.0 : 0.0));
    if (affectionWeight > 0.05) {
      _drawAffectionParticles(canvas, size, affectionWeight);
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

  /// Dibuja los elementos del entorno situados detrás de Lev (paredes, cielo, fondo)
  void _drawActiveDecorationsBackground(Canvas canvas, Size size) {
    if (activeDecors.isEmpty) return;
    final centerX = size.width * 0.5;

    // 1. Farolillo de Papel Japonés (Techo superior izquierdo)
    if (activeDecors.contains(SanctuaryDecorItem.paperLantern)) {
      final sway = sin(animationValue * 2 * pi * 0.7) * 3.5;
      final lanternX = 42.0 + sway;
      const ropeStartY = 0.0;
      const ropeEndY = 36.0;

      final ropePaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 1.2;
      canvas.drawLine(const Offset(42.0, ropeStartY), Offset(lanternX, ropeEndY), ropePaint);

      // Resplandor cálido
      final lanternGlow = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.35 + sin(animationValue * 2 * pi) * 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(Offset(lanternX, ropeEndY + 22), 26, lanternGlow);

      // Cuerpo del farolillo
      final bodyRect = Rect.fromCenter(center: Offset(lanternX, ropeEndY + 22), width: 24, height: 32);
      final bodyPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF9C4), Color(0xFFFFE082), Color(0xFFFFCC80)],
        ).createShader(bodyRect);
      canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), bodyPaint);

      // Tapas superior e inferior
      final capPaint = Paint()..color = const Color(0xFF3E2723);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(lanternX, ropeEndY + 6), width: 18, height: 3.5), const Radius.circular(2)), capPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(lanternX, ropeEndY + 38), width: 18, height: 3.5), const Radius.circular(2)), capPaint);

      // Borla colgante
      final tasselPaint = Paint()
        ..color = const Color(0xFFC62828)
        ..strokeWidth = 1.4;
      canvas.drawLine(Offset(lanternX, ropeEndY + 40), Offset(lanternX + sway * 0.4, ropeEndY + 54), tasselPaint);
    }

    // 2. Campanillas de Bambú (Techo superior derecho)
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

    // 3. Pajarito Cantor en Rama (Superior derecho)
    if (activeDecors.contains(SanctuaryDecorItem.zenBird)) {
      final branchPaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      final branchPath = Path()
        ..moveTo(size.width, 50)
        ..quadraticBezierTo(size.width - 35, 55, size.width - 65, 68);
      canvas.drawPath(branchPath, branchPaint);

      // Florecita en la rama
      final flowerPaint = Paint()..color = const Color(0xFFF8BBD0);
      canvas.drawCircle(Offset(size.width - 52, 60), 3.5, flowerPaint);

      // Pajarito azul
      final bob = sin(animationValue * 2 * pi * 0.9) * 1.5;
      final birdX = size.width - 48.0;
      final birdY = 56.0 + bob;

      final birdBodyPaint = Paint()..color = const Color(0xFF4FC3F7);
      canvas.drawOval(Rect.fromCenter(center: Offset(birdX, birdY), width: 16, height: 11), birdBodyPaint);

      // Pancita blanca
      final bellyPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawOval(Rect.fromCenter(center: Offset(birdX - 2, birdY + 2), width: 9, height: 6), bellyPaint);

      // Cabeza
      canvas.drawCircle(Offset(birdX - 7, birdY - 3), 4.5, birdBodyPaint);

      // Piquito amarillo
      final beakPaint = Paint()..color = const Color(0xFFFFB300);
      final beakPath = Path()
        ..moveTo(birdX - 11, birdY - 4)
        ..lineTo(birdX - 15, birdY - 2.5)
        ..lineTo(birdX - 11, birdY - 1)
        ..close();
      canvas.drawPath(beakPath, beakPaint);

      // Ojo
      canvas.drawCircle(Offset(birdX - 8, birdY - 4), 0.9, Paint()..color = const Color(0xFF263238));
    }

    // 4. Biombo de Bambú Vivo (Borde izquierdo de la casa)
    if (activeDecors.contains(SanctuaryDecorItem.bambooPartition)) {
      final stalkPaint = Paint()
        ..color = const Color(0xFF689F38)
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round;
      final leafPaint = Paint()..color = const Color(0xFF8BC34A);

      for (int i = 0; i < 4; i++) {
        final bx = 12.0 + (i * 9.0);
        final topY = size.height * 0.60 + (i % 2) * 16.0;
        final botY = size.height * 0.90;

        canvas.drawLine(Offset(bx, topY), Offset(bx, botY), stalkPaint);

        // Nudos de bambú
        final nodePaint = Paint()
          ..color = const Color(0xFF33691E)
          ..strokeWidth = 1.0;
        for (double ny = topY + 20; ny < botY; ny += 28) {
          canvas.drawLine(Offset(bx - 3, ny), Offset(bx + 3, ny), nodePaint);
        }

        // Hojita verde
        if (i % 2 == 0) {
          canvas.drawOval(Rect.fromCenter(center: Offset(bx + 7, topY + 25), width: 11, height: 4), leafPaint);
        }
      }
    }

    // 5. Estanque de Loto
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

    // 6. Rocas de Jardín Zen
    if (activeDecors.contains(SanctuaryDecorItem.zenStones)) {
      final stoneBaseY = size.height * 0.84;
      final stonePaint1 = Paint()..color = const Color(0xFFB0BEC5);
      final stonePaint2 = Paint()..color = const Color(0xFF90A4AE);
      final stonePaint3 = Paint()..color = const Color(0xFF78909C);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 105, stoneBaseY), width: 30, height: 13), stonePaint1);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 105, stoneBaseY - 6), width: 22, height: 10), stonePaint2);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 105, stoneBaseY - 12), width: 14, height: 7), stonePaint3);
    }

    // 7. Musgo Bioluminiscente
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

    // 8. Bonsái Ancestral (Lado izquierdo medio)
    if (activeDecors.contains(SanctuaryDecorItem.bonsaiTree)) {
      final bx = centerX - 122.0;
      final by = size.height * 0.77;

      // Maceta de barro
      final potPaint = Paint()..color = const Color(0xFF8D6E63);
      final potRect = Rect.fromCenter(center: Offset(bx, by + 12), width: 34, height: 12);
      canvas.drawRRect(RRect.fromRectAndRadius(potRect, const Radius.circular(3)), potPaint);

      // Peana de madera oscura
      canvas.drawRect(Rect.fromCenter(center: Offset(bx, by + 19), width: 40, height: 3), Paint()..color = const Color(0xFF4E342E));

      // Tronco retorcido
      final trunkPaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      final trunkPath = Path()
        ..moveTo(bx, by + 6)
        ..cubicTo(bx - 6, by - 6, bx + 10, by - 14, bx + 2, by - 24);
      canvas.drawPath(trunkPath, trunkPaint);

      // Copas de follaje verde jade
      final leavesPaint1 = Paint()..color = const Color(0xFF2E7D32);
      final leavesPaint2 = Paint()..color = const Color(0xFF43A047);
      canvas.drawCircle(Offset(bx + 2, by - 26), 11, leavesPaint1);
      canvas.drawCircle(Offset(bx - 8, by - 18), 8, leavesPaint2);
      canvas.drawCircle(Offset(bx + 11, by - 16), 7, leavesPaint1);
    }

    // 9. Jarrón de Sakura (Lado derecho medio)
    if (activeDecors.contains(SanctuaryDecorItem.sakuraVase)) {
      final vx = centerX + 118.0;
      final vy = size.height * 0.76;

      // Jarrón cerámico blanco
      final vasePaint = Paint()..color = const Color(0xFFECEFF1);
      final vaseRect = Rect.fromCenter(center: Offset(vx, vy + 8), width: 20, height: 26);
      canvas.drawRRect(RRect.fromRectAndRadius(vaseRect, const Radius.circular(7)), vasePaint);

      // Cuello del jarrón
      canvas.drawRect(Rect.fromCenter(center: Offset(vx, vy - 6), width: 8, height: 6), vasePaint);

      // Ramas floridas
      final branchPaint = Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(vx, vy - 6), Offset(vx - 8, vy - 24), branchPaint);
      canvas.drawLine(Offset(vx, vy - 6), Offset(vx + 9, vy - 28), branchPaint);

      // Flores de sakura rosadas
      final petalPaint = Paint()..color = const Color(0xFFF8BBD0);
      final centerPink = Paint()..color = const Color(0xFFEC407A);

      for (final p in [
        Offset(vx - 8, vy - 24),
        Offset(vx + 9, vy - 28),
        Offset(vx + 2, vy - 20),
        Offset(vx - 14, vy - 18),
      ]) {
        canvas.drawCircle(p, 4.2, petalPaint);
        canvas.drawCircle(p, 1.2, centerPink);
      }

      // Pétalo caído en la mesa
      canvas.drawOval(Rect.fromCenter(center: Offset(vx - 12, vy + 20), width: 4, height: 2.2), petalPaint);
    }

    // 10. Rincón de Libros Botánicos (Detrás a la izquierda)
    if (activeDecors.contains(SanctuaryDecorItem.readingBooks)) {
      final rx = centerX - 110.0;
      final ry = size.height * 0.85;

      // Libro 1 (base - salvia)
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(rx, ry + 4), width: 34, height: 7), const Radius.circular(1.5)), Paint()..color = const Color(0xFF81C784));
      // Libro 2 (medio - mostaza)
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(rx + 2, ry - 3), width: 30, height: 6.5), const Radius.circular(1.5)), Paint()..color = const Color(0xFFFFD54F));
      // Libro 3 (arriba - lavanda)
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(rx - 1, ry - 10), width: 26, height: 6), const Radius.circular(1.5)), Paint()..color = const Color(0xFFCE93D8));

      // Marcapáginas colgando
      final ribbonPaint = Paint()
        ..color = const Color(0xFFE57373)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(rx + 11, ry - 7), Offset(rx + 15, ry + 2), ribbonPaint);

      // Taza pequeña con té
      final cupPaint = Paint()..color = Colors.white;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(rx + 18, ry + 4), width: 10, height: 9), const Radius.circular(2)), cupPaint);
      canvas.drawCircle(Offset(rx + 18, ry + 2), 2, Paint()..color = const Color(0xFF81C784));
    }

    // 11. Hongos Bioluminiscentes (Suelo izquierdo)
    if (activeDecors.contains(SanctuaryDecorItem.magicMushrooms)) {
      final mx = centerX - 84.0;
      final my = size.height * 0.87;

      final stalkPaint = Paint()
        ..color = const Color(0xFFE0E0E0)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(mx, my), Offset(mx, my - 12), stalkPaint);
      canvas.drawLine(Offset(mx - 8, my + 1), Offset(mx - 7, my - 8), stalkPaint);
      canvas.drawLine(Offset(mx + 8, my + 2), Offset(mx + 7, my - 10), stalkPaint);

      // Resplandor turquesa
      final glowPaint = Paint()
        ..color = const Color(0xFF80DEEA).withValues(alpha: 0.45 + sin(animationValue * 2 * pi) * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(mx, my - 14), 10, glowPaint);

      // Sombreros turquesa / aguamarina
      final capPaint = Paint()..color = const Color(0xFF26C6DA);
      canvas.drawArc(Rect.fromCenter(center: Offset(mx, my - 13), width: 16, height: 13), pi, pi, true, capPaint);
      canvas.drawArc(Rect.fromCenter(center: Offset(mx - 7, my - 9), width: 11, height: 9), pi, pi, true, Paint()..color = const Color(0xFF4DD0E1));
      canvas.drawArc(Rect.fromCenter(center: Offset(mx + 7, my - 11), width: 12, height: 10), pi, pi, true, Paint()..color = const Color(0xFF80CBC4));

      // Puntos bioluminiscentes
      canvas.drawCircle(Offset(mx - 3, my - 16), 1.0, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(mx + 2, my - 15), 1.0, Paint()..color = Colors.white);
    }

    // 12. Fuente de Caña Shishi-Odoshi (Detrás a la derecha)
    if (activeDecors.contains(SanctuaryDecorItem.waterFountain)) {
      final fx = centerX + 102.0;
      final fy = size.height * 0.82;

      // Cuenco de piedra en la base
      final basinPaint = Paint()..color = const Color(0xFF78909C);
      canvas.drawOval(Rect.fromCenter(center: Offset(fx, fy + 12), width: 36, height: 16), basinPaint);
      // Agua dentro del cuenco
      canvas.drawOval(Rect.fromCenter(center: Offset(fx, fy + 11), width: 28, height: 10), Paint()..color = const Color(0xFF80DEEA).withValues(alpha: 0.70));

      // Soporte de bambú vertical
      final postPaint = Paint()
        ..color = const Color(0xFF558B2F)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(fx - 8, fy + 12), Offset(fx - 8, fy - 14), postPaint);

      // Caña oscilante de bambú
      final tilt = sin(animationValue * 2 * pi * 0.6) * 4.0;
      final spoutPaint = Paint()
        ..color = const Color(0xFF689F38)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(fx - 14, fy - 10 - tilt * 0.4), Offset(fx + 6, fy - 6 + tilt), spoutPaint);

      // Gota cayendo
      final dropY = fy - 2 + ((animationValue * 3) % 1.0) * 12.0;
      canvas.drawCircle(Offset(fx + 6, dropY), 1.5, Paint()..color = const Color(0xFFB2EBF2));
    }
  }

  /// Dibuja los elementos en primer plano (frente a Lev, compañeros, fuego vivo, confort)
  void _drawActiveDecorationsForeground(Canvas canvas, Size size) {
    if (activeDecors.isEmpty) return;
    final centerX = size.width * 0.5;

    // 13. Cojín Zafu de Meditación (Suelo izquierdo frente a Lev)
    if (activeDecors.contains(SanctuaryDecorItem.meditationCushion)) {
      final cx = centerX - 66.0;
      final cy = size.height * 0.87;

      // Sombra del cojín
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 5), width: 38, height: 12), Paint()..color = Colors.black.withValues(alpha: 0.08)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      // Cuerpo del cojín acolchado
      final cushionRect = Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 18);
      final cushionPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA5D6A7), Color(0xFF81C784), Color(0xFF66BB6A)],
        ).createShader(cushionRect);
      canvas.drawOval(cushionRect, cushionPaint);

      // Pliegues y botón central de lino
      final foldPaint = Paint()
        ..color = const Color(0xFF388E3C).withValues(alpha: 0.35)
        ..strokeWidth = 1.0;
      for (int i = 0; i < 6; i++) {
        final angle = i * pi / 3;
        canvas.drawLine(Offset(cx, cy), Offset(cx + cos(angle) * 14, cy + sin(angle) * 6), foldPaint);
      }
      canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = const Color(0xFFFFF9C4));
    }

    // 14. Mesa de Té Matcha con Vapor Animado (Suelo derecho)
    if (activeDecors.contains(SanctuaryDecorItem.matchaTable)) {
      final tx = centerX + 66.0;
      final ty = size.height * 0.87;

      // Mesita de madera
      final tablePaint = Paint()..color = const Color(0xFF795548);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(tx, ty + 5), width: 42, height: 8), const Radius.circular(2)), tablePaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(tx - 15, ty + 11), width: 3.5, height: 7), tablePaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(tx + 15, ty + 11), width: 3.5, height: 7), tablePaint);

      // Cuenco de matcha (Chawan)
      final bowlPaint = Paint()..color = const Color(0xFF3E2723);
      canvas.drawOval(Rect.fromCenter(center: Offset(tx, ty - 2), width: 18, height: 11), bowlPaint);
      // Espuma de té matcha verde vivo
      final teaPaint = Paint()..color = const Color(0xFF4CAF50);
      canvas.drawOval(Rect.fromCenter(center: Offset(tx, ty - 3), width: 14, height: 7), teaPaint);

      // Volutas de vapor ondeantes a 60 FPS
      final steamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.50)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      for (int i = 0; i < 2; i++) {
        final sx = tx - 3.0 + (i * 6.0);
        final steamPath = Path()..moveTo(sx, ty - 8);
        final cycle = animationValue * 4 * pi + (i * pi);
        steamPath.cubicTo(
          sx + sin(cycle) * 3, ty - 16,
          sx - sin(cycle) * 3, ty - 24,
          sx + sin(cycle) * 2, ty - 32,
        );
        canvas.drawPath(steamPath, steamPaint);
      }
    }

    // 15. Vela Aromática con Llama Viva (Frente izquierda)
    if (activeDecors.contains(SanctuaryDecorItem.aromaCandle)) {
      final cx = centerX - 42.0;
      final cy = size.height * 0.90;

      // Vaso de cristal con cera lavanda
      final glassPaint = Paint()..color = const Color(0xFFD1C4E9).withValues(alpha: 0.85);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 3), width: 14, height: 14), const Radius.circular(2)), glassPaint);

      // Mecha
      canvas.drawLine(Offset(cx, cy - 4), Offset(cx, cy - 7), Paint()..color = const Color(0xFF3E2723)..strokeWidth = 1.0);

      // Llama animada oscilante
      final flameFlicker = sin(animationValue * 8 * pi) * 1.0;
      final flamePath = Path()
        ..moveTo(cx, cy - 7)
        ..quadraticBezierTo(cx + 2.5 + flameFlicker, cy - 11, cx + flameFlicker * 0.5, cy - 16)
        ..quadraticBezierTo(cx - 2.5 + flameFlicker, cy - 11, cx, cy - 7)
        ..close();

      // Resplandor cálido
      final flameGlow = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(cx, cy - 11), 8, flameGlow);

      // Núcleo de la llama
      canvas.drawPath(flamePath, Paint()..color = const Color(0xFFFFB74D));
      canvas.drawCircle(Offset(cx, cy - 9), 1.6, Paint()..color = const Color(0xFFFFF9C4));
    }

    // 16. Lámpara de Sal del Himalaya (Frente derecha)
    if (activeDecors.contains(SanctuaryDecorItem.saltLamp)) {
      final lx = centerX + 42.0;
      final ly = size.height * 0.90;

      // Resplandor rosa/ámbar
      final saltGlow = Paint()
        ..color = const Color(0xFFFFAB91).withValues(alpha: 0.40 + sin(animationValue * 2 * pi) * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(lx, ly), 16, saltGlow);

      // Base de madera oscura
      canvas.drawOval(Rect.fromCenter(center: Offset(lx, ly + 8), width: 22, height: 6), Paint()..color = const Color(0xFF4E342E));

      // Cristal facetado de sal
      final crystalPath = Path()
        ..moveTo(lx - 8, ly + 7)
        ..lineTo(lx - 9, ly - 3)
        ..lineTo(lx - 4, ly - 12)
        ..lineTo(lx + 5, ly - 13)
        ..lineTo(lx + 8, ly - 4)
        ..lineTo(lx + 7, ly + 7)
        ..close();

      final crystalPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFCCBC), Color(0xFFFF8A65), Color(0xFFD84315)],
        ).createShader(Rect.fromCenter(center: Offset(lx, ly), width: 18, height: 22));
      canvas.drawPath(crystalPath, crystalPaint);
    }

    // 17. Gatito Curvado en Siesta (Suelo derecho junto a Lev)
    if (activeDecors.contains(SanctuaryDecorItem.cozyCat)) {
      final kx = centerX + 88.0;
      final ky = size.height * 0.89;

      // Respiración rítmica sutil (lomo sube y baja 1.2px)
      final breath = sin(animationValue * 2 * pi * 0.5) * 1.2;

      // Sombra
      canvas.drawOval(Rect.fromCenter(center: Offset(kx, ky + 7), width: 28, height: 9), Paint()..color = Colors.black.withValues(alpha: 0.07)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      // Cuerpo acurrucado (bolita de pelo jengibre)
      final catPaint = Paint()..color = const Color(0xFFFFB74D);
      canvas.drawOval(Rect.fromCenter(center: Offset(kx, ky + breath * 0.5), width: 24, height: 16 + breath), catPaint);

      // Cabeza
      canvas.drawCircle(Offset(kx - 7, ky + 2), 6.5, catPaint);

      // Orejitas
      final earPaint = Paint()..color = const Color(0xFFFF8A65);
      final ear1 = Path()..moveTo(kx - 11, ky - 2)..lineTo(kx - 9, ky - 8)..lineTo(kx - 6, ky - 3)..close();
      final ear2 = Path()..moveTo(kx - 6, ky - 3)..lineTo(kx - 3, ky - 8)..lineTo(kx - 2, ky - 2)..close();
      canvas.drawPath(ear1, earPaint);
      canvas.drawPath(ear2, earPaint);

      // Cola curvada envolviendo el cuerpo
      final tailPaint = Paint()
        ..color = const Color(0xFFFFA726)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCenter(center: Offset(kx + 8, ky + 2), width: 12, height: 12), -pi * 0.2, pi * 1.1, false, tailPaint);

      // Micro "Zzz"
      final zAlpha = ((sin(animationValue * 2 * pi * 0.7) + 1.0) * 0.45).clamp(0.1, 0.9);
      final zPaint = Paint()..color = LevTheme.levMatchaDark.withValues(alpha: zAlpha);
      canvas.drawCircle(Offset(kx - 14, ky - 10), 1.2, zPaint);
      canvas.drawCircle(Offset(kx - 18, ky - 14), 1.6, zPaint);
    }

    // 18. Mariposa de Cristal (Aleteando cerca de las flores)
    if (activeDecors.contains(SanctuaryDecorItem.spiritButterfly)) {
      final flap = (cos(animationValue * 8 * pi)).abs(); // Aleteo a 60 FPS
      final bx = centerX + 110.0 + sin(animationValue * 2 * pi) * 6.0;
      final by = size.height * 0.68 + cos(animationValue * 2 * pi) * 4.0;

      // Halo de luz suave
      final glowPaint = Paint()
        ..color = const Color(0xFF80E8CB).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(bx, by), 8, glowPaint);

      // Alas esmeralda translúcidas moduladas por el aleteo
      final wingPaint = Paint()..color = const Color(0xFF64FFDA).withValues(alpha: 0.75);
      final wingW = 7.0 * flap.clamp(0.2, 1.0);

      // Ala izquierda y derecha
      canvas.drawOval(Rect.fromCenter(center: Offset(bx - wingW * 0.8, by - 3), width: wingW, height: 9), wingPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(bx + wingW * 0.8, by - 3), width: wingW, height: 9), wingPaint);

      // Cuerpo fino
      canvas.drawLine(Offset(bx, by - 6), Offset(bx, by + 4), Paint()..color = const Color(0xFF004D40)..strokeWidth = 1.0);
    }

    // 19. Enjambre de Luciérnagas (Revoloteando por todo el santuario)
    if (activeDecors.contains(SanctuaryDecorItem.fireflies)) {
      final glowPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      final corePaint = Paint()..color = const Color(0xFFFFFF8D);

      const fireflySeeds = [
        [0.18, 0.45, 0.8, 48.0],
        [0.82, 0.52, 1.1, 56.0],
        [0.32, 0.68, 0.9, 64.0],
        [0.70, 0.72, 1.3, 52.0],
        [0.48, 0.38, 0.7, 70.0],
        [0.22, 0.78, 1.2, 44.0],
        [0.78, 0.34, 0.85, 60.0],
      ];

      for (int i = 0; i < fireflySeeds.length; i++) {
        final seed = fireflySeeds[i];
        final speed = seed[2];
        final radius = seed[3];
        final fx = size.width * seed[0] + sin(animationValue * 2 * pi * speed + i) * radius * 0.35;
        final fy = size.height * seed[1] + cos(animationValue * 2 * pi * speed * 1.2 + i * 1.5) * radius * 0.25;

        final pulse = (sin(animationValue * 4 * pi * speed + i * 2.0) + 1.0) * 0.5;
        glowPaint.color = const Color(0xFFC6FF00).withValues(alpha: 0.25 + pulse * 0.45);

        canvas.drawCircle(Offset(fx, fy), 4.5 + pulse * 2.5, glowPaint);
        canvas.drawCircle(Offset(fx, fy), 1.4, corePaint);
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
