import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/lev_theme.dart';
import '../../../sanctuary/domain/sanctuary_state.dart';

class LevGrowthCard extends StatelessWidget {
  final SanctuaryState sanctuary;
  const LevGrowthCard({super.key, required this.sanctuary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = sanctuary.growthStage;
    final progress = sanctuary.growthFactor;
    final nextXp = sanctuary.xpToNextStage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: theme.brightness == Brightness.dark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LevTheme.levMatchaNight.withValues(alpha: 0.15),
                  LevTheme.levDarkSurfaceVariant,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LevTheme.levMatcha.withValues(alpha: 0.15),
                  LevTheme.levMatchaDark.withValues(alpha: 0.08),
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? LevTheme.levDarkBorder
              : LevTheme.levMatcha.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? LevTheme.levDarkSurface
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? LevTheme.levMatchaNight.withValues(alpha: 0.4)
                        : LevTheme.levMatcha.withValues(alpha: 0.3),
                  ),
                  boxShadow: LevTheme.softShadow,
                ),
                child: Icon(
                  sanctuary.stageMaterialIcon,
                  size: 24,
                  color: theme.brightness == Brightness.dark
                      ? LevTheme.levMatchaNight
                      : LevTheme.levMatchaDark,
                ),
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
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      nextXp != null && nextXp > 0
                          ? 'Faltan $nextXp XP para la siguiente etapa'
                          : 'Ha alcanzado su forma final',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: theme.brightness == Brightness.dark
                            ? LevTheme.levDarkTextMuted
                            : LevTheme.levTextMuted,
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
          if (nextXp != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: theme.brightness == Brightness.dark
                    ? LevTheme.levDarkSurfaceVariant
                    : LevTheme.levMatchaLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.brightness == Brightness.dark
                      ? LevTheme.levMatchaNight
                      : LevTheme.levMatchaDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatChip({
    super.key,
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
