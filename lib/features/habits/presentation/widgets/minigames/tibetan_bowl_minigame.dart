import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
class TibetanBowlMinigame extends StatefulWidget {
  const TibetanBowlMinigame({super.key});

  @override
  State<TibetanBowlMinigame> createState() => _TibetanBowlMinigameState();
}

class _TibetanBowlMinigameState extends State<TibetanBowlMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _resonance = 0.0;
  double? _lastAngle;
  double _gongWaveRadius = 0.0;
  double _gongWaveAlpha = 0.0;
  Offset? _touchPos;
  int _hapticCooldown = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();
  }

  void _tick() {
    // Decaimiento suave de la resonancia si no se frota
    _resonance = (_resonance - 0.0035).clamp(0.0, 1.0);

    // Onda expansiva del gong
    if (_gongWaveAlpha > 0.0) {
      _gongWaveRadius += 4.8;
      _gongWaveAlpha = (_gongWaveAlpha - 0.024).clamp(0.0, 1.0);
    }

    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    _touchPos = details.localPosition;
    _lastAngle = _calculateAngle(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _touchPos = details.localPosition;
    final newAngle = _calculateAngle(details.localPosition);

    if (_lastAngle != null) {
      double diff = (newAngle - _lastAngle!).abs();
      if (diff > pi) diff = (2 * pi - diff).abs();

      // Si gira a velocidad armónica
      if (diff > 0.03 && diff < 0.9) {
        _resonance = (_resonance + diff * 0.20).clamp(0.0, 1.0);
        _hapticCooldown++;
        if (_hapticCooldown % 9 == 0) {
          HapticsHelper.light();
        }
      }
    }
    _lastAngle = newAngle;
  }

  void _onPanEnd(DragEndDetails details) {
    _touchPos = null;
    _lastAngle = null;
  }

  void _onTapDown(TapDownDetails details) {
    _touchPos = details.localPosition;
    // Toque seco: Gong
    HapticsHelper.medium();
    _gongWaveRadius = 60.0;
    _gongWaveAlpha = 0.95;
    _resonance = (_resonance + 0.28).clamp(0.0, 1.0);
  }

  double _calculateAngle(Offset touch) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return 0.0;
    final center = Offset(renderBox.size.width * 0.5, renderBox.size.height * 0.5);
    return atan2(touch.dy - center.dy, touch.dx - center.dx);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resonancePct = (_resonance * 100).toInt();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Resonancia: $resonancePct%',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _resonance > 0.6 ? const Color(0xFFC59B27) : LevTheme.levTextDark,
                  ),
                ),
              ),
              Text(
                'Toca o gira el borde',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: LevTheme.levTextMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: GestureDetector(
                onTapDown: _onTapDown,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF1F1A17), // Tatami oscuro de templo
                  child: CustomPaint(
                    painter: _TibetanBowlPainter(
                      resonance: _resonance,
                      gongRadius: _gongWaveRadius,
                      gongAlpha: _gongWaveAlpha,
                      touchPos: _touchPos,
                      animValue: _controller.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TibetanBowlPainter extends CustomPainter {
  final double resonance;
  final double gongRadius;
  final double gongAlpha;
  final Offset? touchPos;
  final double animValue;

  _TibetanBowlPainter({
    required this.resonance,
    required this.gongRadius,
    required this.gongAlpha,
    required this.touchPos,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final bowlRadius = min(size.width, size.height) * 0.32;

    // 1. Ondas armónicas doradas emanando del cuenco
    if (resonance > 0.05) {
      for (int i = 0; i < 3; i++) {
        final progress = (animValue + (i * 0.33)) % 1.0;
        final waveRadius = bowlRadius + progress * 75.0;
        final waveAlpha = (1.0 - progress) * resonance * 0.65;

        final soundPaint = Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: waveAlpha)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, waveRadius, soundPaint);
      }
    }

    // 2. Onda expansiva del Gong seco
    if (gongAlpha > 0.0) {
      final gongPaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: gongAlpha)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, gongRadius, gongPaint);
    }

    // 3. Cojín de seda roja bajo el cuenco
    final cushionPaint = Paint()..color = const Color(0xFF8B2522);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + bowlRadius * 0.75), width: bowlRadius * 1.8, height: bowlRadius * 0.45),
        const Radius.circular(16),
      ),
      cushionPaint,
    );
    // Borde dorado del cojín
    final cushionTrim = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + bowlRadius * 0.75), width: bowlRadius * 1.8, height: bowlRadius * 0.45),
        const Radius.circular(16),
      ),
      cushionTrim,
    );

    // 4. Halo dorado brillante cuando hay alta resonancia
    if (resonance > 0.2) {
      final pulse = sin(animValue * 8 * pi) * 6.0;
      final haloPaint = Paint()
        ..color = const Color(0xFFFFC107).withValues(alpha: resonance * 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28 + pulse);
      canvas.drawCircle(center, bowlRadius + 14, haloPaint);
    }

    // 5. Cuerpo del Cuenco Tibetano de Bronce
    final bowlPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.88,
        colors: const [
          Color(0xFFE5C06E),
          Color(0xFFB38F39),
          Color(0xFF6B4F1A),
          Color(0xFF38290E),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: bowlRadius));
    canvas.drawCircle(center, bowlRadius, bowlPaint);

    // 6. Interior cóncavo del cuenco
    final interiorPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.8,
        colors: const [
          Color(0xFF2C1E0D),
          Color(0xFF523D17),
          Color(0xFF8A6A29),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: bowlRadius * 0.82));
    canvas.drawCircle(center, bowlRadius * 0.82, interiorPaint);

    // 7. Borde brillante del cuenco (reborde de bronce pulido)
    final rimPaint = Paint()
      ..color = const Color(0xFFFFF1C5)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, bowlRadius * 0.83, rimPaint);

    // 8. Toque del mazo de madera
    if (touchPos != null) {
      final malletPaint = Paint()..color = const Color(0xFFD7CCC8);
      canvas.drawCircle(touchPos!, 14.0, malletPaint);
      final malletInner = Paint()..color = const Color(0xFF8D6E63);
      canvas.drawCircle(touchPos!, 8.0, malletInner);
    }
  }

  @override
  bool shouldRepaint(covariant _TibetanBowlPainter oldDelegate) => true;
}
