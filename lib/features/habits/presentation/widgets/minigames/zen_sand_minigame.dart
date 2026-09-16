import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
class ZenSandMinigame extends StatefulWidget {
  const ZenSandMinigame({super.key});

  @override
  State<ZenSandMinigame> createState() => _ZenSandMinigameState();
}

class _ZenSandMinigameState extends State<ZenSandMinigame> {
  final List<Offset> _points = [];

  void _clearSand() {
    HapticsHelper.light();
    setState(() {
      _points.clear();
    });
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
                  'Traza ondas lentas con tu dedo',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _clearSand,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Limpiar arena'),
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
              child: GestureDetector(
                onPanDown: (details) {
                  HapticsHelper.selection();
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF2ECE1), // Arena zen cálida
                  child: CustomPaint(
                    painter: _ZenSandPainter(points: _points),
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

class _ZenSandPainter extends CustomPainter {
  final List<Offset> points;

  _ZenSandPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Textura de arena suave con sutiles líneas de rastrillo
    final sandPaint = Paint()
      ..color = const Color(0xFFE5DCCE).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (double y = 20; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), sandPaint);
    }

    // 2. Tres piedras de río con musgo
    _drawRiverStone(canvas, Offset(size.width * 0.32, size.height * 0.38), 34, const Color(0xFF5A626A));
    _drawRiverStone(canvas, Offset(size.width * 0.72, size.height * 0.58), 28, const Color(0xFF4C555E));
    _drawRiverStone(canvas, Offset(size.width * 0.45, size.height * 0.72), 22, const Color(0xFF6B7280));

    // 3. Trazo del dedo del usuario (surco de rastreo)
    if (points.length > 1) {
      final furrowPaint = Paint()
        ..color = const Color(0xFFD4C8B5)
        ..strokeWidth = 16.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final innerPaint = Paint()
        ..color = const Color(0xFFC7B9A3)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      canvas.drawPath(path, furrowPaint);
      canvas.drawPath(path, innerPaint);
    }
  }

  void _drawRiverStone(Canvas canvas, Offset center, double radius, Color color) {
    // Sombra suave de la piedra
    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 4), width: radius * 2.2, height: radius * 1.5),
      shadowPaint,
    );

    // Cuerpo de la piedra
    final stonePaint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2.0, height: radius * 1.4),
      stonePaint,
    );

    // Toque de musgo botánico en la orilla
    final mossPaint = Paint()..color = const Color(0xFF7A9A60).withValues(alpha: 0.75);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.35, center.dy - radius * 0.2), width: radius * 0.8, height: radius * 0.5),
      mossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ZenSandPainter oldDelegate) => true;
}
