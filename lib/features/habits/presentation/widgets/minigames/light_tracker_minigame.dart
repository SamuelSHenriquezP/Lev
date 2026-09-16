import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
class LightTrackerMinigame extends StatefulWidget {
  const LightTrackerMinigame({super.key});

  @override
  State<LightTrackerMinigame> createState() => _LightTrackerMinigameState();
}

class _LightTrackerMinigameState extends State<LightTrackerMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    // Órbita armónica lenta en figura 8 (6 segundos por ciclo completo)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
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
                  'Sigue la luz con tu mirada y tu dedo',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isFollowing ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 13, color: LevTheme.levMatchaDark),
                      const SizedBox(width: 4),
                      Text(
                        'En sintonía',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levMatchaDark,
                        ),
                      ),
                    ],
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
                onPanDown: (details) => _checkTouch(details.localPosition),
                onPanUpdate: (details) => _checkTouch(details.localPosition),
                onPanEnd: (_) => setState(() => _isFollowing = false),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF22352E), // Bosque nocturno relajante
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _LightOrbPainter(
                          progress: _controller.value,
                          isFollowing: _isFollowing,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _checkTouch(Offset touch) {
    // Comprobar cercanía a la órbita de luz
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final orbPos = _LightOrbPainter.calculateOrbPosition(
        _controller.value,
        renderBox.size,
      );
      final dist = (touch - orbPos).distance;
      if (dist < 60) {
        if (!_isFollowing) {
          HapticsHelper.light();
        }
        setState(() => _isFollowing = true);
      } else {
        setState(() => _isFollowing = false);
      }
    }
  }
}

class _LightOrbPainter extends CustomPainter {
  final double progress;
  final bool isFollowing;

  _LightOrbPainter({required this.progress, required this.isFollowing});

  static Offset calculateOrbPosition(double t, Size size) {
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final cycle = t * 2 * pi;

    // Curva de Lissajous armónica suave (figura 8)
    final x = centerX + sin(cycle) * (size.width * 0.35);
    final y = centerY + sin(cycle * 2) * (size.height * 0.28);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final orbPos = calculateOrbPosition(progress, size);

    // 1. Estela de luz tenue
    final trailPaint = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 0.12)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double i = 0; i <= 1.0; i += 0.02) {
      final p = calculateOrbPosition(i, size);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, trailPaint);

    // 2. Halo áurico brillante
    final haloRadius = isFollowing ? 54.0 : 38.0;
    final haloPaint = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: isFollowing ? 0.55 : 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(orbPos, haloRadius, haloPaint);

    // 3. Núcleo de la luciérnaga
    final corePaint = Paint()..color = const Color(0xFFFFFDE7);
    canvas.drawCircle(orbPos, 8.0, corePaint);
  }

  @override
  bool shouldRepaint(covariant _LightOrbPainter oldDelegate) => true;
}