import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/sanctuary_state.dart';
import '../../../habits/domain/micro_habit.dart';
import 'painters/lev_accessory_painter.dart';
import 'painters/lev_stage_ornaments_painter.dart';

import 'painters/lev_task_effects_painter.dart';
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
  final double? prayProgress;       // Oración y fe: hojas en plegaria, ojos serenos y resplandor celestial
  final LevAccessory activeAccessory; // Accesorio botánico equipado
  final Offset? touchNormalizedOffset; // (-1.0 a 1.0 relativo al centro de Lev)
  final bool isFingerActive;
  final double touchDistance;

  LivingSeedSpiritPainter({
    required this.animationValue,
    required this.emotion,
    required this.isPetting,
    this.sizeScale = 1.0,
    this.taskAction,
    this.growthStage = LevGrowthStage.youngPlant,
    this.growthFactor = 0.0,
    this.activeAccessory = LevAccessory.none,
    this.touchNormalizedOffset,
    this.isFingerActive = false,
    this.touchDistance = 999.0,
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
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.48;

    final t = animationValue;
    final cycle = t * 2 * pi;

    // --- EFECTIVIDAD DE EMOCIONES (Interpolación suave 0.0 -> 1.0 sin saltos bruscos) ---
    final isJoyJumping = (emotion == LevEmotion.joyJump) || (jumpProgress > 0.0);
    final isTouchingLev = isFingerActive && touchDistance < 85.0;
    final effectiveIsPetting = isPetting || isTouchingLev;

    final effWrap = leafWrapProgress ?? (emotion == LevEmotion.sheltered ? 1.0 : 0.0);
    final effSleep = sleepProgress ?? (emotion == LevEmotion.sleeping ? 1.0 : 0.0);
    final effHappy = happyProgress ?? max(effectiveIsPetting ? 1.0 : 0.0, ((emotion == LevEmotion.happy || isJoyJumping) ? 1.0 : 0.0));
    final effBreath = breathingProgress ?? (emotion == LevEmotion.breathing ? 1.0 : 0.0);
    final effCurious = curiousProgress ?? (emotion == LevEmotion.curious ? 1.0 : 0.0);
    final effSad = sadProgress ?? (emotion == LevEmotion.sad ? 1.0 : 0.0);
    final effAnxious = anxiousProgress ?? (emotion == LevEmotion.anxious ? 1.0 : 0.0);
    final effTired = tiredProgress ?? (emotion == LevEmotion.tired ? 1.0 : 0.0);
    final effCelebrate = celebrateProgress ?? ((emotion == LevEmotion.celebrating || isJoyJumping) ? 1.0 : 0.0);
    final effPray = prayProgress ?? (emotion == LevEmotion.praying ? 1.0 : 0.0);

    // --- 1. CINEMÁTICA Y BIOMECÁNICA INDEPENDIENTE POR ETAPA ---
    final double stageBaseFloatY;
    final double stageBaseSway;
    final double stageBreatheFrequency;
    final double stageBreatheAmplitude;
    final double stageJumpHeight;
    final double stageJumpSquash;
    final double stageTouchSwayMultiplier;
    final double stageTouchStretchMultiplier;
    final double stagePetSquashMultiplier;

    switch (growthStage) {
      case LevGrowthStage.seed:
        // Semilla: Reposa en el suelo/lecho (+20px), pesada y terrenal, no vuela.
        // Balanceo suave de tentetieso, respiración uterina lenta.
        stageBaseFloatY = 20.0 + sin(cycle * 0.7) * 2.2;
        stageBaseSway = sin(cycle * 0.7) * 0.025;
        stageBreatheFrequency = 0.65;
        stageBreatheAmplitude = 0.020;
        stageJumpHeight = 22.0; // Saltito bajo tipo "pop" de semilla
        stageJumpSquash = 0.20; // Rebote elástico rechoncho
        // Al arrastrar/tocar: se tambalea como un tentetieso roly-poly sobre su base
        stageTouchSwayMultiplier = 0.38 * (1.0 + sin(cycle * 6.0) * 0.35);
        stageTouchStretchMultiplier = 0.04;
        stagePetSquashMultiplier = 0.08;
        break;

      case LevGrowthStage.sprout:
        // Brote: Muy ligero y frágil. Flotación ágil a media altura, temblorcito tierno de cotiledón.
        stageBaseFloatY = sin(cycle * 1.3) * 5.5;
        stageBaseSway = sin(cycle * 1.4) * 0.045;
        stageBreatheFrequency = 1.25;
        stageBreatheAmplitude = 0.032;
        stageJumpHeight = 46.0; // Salto alto con estiramiento vertical de fideo
        stageJumpSquash = 0.22;
        stageTouchSwayMultiplier = 0.24;
        stageTouchStretchMultiplier = 0.14; // Gran estiramiento buscando la luz
        stagePetSquashMultiplier = 0.06;
        break;

      case LevGrowthStage.seedling:
        // Plántula: Vivaz, ágil, antena elástica curiosa con giros rápidos.
        stageBaseFloatY = sin(cycle * 1.5) * 6.5;
        stageBaseSway = sin(cycle * 1.2) * 0.035;
        stageBreatheFrequency = 1.1;
        stageBreatheAmplitude = 0.028;
        stageJumpHeight = 48.0;
        stageJumpSquash = 0.16;
        stageTouchSwayMultiplier = 0.28;
        stageTouchStretchMultiplier = 0.11;
        stagePetSquashMultiplier = 0.055;
        break;

      case LevGrowthStage.youngPlant:
        // Planta Joven: Clásico armónico balanceado.
        stageBaseFloatY = sin(cycle) * 7.0;
        stageBaseSway = sin(cycle * 0.5) * 0.022;
        stageBreatheFrequency = 1.0;
        stageBreatheAmplitude = 0.024;
        stageJumpHeight = 48.0;
        stageJumpSquash = 0.16;
        stageTouchSwayMultiplier = 0.18;
        stageTouchStretchMultiplier = 0.09;
        stagePetSquashMultiplier = 0.04;
        break;

      case LevGrowthStage.vibrantPlant:
        // Planta Vibrante: Fluida, aromática, hojas con pétalos en suspensión ingrávida.
        stageBaseFloatY = sin(cycle * 0.9) * 8.0;
        stageBaseSway = sin(cycle * 0.6) * 0.030;
        stageBreatheFrequency = 0.95;
        stageBreatheAmplitude = 0.030;
        stageJumpHeight = 52.0; // Salto en cámara lenta con suspensión
        stageJumpSquash = 0.14;
        stageTouchSwayMultiplier = 0.20;
        stageTouchStretchMultiplier = 0.10;
        stagePetSquashMultiplier = 0.05;
        break;

      case LevGrowthStage.youngTree:
        // Árbol Joven: Sólido, denso, mayor masa física e inercia.
        stageBaseFloatY = sin(cycle * 0.75) * 5.0;
        stageBaseSway = sin(cycle * 0.4) * 0.018;
        stageBreatheFrequency = 0.85;
        stageBreatheAmplitude = 0.022;
        stageJumpHeight = 40.0; // Salto solemne con fuerte impacto elástico
        stageJumpSquash = 0.20;
        stageTouchSwayMultiplier = 0.12;
        stageTouchStretchMultiplier = 0.06;
        stagePetSquashMultiplier = 0.035;
        break;

      case LevGrowthStage.adultTree:
        // Árbol Sabio: Flotación zen majestuosa, corona astral en rotación continua.
        stageBaseFloatY = sin(cycle * 0.5) * 5.5;
        stageBaseSway = sin(cycle * 0.3) * 0.015;
        stageBreatheFrequency = 0.75;
        stageBreatheAmplitude = 0.020;
        stageJumpHeight = 42.0;
        stageJumpSquash = 0.14;
        stageTouchSwayMultiplier = 0.14;
        stageTouchStretchMultiplier = 0.07;
        stagePetSquashMultiplier = 0.03;
        break;

      case LevGrowthStage.forestSpirit:
        // Espíritu del Bosque: Levitación cósmica multicapa, 3 pares de alas activas.
        stageBaseFloatY = sin(cycle * 0.7) * 9.0 + cos(cycle * 0.45) * 3.5;
        stageBaseSway = sin(cycle * 0.5) * 0.025;
        stageBreatheFrequency = 0.70;
        stageBreatheAmplitude = 0.035;
        stageJumpHeight = 58.0; // Ascenso celestial divino
        stageJumpSquash = 0.12;
        stageTouchSwayMultiplier = 0.22;
        stageTouchStretchMultiplier = 0.12;
        stagePetSquashMultiplier = 0.045;
        break;
    }

    // --- 2. RESPIRACIÓN Y OSCILACIÓN BASE MODULADA ---
    final breatheSpeedMultiplier = (effSleep > 0.5) ? 0.6 : (effAnxious > 0.5 ? 2.2 : 1.0);
    final breathCycle = t * 2 * pi * breatheSpeedMultiplier * stageBreatheFrequency;

    final baseFloatY = stageBaseFloatY;
    final baseBreatheY = sin(breathCycle) * stageBreatheAmplitude;
    final baseBreatheX = -baseBreatheY * 0.55;
    final baseSway = stageBaseSway;

    // --- 3. CAPAS DE INTERACCIÓN SOMÁTICA ---
    final deepBreatheY = sin(breathCycle) * 0.12 * effBreath;
    final deepBreatheX = -deepBreatheY * 0.55;

    final sleepSway = 0.055 * effSleep;
    final sleepFloat = (growthStage == LevGrowthStage.seed ? 2.0 : 6.0) * effSleep;

    final happySway = sin(cycle * 3.2) * 0.08 * effHappy;
    final happyFloat = sin(cycle * 2.0) * 4.0 * effHappy;

    final curiousSway = (0.12 + sin(cycle * 1.5) * 0.04) * effCurious;
    final curiousFloat = -3.0 * effCurious;

    final sadFloat = (growthStage == LevGrowthStage.seed ? 3.0 : 8.0) * effSad;
    final sadSway = -0.04 * effSad;

    final anxiousShakeX = sin(cycle * 24.0) * 1.6 * effAnxious;
    final anxiousShakeY = cos(cycle * 28.0) * 1.2 * effAnxious;

    final tiredFloat = (4.0 + sin(cycle * 0.8) * 3.5) * effTired;

    // Celebración: curvatura armónica suave C∞ que elimina cualquier salto o movimiento entrecortado
    final celebrateSway = sin(cycle * 1.6) * 0.08 * effCelebrate;
    final celebrateCycle = sin(cycle * 3.0);
    final celebrateFloat = -(celebrateCycle * celebrateCycle) * 14.0 * effCelebrate;
    final celebrateScaleY = (celebrateCycle * celebrateCycle) * 0.07 * effCelebrate;
    final celebrateScaleX = -(celebrateScaleY * 0.45);

    // --- 4. CAPA DE SALTO ELÁSTICO DE ALEGRÍA INDIVIDUALIZADO POR ETAPA (SIN CORTES) ---
    double jumpFloatY = 0.0;
    double jumpScaleY = 0.0;
    double jumpScaleX = 0.0;
    double jumpSway = 0.0;

    if (isJoyJumping) {
      final p = jumpProgress > 0.0 ? jumpProgress : (t % 1.0);
      final phi = p * 2 * pi;
      final jumpSin = sin(phi);

      if (jumpSin > 0) {
        // Fase de impulso y elevación elástica según la masa de la etapa
        jumpFloatY = -stageJumpHeight * jumpSin;
        jumpScaleY = stageJumpSquash * jumpSin;
        jumpScaleX = -(stageJumpSquash * 0.55) * jumpSin;
      } else {
        // Fase de amortiguación elástica de aterrizaje
        jumpFloatY = -(stageJumpHeight * 0.16) * jumpSin;
        jumpScaleY = (stageJumpSquash * 0.75) * jumpSin;
        jumpScaleX = -(stageJumpSquash * 0.45) * jumpSin;
      }
      jumpSway = sin(phi * 2.0) * 0.05;
    }

    // --- 5. REACTIVIDAD TÁCTIL Y CARICIAS ADAPTADAS A CADA ETAPA ---
    final touchX = touchNormalizedOffset?.dx.clamp(-1.0, 1.0) ?? 0.0;
    final touchY = touchNormalizedOffset?.dy.clamp(-1.0, 1.0) ?? 0.0;

    // Desplazamiento orgánico físico del cuerpo de Lev persiguiendo al dedo en la pantalla.
    // Depende directamente de la posición continua suavizada (touchX, touchY) sin truncar a 0
    // al levantar el dedo, permitiendo que Lev retorne con física elástica de muelle orgánico.
    final touchTranslateX = (touchX * 36.0);

    // Inclinación corporal elástica y expresiva orientada al dedo (hasta ~22°)
    final touchSway = (touchX * 0.38 * stageTouchSwayMultiplier);

    // Deformación somática viva: estiramiento al mirar hacia arriba, compresión al agacharse y caricia directa
    final touchStretchY = touchY < 0
        ? -touchY * stageTouchStretchMultiplier * 1.6
        : -touchY * stageTouchStretchMultiplier * 0.8;
    final touchStretchX = -touchStretchY * 0.5;
    final touchFloatY = touchY * (stageBaseFloatY.abs() > 10 ? 8.0 : 12.0);
    final directTouchSquash = isTouchingLev ? 0.08 : 0.0;
    final pettingSquash = effectiveIsPetting ? (sin(cycle * 8.0) * stagePetSquashMultiplier) : directTouchSquash;

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
        case LevTaskAction.prayer:
          taskFloatY = sin(cycle * 1.5) * 2.5;
          taskSway = sin(cycle * 1.5) * 0.015;
          break;
      }
    }

    final stageScaleMultiplier = _getStageScaleMultiplier(growthStage);

    // Desacoplamiento armónico de animación: si está saltando activamente, el canal de salto domina
    // sobre la celebración y la respiración base para eliminar cualquier movimiento entrecortado
    final effectiveCelebrateFloat = isJoyJumping ? (celebrateFloat * 0.25) : celebrateFloat;
    final effectiveBaseFloat = isJoyJumping ? (baseFloatY * 0.2) : baseFloatY;

    final prayFloatY = sin(t * 1.6 * pi) * 2.5 * effPray;
    final prayBow = sin(t * 1.6 * pi) * 0.015 * effPray;

    final finalFloatY = effectiveBaseFloat + sleepFloat + happyFloat + curiousFloat +
        sadFloat + tiredFloat + effectiveCelebrateFloat + jumpFloatY + taskFloatY + taskShakeY + touchFloatY + prayFloatY;
    final finalSway = baseSway + sleepSway + happySway + curiousSway + sadSway +
        celebrateSway + jumpSway + taskSway + touchSway + prayBow;
    final finalScaleY = 1.0 + baseBreatheY + deepBreatheY + jumpScaleY + taskScaleY + touchStretchY - pettingSquash + celebrateScaleY;
    final finalScaleX = 1.0 + baseBreatheX + deepBreatheX + jumpScaleX + taskScaleX + touchStretchX + pettingSquash + celebrateScaleX;

    // Auto-ajuste de escala inteligente: garantiza que Lev nunca desborde recuadros ni tarjetas pequeñas
    // En un lienzo grande (270px+) mantiene su tamaño completo (1.0). En cuadros de 120-190px se auto-escala con holgura visual.
    final minDim = min(size.width, size.height);
    final autoFitScale = (minDim / 270.0).clamp(0.20, 1.0);
    final totalScale = sizeScale * stageScaleMultiplier * autoFitScale;

    canvas.save();
    canvas.translate(centerX + anxiousShakeX + taskShakeX + touchTranslateX, centerY + finalFloatY + anxiousShakeY);
    canvas.rotate(finalSway);
    canvas.scale(totalScale * finalScaleX, totalScale * finalScaleY);

    // 0. Elementos traseros de etapa suprema (Orbes orbitales que pasan por detrás)
    if (growthStage == LevGrowthStage.forestSpirit) {
      LevStageOrnamentsPainter.drawForestSpiritOrbs(canvas, t, inFront: false);
    }

    // 1. Resplandor áurico ambiental adaptativo
    _drawAmbientAura(canvas, t, effSleep, effBreath, effAnxious, effCelebrate, effPray: effPray);

    // 2. Alas suculentas / Follaje según la etapa de crecimiento reactivo
    _drawGrowthFoliage(
      canvas,
      t,
      effWrap,
      effSleep,
      effHappy,
      effSad,
      effCurious,
      effPray: effPray,
      effectiveIsPetting: effectiveIsPetting,
      touchX: touchX,
      touchY: touchY,
      isFingerActive: isFingerActive,
    );

    // 3. Tallo / Base Inferior
    _drawStemBase(canvas);

    // 4. Bulbo de Semilla / Cuerpo de Llama
    _drawFlameBulb(canvas, t, effBreath, effAnxious);

    // 5. Cáliz Frontal / Sépalos de protección
    _drawFrontCalyx(canvas, t);

    // 6. Rostro de Lev con transición fluida entre expresiones y seguimiento de dedo
    _drawZenFace(
      canvas,
      t,
      effSleep,
      effHappy,
      effSad,
      effCurious,
      effTired,
      effAnxious,
      effPray: effPray,
      touchGazeOffset: Offset(touchX * 9.5, touchY * 7.0),
      isTouchingLev: isTouchingLev,
      isFingerActive: isFingerActive,
      effectiveIsPetting: effectiveIsPetting,
    );

    // 7. Detalles botánicos ornamentales según etapa reactiva al dedo y caricias
    _drawStageOrnaments(
      canvas,
      t,
      effCelebrate,
      effectiveIsPetting: effectiveIsPetting,
      touchX: touchX,
      touchY: touchY,
      isFingerActive: isFingerActive,
    );

    // 8. Efectos y partículas emocionales
    if (effSleep > 0.05) {
      _drawSleepingZzz(canvas, t, effSleep);
    }
    if (effPray > 0.05) {
      _drawPrayerGraceParticles(canvas, t, effPray);
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
      LevStageOrnamentsPainter.drawForestSpiritOrbs(canvas, t, inFront: true);
    }

    // 10. Efectos somáticos específicos de tarea
    if (taskAction != null) {
      _drawTaskEffects(canvas, t);
    }

    // 11. Accesorio botánico equipado
    if (activeAccessory != LevAccessory.none) {
      _drawAccessory(canvas, t, activeAccessory);
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
    double effCelebrate, {
    double effPray = 0.0,
  }) {
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

    if (effPray > 0.05) {
      auraColor = const Color(0xFFFFD54F);
      baseAlpha = (baseAlpha + 0.24 * effPray).clamp(0.20, 0.75);
      baseRadius += 35.0 * effPray;
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

    if (effPray > 0.05) {
      final prayerGlow = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: (0.26 + sin(t * 2 * pi) * 0.12) * effPray)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);
      canvas.drawCircle(const Offset(0, -20), finalRadius * 0.85, prayerGlow);
    }
  }

  void _drawGrowthFoliage(
    Canvas canvas,
    double t,
    double effWrap,
    double effSleep,
    double effHappy,
    double effSad,
    double effCurious, {
    double effPray = 0.0,
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
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

    if (effPray > 0.05) {
      // Manos/hojas unidas en reverente oración hacia el corazón
      leftAngle = lerpDouble(leftAngle, -0.74, effPray)!;
      rightAngle = lerpDouble(rightAngle, 0.74, effPray)!;
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
        case LevTaskAction.prayer:
          leftAngle = -0.74 + sin(cycle * 0.8) * 0.03;
          rightAngle = 0.74 - sin(cycle * 0.8) * 0.03;
          break;
        default:
          break;
      }
    }

    switch (growthStage) {
      case LevGrowthStage.seed:
        _drawSeedCotyledons(
          canvas,
          cycle,
          effHappy,
          t,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
        );
        break;

      case LevGrowthStage.sprout:
        // Los cotiledones se mueven con curiosidad hacia el dedo y aletean al acariciar
        final sproutLeft = leftAngle + (touchX * 0.12) + (effectiveIsPetting ? sin(cycle * 14.0) * 0.20 : 0.0);
        final sproutRight = rightAngle + (touchX * 0.12) - (effectiveIsPetting ? sin(cycle * 14.0) * 0.20 : 0.0);
        _drawSucculentPair(canvas, sproutLeft, sproutRight, const Size(54, 28), 0.0);
        break;

      case LevGrowthStage.seedling:
        final seedlingLeft = leftAngle + (touchX * 0.10) + (effectiveIsPetting ? sin(cycle * 8.0) * 0.12 : 0.0);
        final seedlingRight = rightAngle + (touchX * 0.10) - (effectiveIsPetting ? sin(cycle * 8.0) * 0.12 : 0.0);
        _drawSucculentPair(canvas, seedlingLeft, seedlingRight, const Size(78, 36), 0.0);
        break;

      case LevGrowthStage.youngPlant:
        final youngLeft = leftAngle + (effectiveIsPetting ? sin(cycle * 6.0) * 0.08 : 0.0);
        final youngRight = rightAngle - (effectiveIsPetting ? sin(cycle * 6.0) * 0.08 : 0.0);
        _drawSucculentPair(canvas, youngLeft, youngRight, const Size(100, 44), 0.0);
        break;

      case LevGrowthStage.vibrantPlant:
        final vibLeft = leftAngle + (effectiveIsPetting ? sin(cycle * 5.0) * 0.10 : 0.0);
        final vibRight = rightAngle - (effectiveIsPetting ? sin(cycle * 5.0) * 0.10 : 0.0);
        _drawSucculentPair(canvas, vibLeft, vibRight, const Size(104, 45), 0.0);
        _drawWingtipBlossoms(canvas, vibLeft, vibRight, 104.0, isBloomed: effectiveIsPetting);
        break;

      case LevGrowthStage.youngTree:
        final upperLeft = leftAngle * 0.72 - 0.20 + sin(cycle * 1.4) * 0.04 + (touchX * 0.06);
        final upperRight = rightAngle * 0.72 + 0.20 - sin(cycle * 1.4) * 0.04 + (touchX * 0.06);
        _drawSucculentPair(canvas, upperLeft, upperRight, const Size(70, 32), -26.0, hasVeins: true);
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(110, 46), 0.0, hasVeins: true);
        break;

      case LevGrowthStage.adultTree:
        final upperLeft = leftAngle * 0.75 - 0.24 + sin(cycle * 1.5) * 0.05 + (touchX * 0.07);
        final upperRight = rightAngle * 0.75 + 0.24 - sin(cycle * 1.5) * 0.05 + (touchX * 0.07);
        _drawSucculentPair(canvas, upperLeft, upperRight, const Size(82, 36), -30.0, hasVeins: true);
        _drawSucculentPair(canvas, leftAngle, rightAngle, const Size(116, 48), 0.0, hasVeins: true);
        break;

      case LevGrowthStage.forestSpirit:
        // Alas triples celestiales: dinámica polifónica independiente en 3 frecuencias
        final fanOut = effectiveIsPetting ? 0.28 : 0.0;
        final upperLeft = -0.68 - fanOut + sin(cycle * 2.2) * 0.08 + (touchY * 0.12);
        final upperRight = 0.68 + fanOut - sin(cycle * 2.2) * 0.08 - (touchY * 0.12);

        final midLeft = leftAngle - (fanOut * 0.4) + sin(cycle * 1.6 + 1.2) * 0.06;
        final midRight = rightAngle + (fanOut * 0.4) - sin(cycle * 1.6 + 1.2) * 0.06;

        final lowerLeft = -0.22 + (fanOut * 0.6) + sin(cycle * 1.1 + 2.4) * 0.05 - (touchY * 0.08);
        final lowerRight = 0.22 - (fanOut * 0.6) - sin(cycle * 1.1 + 2.4) * 0.05 + (touchY * 0.08);

        _drawSucculentPair(canvas, upperLeft, upperRight, const Size(90, 38), -44.0, hasVeins: true, celestialGlow: true);
        _drawSucculentPair(canvas, midLeft, midRight, const Size(122, 50), 0.0, hasVeins: true, celestialGlow: true);
        _drawSucculentPair(canvas, lowerLeft, lowerRight, const Size(68, 30), 38.0, hasVeins: true, celestialGlow: true);
        break;
    }
  }

  void _drawSeedCotyledons(
    Canvas canvas,
    double cycle,
    double effHappy,
    double t, {
    required bool effectiveIsPetting,
    required double touchX,
  }) {
    // 1. Raíces subterráneas biomórficas que pulsan savia y absorben calor
    final speed = effectiveIsPetting ? 6.0 : 2.5;
    final rootPulse = (sin(cycle * speed) + 1.0) * 0.5;
    final rootPaint = Paint()
      ..color = const Color(0xFF80E2BF).withValues(alpha: effectiveIsPetting ? 0.80 : (0.45 + rootPulse * 0.35))
      ..style = PaintingStyle.stroke
      ..strokeWidth = effectiveIsPetting ? 3.0 : 2.4
      ..strokeCap = StrokeCap.round;

    final rootSpread = effectiveIsPetting ? 8.0 : 0.0;
    final r1 = Path()..moveTo(-10, 52)..cubicTo(-18 - rootSpread, 68, -26 - rootSpread, 80, -34 - rootSpread, 95);
    final r2 = Path()..moveTo(0, 54)..cubicTo(3, 72, -4, 90 + rootSpread, 0, 108 + rootSpread);
    final r3 = Path()..moveTo(10, 52)..cubicTo(18 + rootSpread, 70, 26 + rootSpread, 82, 36 + rootSpread, 96);
    canvas.drawPath(r1, rootPaint);
    canvas.drawPath(r2, rootPaint);
    canvas.drawPath(r3, rootPaint);

    // 2. Cotiledones tiernos que respiran a los costados
    final wiggle = sin(cycle * 2.5) * 0.08 + (effHappy * sin(cycle * 5.0) * 0.14) + (effectiveIsPetting ? sin(cycle * 10.0) * 0.18 : 0.0);
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

    // 3. Esporas doradas de luz: si se acaricia, brota un enjambre de 12 esporas radiantes
    final sporeCount = effectiveIsPetting ? 12 : 6;
    for (int i = 0; i < sporeCount; i++) {
      final phase = (t + i / sporeCount.toDouble()) % 1.0;
      final driftX = touchX * 18.0;
      final sx = sin(phase * 2 * pi + i * 1.3) * (effectiveIsPetting ? 52 : 36) + driftX;
      final sy = -40 + phase * (effectiveIsPetting ? 110 : 85);
      final sporeAlpha = sin(phase * pi) * (effectiveIsPetting ? 0.95 : 0.7);
      final sporePaint = Paint()
        ..color = (effectiveIsPetting ? const Color(0xFFFFD54F) : const Color(0xFFFFF59D)).withValues(alpha: sporeAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(sx, sy), effectiveIsPetting ? 3.4 : 2.4, sporePaint);
    }
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

  void _drawWingtipBlossoms(Canvas canvas, double leftAngle, double rightAngle, double wingLength, {bool isBloomed = false}) {
    canvas.save();
    canvas.translate(-8, 54);
    canvas.rotate(leftAngle);
    canvas.translate(-wingLength, 0);
    _drawMiniBlossom(canvas, isBloomed: isBloomed);
    canvas.restore();

    canvas.save();
    canvas.translate(8, 54);
    canvas.rotate(rightAngle);
    canvas.translate(wingLength, 0);
    _drawMiniBlossom(canvas, isBloomed: isBloomed);
    canvas.restore();
  }

  void _drawMiniBlossom(Canvas canvas, {bool isBloomed = false}) {
    final scale = isBloomed ? 1.35 : 1.0;
    final petalPaint = Paint()..color = const Color(0xFFFFB4C8).withValues(alpha: 0.90);
    final centerPaint = Paint()..color = const Color(0xFFFFE082);

    for (int i = 0; i < 5; i++) {
      final angle = i * (2 * pi / 5);
      final px = cos(angle) * (7.0 * scale);
      final py = sin(angle) * (7.0 * scale);
      canvas.drawCircle(Offset(px, py), 4.2 * scale, petalPaint);
    }
    canvas.drawCircle(Offset.zero, 3.5 * scale, centerPaint);

    if (isBloomed) {
      final bloomAura = Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset.zero, 12.0, bloomAura);
    }
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
      final rect = const Rect.fromLTWH(-46, -66, 92, 118);
      bulbPath.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(44)));

      final seedShader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.45, 1.0],
        colors: [
          Color(0xFFFFF9C4),
          Color(0xFFFFD54F),
          Color(0xFFB3731E),
        ],
      ).createShader(rect);

      canvas.drawPath(bulbPath, Paint()..shader = seedShader);

      // Latido embrionario cálido y rítmico en el núcleo de la semilla
      final heartbeat = (sin(t * 6 * pi) + 1.0) * 0.5;
      final heartGlow = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.40 + heartbeat * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(const Offset(0, -6), 18 + heartbeat * 6, heartGlow);
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
    double effAnxious, {
    double effPray = 0.0,
    Offset touchGazeOffset = Offset.zero,
    bool isTouchingLev = false,
    bool isFingerActive = false,
    bool effectiveIsPetting = false,
  }) {
    if (growthStage == LevGrowthStage.seed) {
      final babyEyeY = -8.0 + touchGazeOffset.dy * 0.4;
      final babyEyeDist = 14.0;
      final babyMouthY = 5.0 + touchGazeOffset.dy * 0.3;

      final babyPaint = Paint()
        ..color = const Color(0xFF0E382B).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;

      if (isFingerActive && !effectiveIsPetting && effSleep < 0.3 && effPray < 0.3) {
        // Bebé semilla abre ojos curiosos tiernos con pupilas y reflejos siguiendo el dedo
        final babyPupil = Paint()..color = const Color(0xFF0E382B);
        final babyGlint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(-babyEyeDist + touchGazeOffset.dx * 0.4, babyEyeY), 3.4, babyPupil);
        canvas.drawCircle(Offset(-babyEyeDist - 1.0 + touchGazeOffset.dx * 0.4, babyEyeY - 1.0), 1.2, babyGlint);
        canvas.drawCircle(Offset(babyEyeDist + touchGazeOffset.dx * 0.4, babyEyeY), 3.4, babyPupil);
        canvas.drawCircle(Offset(babyEyeDist - 1.0 + touchGazeOffset.dx * 0.4, babyEyeY - 1.0), 1.2, babyGlint);
      } else {
        // Ojos durmientes curvos tiernos descansando en paz zen o en oración
        final leftEyePath = Path()
          ..moveTo(-babyEyeDist - 5, babyEyeY)
          ..quadraticBezierTo(-babyEyeDist, babyEyeY + 3.5, -babyEyeDist + 5, babyEyeY);
        final rightEyePath = Path()
          ..moveTo(babyEyeDist - 5, babyEyeY)
          ..quadraticBezierTo(babyEyeDist, babyEyeY + 3.5, babyEyeDist + 5, babyEyeY);
        canvas.drawPath(leftEyePath, babyPaint);
        canvas.drawPath(rightEyePath, babyPaint);
      }

      // Sonrisita de bebé semilla
      final babyMouth = Path()
        ..moveTo(-4 + touchGazeOffset.dx * 0.25, babyMouthY)
        ..quadraticBezierTo(touchGazeOffset.dx * 0.25, babyMouthY + 3.0, 4 + touchGazeOffset.dx * 0.25, babyMouthY);
      canvas.drawPath(babyMouth, babyPaint);

      // Mejillitas rosadas suaves
      final babyCheek = Paint()
        ..color = const Color(0xFFFFAE52).withValues(alpha: isTouchingLev ? 0.65 : 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(-20 + touchGazeOffset.dx * 0.2, babyEyeY + 8), 5, babyCheek);
      canvas.drawCircle(Offset(20 + touchGazeOffset.dx * 0.2, babyEyeY + 8), 5, babyCheek);
      return;
    }

    final eyeY = -4.0 + touchGazeOffset.dy;
    final eyeDist = 19.0;
    final leftCenter = Offset(-eyeDist + touchGazeOffset.dx, eyeY);
    final rightCenter = Offset(eyeDist + touchGazeOffset.dx, eyeY);

    final blinkT = t % 1.0;
    final isBlinking = (effSleep < 0.3 && blinkT > 0.50 && blinkT < 0.54) || (effTired > 0.5 && blinkT > 0.46 && blinkT < 0.58);

    final featurePaint = Paint()
      ..color = const Color(0xFF0E382B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round;

    if (isBlinking) {
      canvas.drawLine(Offset(leftCenter.dx - 5, eyeY), Offset(leftCenter.dx + 5, eyeY), featurePaint);
      canvas.drawLine(Offset(rightCenter.dx - 5, eyeY), Offset(rightCenter.dx + 5, eyeY), featurePaint);
    } else if (isFingerActive && !effectiveIsPetting && effSleep < 0.3 && effPray < 0.3) {
      // Dedo activo sobre la pantalla: Lev abre sus ojos curiosos siguiendo la mirada
      _drawCuriousEye(canvas, leftCenter, 13.0, featurePaint);
      _drawCuriousEye(canvas, rightCenter, 13.0, featurePaint);
    } else {
      // Dedo libre, reposo zen u oración: Lev cierra los ojos serenamente
      _drawDynamicEye(canvas, leftCenter, 14.0, featurePaint, effHappy, effSleep, effSad, effTired, effectiveIsPetting);
      _drawDynamicEye(canvas, rightCenter, 14.0, featurePaint, effHappy, effSleep, effSad, effTired, effectiveIsPetting);
    }

    final mouthY = 13.0 + touchGazeOffset.dy * 0.4;
    var mouthDepth = lerpDouble(7.0, 3.5, effSleep)!;
    var mouthWidth = lerpDouble(7.5, 5.5, effSleep)!;

    if (effSad > 0.3) {
      mouthDepth = -3.5 * effSad;
    } else if (effHappy > 0.3 || isTouchingLev) {
      mouthDepth = isTouchingLev ? 11.5 : 9.5;
      mouthWidth = isTouchingLev ? 9.5 : 9.0;
    }

    final mouthPaint = Paint()
      ..color = const Color(0xFF0E382B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(-mouthWidth + touchGazeOffset.dx * 0.3, mouthY);
    mouthPath.quadraticBezierTo(touchGazeOffset.dx * 0.3, mouthY + mouthDepth, mouthWidth + touchGazeOffset.dx * 0.3, mouthY);
    canvas.drawPath(mouthPath, mouthPaint);

    final cheekAlpha = isTouchingLev
        ? 0.60
        : lerpDouble(0.14, 0.34, max(effHappy, effectiveIsPetting ? 1.0 : 0.0))!;
    final cheekPaint = Paint()
      ..color = const Color(0xFFFFAE52).withValues(alpha: cheekAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(Rect.fromCenter(center: Offset(-28 + touchGazeOffset.dx * 0.3, 6 + touchGazeOffset.dy * 0.3), width: 16, height: 10), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(28 + touchGazeOffset.dx * 0.3, 6 + touchGazeOffset.dy * 0.3), width: 16, height: 10), cheekPaint);
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
    bool effectiveIsPetting,
  ) {
    final happyWeight = max(effHappy, effectiveIsPetting ? 1.0 : 0.0);
    // Párpados relajados cerrados en calma zen (+4.2) o arqueados hacia arriba con felicidad (^ ^ -6.5)
    var curve = lerpDouble(4.2, -6.5, happyWeight)!;
    curve = lerpDouble(curve, 3.8, effSleep)!;
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

  void _drawStageOrnaments(
    Canvas canvas,
    double t,
    double effCelebrate, {
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    LevStageOrnamentsPainter.draw(
      canvas,
      t,
      effCelebrate,
      growthStage: growthStage,
      effectiveIsPetting: effectiveIsPetting,
      touchX: touchX,
      touchY: touchY,
      isFingerActive: isFingerActive,
    );
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

  void _drawPrayerGraceParticles(Canvas canvas, double t, double effPray) {
    if (effPray <= 0.05) return;

    // 1. Rayos celestiales de luz cálida que emanan con reverencia
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi / rayCount) + sin(t * pi) * 0.08;
      final rayLength = 35.0 + sin(t * 3 * pi + i) * 8.0;
      final rayAlpha = (0.28 + 0.18 * sin(t * 2 * pi + i)).clamp(0.0, 1.0) * effPray;
      rayPaint
        ..strokeWidth = 2.0
        ..color = const Color(0xFFFFE082).withValues(alpha: rayAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      final start = Offset(cos(angle) * 30, -10 + sin(angle) * 30);
      final end = Offset(cos(angle) * (30 + rayLength), -10 + sin(angle) * (30 + rayLength));
      canvas.drawLine(start, end, rayPaint);
    }

    // 2. Partículas doradas de oración que ascienden serenamente
    final particlePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    for (int p = 0; p < 7; p++) {
      final phase = (t * 0.8 + p * 0.14) % 1.0;
      final px = sin(phase * 2 * pi + p * 2.0) * (26.0 + p * 4.0);
      final py = 20.0 - phase * 90.0;
      final pAlpha = sin(phase * pi) * 0.75 * effPray;
      particlePaint.color = const Color(0xFFFFF9C4).withValues(alpha: pAlpha);
      canvas.drawCircle(Offset(px, py), 2.2 + sin(phase * pi) * 1.5, particlePaint);
    }

    // 3. Destello de paz en el centro del pecho
    final crossGlow = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: (0.50 + sin(t * 3 * pi) * 0.20) * effPray)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(const Offset(0, 18), 12, crossGlow);
    final coreGlint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * effPray);
    canvas.drawCircle(const Offset(0, 18), 2.4, coreGlint);
  }

  void _drawTaskEffects(Canvas canvas, double t) {
    LevTaskEffectsPainter.draw(
      canvas,
      t,
      taskAction!,
      onDrawSleepingZzz: (c, time, op) => _drawSleepingZzz(c, time, op),
    );
  }
  // --- DIBUJADO DE ACCESORIOS BOTÁNICOS Y DE ABRIGO ---
  void _drawAccessory(Canvas canvas, double t, LevAccessory accessory) {
    LevAccessoryPainter.draw(canvas, t, accessory);
  }

  @override
  bool shouldRepaint(covariant LivingSeedSpiritPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.emotion != emotion ||
        oldDelegate.isPetting != isPetting ||
        oldDelegate.sizeScale != sizeScale ||
        oldDelegate.growthStage != growthStage ||
        oldDelegate.growthFactor != growthFactor ||
        oldDelegate.activeAccessory != activeAccessory ||
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
        oldDelegate.celebrateProgress != celebrateProgress ||
        oldDelegate.prayProgress != prayProgress ||
        oldDelegate.touchNormalizedOffset != touchNormalizedOffset ||
        oldDelegate.isFingerActive != isFingerActive ||
        oldDelegate.touchDistance != touchDistance;
  }
}
