import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';

/// Pintor vectorial especializado para los ornamentos y atributos de las 8 etapas evolutivas de Lev.
class LevStageOrnamentsPainter {
  const LevStageOrnamentsPainter._();

  static void draw(
    Canvas canvas,
    double t,
    double effCelebrate, {
    required LevGrowthStage growthStage,
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    final cycle = t * 2 * pi;

    switch (growthStage) {
      case LevGrowthStage.seed:
        final nubPulse = sin(cycle * (effectiveIsPetting ? 6.0 : 3.0)) * 2.0;
        final nubPaint = Paint()
          ..color = (effectiveIsPetting ? const Color(0xFFFFD54F) : const Color(0xFF80E2BF))
              .withValues(alpha: effectiveIsPetting ? 0.95 : 0.85);
        canvas.drawCircle(Offset(0, -66 - nubPulse), effectiveIsPetting ? 7.0 : 5.5, nubPaint);
        break;

      case LevGrowthStage.sprout:
        _drawSproutDewdrops(
          canvas,
          cycle,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          isFingerActive: isFingerActive,
        );
        break;

      case LevGrowthStage.seedling:
        _drawSeedlingAntenna(
          canvas,
          cycle,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          touchY: touchY,
          isFingerActive: isFingerActive,
        );
        break;

      case LevGrowthStage.youngPlant:
        _drawYoungPlantEars(
          canvas,
          cycle,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          isFingerActive: isFingerActive,
        );
        break;

      case LevGrowthStage.vibrantPlant:
        _drawSwirlingPetals(
          canvas,
          t,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          touchY: touchY,
          isFingerActive: isFingerActive,
        );
        break;

      case LevGrowthStage.youngTree:
        _drawResonantForeheadGem(
          canvas,
          t,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          touchY: touchY,
          isFingerActive: isFingerActive,
        );
        break;

      case LevGrowthStage.adultTree:
        _drawFloralCirclet(
          canvas,
          t,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          touchY: touchY,
          isFingerActive: isFingerActive,
        );
        _drawCanopyLightMotes(
          canvas,
          t,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          touchY: touchY,
          isFingerActive: isFingerActive,
        );
        break;

      case LevGrowthStage.forestSpirit:
        _drawDivineCrown(
          canvas,
          t,
          effectiveIsPetting: effectiveIsPetting,
        );
        _drawSacredForeheadSpiral(canvas);
        _drawCelestialAuraRings(
          canvas,
          t,
          effectiveIsPetting: effectiveIsPetting,
          touchX: touchX,
          touchY: touchY,
          isFingerActive: isFingerActive,
        );
        break;
    }
  }

  static void _drawSproutDewdrops(
    Canvas canvas,
    double cycle, {
    required bool effectiveIsPetting,
    required double touchX,
    required bool isFingerActive,
  }) {
    final speed = effectiveIsPetting ? 12.0 : 3.0;
    final glint = (sin(cycle * speed) + 1.0) * 0.5;
    final dewdropPaint = Paint()
      ..color = Colors.white.withValues(alpha: effectiveIsPetting ? 0.95 : (0.55 + glint * 0.40))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final shiftX = touchX * 4.0;
    final tremble = effectiveIsPetting ? sin(cycle * 16.0) * 1.8 : 0.0;

    canvas.drawCircle(Offset(-42 + shiftX, 38 + tremble), effectiveIsPetting ? 4.5 : 3.5, dewdropPaint);
    canvas.drawCircle(Offset(42 + shiftX, 38 - tremble), effectiveIsPetting ? 4.5 : 3.5, dewdropPaint);

    // Salpicaduras de micro-rocío si se acaricia
    if (effectiveIsPetting) {
      final sprayPaint = Paint()
        ..color = const Color(0xFFE0F7FA).withValues(alpha: 0.70)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      for (int i = 0; i < 4; i++) {
        final a = (cycle * 2.0 + i * (pi / 2));
        canvas.drawCircle(Offset(-42 + cos(a) * 7.0, 38 + sin(a) * 7.0), 1.5, sprayPaint);
        canvas.drawCircle(Offset(42 + cos(a) * 7.0, 38 + sin(a) * 7.0), 1.5, sprayPaint);
      }
    }
  }

  static void _drawSeedlingAntenna(
    Canvas canvas,
    double cycle, {
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    final bob = sin(cycle * (effectiveIsPetting ? 5.0 : 2.0)) * 3.5;
    // La antena apunta dinámicamente en dirección al dedo
    final targetBendX = (touchX * 18.0).clamp(-22.0, 22.0);
    final targetBendY = (touchY * 8.0).clamp(-12.0, 12.0);

    // Pirueta en bucle cuando está siendo acariciado
    final petAcrobatics = effectiveIsPetting ? sin(cycle * 8.0) * 12.0 : 0.0;

    final tipX = 2.0 + targetBendX + petAcrobatics;
    final tipY = -125.0 + bob + targetBendY;

    final antennaPath = Path()
      ..moveTo(0, -96)
      ..cubicTo(
        -4 + targetBendX * 0.4,
        -108,
        6 + targetBendX * 0.7,
        -118 + bob + targetBendY * 0.5,
        tipX,
        tipY,
      );

    final antennaPaint = Paint()
      ..color = effectiveIsPetting ? const Color(0xFF69F0AE) : const Color(0xFF80E2BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = effectiveIsPetting ? 2.8 : 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(antennaPath, antennaPaint);

    final pearlPaint = Paint()
      ..color = effectiveIsPetting ? const Color(0xFFFFEB3B) : const Color(0xFFFFF59D);
    canvas.drawCircle(Offset(tipX, tipY), effectiveIsPetting ? 5.0 : 3.5, pearlPaint);

    // Chispas de alegría estelar al acariciar
    if (effectiveIsPetting) {
      final sparkPaint = Paint()
        ..color = const Color(0xFFFFF59D).withValues(alpha: 0.85)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 4; i++) {
        final a = (cycle * 3.0 + i * (pi / 2));
        final px = tipX + cos(a) * 9.0;
        final py = tipY + sin(a) * 9.0;
        canvas.drawLine(Offset(tipX, tipY), Offset(px, py), sparkPaint);
      }
    }
  }

  static void _drawYoungPlantEars(
    Canvas canvas,
    double cycle, {
    required bool effectiveIsPetting,
    required double touchX,
    required bool isFingerActive,
  }) {
    // La oreja más cercana se asoma curiosa hacia la dirección táctil
    final earBias = (touchX * 0.25).clamp(-0.35, 0.35);
    // Si se acaricia, ambas orejitas aletean en un ronroneo cadencioso
    final purrFlutter = effectiveIsPetting ? sin(cycle * 10.0) * 0.16 : 0.0;
    final twitch = sin(cycle * 4.0).abs() * 0.08;

    final earPaint = Paint()
      ..color = effectiveIsPetting
          ? const Color(0xFF4DB6AC).withValues(alpha: 0.95)
          : const Color(0xFF45A586).withValues(alpha: 0.85);

    canvas.save();
    canvas.translate(-14, -86);
    canvas.rotate(-0.45 - twitch + earBias + purrFlutter);
    canvas.drawOval(const Rect.fromLTWH(-10, -6, 12, 8), earPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(14, -86);
    canvas.rotate(0.45 + twitch + earBias - purrFlutter);
    canvas.drawOval(const Rect.fromLTWH(-2, -6, 12, 8), earPaint);
    canvas.restore();
  }

  static void _drawSwirlingPetals(
    Canvas canvas,
    double t, {
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    final petalPaint = Paint()
      ..color = (effectiveIsPetting ? const Color(0xFFFF80AB) : const Color(0xFFFFC1D1))
          .withValues(alpha: effectiveIsPetting ? 0.95 : 0.80);

    final speedMult = effectiveIsPetting ? 1.8 : 1.0;
    final attractX = touchX * 42.0;
    final attractY = touchY * 28.0;

    for (int i = 0; i < 6; i++) {
      final p = ((t * speedMult) + (i / 6.0)) % 1.0;
      final angle = p * 2 * pi;
      final radius = (effectiveIsPetting ? 68.0 : 55.0) + sin(p * 4 * pi) * 16.0;
      final px = cos(angle) * radius + attractX * 0.45;
      final py = -20.0 + sin(angle) * (radius * 0.5) + (p * 20.0 - 10.0) + attractY * 0.45;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle * 2.0);
      canvas.drawOval(const Rect.fromLTWH(-4, -2.5, 8, 5), petalPaint);
      canvas.restore();
    }
  }

  static void _drawResonantForeheadGem(
    Canvas canvas,
    double t, {
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    final cycle = t * 2 * pi;
    final pulseSpeed = effectiveIsPetting ? 5.0 : 2.5;
    final pulse = (sin(cycle * pulseSpeed) + 1.0) * 0.5;

    final ringPaint = Paint()
      ..color = (effectiveIsPetting ? const Color(0xFFFFC107) : const Color(0xFFFFD54F))
          .withValues(alpha: (effectiveIsPetting ? 0.55 : 0.35) * (1.0 - pulse))
      ..style = PaintingStyle.stroke
      ..strokeWidth = effectiveIsPetting ? 2.2 : 1.5;

    final targetShift = Offset(touchX * 10.0, touchY * 6.0);
    canvas.drawCircle(const Offset(0, -52) + targetShift * 0.4, 8.0 + pulse * 14.0, ringPaint);

    final gemPaint = Paint()
      ..color = effectiveIsPetting ? const Color(0xFFFFB300) : const Color(0xFFFFCA28)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, effectiveIsPetting ? 4 : 2);
    canvas.drawCircle(const Offset(0, -52), effectiveIsPetting ? 5.8 : 4.5, gemPaint);
    canvas.drawCircle(const Offset(-1, -53), 1.8, Paint()..color = Colors.white);
  }

  static void _drawCanopyLightMotes(
    Canvas canvas,
    double t, {
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    final count = effectiveIsPetting ? 9 : 7;
    final attractX = touchX * 42.0;
    final attractY = touchY * 30.0;

    for (int i = 0; i < count; i++) {
      final phase = (t + (i * (1.0 / count))) % 1.0;
      final angle = (i * (2 * pi / count)) + (phase * pi);
      final mx = cos(angle) * (50.0 + sin(phase * 2 * pi) * 20.0) + attractX * 0.35;
      final my = -60.0 + sin(angle) * 35.0 + attractY * 0.35;
      final alpha = sin(phase * pi) * (effectiveIsPetting ? 0.95 : 0.75);
      final motePaint = Paint()
        ..color = (effectiveIsPetting ? const Color(0xFFB9F6CA) : const Color(0xFFC8E6C9)).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(mx, my), effectiveIsPetting ? 4.0 : 3.0, motePaint);
    }
  }

  static void _drawCelestialAuraRings(
    Canvas canvas,
    double t, {
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    final cycle = t * 2 * pi;
    final ringPaint = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: (effectiveIsPetting ? 0.45 : 0.28) + sin(cycle) * 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = effectiveIsPetting ? 1.8 : 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final shift = Offset(touchX * 14.0, touchY * 10.0);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -35) + shift, width: 140, height: 42),
      ringPaint,
    );

    // Segundo anillo orbital celestial ortogonal en modo caricia
    if (effectiveIsPetting) {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -35) + shift, width: 110, height: 65),
        ringPaint,
      );
    }
  }

  static void _drawFloralCirclet(
    Canvas canvas,
    double t, {
    required bool effectiveIsPetting,
    required double touchX,
    required double touchY,
    required bool isFingerActive,
  }) {
    final circletPaint = Paint()
      ..color = (effectiveIsPetting ? const Color(0xFF69F0AE) : const Color(0xFF80E2BF))
          .withValues(alpha: effectiveIsPetting ? 0.95 : 0.75);

    final speed = effectiveIsPetting ? 2.2 : 0.5;
    final tiltX = touchX * 8.0;
    final tiltY = touchY * 5.0;

    for (int i = 0; i < 7; i++) {
      final angle = (i * (2 * pi / 7)) + (t * speed);
      final px = cos(angle) * 32.0 + tiltX;
      final py = -70.0 + sin(angle) * 8.0 + tiltY;
      canvas.drawCircle(Offset(px, py), effectiveIsPetting ? 4.2 : 3.2, circletPaint);
    }
  }

  static void _drawDivineCrown(
    Canvas canvas,
    double t, {
    required bool effectiveIsPetting,
  }) {
    final crestPath = Path();
    final crestPulse = sin(t * 2 * pi * (effectiveIsPetting ? 3.0 : 1.0)) * (effectiveIsPetting ? 6.0 : 3.0);

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

  static void _drawSacredForeheadSpiral(Canvas canvas) {
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

  static void drawForestSpiritOrbs(Canvas canvas, double t, {required bool inFront}) {
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
}
