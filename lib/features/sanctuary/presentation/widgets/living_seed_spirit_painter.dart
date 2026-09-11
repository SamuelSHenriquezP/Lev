import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/sanctuary_state.dart';
import '../../../habits/domain/micro_habit.dart';

/// Pintor vectorial de alta precisión para "Lev: La Planta de Luz".
/// Reproducción botánica 1:1 con soporte integral para:
/// 1. Los 8 SPRITES / ETAPAS DE CRECIMIENTO (Semilla, Brote, Plántula, Planta Joven,
///    Planta Vibrante en Flor, Árbol Juvenil, Guardián Adulto, Espíritu del Bosque).
/// 2. TODAS LAS ANIMACIONES CON INICIOS Y FINALES NATURALES (anticipación, squash & stretch,
///    balanceo armónico a 60 FPS, seguimiento inercial, oscilación amortiguada y recuperación).
/// 3. Soporte para todas las emociones somáticas y acciones de microhábitos.
class LivingSeedSpiritPainter extends CustomPainter {
  final double animationValue; // 0.0 a 1.0 (tiempo armónico continuo a 60 FPS)
  final LevEmotion emotion;
  final bool isPetting;
  final double sizeScale;
  final LevTaskAction? taskAction;
  final LevGrowthStage growthStage;
  final double growthFactor; // 0.0 a 1.0 dentro de la etapa actual

  // Factores de transición suave (0.0 a 1.0 interpolados dinámicamente)
  final double? leafWrapProgress;   // Abrazo protector envuelto
  final double? sleepProgress;      // Siesta plácida con Zzz
  final double? happyProgress;      // Cosquillas / alegría
  final double? breathingProgress;  // Respiración somática guiada profunda
  final double jumpProgress;        // Salto elástico con anticipación, ápice y aterrizaje amortiguado
  final double? curiousProgress;    // Curiosidad: inclinación lúdica y oreja alzada
  final double? sadProgress;        // Tristeza somática: alas caídas y lágrima de rocío
  final double? anxiousProgress;    // Ansiedad somática: microtemblor y respiración superficial
  final double? tiredProgress;      // Cansancio: parpadeo pesado y cabeceo
  final double? celebrateProgress;  // Celebración: giro festivo y lluvia botánica

