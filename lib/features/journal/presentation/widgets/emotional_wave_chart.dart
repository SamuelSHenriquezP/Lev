import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/lev_theme.dart';
import '../../domain/mood_entry.dart';

class EmotionalWaveChart extends StatelessWidget {
  final List<MoodEntry> entries;

  const EmotionalWaveChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // Tomar los últimos 6 o 7 registros para la gráfica de ondas
    final displayEntries = entries.length > 7
        ? entries.sublist(entries.length - 7)
        : entries;

    if (displayEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: LevTheme.cardRadius,
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ondas de Bienestar',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LevTheme.levMatchaLight,
                  borderRadius: LevTheme.pillRadius,
                ),
                child: Text(
                  'Fluctuación Compasiva',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tu estado no es una línea recta; fluye como las aguas del estanque.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: LevTheme.levTextMuted,
            ),
          ),
          const SizedBox(height: 20),

          // Gráfica de ondas suaves
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaveChartPainter(entries: displayEntries),
            ),
          ),

          const SizedBox(height: 8),

          // Etiquetas de fechas abajo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: displayEntries.map((e) {
              final label = DateFormat('E d', 'es').format(e.timestamp);
              return Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: LevTheme.levTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WaveChartPainter extends CustomPainter {
  final List<MoodEntry> entries;

  _WaveChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    // 1. Líneas de guía horizontales sutiles
    final gridPaint = Paint()
      ..color = LevTheme.levBorder.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 5; i++) {
      final y = size.height - (i / 5.0) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Calcular puntos (X, Y)
    final points = <Offset>[];
    final stepX = entries.length > 1
        ? size.width / (entries.length - 1)
        : size.width / 2;

    for (int i = 0; i < entries.length; i++) {
      final x = entries.length > 1 ? i * stepX : size.width / 2;
      // score va de 1 a 5
      final score = entries[i].mood.score;
      // Mapear a rango de altura dejando margen
      final y = size.height - ((score - 0.7) / 4.6) * size.height;
      points.add(Offset(x, y.clamp(15.0, size.height - 15.0)));
    }

    if (points.length == 1) {
      _drawPoint(canvas, points[0], entries[0]);
      return;
    }

    // 3. Crear curva de onda Bézier suave
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // 4. Relleno con degradado suave bajo la onda
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          LevTheme.levMatcha.withValues(alpha: 0.35),
          LevTheme.levSky.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // 5. Línea de trazo de la onda
    final strokePaint = Paint()
      ..color = LevTheme.levMatcha
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // 6. Puntos interactivos con emojis suaves
    for (int i = 0; i < points.length; i++) {
      _drawPoint(canvas, points[i], entries[i]);
    }
  }

  void _drawPoint(Canvas canvas, Offset pos, MoodEntry entry) {
    // Sombra del punto
    final dotShadow = Paint()
      ..color = LevTheme.levMatcha.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(pos, 7, dotShadow);

    // Borde blanco
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 6, whitePaint);

    // Centro verde
    final centerPaint = Paint()..color = LevTheme.levMatchaDark;
    canvas.drawCircle(pos, 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveChartPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}

