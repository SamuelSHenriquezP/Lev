import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/sanctuary_state.dart';

/// Pintor vectorial de alta precisión para "Lev: La Planta de Luz".
/// Reproducción 1:1 de la ilustración botánica con soporte para
/// TRANSICIONES CONTINUAS SUAVES (sin cortes abruptos ni posturas estáticas).
class LivingSeedSpiritPainter extends CustomPainter {
  final double animationValue; // 0.0 a 1.0 (tiempo armónico continuo a 60 FPS)
  final LevEmotion emotion;
  final bool isPetting;
  final double sizeScale;

  // Factores de transición suave (0.0 a 1.0 interpolados dinámicamente)
  final double leafWrapProgress;   // 0.0 (abiertas) a 1.0 (abrazo protector envuelto)
  final double sleepProgress;      // 0.0 (despierto) a 1.0 (siesta plácida con Zzz)
  final double happyProgress;      // 0.0 (calma) a 1.0 (cosquillas / risa)
  final double breathingProgress;  // 0.0 a 1.0 (respiración somática profunda)
  final double jumpProgress;       // 0.0 a 1.0 (salto elástico con anticipación)

  LivingSeedSpiritPainter({
    required this.animationValue,
    required this.emotion,
    required this.isPetting,
    this.sizeScale = 1.0,
    this.leafWrapProgress = 0.0,
    this.sleepProgress = 0.0,
    this.happyProgress = 0.0,
    this.breathingProgress = 0.0,
    this.jumpProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.48;

    final t = animationValue;
    final cycle = t * 2 * pi;

    // --- 1. FÍSICA BASE CONTINUA (LEV NUNCA ESTÁ ESTÁTICO) ---
    // Incluso al dormir o abrazar, siempre hay un flujo vivo de flotación y respiración
    final baseFloatY = sin(cycle) * 7.0;
    final baseBreatheY = sin(cycle) * 0.024;
    final baseBreatheX = -baseBreatheY * 0.6;
    final baseSway = sin(cycle) * 0.020;

    // --- 2. CAPA DE RESPIRACIÓN SOMÁTICA GUIADA ---
    final deepBreatheY = sin(cycle) * 0.12 * breathingProgress;
    final deepBreatheX = -deepBreatheY * 0.55;

    // --- 3. CAPA DE SIESTA Y REPOSO ---
    final sleepSway = 0.065 * sleepProgress;
    final sleepFloat = 6.0 * sleepProgress;

    // --- 4. CAPA DE CARICIAS / COSQUILLAS ---
    final happySway = sin(cycle * 3.2) * 0.08 * happyProgress;
    final happyFloat = sin(cycle * 2.0) * 4.0 * happyProgress;

    // --- 5. CAPA DE SALTO ELÁSTICO DE ALEGRÍA ---
    double jumpFloatY = 0.0;
    double jumpScaleY = 0.0;
    double jumpScaleX = 0.0;
    double jumpSway = 0.0;

    if (jumpProgress > 0.0 && jumpProgress <= 1.0) {
      if (jumpProgress < 0.20) {
        // Anticipación: compresión elástica hacia abajo
        final p = jumpProgress / 0.20;
        jumpScaleY = -0.16 * sin(p * pi);
        jumpScaleX = 0.12 * sin(p * pi);
        jumpFloatY = 8.0 * sin(p * pi);
      } else if (jumpProgress < 0.70) {
        // Despegue, elevación y estiramiento en el aire
        final p = (jumpProgress - 0.20) / 0.50;
        jumpFloatY = -48.0 * sin(p * pi);
        jumpScaleY = 0.16 * sin(p * pi);
        jumpScaleX = -0.10 * sin(p * pi);
        jumpSway = sin(p * pi) * 0.06;
      } else {
        // Aterrizaje con rebote amortiguado
        final p = (jumpProgress - 0.70) / 0.30;
        final bounce = sin(p * pi * 2) * exp(-p * 3.5);
        jumpScaleY = -0.10 * bounce;
        jumpScaleX = 0.06 * bounce;
        jumpFloatY = -bounce * 6.0;
      }
    }

    // Composición final de transformaciones sinérgicas
    final finalFloatY = baseFloatY + sleepFloat + happyFloat + jumpFloatY;
    final finalSway = baseSway + sleepSway + happySway + jumpSway;
    final finalScaleY = 1.0 + baseBreatheY + deepBreatheY + jumpScaleY;
    final finalScaleX = 1.0 + baseBreatheX + deepBreatheX + jumpScaleX;

    canvas.save();
    canvas.translate(centerX, centerY + finalFloatY);
    canvas.rotate(finalSway);
    canvas.scale(sizeScale * finalScaleX, sizeScale * finalScaleY);

    // 1. Resplandor áurico ambiental con modulación suave
    _drawAmbientAura(canvas, t);

    // 2. Grandes Alas Suculentas Laterales (transición suave entre abiertas y abrazo)
    _drawSucculentWingLeaves(canvas, t);

    // 3. Tallo / Base Inferior
    _drawStemBase(canvas);

    // 4. El Bulbo de Semilla / Brote de Llama (Curva botánica 1:1 con arte original)
    _drawFlameBulb(canvas, t);

    // 5. Cáliz Frontal (Sépalos verde menta que abrazan la base)
    _drawFrontCalyx(canvas, t);

    // 6. Rostro de Lev con transición suave entre expresiones
    _drawZenFace(canvas, t);

    // 7. Partículas según los niveles de transición activos
    if (sleepProgress > 0.05) {
      _drawSleepingZzz(canvas, t, sleepProgress);
    }
    if (happyProgress > 0.05 || isPetting) {
      _drawMagicSpores(canvas, t, max(happyProgress, isPetting ? 1.0 : 0.0));
    }
    if (jumpProgress > 0.20 && jumpProgress < 0.85) {
      _drawJoySparks(canvas, jumpProgress);
    }

    canvas.restore();
  }

  /// Resplandor áurico cálido que emite la semilla
  void _drawAmbientAura(Canvas canvas, double t) {
    // Transición suave de opacidad y radio según estado
    final baseAlpha = 0.32;
    final sleepAlphaMod = lerpDouble(0.0, -0.16, sleepProgress)!;
    final breathingPulse = (sin(t * 2 * pi) + 1.0) * 0.5 * 0.28 * breathingProgress;
    final finalAlpha = (baseAlpha + sleepAlphaMod + breathingPulse).clamp(0.12, 0.65);

    final baseRadius = 170.0;
    final breathingRadiusMod = (sin(t * 2 * pi) + 1.0) * 0.5 * 45.0 * breathingProgress;
    final sleepRadiusMod = lerpDouble(0.0, -35.0, sleepProgress)!;
    final finalRadius = baseRadius + breathingRadiusMod + sleepRadiusMod;

    final auraPaint = Paint()
      ..color = const Color(0xFFFFE899).withValues(alpha: finalAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -20), width: finalRadius, height: finalRadius * 1.25),
      auraPaint,
    );
  }

  /// Las dos grandes hojas carnosas a los lados con interpolación angular suave
  void _drawSucculentWingLeaves(Canvas canvas, double t) {
    final cycle = t * 2 * pi;

    // Aleteo dinámico según cosquillas o respiración
    final baseFlutter = sin(cycle + 0.5) * 0.022;
    final happyFlutter = sin(cycle * 3.2) * 0.08 * happyProgress;

    // Ángulo abierto estándar: ±0.36 rad
    // Ángulo de abrazo protector: ±0.82 rad (envuelven el bulbo como mantita)
    final openLeft = -0.36 + baseFlutter + happyFlutter;
    final openRight = 0.36 - baseFlutter - happyFlutter;

    final hugLeft = -0.82;
    final hugRight = 0.82;

    // Transición suave entre postura abierta y abrazo
    var leftAngle = lerpDouble(openLeft, hugLeft, leafWrapProgress)!;
    var rightAngle = lerpDouble(openRight, hugRight, leafWrapProgress)!;

    // Si duerme y no está abrazando, caen suavemente relajadas
    if (leafWrapProgress < 0.5) {
      leftAngle = lerpDouble(leftAngle, -0.22, sleepProgress)!;
      rightAngle = lerpDouble(rightAngle, 0.22, sleepProgress)!;
    }

    // Hoja Izquierda
    canvas.save();
    canvas.translate(-8, 54);
    canvas.rotate(leftAngle);
    _drawSingleSucculentLeaf(
      canvas,
      const Size(100, 44),
      const Color(0xFF287A60),
      const Color(0xFF45A586),
      isLeft: true,
    );
    canvas.restore();

    // Hoja Derecha
    canvas.save();
    canvas.translate(8, 54);
    canvas.rotate(rightAngle);
    _drawSingleSucculentLeaf(
      canvas,
      const Size(100, 44),
      const Color(0xFF287A60),
      const Color(0xFF45A586),
      isLeft: false,
    );
    canvas.restore();
  }

  void _drawSingleSucculentLeaf(
    Canvas canvas,
    Size size,
    Color baseColor,
    Color tipColor, {
    required bool isLeft,
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

    final highlightPaint = Paint()
      ..color = const Color(0xFF74CEB2).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, highlightPaint);
  }

  void _drawStemBase(Canvas canvas) {
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

  void _drawFlameBulb(Canvas canvas, double t) {
    final bulbPath = Path();
    const apex = Offset(8.0, -96.0);

    bulbPath.moveTo(apex.dx, apex.dy);
    bulbPath.cubicTo(
      18.0, -70.0,
      56.0, -25.0,
      56.0, 15.0,
    );
    bulbPath.cubicTo(
      56.0, 42.0,
      28.0, 58.0,
      0.0, 64.0,
    );
    bulbPath.cubicTo(
      -28.0, 58.0,
      -56.0, 42.0,
      -56.0, 15.0,
    );
    bulbPath.cubicTo(
      -56.0, -25.0,
      -22.0, -70.0,
      apex.dx, apex.dy,
    );
    bulbPath.close();

    final bulbRect = const Rect.fromLTWH(-60, -100, 120, 170);
    final bulbShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.42, 0.68, 1.0],
      colors: [
        Color(0xFFFFCF43),
        Color(0xFFFFEEA8),
        Color(0xFF76CBAE),
        Color(0xFF287B61),
      ],
    ).createShader(bulbRect);

    final bulbPaint = Paint()..shader = bulbShader;
    canvas.drawPath(bulbPath, bulbPaint);

    // Resplandor interno dinámico
    final breathingGlow = (sin(t * 2 * pi) + 1.0) * 0.5 * 0.35 * breathingProgress;
    final finalFaceGlowAlpha = (0.45 + breathingGlow).clamp(0.20, 0.85);

    final faceGlowPaint = Paint()
      ..color = const Color(0xFFFFFBE8).withValues(alpha: finalFaceGlowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(const Offset(0, -6), 34, faceGlowPaint);
  }

  void _drawFrontCalyx(Canvas canvas, double t) {
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
  }

  void _drawZenFace(Canvas canvas, double t) {
    const eyeY = -4.0;
    const eyeDist = 19.0;
    final isBlinking = (sleepProgress < 0.3 && t > 0.50 && t < 0.54);

    final featurePaint = Paint()
      ..color = const Color(0xFF0E382B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round;

    if (isBlinking) {
      canvas.drawLine(Offset(-eyeDist - 5, eyeY), Offset(-eyeDist + 5, eyeY), featurePaint);
      canvas.drawLine(Offset(eyeDist - 5, eyeY), Offset(eyeDist + 5, eyeY), featurePaint);
    } else {
      // Interpolación continua de la curva ocular
      _drawSmoothEye(canvas, Offset(-eyeDist, eyeY), 14.0, featurePaint);
      _drawSmoothEye(canvas, Offset(eyeDist, eyeY), 14.0, featurePaint);
    }

    // Sonrisa con curvatura adaptativa suave
    final mouthY = 13.0;
    final mouthDepth = lerpDouble(7.0, 4.0, sleepProgress)!;
    final mouthWidth = lerpDouble(7.5, 5.5, sleepProgress)!;

    final mouthPaint = Paint()
      ..color = const Color(0xFF0E382B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(-mouthWidth, mouthY);
    mouthPath.quadraticBezierTo(0, mouthY + mouthDepth, mouthWidth, mouthY);
    canvas.drawPath(mouthPath, mouthPaint);

    // Sonrojo difuminado suave
    final cheekAlpha = lerpDouble(0.14, 0.32, max(happyProgress, isPetting ? 1.0 : 0.0))!;
    final cheekPaint = Paint()
      ..color = const Color(0xFFFFAE52).withValues(alpha: cheekAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-28, 6), width: 16, height: 10),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(28, 6), width: 16, height: 10),
      cheekPaint,
    );
  }

  /// Dibuja el ojo interpolando suavemente entre zen, feliz y dormilón
  void _drawSmoothEye(Canvas canvas, Offset center, double width, Paint paint) {
    // Desplazamiento del punto de control según estado:
    // Zen estándar: +6.8 (arco hacia abajo ⌣)
    // Feliz: -6.5 (arco hacia arriba ^)
    // Dormilón: +4.5 (arco más suave y relajado)
    final happyWeight = max(happyProgress, isPetting ? 1.0 : 0.0);
    final zenCurve = 6.8;
    final happyCurve = -6.5;
    final sleepCurve = 4.5;

    var currentCurve = lerpDouble(zenCurve, happyCurve, happyWeight)!;
    currentCurve = lerpDouble(currentCurve, sleepCurve, sleepProgress)!;

    final path = Path();
    path.moveTo(center.dx - width * 0.5, center.dy);
    path.quadraticBezierTo(
      center.dx,
      center.dy + currentCurve,
      center.dx + width * 0.5,
      center.dy,
    );
    canvas.drawPath(path, paint);
  }

  /// Burbujitas Zzz que flotan hacia arriba al dormitar con opacidad suave
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

  /// Esporas mágicas flotantes de luz cálida con fade suave
  void _drawMagicSpores(Canvas canvas, double t, double opacity) {
    for (int i = 0; i < 5; i++) {
      final phase = (t + (i * 0.20)) % 1.0;
      final x = sin(phase * 2 * pi + i * 1.5) * 48.0;
      final y = -45.0 - (phase * 80.0);
      final alpha = ((1.0 - phase) * 0.85 * opacity).clamp(0.0, 1.0);

      final sporePaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), 3.5 + (1.0 - phase) * 2.5, sporePaint);
    }
  }

  /// Corona de chispas en salto alegre
  void _drawJoySparks(Canvas canvas, double p) {
    for (int i = 0; i < 6; i++) {
      final angle = (i * (2 * pi / 6)) + (p * pi);
      final dist = 40.0 + (sin(p * pi) * 38.0);
      final x = cos(angle) * dist;
      final y = sin(angle) * dist - 24;

      final sparkPaint = Paint()
        ..color = const Color(0xFFFFCF43).withValues(alpha: sin(p * pi) * 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), 3.2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LivingSeedSpiritPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.emotion != emotion ||
        oldDelegate.isPetting != isPetting ||
        oldDelegate.sizeScale != sizeScale ||
        oldDelegate.leafWrapProgress != leafWrapProgress ||
        oldDelegate.sleepProgress != sleepProgress ||
        oldDelegate.happyProgress != happyProgress ||
        oldDelegate.breathingProgress != breathingProgress ||
        oldDelegate.jumpProgress != jumpProgress;
  }
}
