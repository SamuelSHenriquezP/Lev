import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
class WaterRippleMinigame extends StatefulWidget {
  const WaterRippleMinigame({super.key});

  @override
  State<WaterRippleMinigame> createState() => _WaterRippleMinigameState();
}

class _WaterRipple {
  final Offset center;
  double radius = 0.0;
  final double maxRadius;
  double alpha = 0.85;
  final double speed;
  final Color color;

  _WaterRipple({
    required this.center,
    required this.maxRadius,
    required this.speed,
    required this.color,
  });
}

class _WaterRippleMinigameState extends State<WaterRippleMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_WaterRipple> _ripples = [];
  final Random _rnd = Random();
  int _dropsCount = 0;
  bool _isRainActive = false;
  int _rainTick = 0;
  Offset? _lastDragPoint;

  final List<Color> _rippleColors = [
    const Color(0xFF64B5F6),
    const Color(0xFF81D4FA),
    const Color(0xFF80CBC4),
    const Color(0xFFB2DFDB),
    const Color(0xFFE0F7FA),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();
  }

  void _tick() {
    // Actualizar ondas activas
    for (int i = _ripples.length - 1; i >= 0; i--) {
      final r = _ripples[i];
      r.radius += r.speed;
      r.alpha = (1.0 - (r.radius / r.maxRadius)).clamp(0.0, 1.0) * 0.85;
      if (r.radius >= r.maxRadius) {
        _ripples.removeAt(i);
      }
    }

    // Lógica de lluvia serena automática
    if (_isRainActive) {
      _rainTick++;
      if (_rainTick % 22 == 0) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          final x = 40.0 + _rnd.nextDouble() * (size.width - 80.0);
          final y = 40.0 + _rnd.nextDouble() * (size.height - 80.0);
          _spawnRipple(Offset(x, y), isRain: true);
        }
      }
    }

    setState(() {});
  }

  void _spawnRipple(Offset point, {bool isRain = false}) {
    if (!isRain) {
      HapticsHelper.selection();
    }
    _dropsCount++;
    final color = _rippleColors[_rnd.nextInt(_rippleColors.length)];
    _ripples.add(
      _WaterRipple(
        center: point,
        maxRadius: 110.0 + _rnd.nextDouble() * 50.0,
        speed: 1.9 + _rnd.nextDouble() * 1.1,
        color: color,
      ),
    );
    if (_ripples.length > 25) {
      _ripples.removeRange(0, _ripples.length - 25);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lastDragPoint == null || (details.localPosition - _lastDragPoint!).distance > 40) {
      _lastDragPoint = details.localPosition;
      _spawnRipple(details.localPosition);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Gotas de calma: $_dropsCount',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticsHelper.light();
                  setState(() => _isRainActive = !_isRainActive);
                },
                icon: Icon(
                  _isRainActive ? Icons.pause_circle_rounded : Icons.grain_rounded,
                  size: 16,
                  color: _isRainActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                ),
                label: Text(
                  _isRainActive ? 'Pausar lluvia' : 'Lluvia serena',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isRainActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                  ),
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
                onTapDown: (details) {
                  _lastDragPoint = details.localPosition;
                  _spawnRipple(details.localPosition);
                },
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _lastDragPoint = null,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF132A26), // Agua profunda y tranquila
                  child: CustomPaint(
                    painter: _WaterRipplePainter(
                      ripples: List.from(_ripples),
                      timeProgress: _controller.value,
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

class _WaterRipplePainter extends CustomPainter {
  final List<_WaterRipple> ripples;
  final double timeProgress;

  _WaterRipplePainter({required this.ripples, required this.timeProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gradiente del fondo del estanque
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: const [
          Color(0xFF1B3833),
          Color(0xFF0F211E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Dibujar hojas de loto flotantes
    _drawLilyPad(canvas, Offset(size.width * 0.25, size.height * 0.30), 38, 0.4, 0);
    _drawLilyPad(canvas, Offset(size.width * 0.78, size.height * 0.42), 44, -0.6, 1);
    _drawLilyPad(canvas, Offset(size.width * 0.35, size.height * 0.76), 34, 1.2, 2);

    // 3. Dibujar flor de loto rosada
    _drawLotusFlower(canvas, Offset(size.width * 0.78, size.height * 0.40));

    // 4. Ondas concéntricas de agua
    for (final r in ripples) {
      if (r.radius <= 0) continue;

      // Anillo principal
      final mainPaint = Paint()
        ..color = r.color.withValues(alpha: r.alpha)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(r.center, r.radius, mainPaint);

      // Anillo de eco secundario
      if (r.radius > 16) {
        final echoPaint = Paint()
          ..color = r.color.withValues(alpha: r.alpha * 0.55)
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(r.center, r.radius * 0.70, echoPaint);
      }

      // Destello central
      if (r.radius < 26) {
        final flashPaint = Paint()
          ..color = Colors.white.withValues(alpha: (1.0 - (r.radius / 26)).clamp(0.0, 1.0) * 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(r.center, 3.5, flashPaint);
      }
    }
  }

  void _drawLilyPad(Canvas canvas, Offset baseCenter, double radius, double angle, int id) {
    final bob = sin((timeProgress + (id * 0.33)) * 2 * pi) * 2.5;
    final center = Offset(baseCenter.dx, baseCenter.dy + bob);

    // Sombra del nenúfar
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(center.dx, center.dy + 3), radius, shadowPaint);

    // Cuerpo de la hoja
    final padPaint = Paint()..color = const Color(0xFF2A574A);
    canvas.drawCircle(center, radius, padPaint);

    // Borde más claro
    final edgePaint = Paint()
      ..color = const Color(0xFF3F7766)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, edgePaint);

    // Muesca triangular de la hoja
    final cutPath = Path();
    cutPath.moveTo(center.dx, center.dy);
    cutPath.lineTo(center.dx + cos(angle - 0.22) * radius * 1.05, center.dy + sin(angle - 0.22) * radius * 1.05);
    cutPath.lineTo(center.dx + cos(angle + 0.22) * radius * 1.05, center.dy + sin(angle + 0.22) * radius * 1.05);
    cutPath.close();

    final cutPaint = Paint()..color = const Color(0xFF1B3833);
    canvas.drawPath(cutPath, cutPaint);
  }

  void _drawLotusFlower(Canvas canvas, Offset center) {
    final bob = sin((timeProgress + 0.33) * 2 * pi) * 2.5;
    final c = Offset(center.dx, center.dy + bob);

    final petalPaint = Paint()..color = const Color(0xFFFFD1DC).withValues(alpha: 0.9);
    for (int i = 0; i < 6; i++) {
      final a = i * (pi / 3);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + cos(a) * 9, c.dy + sin(a) * 9),
          width: 14,
          height: 8,
        ),
        petalPaint,
      );
    }

    final heartPaint = Paint()..color = const Color(0xFFFFE082);
    canvas.drawCircle(c, 4.5, heartPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterRipplePainter oldDelegate) => true;
}