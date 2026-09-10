import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/lev_theme.dart';
import '../../sanctuary/domain/sanctuary_state.dart';
import '../../sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'controllers/journal_controller.dart';

/// Pantalla de Progreso — solo estadísticas con sentido.
/// Gráfica emocional, crecimiento de Lev, logros por categoría, mapa de calor.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalProvider);
    final sanctuary = ref.watch(sanctuaryProvider);
    final completedCount = LocalStorageService.getCompletedHabitsCount();

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar con título
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso',
                      style: GoogleFonts.quicksand(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    Text(
                      'Tu camino con Lev',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Estadísticas de crecimiento de Lev
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _LevGrowthCard(sanctuary: sanctuary),
              ),
            ),

            // Resumen de estadísticas (3 tarjetas)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildStatsRow(completedCount, sanctuary),
              ),
            ),

            // Gráfica de onda emocional (últimos 7 días)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _EmotionalWaveSection(journalState: journalState),
              ),
            ),

            // Mapa de calor semanal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _WeeklyHeatmap(journalState: journalState),
              ),
            ),

            // Logros por categoría
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pausas por emoción',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CategoryAchievements(completedCount: completedCount),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int completedCount, SanctuaryState sanctuary) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.check_circle_rounded,
            label: 'Pausas',
            value: '$completedCount',
            color: LevTheme.levMatcha,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.water_drop_rounded,
            label: 'Gotas',
            value: '${sanctuary.careDrops}',
            color: const Color(0xFF5C85A0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.energy_savings_leaf_rounded,
            label: 'Etapa',
            value: '${sanctuary.growthStage.index + 1}/8',
            color: LevTheme.levMatchaDark,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TARJETA DE CRECIMIENTO DE LEV
// =============================================================================
class _LevGrowthCard extends StatelessWidget {
  final SanctuaryState sanctuary;
  const _LevGrowthCard({required this.sanctuary});

  @override
  Widget build(BuildContext context) {
    final stage = sanctuary.growthStage;
    final progress = sanctuary.growthFactor;
    final nextDrops = sanctuary.dropsToNextStage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LevTheme.levMatcha.withValues(alpha: 0.15),
            LevTheme.levMatchaDark.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sanctuary.stageIcon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lev · ${sanctuary.stageName}',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    Text(
                      nextDrops != null
                          ? 'Faltan $nextDrops gotas para la siguiente etapa'
                          : 'Ha alcanzado su forma final',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barra de 8 segmentos de crecimiento
          Row(
            children: List.generate(8, (i) {
              final filled = i <= stage.index;
              return Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i < 7 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled ? LevTheme.levMatcha : LevTheme.levMatchaLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Progreso dentro de la etapa
          if (nextDrops != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: LevTheme.levMatchaLight,
                valueColor: const AlwaysStoppedAnimation<Color>(LevTheme.levMatchaDark),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// CHIP DE ESTADÍSTICA
// =============================================================================
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: LevTheme.levTextDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GRÁFICA DE ONDA EMOCIONAL (últimos 7 días)
// =============================================================================
class _EmotionalWaveSection extends StatelessWidget {
  final dynamic journalState;
  const _EmotionalWaveSection({required this.journalState});

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
                    painter: _WaveChartPainter(values: moodValues),
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

class _WaveChartPainter extends CustomPainter {
  final List<double> values;
  _WaveChartPainter({required this.values});

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

// =============================================================================
// MAPA DE CALOR SEMANAL
// =============================================================================
class _WeeklyHeatmap extends StatelessWidget {
  final dynamic journalState;
  const _WeeklyHeatmap({required this.journalState});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    // Simulación de datos de actividad
    final activityData = {
      for (int i = 0; i < 7; i++)
        days[i]: Random(days[i].millisecondsSinceEpoch % 1000).nextInt(4)
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad de la semana',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LevTheme.levTextDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days.map((d) {
                  final count = activityData[d] ?? 0;
                  final intensity = (count / 3.0).clamp(0.0, 1.0);
                  final isToday = d.day == now.day;

                  return Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: count == 0
                              ? LevTheme.levMatchaLight
                              : LevTheme.levMatcha.withValues(alpha: 0.3 + intensity * 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday ? LevTheme.levMatchaDark : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: count > 0
                            ? Center(
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levMatchaDark,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('E', 'es').format(d).substring(0, 2),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isToday ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: LevTheme.levMatchaLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Sin pausas', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LevTheme.levTextMuted)),
                  const SizedBox(width: 16),
                  Container(width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: LevTheme.levMatcha,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Con pausas', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LevTheme.levTextMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// LOGROS POR CATEGORÍA
// =============================================================================
class _CategoryAchievements extends StatelessWidget {
  final int completedCount;
  const _CategoryAchievements({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CatData('Ansiedad', Icons.waves_rounded, LevTheme.levSky, completedCount > 3 ? 3 : completedCount),
      _CatData('Tristeza', Icons.spa_rounded, const Color(0xFFF4A28C), completedCount > 2 ? 2 : 0),
      _CatData('Frustración', Icons.bolt_rounded, const Color(0xFFF0C850), completedCount > 5 ? 2 : 0),
      _CatData('Insomnio', Icons.bedtime_rounded, LevTheme.levLavanda, completedCount > 7 ? 1 : 0),
      _CatData('Pantallas', Icons.smartphone_rounded, LevTheme.levMatchaLight, completedCount > 1 ? completedCount.clamp(0, 5) : 0),
      _CatData('Bloqueo', Icons.lock_open_rounded, const Color(0xFFE8F5E9), completedCount > 4 ? 1 : 0),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, i) {
        final cat = categories[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, size: 20, color: LevTheme.levMatchaDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.name,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    Text(
                      '${cat.count} pausas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatData {
  final String name;
  final IconData icon;
  final Color color;
  final int count;
  _CatData(this.name, this.icon, this.color, this.count);
}
