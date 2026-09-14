import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

/// Modal para seleccionar la atmósfera meteorológica del Santuario
void showSanctuaryWeatherSheet(
  BuildContext context,
  SanctuaryController controller,
  SanctuaryWeather currentWeather,
) {
  HapticsHelper.selection();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162420) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? const Color(0xFF263D36) : LevTheme.levBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : LevTheme.levBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Atmósfera del Santuario',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : LevTheme.levTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Elige el clima que acompañe tu momento presente',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: isDark ? Colors.white70 : LevTheme.levTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: SanctuaryWeather.values.map((w) {
                final isSelected = w == currentWeather;
                return InkWell(
                  onTap: () {
                    controller.setWeather(w);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? LevTheme.levMatcha
                          : (isDark ? const Color(0xFF1E2F29) : LevTheme.levMatchaLight),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? LevTheme.levMatchaDark
                            : LevTheme.levMatcha.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          w.icon,
                          size: 24,
                          color: isSelected ? Colors.white : LevTheme.levMatchaDark,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          w.label,
                          style: GoogleFonts.quicksand(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : LevTheme.levMatchaDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    },
  );
}
