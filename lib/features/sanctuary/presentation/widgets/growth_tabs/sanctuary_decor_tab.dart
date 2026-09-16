import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

class SanctuaryDecorTab extends StatefulWidget {
  final SanctuaryState currentSanctuary;
  final SanctuaryController controller;
  final VoidCallback onStateChanged;

  const SanctuaryDecorTab({
    super.key,
    required this.currentSanctuary,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  State<SanctuaryDecorTab> createState() => _SanctuaryDecorTabState();
}

class _SanctuaryDecorTabState extends State<SanctuaryDecorTab> {
  DecorCategory selectedCategory = DecorCategory.all;

  @override
  Widget build(BuildContext context) {
    final currentSanctuary = widget.currentSanctuary;
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Objetos para la casa de Lev:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: LevTheme.levTextDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LevTheme.levMatchaLight,
                borderRadius: LevTheme.pillRadius,
              ),
              child: Text(
                '${currentSanctuary.activeDecors.length}/${SanctuaryDecorItem.values.length} en casa',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levMatchaDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Selector de categorías de objetos
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: DecorCategory.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, catIndex) {
              final cat = DecorCategory.values[catIndex];
              final isCatSelected = selectedCategory == cat;

              return InkWell(
                onTap: () => setState(() => selectedCategory = cat),
                borderRadius: LevTheme.pillRadius,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCatSelected ? LevTheme.levMatcha : Colors.white,
                    borderRadius: LevTheme.pillRadius,
                    border: Border.all(
                      color: isCatSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 13,
                        color: isCatSelected ? Colors.white : LevTheme.levMatchaDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cat.label,
                        style: GoogleFonts.quicksand(
                          fontSize: 11.5,
                          fontWeight: isCatSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isCatSelected ? Colors.white : LevTheme.levTextDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Lista horizontal de objetos filtrados
        Builder(
          builder: (context) {
            final filteredItems = selectedCategory == DecorCategory.all
                ? SanctuaryDecorItem.values
                : SanctuaryDecorItem.values.where((d) => d.category == selectedCategory).toList();

            return SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final item = filteredItems[i];
                  final isUnlocked = currentSanctuary.unlockedDecors.contains(item);
                  final isActive = currentSanctuary.activeDecors.contains(item);
                  final canAfford = currentSanctuary.careDrops >= item.dropCost;

                  return Container(
                    width: 144,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? LevTheme.levMatchaLight.withValues(alpha: 0.75)
                          : const Color(0xFFFAF8F5),
                      borderRadius: LevTheme.cardRadius,
                      border: Border.all(
                        color: isActive
                            ? LevTheme.levMatchaDark
                            : LevTheme.levBorder,
                        width: isActive ? 1.8 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(item.icon, size: 18, color: LevTheme.levMatchaDark),
                            ),
                            if (isUnlocked)
                              Icon(
                                isActive ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                size: 16,
                                color: isActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                              )
                            else
                              Text(
                                '${item.dropCost} 💧',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: canAfford ? const Color(0xFF1976D2) : LevTheme.levTextMuted,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.quicksand(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levTextDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: LevTheme.levTextMuted,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: isUnlocked
                              ? OutlinedButton(
                                  onPressed: () {
                                    HapticsHelper.light();
                                    controller.toggleDecor(item);
                                    widget.onStateChanged();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: isActive ? Colors.white : Colors.transparent,
                                    side: BorderSide(
                                      color: isActive ? LevTheme.levMatchaDark : LevTheme.levBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? 'Colocado 🌿' : 'Poner',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isActive ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: canAfford
                                      ? () async {
                                          HapticsHelper.medium();
                                          final success = await controller.unlockDecor(item);
                                          if (success) widget.onStateChanged();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: LevTheme.levMatcha,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Desbloquear',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
