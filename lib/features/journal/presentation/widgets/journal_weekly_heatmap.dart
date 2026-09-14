import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/lev_theme.dart';

class WeeklyHeatmap extends StatelessWidget {
  final dynamic journalState;
  const WeeklyHeatmap({super.key, required this.journalState});

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
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: LevTheme.levMatchaLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Sin pausas', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LevTheme.levTextMuted)),
                  const SizedBox(width: 16),
                  Container(
                    width: 12,
                    height: 12,
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

class CategoryAchievements extends StatelessWidget {
  final int completedCount;
  const CategoryAchievements({super.key, required this.completedCount});

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
