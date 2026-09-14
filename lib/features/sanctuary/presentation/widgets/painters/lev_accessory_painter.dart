import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';

/// Dibujador especializado de accesorios botánicos y de abrigo para Lev.
class LevAccessoryPainter {
  const LevAccessoryPainter._();

  static void draw(Canvas canvas, double t, LevAccessory accessory) {
    switch (accessory) {
      case LevAccessory.none:
        break;
      case LevAccessory.sakuraFlower:
        _drawSakuraAccessory(canvas, t);
        break;
      case LevAccessory.cloverSprout:
        _drawCloverAccessory(canvas, t);
        break;
      case LevAccessory.lavenderScarf:
        _drawLavenderScarf(canvas, t);
        break;
      case LevAccessory.nightCap:
        _drawNightCap(canvas, t);
        break;
      case LevAccessory.goldenCrown:
        _drawGoldenCrown(canvas, t);
        break;
    }
  }

  static void _drawSakuraAccessory(Canvas canvas, double t) {
    final sway = sin(t * 2 * pi) * 0.06;
    canvas.save();
    canvas.translate(28, -52);
    canvas.rotate(sway);

    final petalPaint = Paint()..color = const Color(0xFFFFD1DC);
    for (int i = 0; i < 5; i++) {
      final a = (i * 2 * pi / 5);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cos(a) * 7.5, sin(a) * 7.5), width: 11, height: 7),
        petalPaint,
      );
    }
    final centerPaint = Paint()..color = const Color(0xFFFFE082);
    canvas.drawCircle(Offset.zero, 3.5, centerPaint);
    canvas.restore();
  }

  static void _drawCloverAccessory(Canvas canvas, double t) {
    final sway = sin(t * 2 * pi) * 0.10;
    canvas.save();
    canvas.translate(0, -68);
    canvas.rotate(sway);

    // Tallito
    final stemPaint = Paint()
      ..color = const Color(0xFF43A047)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 14), Offset.zero, stemPaint);

    // 4 hojitas
    final leafPaint = Paint()..color = const Color(0xFF66BB6A);
    for (int i = 0; i < 4; i++) {
      final a = (i * pi / 2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cos(a) * 6, sin(a) * 6), width: 8, height: 5.5),
        leafPaint,
      );
    }
    canvas.restore();
  }

  static void _drawLavenderScarf(Canvas canvas, double t) {
    final flutter = sin(t * 2 * pi + 0.5) * 3.0;

    // Banda principal del cuello
    final scarfPaint = Paint()..color = const Color(0xFFB39DDB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 24), width: 62, height: 16),
        const Radius.circular(8),
      ),
      scarfPaint,
    );

    // Textura tejida
    final knitPaint = Paint()
      ..color = const Color(0xFF9575CD)
      ..strokeWidth = 1.2;
    for (double x = -24; x <= 24; x += 8) {
      canvas.drawLine(Offset(x, 17), Offset(x, 31), knitPaint);
    }

    // Extremo colgante con flecos
    final fringePath = Path();
    fringePath.moveTo(10, 28);
    fringePath.lineTo(16 + flutter, 52);
    fringePath.lineTo(26 + flutter, 50);
    fringePath.lineTo(22, 28);
    fringePath.close();

    canvas.drawPath(fringePath, scarfPaint);
  }

  static void _drawNightCap(Canvas canvas, double t) {
    final bob = sin(t * 2 * pi) * 2.0;

    canvas.save();
    canvas.translate(0, -60);

    // Banda blanca
    final bandPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 4), width: 50, height: 12),
        const Radius.circular(6),
      ),
      bandPaint,
    );

    // Cono del gorro
    final capPaint = Paint()..color = const Color(0xFF5C6BC0);
    final capPath = Path();
    capPath.moveTo(-20, 0);
    capPath.quadraticBezierTo(-5, -28, 28 + bob, -16);
    capPath.quadraticBezierTo(14, 0, 20, 0);
    capPath.close();
    canvas.drawPath(capPath, capPaint);

    // Pompón blanco en la punta
    final pompomPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(28 + bob, -16), 6.5, pompomPaint);

    canvas.restore();
  }

  static void _drawGoldenCrown(Canvas canvas, double t) {
    final shimmer = 0.85 + sin(t * 4 * pi) * 0.15;

    canvas.save();
    canvas.translate(0, -68);

    // Halo dorado suave
    final auraPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35 * shimmer)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset.zero, 18, auraPaint);

    // Diadema / Corona de hojas
    final leafPaint = Paint()..color = const Color(0xFFFFC107);
    for (int i = -3; i <= 3; i++) {
      if (i == 0) continue;
      final x = i * 6.5;
      final y = -(4 - i.abs()).toDouble() * 2.5;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 6.5, height: 10),
        leafPaint,
      );
    }
    // Gema central
    final gemPaint = Paint()..color = const Color(0xFFFFFDE7);
    canvas.drawCircle(const Offset(0, -10), 3.0, gemPaint);

    canvas.restore();
  }
}