  LivingSeedSpiritPainter({
    required this.animationValue,
    required this.emotion,
    required this.isPetting,
    this.sizeScale = 1.0,
    this.taskAction,
    this.growthStage = LevGrowthStage.youngPlant,
    this.growthFactor = 0.0,
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
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.48;

    final t = animationValue;
    final cycle = t * 2 * pi;

    // --- EFECTIVIDAD DE EMOCIONES (Interpolación suave 0.0 -> 1.0 sin saltos bruscos) ---
    final effWrap = leafWrapProgress ?? (emotion == LevEmotion.sheltered ? 1.0 : 0.0);
    final effSleep = sleepProgress ?? (emotion == LevEmotion.sleeping ? 1.0 : 0.0);
    final effHappy = happyProgress ?? max(isPetting ? 1.0 : 0.0, (emotion == LevEmotion.happy ? 1.0 : 0.0));
    final effBreath = breathingProgress ?? (emotion == LevEmotion.breathing ? 1.0 : 0.0);
    final effCurious = curiousProgress ?? (emotion == LevEmotion.curious ? 1.0 : 0.0);
    final effSad = sadProgress ?? (emotion == LevEmotion.sad ? 1.0 : 0.0);
    final effAnxious = anxiousProgress ?? (emotion == LevEmotion.anxious ? 1.0 : 0.0);
    final effTired = tiredProgress ?? (emotion == LevEmotion.tired ? 1.0 : 0.0);
    final effCelebrate = celebrateProgress ?? (emotion == LevEmotion.celebrating ? 1.0 : 0.0);

    // --- 1. FÍSICA BASE CONTINUA A 60 FPS (LEV NUNCA ESTÁ ESTÁTICO) ---
    final breatheSpeedMultiplier = (effSleep > 0.5) ? 0.6 : (effAnxious > 0.5 ? 2.2 : 1.0);
    final breathCycle = t * 2 * pi * breatheSpeedMultiplier;

    final baseFloatY = sin(cycle) * 7.0;
    final baseBreatheY = sin(breathCycle) * 0.024;
    final baseBreatheX = -baseBreatheY * 0.55;
    final baseSway = sin(cycle) * 0.020;

    // --- 2. CAPAS DE INTERACCIÓN SOMÁTICA ---
    final deepBreatheY = sin(breathCycle) * 0.12 * effBreath;
    final deepBreatheX = -deepBreatheY * 0.55;

    final sleepSway = 0.055 * effSleep;
    final sleepFloat = 6.0 * effSleep;

    final happySway = sin(cycle * 3.2) * 0.08 * effHappy;
    final happyFloat = sin(cycle * 2.0) * 4.0 * effHappy;

    final curiousSway = (0.12 + sin(cycle * 1.5) * 0.04) * effCurious;
    final curiousFloat = -3.0 * effCurious;

    final sadFloat = 8.0 * effSad;
    final sadSway = -0.04 * effSad;

    final anxiousShakeX = sin(cycle * 24.0) * 1.6 * effAnxious;
    final anxiousShakeY = cos(cycle * 28.0) * 1.2 * effAnxious;

    final tiredFloat = (4.0 + sin(cycle * 0.8) * 3.5) * effTired;

    final celebrateSway = sin(cycle * 2.8) * 0.10 * effCelebrate;
    final celebrateFloat = -sin(cycle * 2.8).abs() * 8.0 * effCelebrate;

    // --- 3. CAPA DE SALTO ELÁSTICO DE ALEGRÍA (JOY JUMP FÍSICO COMPLETO) ---
    double jumpFloatY = 0.0;
    double jumpScaleY = 0.0;
    double jumpScaleX = 0.0;
    double jumpSway = 0.0;

    if (jumpProgress > 0.0 && jumpProgress <= 1.0) {
      if (jumpProgress < 0.20) {
        final p = jumpProgress / 0.20;
        final curve = Curves.easeInOutQuad.transform(p);
        jumpScaleY = -0.16 * sin(curve * pi);
        jumpScaleX = 0.12 * sin(curve * pi);
        jumpFloatY = 9.0 * sin(curve * pi);
      } else if (jumpProgress < 0.58) {
        final p = (jumpProgress - 0.20) / 0.38;
        final curve = Curves.easeOutQuad.transform(p);
        jumpFloatY = -52.0 * sin(curve * pi * 0.5);
        jumpScaleY = 0.18 * (1.0 - curve);
        jumpScaleX = -0.10 * (1.0 - curve);
        jumpSway = sin(curve * pi) * 0.08;
      } else if (jumpProgress < 0.75) {
        final p = (jumpProgress - 0.58) / 0.17;
        jumpFloatY = -52.0 + (p * 8.0);
        jumpSway = cos(p * pi) * 0.08;
      } else {
        final p = (jumpProgress - 0.75) / 0.25;
        final bounce = sin(p * pi * 2.8) * exp(-p * 3.8);
        jumpScaleY = -0.12 * bounce;
        jumpScaleX = 0.08 * bounce;
        jumpFloatY = -bounce * 8.0;
      }
    }

    // --- 4. ACCIONES SOMÁTICAS DE TAREAS ESPECÍFICAS ---
    double taskFloatY = 0.0;
    double taskSway = 0.0;
    double taskScaleX = 0.0;
    double taskScaleY = 0.0;
    double taskShakeX = 0.0;
    double taskShakeY = 0.0;

    if (taskAction != null) {
      switch (taskAction!) {
        case LevTaskAction.breathing:
          final bCycle = sin(cycle);
          taskScaleY = bCycle * 0.14;
          taskScaleX = -bCycle * 0.06;
          break;
        case LevTaskAction.eyeRest:
          taskFloatY = sin(cycle * 0.8) * 3.0;
          break;
        case LevTaskAction.chestStretch:
          taskSway = sin(cycle * 0.7) * 0.12;
          taskScaleY = sin(cycle * 0.7) * 0.08;
          break;
        case LevTaskAction.soothingTouch:
          final heartPulse = sin(cycle * 2.0);
          taskScaleY = heartPulse * 0.04;
          break;
        case LevTaskAction.coldSplash:
          taskShakeX = sin(cycle * 8.0) * 1.5;
          break;
        case LevTaskAction.tensionShake:
          taskShakeX = sin(cycle * 15.0) * 3.2;
          taskShakeY = cos(cycle * 18.0) * 1.8;
          break;
        case LevTaskAction.sleepDrift:
          taskFloatY = 5.0;
          taskSway = 0.05;
          break;
        case LevTaskAction.grounding:
          taskFloatY = -baseFloatY * 0.65;
          break;
        case LevTaskAction.warmTeaHold:
          taskFloatY = sin(cycle) * 4.0;
          break;
      }
    }

    final stageScaleMultiplier = _getStageScaleMultiplier(growthStage);

    final finalFloatY = baseFloatY + sleepFloat + happyFloat + curiousFloat +
        sadFloat + tiredFloat + celebrateFloat + jumpFloatY + taskFloatY + taskShakeY;
    final finalSway = baseSway + sleepSway + happySway + curiousSway + sadSway +
        celebrateSway + jumpSway + taskSway;
    final finalScaleY = 1.0 + baseBreatheY + deepBreatheY + jumpScaleY + taskScaleY;
    final finalScaleX = 1.0 + baseBreatheX + deepBreatheX + jumpScaleX + taskScaleX;

    canvas.save();
    canvas.translate(centerX + anxiousShakeX + taskShakeX, centerY + finalFloatY + anxiousShakeY);
    canvas.rotate(finalSway);
    canvas.scale(sizeScale * stageScaleMultiplier * finalScaleX, sizeScale * stageScaleMultiplier * finalScaleY);

    // 0. Elementos traseros de etapa suprema (Orbes orbitales que pasan por detrás)
    if (growthStage == LevGrowthStage.forestSpirit) {
      _drawForestSpiritOrbs(canvas, t, inFront: false);
    }

    // 1. Resplandor áurico ambiental adaptativo
    _drawAmbientAura(canvas, t, effSleep, effBreath, effAnxious, effCelebrate);

    // 2. Alas suculentas / Follaje según la etapa de crecimiento
    _drawGrowthFoliage(canvas, t, effWrap, effSleep, effHappy, effSad, effCurious);

    // 3. Tallo / Base Inferior
    _drawStemBase(canvas);

    // 4. Bulbo de Semilla / Cuerpo de Llama
    _drawFlameBulb(canvas, t, effBreath, effAnxious);

    // 5. Cáliz Frontal / Sépalos de protección
    _drawFrontCalyx(canvas, t);

    // 6. Rostro de Lev con transición fluida entre expresiones
    _drawZenFace(canvas, t, effSleep, effHappy, effSad, effCurious, effTired, effAnxious);

    // 7. Detalles botánicos ornamentales según etapa (Flores, Corona, Tercer Ojo)
    _drawStageOrnaments(canvas, t, effCelebrate);

    // 8. Efectos y partículas emocionales
    if (effSleep > 0.05) {
      _drawSleepingZzz(canvas, t, effSleep);
    }
    if (effHappy > 0.05 || isPetting) {
      _drawMagicSpores(canvas, t, max(effHappy, isPetting ? 1.0 : 0.0));
    }
    if (effSad > 0.05) {
      _drawDewdropTear(canvas, t, effSad);
    }
    if (effCelebrate > 0.05) {
      _drawCelebrationConfetti(canvas, t, effCelebrate);
    }
    if (jumpProgress > 0.20 && jumpProgress < 0.85) {
      _drawJoySparks(canvas, jumpProgress);
    }

    // 9. Elementos frontales de etapa suprema (Orbes que pasan por delante)
    if (growthStage == LevGrowthStage.forestSpirit) {
      _drawForestSpiritOrbs(canvas, t, inFront: true);
    }

    // 10. Efectos somáticos específicos de tarea
    if (taskAction != null) {
      _drawTaskEffects(canvas, t);
    }

    canvas.restore();
  }

  double _getStageScaleMultiplier(LevGrowthStage stage) {
    switch (stage) {
      case LevGrowthStage.seed:
        return 0.78;
      case LevGrowthStage.sprout:
        return 0.86;
      case LevGrowthStage.seedling:
        return 0.94;
      case LevGrowthStage.youngPlant:
        return 1.00;
      case LevGrowthStage.vibrantPlant:
        return 1.06;
      case LevGrowthStage.youngTree:
        return 1.14;
      case LevGrowthStage.adultTree:
        return 1.20;
      case LevGrowthStage.forestSpirit:
        return 1.28;
    }
  }

  void _drawAmbientAura(
    Canvas canvas,
    double t,
    double effSleep,
    double effBreath,
    double effAnxious,
    double effCelebrate,
  ) {
    var baseAlpha = 0.32;
    var baseRadius = 170.0;
    Color auraColor = const Color(0xFFFFE899);

    switch (growthStage) {
      case LevGrowthStage.seed:
        baseRadius = 140.0;
        baseAlpha = 0.28;
        auraColor = const Color(0xFFFFDF7A);
        break;
      case LevGrowthStage.sprout:
      case LevGrowthStage.seedling:
        baseRadius = 155.0;
        baseAlpha = 0.30;
        break;
      case LevGrowthStage.youngPlant:
        baseRadius = 170.0;
        baseAlpha = 0.32;
        break;
      case LevGrowthStage.vibrantPlant:
        baseRadius = 185.0;
        baseAlpha = 0.36;
        auraColor = const Color(0xFFFFEEB3);
        break;
      case LevGrowthStage.youngTree:
      case LevGrowthStage.adultTree:
        baseRadius = 205.0;
        baseAlpha = 0.40;
        auraColor = const Color(0xFFD4F7DC);
        break;
      case LevGrowthStage.forestSpirit:
        baseRadius = 230.0;
        baseAlpha = 0.46;
        auraColor = const Color(0xFFE8F5E9);
        break;
    }

    final sleepAlphaMod = lerpDouble(0.0, -0.16, effSleep)!;
    final breathingPulse = (sin(t * 2 * pi) + 1.0) * 0.5 * 0.28 * effBreath;
    final celebratePulse = (sin(t * 4 * pi) + 1.0) * 0.5 * 0.15 * effCelebrate;
    final finalAlpha = (baseAlpha + sleepAlphaMod + breathingPulse + celebratePulse).clamp(0.10, 0.70);

    final breathingRadiusMod = (sin(t * 2 * pi) + 1.0) * 0.5 * 45.0 * effBreath;
    final sleepRadiusMod = lerpDouble(0.0, -35.0, effSleep)!;
    final finalRadius = baseRadius + breathingRadiusMod + sleepRadiusMod;

    final auraPaint = Paint()
      ..color = auraColor.withValues(alpha: finalAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -20), width: finalRadius, height: finalRadius * 1.25),
      auraPaint,
    );

