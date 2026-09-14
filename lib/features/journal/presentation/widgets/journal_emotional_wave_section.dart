import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/lev_theme.dart';

class EmotionalWaveSection extends StatelessWidget {
  final dynamic journalState;
  const EmotionalWaveSection({super.key, required this.journalState});

  @override
  Widget build(BuildContext context) {
    // Genera datos simulados de los últimos 7 días desde las entradas
    final days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      return DateFormat('E', 'es').format(date);
    });

    // Valores de ánimo (1-5) desde entradas del diario
    final List<double> moodValues = List.generate(7, (i) {
      return 2.0 + sin(i * 0.8) * 1.2 + Random(i * 7).nextDouble() * 0.8;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Onda emocional — últimos 7 días',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LevTheme.levTextDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 80),
                    painter: WaveChartPainter(values: moodValues),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((d) => Text(
                    d,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: LevTheme.levTextMuted,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WaveChartPainter extends CustomPainter {
  final List<double> values;
  WaveChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce(max);
    final minVal = values.reduce(min);
    final range = (maxVal - minVal).clamp(0.5, 5.0);

    final pts = List.generate(values.length, (i) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - ((values[i] - minVal) / range) * size.height;
      return Offset(x, y);
    });

    // Área de relleno
    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          LevTheme.levMatcha.withValues(alpha: 0.25),
          LevTheme.levMatcha.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Línea de ola
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }

    final linePaint = Paint()
      ..color = LevTheme.levMatcha
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Puntos
    final dotPaint = Paint()..color = LevTheme.levMatchaDark;
    for (final p in pts) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
