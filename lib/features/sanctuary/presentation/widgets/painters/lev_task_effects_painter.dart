import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';

/// Pintor especializado para los efectos visuales somáticos asociados a cada acción de microhábito.
class LevTaskEffectsPainter {
  const LevTaskEffectsPainter._();

  static void draw(
    Canvas canvas,
    double t,
    LevTaskAction taskAction, {
    required void Function(Canvas, double, double) onDrawSleepingZzz,
  }) {
    switch (taskAction) {
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
        onDrawSleepingZzz(canvas, t, 1.0);
        break;
      case LevTaskAction.chestStretch:
        break;
      case LevTaskAction.prayer:
        _drawPrayerCelestialAura(canvas, t);
        break;
    }
  }

  static void _drawPrayerCelestialAura(Canvas canvas, double t) {
    final pulse = (sin(t * 2 * pi) + 1.0) * 0.5;
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35 + pulse * 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(const Offset(0, -10), 32 + pulse * 8, glowPaint);

    final sparklePaint = Paint()
      ..color = const Color(0xFFFFF9C4).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) + t * pi;
      final dist = 24.0 + pulse * 6.0;
      canvas.drawCircle(Offset(cos(angle) * dist, -10 + sin(angle) * dist), 2.0, sparklePaint);
    }
  }
  static void _drawEyeRestGlow(Canvas canvas, double t) {
    final pulse = (sin(t * 2 * pi) + 1.0) * 0.5;
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35 + pulse * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(const Offset(-13, -28), 10 + pulse * 4, glowPaint);
    canvas.drawCircle(const Offset(13, -28), 10 + pulse * 4, glowPaint);
  }

  static void _drawHeartCalmPulse(Canvas canvas, double t) {
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

  static void _drawColdSplashDrops(Canvas canvas, double t) {
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

  static void _drawTensionDischarge(Canvas canvas, double t) {
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

  static void _drawGroundingRoots(Canvas canvas, double t) {
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

  static void _drawWarmTeaSteam(Canvas canvas, double t) {
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

  static void _drawBreathMist(Canvas canvas, double t) {
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

}