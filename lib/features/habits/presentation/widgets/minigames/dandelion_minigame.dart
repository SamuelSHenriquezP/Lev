import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
class DandelionMinigame extends StatefulWidget {
  const DandelionMinigame({super.key});

  @override
  State<DandelionMinigame> createState() => _DandelionMinigameState();
}

class _DandelionSeed {
  final double angle;
  final double length;
  double x;
  double y;
  double vx = 0.0;
  double vy = 0.0;
  double rotation;
  double spin = 0.0;
  bool isFlying = false;
  double opacity = 0.95;

  _DandelionSeed({
    required this.angle,
    required this.length,
    required this.x,
    required this.y,
    required this.rotation,
  });
}

class _DandelionMinigameState extends State<DandelionMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_DandelionSeed> _seeds = [];
  final Random _rnd = Random();
  int _releasedCount = 0;
  Offset _flowerCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();
  }

  void _initSeeds(Size size) {
    if (_seeds.isNotEmpty) return;
    _flowerCenter = Offset(size.width * 0.5, size.height * 0.62);

    // Generar 36 vilanos de diente de león
    for (int i = 0; i < 36; i++) {
      final a = (i / 36) * 2 * pi;
      final dist = 18.0 + _rnd.nextDouble() * 32.0;
      final sx = _flowerCenter.dx + cos(a) * dist;
      final sy = _flowerCenter.dy + sin(a) * dist;

      _seeds.add(
        _DandelionSeed(
          angle: a,
          length: dist,
          x: sx,
          y: sy,
          rotation: a,
        ),
      );
    }
  }

  void _tick() {
    for (final s in _seeds) {
      if (s.isFlying) {
        s.x += s.vx + sin(s.y * 0.04) * 0.9;
        s.y += s.vy;
        s.rotation += s.spin;
        s.vy = (s.vy * 0.985) - 0.04; // flotación aerodinámica ascendente

        if (s.y < 30) {
          s.opacity = (s.opacity - 0.02).clamp(0.0, 1.0);
        }
      }
    }
    setState(() {});
  }

  void _releaseNearbySeeds(Offset touch) {
    bool releasedAny = false;
    for (final s in _seeds) {
      if (!s.isFlying) {
        final d = (Offset(s.x, s.y) - touch).distance;
        if (d < 65) {
          s.isFlying = true;
          s.vx = (s.x - touch.dx) * 0.06 + (_rnd.nextDouble() - 0.4) * 1.5;
          s.vy = -3.2 - _rnd.nextDouble() * 2.6;
          s.spin = (_rnd.nextDouble() - 0.5) * 0.12;
          _releasedCount++;
          releasedAny = true;
        }
      }
    }
    if (releasedAny) {
      HapticsHelper.light();
    }
  }

  void _resetDandelion() {
    HapticsHelper.medium();
    setState(() {
      _seeds.clear();
    });
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
                  'Pensamientos soltados: $_releasedCount',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _resetDandelion,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Nuevo brote'),
                style: TextButton.styleFrom(
                  foregroundColor: LevTheme.levMatchaDark,
                  textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _initSeeds(Size(constraints.maxWidth, constraints.maxHeight));

                  return GestureDetector(
                    onTapDown: (details) => _releaseNearbySeeds(details.localPosition),
                    onPanUpdate: (details) => _releaseNearbySeeds(details.localPosition),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFE8F2EA), // Cielo suave salvia
                            Color(0xFFF9F6F0), // Calidez terrena
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _DandelionPainter(
                          seeds: _seeds,
                          flowerCenter: _flowerCenter,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DandelionPainter extends CustomPainter {
  final List<_DandelionSeed> seeds;
  final Offset flowerCenter;

  _DandelionPainter({required this.seeds, required this.flowerCenter});

  @override
  void paint(Canvas canvas, Size size) {
    final fc = flowerCenter.dx == 0 ? Offset(size.width * 0.5, size.height * 0.62) : flowerCenter;

    // 1. Tallo verde botánico curvado
    final stemPaint = Paint()
      ..color = const Color(0xFF7A9E7E)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(fc.dx, fc.dy);
    stemPath.quadraticBezierTo(fc.dx - 12, size.height * 0.82, fc.dx - 6, size.height);
    canvas.drawPath(stemPath, stemPaint);

    // 2. Receptáculo central de la flor
    final centerPaint = Paint()..color = const Color(0xFF5A755D);
    canvas.drawCircle(fc, 11.0, centerPaint);
    final corePaint = Paint()..color = const Color(0xFF8DA38A);
    canvas.drawCircle(fc, 6.0, corePaint);

    // 3. Semillas y vilanos plumosos
    for (final s in seeds) {
      if (s.opacity <= 0.0) continue;

      canvas.save();
      canvas.translate(s.x, s.y);
      canvas.rotate(s.rotation);

      // Filamento
      final filPaint = Paint()
        ..color = const Color(0xFF37474F).withValues(alpha: s.opacity * 0.55)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset.zero, const Offset(0, 14), filPaint);

      // Plumón esponjoso (brácteas blancas de paracaídas)
      final fluffPaint = Paint()
        ..color = Colors.white.withValues(alpha: s.opacity * 0.85)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;

      for (int i = -3; i <= 3; i++) {
        canvas.drawLine(
          Offset.zero,
          Offset(i * 3.5, -8.0 - (i.abs() * 1.5)),
          fluffPaint,
        );
      }

      // Semilla marrón diminuta en la base
      final seedDotPaint = Paint()..color = const Color(0xFF6D4C41).withValues(alpha: s.opacity);
      canvas.drawCircle(const Offset(0, 14), 2.2, seedDotPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DandelionPainter oldDelegate) => true;
}