    if (growthStage == LevGrowthStage.adultTree || growthStage == LevGrowthStage.forestSpirit) {
      final divineGlow = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.18 + sin(t * 2 * pi) * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 65);
      canvas.drawCircle(const Offset(0, -26), finalRadius * 0.75, divineGlow);
    }
  }

  void _drawGrowthFoliage(
    Canvas canvas,
    double t,
    double effWrap,
    double effSleep,
    double effHappy,
    double effSad,
    double effCurious,
  ) {
    final cycle = t * 2 * pi;
    final baseFlutter = sin(cycle + 0.5) * 0.022;
    final happyFlutter = sin(cycle * 3.2) * 0.08 * effHappy;

    var leftAngle = -0.36 + baseFlutter + happyFlutter;
    var rightAngle = 0.36 - baseFlutter - happyFlutter;

    leftAngle += -0.14 * effCurious;
    rightAngle += 0.28 * effCurious;

    leftAngle = lerpDouble(leftAngle, -0.18, effSad)!;
    rightAngle = lerpDouble(rightAngle, 0.18, effSad)!;

    leftAngle = lerpDouble(leftAngle, -0.82, effWrap)!;
    rightAngle = lerpDouble(rightAngle, 0.82, effWrap)!;

    if (effWrap < 0.5) {
      leftAngle = lerpDouble(leftAngle, -0.22, effSleep)!;
      rightAngle = lerpDouble(rightAngle, 0.22, effSleep)!;
    }

    if (taskAction != null) {
      switch (taskAction!) {
        case LevTaskAction.chestStretch:
          leftAngle = -0.62 + sin(cycle * 0.7) * 0.08;
          rightAngle = 0.62 - sin(cycle * 0.7) * 0.08;
          break;
        case LevTaskAction.soothingTouch:
          leftAngle = -0.84 + sin(cycle * 2.0) * 0.03;
          rightAngle = 0.84 - sin(cycle * 2.0) * 0.03;
          break;
        case LevTaskAction.eyeRest:
          leftAngle = -0.76;
          rightAngle = 0.76;
          break;
        case LevTaskAction.warmTeaHold:
          leftAngle = -0.58;
          rightAngle = 0.58;
          break;
        default:
          break;
      }
    }

    switch (growthStage) {
      case LevGrowthStage.seed:
        _drawSeedCotyledons(canvas, cycle, effHappy);
        break;

      case LevGrowthStage.sprout:
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(54, 28), 0.0);
        break;

      case LevGrowthStage.seedling:
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(78, 36), 0.0);
        break;

      case LevGrowthStage.youngPlant:
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(100, 44), 0.0);
        break;

      case LevGrowthStage.vibrantPlant:
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(104, 45), 0.0);
        _drawWingtipBlossoms(canvas, leftAngle, rightAngle, 104.0);
        break;

      case LevGrowthStage.youngTree:
        final upperLeft = leftAngle * 0.72 - 0.20 + sin(cycle * 1.4) * 0.04;
        final upperRight = rightAngle * 0.72 + 0.20 - sin(cycle * 1.4) * 0.04;
        _drawSucculentPair(canvas, upperLeft, upperRight, const Size(70, 32), -26.0, hasVeins: true);
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(110, 46), 0.0, hasVeins: true);
        break;

      case LevGrowthStage.adultTree:
        final upperLeft = leftAngle * 0.75 - 0.24 + sin(cycle * 1.5) * 0.05;
        final upperRight = rightAngle * 0.75 + 0.24 - sin(cycle * 1.5) * 0.05;
        _drawSucculentPair(canvas, upperLeft, upperRight, const Size(82, 36), -30.0, hasVeins: true);
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(116, 48), 0.0, hasVeins: true);
        break;

      case LevGrowthStage.forestSpirit:
        final upperLeft = -0.68 + sin(cycle * 1.6) * 0.05;
        final upperRight = 0.68 - sin(cycle * 1.6) * 0.05;
        final lowerLeft = -0.22 + sin(cycle * 1.2) * 0.03;
        final lowerRight = 0.22 - sin(cycle * 1.2) * 0.03;

        _drawSucculentPair(canvas, upperLeft, upperRight, const Size(90, 38), -44.0, hasVeins: true, celestialGlow: true);
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(122, 50), 0.0, hasVeins: true, celestialGlow: true);
        _drawSucculentPair(canvas, lowerLeft, lowerRight, const Size(68, 30), 38.0, hasVeins: true, celestialGlow: true);
        break;
    }
  }

  void _drawSeedCotyledons(Canvas canvas, double cycle, double effHappy) {
    final wiggle = sin(cycle * 2.5) * 0.08 + (effHappy * sin(cycle * 5.0) * 0.14);
    final budPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF388E6E), Color(0xFF80E2BF)],
      ).createShader(const Rect.fromLTWH(-30, 20, 60, 30));

    canvas.save();
    canvas.translate(-38, 28);
    canvas.rotate(-0.35 + wiggle);
    canvas.drawOval(const Rect.fromLTWH(-18, -9, 20, 14), budPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(38, 28);
    canvas.rotate(0.35 - wiggle);
    canvas.drawOval(const Rect.fromLTWH(-2, -9, 20, 14), budPaint);
    canvas.restore();
  }

  void _drawSucculentPair(
    Canvas canvas,
    double leftAngle,
    double rightAngle,
    Size leafSize,
    double yOffset, {
    bool hasVeins = false,
    bool celestialGlow = false,
  }) {
    canvas.save();
    canvas.translate(-8, 54 + yOffset);
    canvas.rotate(leftAngle);
    _drawSingleSucculentLeaf(
      canvas,
      leafSize,
      const Color(0xFF287A60),
      const Color(0xFF45A586),
      isLeft: true,
      hasVeins: hasVeins,
      celestialGlow: celestialGlow,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(8, 54 + yOffset);
    canvas.rotate(rightAngle);
    _drawSingleSucculentLeaf(
      canvas,
      leafSize,
      const Color(0xFF287A60),
      const Color(0xFF45A586),
      isLeft: false,
      hasVeins: hasVeins,
      celestialGlow: celestialGlow,
    );
    canvas.restore();
  }

  void _drawSingleSucculentLeaf(
    Canvas canvas,
    Size size,
    Color baseColor,
    Color tipColor, {
    required bool isLeft,
    bool hasVeins = false,
    bool celestialGlow = false,
  }) {
    final path = Path();
    final sign = isLeft ? -1.0 : 1.0;
    final w = size.width * sign;
    final h = size.height;

    path.moveTo(0, 0);
    path.cubicTo(
      w * 0.30, -h * 0.60,
      w * 0.85, -h * 0.35,
      w, 0,
    );
    path.cubicTo(
      w * 0.85, h * 0.45,
      w * 0.30, h * 0.30,
      0, 0,
    );
    path.close();

    final leafRect = Rect.fromCenter(
      center: Offset(w * 0.5, 0),
      width: size.width,
      height: size.height,
    );

    final leafPaint = Paint()
      ..shader = LinearGradient(
        begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        colors: [baseColor, tipColor],
      ).createShader(leafRect);

    canvas.drawPath(path, leafPaint);

    if (celestialGlow) {
      final glowPaint = Paint()
        ..color = const Color(0xFF80E2BF).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glowPaint);
    }

    final highlightPaint = Paint()
      ..color = const Color(0xFF74CEB2).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, highlightPaint);

    if (hasVeins) {
      final veinPaint = Paint()
        ..color = const Color(0xFFD4F7DC).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.4;

      final veinPath = Path();
      veinPath.moveTo(0, 0);
      veinPath.quadraticBezierTo(w * 0.45, -h * 0.15, w * 0.88, -h * 0.05);

      veinPath.moveTo(w * 0.35, -h * 0.12);
      veinPath.quadraticBezierTo(w * 0.50, -h * 0.35, w * 0.65, -h * 0.30);

      veinPath.moveTo(w * 0.55, -h * 0.10);
      veinPath.quadraticBezierTo(w * 0.70, h * 0.15, w * 0.80, h * 0.18);

      canvas.drawPath(veinPath, veinPaint);
    }
  }

  void _drawWingtipBlossoms(Canvas canvas, double leftAngle, double rightAngle, double wingLength) {
    canvas.save();
    canvas.translate(-8, 54);
    canvas.rotate(leftAngle);
    canvas.translate(-wingLength, 0);
    _drawMiniBlossom(canvas);
    canvas.restore();

    canvas.save();
    canvas.translate(8, 54);
    canvas.rotate(rightAngle);
    canvas.translate(wingLength, 0);
    _drawMiniBlossom(canvas);
    canvas.restore();
  }

  void _drawMiniBlossom(Canvas canvas) {
    final petalPaint = Paint()..color = const Color(0xFFFFB4C8).withValues(alpha: 0.90);
    final centerPaint = Paint()..color = const Color(0xFFFFE082);

    for (int i = 0; i < 5; i++) {
      final angle = i * (2 * pi / 5);
      final px = cos(angle) * 7.0;
      final py = sin(angle) * 7.0;
      canvas.drawCircle(Offset(px, py), 4.2, petalPaint);
    }
    canvas.drawCircle(Offset.zero, 3.5, centerPaint);
  }

  void _drawStemBase(Canvas canvas) {
    if (growthStage == LevGrowthStage.seed) {
      final seedStemPaint = Paint()
        ..color = const Color(0xFF4A7D6B).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawOval(const Rect.fromLTWH(-12, 48, 24, 12), seedStemPaint);
      return;
    }

    final path = Path();
    path.moveTo(-10, 52);
    path.cubicTo(-14, 75, -6, 92, 0, 98);
    path.cubicTo(6, 92, 14, 75, 10, 52);
    path.close();

    final stemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF226E56), Color(0xFF144B3A)],
      ).createShader(const Rect.fromLTWH(-15, 50, 30, 50));

    canvas.drawPath(path, stemPaint);
  }

  void _drawFlameBulb(Canvas canvas, double t, double effBreath, double effAnxious) {
    final bulbPath = Path();

    if (growthStage == LevGrowthStage.seed) {
      final rect = const Rect.fromLTWH(-48, -70, 96, 124);
      bulbPath.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(46)));

      final seedShader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.50, 1.0],
        colors: [
          Color(0xFFFFF3A1),
          Color(0xFFF9B73F),
          Color(0xFFC88126),
        ],
      ).createShader(rect);

      canvas.drawPath(bulbPath, Paint()..shader = seedShader);
      return;
    }

    const apex = Offset(8.0, -96.0);
    bulbPath.moveTo(apex.dx, apex.dy);
    bulbPath.cubicTo(18.0, -70.0, 56.0, -25.0, 56.0, 15.0);
    bulbPath.cubicTo(56.0, 42.0, 28.0, 58.0, 0.0, 64.0);
    bulbPath.cubicTo(-28.0, 58.0, -56.0, 42.0, -56.0, 15.0);
    bulbPath.cubicTo(-56.0, -25.0, -22.0, -70.0, apex.dx, apex.dy);
    bulbPath.close();

    final bulbRect = const Rect.fromLTWH(-60, -100, 120, 170);

    List<Color> bulbColors = [
      const Color(0xFFFFCF43),
      const Color(0xFFFFEEA8),
      const Color(0xFF76CBAE),
      const Color(0xFF287B61),
    ];

    if (growthStage == LevGrowthStage.forestSpirit) {
      bulbColors = [
        const Color(0xFFFFF9C4),
        const Color(0xFFFFE082),
        const Color(0xFF80E2BF),
        const Color(0xFF1B5E49),
      ];
    }

    final bulbShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.42, 0.68, 1.0],
      colors: bulbColors,
    ).createShader(bulbRect);

    canvas.drawPath(bulbPath, Paint()..shader = bulbShader);

    final breathingGlow = (sin(t * 2 * pi) + 1.0) * 0.5 * 0.35 * effBreath;
    final finalFaceGlowAlpha = (0.45 + breathingGlow).clamp(0.20, 0.85);

    final faceGlowPaint = Paint()
      ..color = const Color(0xFFFFFBE8).withValues(alpha: finalFaceGlowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(const Offset(0, -6), 34, faceGlowPaint);
  }

  void _drawFrontCalyx(Canvas canvas, double t) {
    if (growthStage == LevGrowthStage.seed) return;

    final sepalColor = const Color(0xFF86D5BC);
    final sepalShade = const Color(0xFF4FA98E);

    final leftSepal = Path();
    leftSepal.moveTo(0, 68);
    leftSepal.cubicTo(-10, 62, -22, 48, -20, 32);
    leftSepal.cubicTo(-14, 40, -6, 55, 0, 68);
    leftSepal.close();

    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [sepalShade, sepalColor],
      ).createShader(const Rect.fromLTWH(-25, 30, 25, 40));
    canvas.drawPath(leftSepal, leftPaint);

    final rightSepal = Path();
    rightSepal.moveTo(0, 68);
    rightSepal.cubicTo(10, 62, 22, 48, 20, 32);
    rightSepal.cubicTo(14, 40, 6, 55, 0, 68);
    rightSepal.close();

    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [sepalShade, sepalColor],
      ).createShader(const Rect.fromLTWH(0, 30, 25, 40));
    canvas.drawPath(rightSepal, rightPaint);

    if (growthStage == LevGrowthStage.adultTree || growthStage == LevGrowthStage.forestSpirit) {
      final centerSepal = Path();
      centerSepal.moveTo(0, 72);
      centerSepal.cubicTo(-8, 56, 0, 42, 0, 38);
      centerSepal.cubicTo(0, 42, 8, 56, 0, 72);
      centerSepal.close();

      final centerPaint = Paint()
        ..color = const Color(0xFF70C5A9).withValues(alpha: 0.85);
      canvas.drawPath(centerSepal, centerPaint);
    }
  }

  void _drawZenFace(
    Canvas canvas,
    double t,
    double effSleep,
    double effHappy,
    double effSad,
    double effCurious,
    double effTired,
    double effAnxious,
  ) {
    const eyeY = -4.0;
    const eyeDist = 19.0;

    final isBlinking = (effSleep < 0.3 && t > 0.50 && t < 0.54) || (effTired > 0.5 && t > 0.46 && t < 0.58);

    final featurePaint = Paint()
      ..color = const Color(0xFF0E382B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round;

    if (isBlinking) {
      canvas.drawLine(Offset(-eyeDist - 5, eyeY), Offset(-eyeDist + 5, eyeY), featurePaint);
      canvas.drawLine(Offset(eyeDist - 5, eyeY), Offset(eyeDist + 5, eyeY), featurePaint);
    } else if (effCurious > 0.5) {
      _drawCuriousEye(canvas, Offset(-eyeDist, eyeY), 13.0, featurePaint);
      _drawCuriousEye(canvas, Offset(eyeDist, eyeY), 13.0, featurePaint);
    } else {
      _drawDynamicEye(canvas, Offset(-eyeDist, eyeY), 14.0, featurePaint, effHappy, effSleep, effSad, effTired);
      _drawDynamicEye(canvas, Offset(eyeDist, eyeY), 14.0, featurePaint, effHappy, effSleep, effSad, effTired);
    }

    final mouthY = 13.0;
    var mouthDepth = lerpDouble(7.0, 3.5, effSleep)!;
    var mouthWidth = lerpDouble(7.5, 5.5, effSleep)!;

    if (effSad > 0.3) {
      mouthDepth = -3.5 * effSad;
    } else if (effHappy > 0.3) {
      mouthDepth = 9.5;
      mouthWidth = 9.0;
    }

    final mouthPaint = Paint()
      ..color = const Color(0xFF0E382B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(-mouthWidth, mouthY);
    mouthPath.quadraticBezierTo(0, mouthY + mouthDepth, mouthWidth, mouthY);
    canvas.drawPath(mouthPath, mouthPaint);

    final cheekAlpha = lerpDouble(0.14, 0.34, max(effHappy, isPetting ? 1.0 : 0.0))!;
    final cheekPaint = Paint()
      ..color = const Color(0xFFFFAE52).withValues(alpha: cheekAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(Rect.fromCenter(center: const Offset(-28, 6), width: 16, height: 10), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(28, 6), width: 16, height: 10), cheekPaint);
  }

  void _drawDynamicEye(
    Canvas canvas,
    Offset center,
    double width,
    Paint paint,
    double effHappy,
    double effSleep,
    double effSad,
    double effTired,
  ) {
    final happyWeight = max(effHappy, isPetting ? 1.0 : 0.0);
    var curve = lerpDouble(6.8, -6.5, happyWeight)!;
    curve = lerpDouble(curve, 4.2, effSleep)!;
    curve = lerpDouble(curve, 2.5, effSad)!;
    curve = lerpDouble(curve, 3.0, effTired)!;

    final path = Path();
    path.moveTo(center.dx - width * 0.5, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + curve, center.dx + width * 0.5, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawCuriousEye(Canvas canvas, Offset center, double radius, Paint borderPaint) {
    final pupilPaint = Paint()..color = const Color(0xFF0E382B);
    final highlightPaint = Paint()..color = Colors.white;

    canvas.drawCircle(center, 5.0, pupilPaint);
    canvas.drawCircle(Offset(center.dx - 1.8, center.dy - 1.8), 1.8, highlightPaint);
  }

  void _drawStageOrnaments(Canvas canvas, double t, double effCelebrate) {
    switch (growthStage) {
      case LevGrowthStage.seed:
        final nubPaint = Paint()..color = const Color(0xFF80E2BF);
        canvas.drawCircle(const Offset(0, -68), 5.5, nubPaint);
        break;

      case LevGrowthStage.youngTree:
        final gemPaint = Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(const Offset(8, -96), 4.5, gemPaint);
        break;

      case LevGrowthStage.adultTree:
        _drawFloralCirclet(canvas, t);
        break;

      case LevGrowthStage.forestSpirit:
        _drawDivineCrown(canvas, t);
        _drawSacredForeheadSpiral(canvas);
        break;

      default:
        break;
    }
  }

  void _drawFloralCirclet(Canvas canvas, double t) {
    final circletPaint = Paint()
      ..color = const Color(0xFF80E2BF).withValues(alpha: 0.75);
    for (int i = 0; i < 7; i++) {
      final angle = (i * (2 * pi / 7)) + (t * 0.5);
      final px = cos(angle) * 32.0;
      final py = -70.0 + sin(angle) * 8.0;
      canvas.drawCircle(Offset(px, py), 3.2, circletPaint);
    }
  }

  void _drawDivineCrown(Canvas canvas, double t) {
    final crestPath = Path();
    final crestPulse = sin(t * 2 * pi) * 3.0;

    crestPath.moveTo(0, -96);
    crestPath.quadraticBezierTo(-12, -120 - crestPulse, -18, -135 - crestPulse);
    crestPath.quadraticBezierTo(-8, -125, 0, -112);
    crestPath.quadraticBezierTo(8, -125, 18, -135 - crestPulse);
    crestPath.quadraticBezierTo(12, -120 - crestPulse, 0, -96);
    crestPath.close();

    final crestPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFFFD54F), Color(0xFFFFF9C4)],
      ).createShader(const Rect.fromLTWH(-20, -140, 40, 50));

    canvas.drawPath(crestPath, crestPaint);
  }

  void _drawSacredForeheadSpiral(Canvas canvas) {
    final spiralPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, -32);
    path.cubicTo(-4, -34, -4, -38, 0, -38);
    path.cubicTo(4, -38, 4, -32, 0, -30);
    canvas.drawPath(path, spiralPaint);
  }

  void _drawForestSpiritOrbs(Canvas canvas, double t, {required bool inFront}) {
    for (int i = 0; i < 3; i++) {
      final angle = (t * 2 * pi) + (i * (2 * pi / 3));
      final sinA = sin(angle);
      final cosA = cos(angle);

      final isFront = sinA >= 0;
      if (isFront != inFront) continue;

      final ox = cosA * 85.0;
      final oy = -20.0 + sinA * 26.0;
      final orbScale = 0.8 + (sinA + 1.0) * 0.25;

      final orbPaint = Paint()
        ..color = const Color(0xFF80E2BF).withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(ox, oy), 6.0 * orbScale, orbPaint);

      final corePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(ox, oy), 3.0 * orbScale, corePaint);
    }
  }

  void _drawDewdropTear(Canvas canvas, double t, double effSad) {
    final tearProgress = (t * 1.6) % 1.0;
    final tearY = -2.0 + (tearProgress * 22.0);
    final tearAlpha = sin(tearProgress * pi) * 0.85 * effSad;

    final tearPaint = Paint()
      ..color = const Color(0xFF80DEEA).withValues(alpha: tearAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(-19, tearY), width: 4.5, height: 6.5),
      tearPaint,
    );
  }

  void _drawCelebrationConfetti(Canvas canvas, double t, double effCelebrate) {
    final confettiColors = [
      const Color(0xFFFFD54F),
      const Color(0xFF80E2BF),
      const Color(0xFFFF8A80),
      const Color(0xFFB39DDB),
    ];

    for (int i = 0; i < 10; i++) {
      final phase = (t + (i * 0.10)) % 1.0;
      final px = sin(phase * 2 * pi + i * 2) * 80.0;
      final py = -110.0 + (phase * 190.0);
      final alpha = sin(phase * pi) * 0.9 * effCelebrate;

      final cPaint = Paint()
        ..color = confettiColors[i % confettiColors.length].withValues(alpha: alpha);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(phase * 4 * pi);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-3, -2, 6, 4), const Radius.circular(2)), cPaint);
      canvas.restore();
    }
  }

  void _drawSleepingZzz(Canvas canvas, double t, double opacity) {
    const letters = ['z', 'Z', 'z'];
    for (int i = 0; i < 3; i++) {
      final phase = (t + (i * 0.33)) % 1.0;
      final x = 30.0 + (i * 14.0) + (sin(phase * pi) * 12.0);
      final y = -35.0 - (phase * 80.0);
      final alpha = (sin(phase * pi) * 0.75 * opacity).clamp(0.0, 1.0);

      final textSpan = TextSpan(
        text: letters[i],
        style: TextStyle(
          color: const Color(0xFF4A7D6B).withValues(alpha: alpha),
          fontSize: 14.0 + (i * 4.0),
          fontWeight: FontWeight.bold,
          fontFamily: 'Quicksand',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  void _drawMagicSpores(Canvas canvas, double t, double opacity) {
    for (int i = 0; i < 6; i++) {
      final phase = (t + (i * 0.16)) % 1.0;
      final x = sin(phase * 2 * pi + i * 1.5) * 52.0;
      final y = -45.0 - (phase * 85.0);
      final alpha = ((1.0 - phase) * 0.85 * opacity).clamp(0.0, 1.0);

      final sporePaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), 3.5 + (1.0 - phase) * 2.5, sporePaint);
    }
  }

  void _drawJoySparks(Canvas canvas, double p) {
    for (int i = 0; i < 7; i++) {
      final angle = (i * (2 * pi / 7)) + (p * pi);
      final dist = 40.0 + (sin(p * pi) * 42.0);
      final x = cos(angle) * dist;
      final y = sin(angle) * dist - 24;

      final sparkPaint = Paint()
        ..color = const Color(0xFFFFCF43).withValues(alpha: sin(p * pi) * 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), 3.4, sparkPaint);
    }
  }

  void _drawTaskEffects(Canvas canvas, double t) {
    switch (taskAction!) {
      case LevTaskAction.eyeRest:
        _drawEyeRestGlow(canvas, t);
        break;
      case LevTaskAction.soothingTouch:
        _drawHeartCalmPulse(canvas, t);
        break;
      case LevTaskAction.coldSplash:
        _drawColdSplashDrops(canvas, t);
        break;
      case LevTaskAction.tensionShake:
        _drawTensionDischarge(canvas, t);
        break;
      case LevTaskAction.grounding:
        _drawGroundingRoots(canvas, t);
        break;
      case LevTaskAction.warmTeaHold:
        _drawWarmTeaSteam(canvas, t);
        break;
      case LevTaskAction.breathing:
        _drawBreathMist(canvas, t);
        break;
      case LevTaskAction.sleepDrift:
        _drawSleepingZzz(canvas, t, 1.0);
        break;
      case LevTaskAction.chestStretch:
        break;
    }
  }

  void _drawEyeRestGlow(Canvas canvas, double t) {
    final pulse = (sin(t * 2 * pi) + 1.0) * 0.5;
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35 + pulse * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(const Offset(-13, -28), 10 + pulse * 4, glowPaint);
    canvas.drawCircle(const Offset(13, -28), 10 + pulse * 4, glowPaint);
  }

  void _drawHeartCalmPulse(Canvas canvas, double t) {
    final pulse = (sin(t * 2 * pi) + 1.0) * 0.5;
    final heartRadius = 18.0 + pulse * 14.0;
    final heartAlpha = (1.0 - pulse) * 0.55;

    final pulsePaint = Paint()
      ..color = const Color(0xFFFF8A80).withValues(alpha: heartAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(const Offset(0, -10), heartRadius, pulsePaint);
  }

  void _drawColdSplashDrops(Canvas canvas, double t) {
    for (int i = 0; i < 6; i++) {
      final phase = (t * 1.5 + (i / 6.0)) % 1.0;
      final angle = (i * (pi / 3.0)) - (pi / 2.0);
      final dist = 32.0 + phase * 40.0;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist + 10;
      final dropAlpha = sin(phase * pi) * 0.8;

      final dropPaint = Paint()
        ..color = (i.isEven ? const Color(0xFF80DEEA) : const Color(0xFF64B5F6)).withValues(alpha: dropAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), 2.2 + (1.0 - phase) * 2.0, dropPaint);
    }
  }

  void _drawTensionDischarge(Canvas canvas, double t) {
    final wave = (t * 3.0) % 1.0;
    final ringPaint = Paint()
      ..color = const Color(0xFF81C784).withValues(alpha: (1.0 - wave) * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -15), width: 70 + wave * 50, height: 85 + wave * 50),
      ringPaint,
    );
  }

  void _drawGroundingRoots(Canvas canvas, double t) {
    final sway = sin(t * 2 * pi) * 1.5;
    final rootPaint = Paint()
      ..color = const Color(0xFF4E7D56).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;

    final centerRoot = Path()
      ..moveTo(0, 48)
      ..quadraticBezierTo(sway, 62, sway * 0.5, 78);
    canvas.drawPath(centerRoot, rootPaint);

    final leftRoot = Path()
      ..moveTo(-8, 46)
      ..quadraticBezierTo(-16 + sway, 60, -22 + sway, 72);
    canvas.drawPath(leftRoot, rootPaint);

    final rightRoot = Path()
      ..moveTo(8, 46)
      ..quadraticBezierTo(16 - sway, 60, 22 - sway, 72);
    canvas.drawPath(rightRoot, rootPaint);
  }

  void _drawWarmTeaSteam(Canvas canvas, double t) {
    for (int i = 0; i < 3; i++) {
      final phase = (t + (i * 0.33)) % 1.0;
      final y = 15.0 - phase * 65.0;
      final x = sin((phase * 2 * pi) + (i * 1.5)) * 10.0 + (i - 1) * 9.0;
      final steamAlpha = sin(phase * pi) * 0.45;

      final steamPaint = Paint()
        ..color = const Color(0xFFFFF9C4).withValues(alpha: steamAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(Offset(x, y), 5.0 + phase * 8.0, steamPaint);
    }
  }

  void _drawBreathMist(Canvas canvas, double t) {
    final lungCycle = (sin(t * 2 * pi) + 1.0) * 0.5;
    final mistAlpha = (1.0 - lungCycle) * 0.45;
    final mistRadius = 25.0 + (1.0 - lungCycle) * 35.0;

    final mistPaint = Paint()
      ..color = const Color(0xFFA5D6A7).withValues(alpha: mistAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(const Offset(0, -15), mistRadius, mistPaint);
  }

  @override
  bool shouldRepaint(covariant LivingSeedSpiritPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.emotion != emotion ||
        oldDelegate.isPetting != isPetting ||
        oldDelegate.sizeScale != sizeScale ||
        oldDelegate.growthStage != growthStage ||
        oldDelegate.growthFactor != growthFactor ||
        oldDelegate.taskAction != taskAction ||
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
