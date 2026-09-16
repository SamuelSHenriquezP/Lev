import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'growth_tabs/evolution_stages_tab.dart';
import 'growth_tabs/sanctuary_decor_tab.dart';
import 'growth_tabs/wardrobe_accessories_tab.dart';
import 'growth_tabs/circadian_sky_tab.dart';

/// Modal para visualizar y gestionar el progreso evolutivo de Lev,
/// los 8 estados de crecimiento, la decoración del santuario y los accesorios.
void showSanctuaryGrowthDialog(
  BuildContext context,
  WidgetRef ref,
  SanctuaryState sanctuary, {
  int initialTab = 0,
  void Function(int)? onNavigateToTab,
}) {
  final controller = ref.read(sanctuaryProvider.notifier);
  int activeTab = initialTab; // 0 = Evolución (XP), 1 = Casa (Gotas), 2 = Armario, 3 = Cielo

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? LevTheme.levDarkSurface
        : Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final currentSanctuary = ref.watch(sanctuaryProvider);
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? LevTheme.levDarkBorder : LevTheme.levBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Santuario Botánico',
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: LevTheme.levMatchaLight,
                            borderRadius: LevTheme.pillRadius,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.eco_rounded, size: 14, color: LevTheme.levMatchaDark),
                              const SizedBox(width: 4),
                              Text(
                                '${currentSanctuary.experiencePoints} XP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: LevTheme.levMatchaDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: LevTheme.pillRadius,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.water_drop_rounded, size: 14, color: Color(0xFF1976D2)),
                              const SizedBox(width: 4),
                              Text(
                                '${currentSanctuary.careDrops} 💧',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1976D2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Selector de pestañas
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? LevTheme.levDarkSurfaceVariant : LevTheme.levCream,
                    borderRadius: LevTheme.pillRadius,
                    border: Border.all(color: isDark ? LevTheme.levDarkBorder : LevTheme.levBorder),
                  ),
                  child: Row(
                    children: [
                      _buildGrowthTabPill('🌱 Etapas', 0, activeTab, () => setModalState(() => activeTab = 0)),
                      _buildGrowthTabPill('🏡 Casa', 1, activeTab, () => setModalState(() => activeTab = 1)),
                      _buildGrowthTabPill('🎀 Armario', 2, activeTab, () => setModalState(() => activeTab = 2)),
                      _buildGrowthTabPill('☀️ Cielo', 3, activeTab, () => setModalState(() => activeTab = 3)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (activeTab == 0)
                  EvolutionStagesTab(
                    currentSanctuary: currentSanctuary,
                    controller: controller,
                    onStateChanged: () => setModalState(() {}),
                  )
                else if (activeTab == 1)
                  SanctuaryDecorTab(
                    currentSanctuary: currentSanctuary,
                    controller: controller,
                    onStateChanged: () => setModalState(() {}),
                  )
                else if (activeTab == 2)
                  WardrobeAccessoriesTab(
                    currentSanctuary: currentSanctuary,
                    controller: controller,
                    onStateChanged: () => setModalState(() {}),
                  )
                else
                  CircadianSkyTab(
                    currentSanctuary: currentSanctuary,
                    controller: controller,
                    onStateChanged: () => setModalState(() {}),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildGrowthTabPill(String label, int index, int current, VoidCallback onTap) {
  final isSelected = index == current;
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: LevTheme.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: LevTheme.pillRadius,
          boxShadow: isSelected ? LevTheme.softShadow : null,
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
            ),
          ),
        ),
      ),
    ),
  );
}