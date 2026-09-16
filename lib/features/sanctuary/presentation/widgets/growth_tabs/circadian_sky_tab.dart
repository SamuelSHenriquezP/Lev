import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

class CircadianSkyTab extends StatelessWidget {
  final SanctuaryState currentSanctuary;
  final SanctuaryController controller;
  final VoidCallback onStateChanged;

  const CircadianSkyTab({
    super.key,
    required this.currentSanctuary,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atmósfera circadiana del Santuario:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: LevTheme.levTextDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Por defecto, Lev sincroniza la luz con tu reloj local para cuidar tu descanso nocturno sin luz azul.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: LevTheme.levTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCircadianChip(
              label: 'Automático (Reloj)',
              icon: Icons.access_time_rounded,
              isSelected: currentSanctuary.circadianOverride == null,
              onTap: () {
                HapticsHelper.selection();
                controller.setCircadianOverride(null);
                onStateChanged();
              },
            ),
            _buildCircadianChip(
              label: 'Amanecer 🌅',
              icon: Icons.wb_twilight_rounded,
              isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.morning,
              onTap: () {
                HapticsHelper.selection();
                controller.setCircadianOverride(SanctuaryTimeOfDay.morning);
                onStateChanged();
              },
            ),
            _buildCircadianChip(
              label: 'Día ☀️',
              icon: Icons.wb_sunny_rounded,
              isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.afternoon,
              onTap: () {
                HapticsHelper.selection();
                controller.setCircadianOverride(SanctuaryTimeOfDay.afternoon);
                onStateChanged();
              },
            ),
            _buildCircadianChip(
              label: 'Ocaso 🌇',
              icon: Icons.wb_cloudy_rounded,
              isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.dusk,
              onTap: () {
                HapticsHelper.selection();
                controller.setCircadianOverride(SanctuaryTimeOfDay.dusk);
                onStateChanged();
              },
            ),
            _buildCircadianChip(
              label: 'Noche Serena 🌙',
              icon: Icons.bedtime_rounded,
              isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.night,
              onTap: () {
                HapticsHelper.selection();
                controller.setCircadianOverride(SanctuaryTimeOfDay.night);
                onStateChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                ? const Color(0xFF192530)
                : const Color(0xFFF6F4ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LevTheme.levBorder),
          ),
          child: Row(
            children: [
              Icon(
                currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                    ? Icons.nights_stay_rounded
                    : Icons.light_mode_rounded,
                size: 18,
                color: currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                    ? const Color(0xFFFFF9E0)
                    : LevTheme.levMatchaDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                      ? 'Cielo nocturno activo: estrellas titilantes y luna serena sin luz azul.'
                      : 'Iluminación cálida diurna activa en el santuario.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                        ? Colors.white.withValues(alpha: 0.9)
                        : LevTheme.levTextDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircadianChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: LevTheme.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? LevTheme.levMatcha : Colors.white,
          borderRadius: LevTheme.pillRadius,
          border: Border.all(
            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? LevTheme.glowShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : LevTheme.levMatchaDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : LevTheme.levTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
