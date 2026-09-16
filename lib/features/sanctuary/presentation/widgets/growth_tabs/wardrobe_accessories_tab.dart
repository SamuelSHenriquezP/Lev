import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

class WardrobeAccessoriesTab extends StatelessWidget {
  final SanctuaryState currentSanctuary;
  final SanctuaryController controller;
  final VoidCallback onStateChanged;

  const WardrobeAccessoriesTab({
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Accesorios botánicos para Lev:',
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
                '${currentSanctuary.unlockedAccessories.length}/${LevAccessory.values.length} en armario',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levMatchaDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: LevAccessory.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final acc = LevAccessory.values[i];
              final isEquipped = currentSanctuary.activeAccessory == acc;
              final isUnlocked = acc == LevAccessory.none || currentSanctuary.unlockedAccessories.contains(acc);
              final canAfford = currentSanctuary.careDrops >= acc.dropCost;

              return Container(
                width: 144,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEquipped
                      ? LevTheme.levMatchaLight.withValues(alpha: 0.75)
                      : const Color(0xFFFAF8F5),
                  borderRadius: LevTheme.cardRadius,
                  border: Border.all(
                    color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levBorder,
                    width: isEquipped ? 1.8 : 1.0,
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
                          child: Icon(acc.icon, size: 18, color: LevTheme.levMatchaDark),
                        ),
                        if (isUnlocked)
                          Icon(
                            isEquipped ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                          )
                        else
                          Text(
                            '${acc.dropCost} 💧',
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
                          acc.name,
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
                          acc.description,
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
                                if (isEquipped) {
                                  controller.equipAccessory(LevAccessory.none);
                                } else {
                                  controller.equipAccessory(acc);
                                }
                                onStateChanged();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: isEquipped ? Colors.white : Colors.transparent,
                                side: BorderSide(
                                  color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isEquipped ? 'Puesto 🌿' : (acc == LevAccessory.none ? 'Sin nada' : 'Poner'),
                                style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: canAfford
                                  ? () async {
                                      HapticsHelper.medium();
                                      final success = await controller.unlockAccessory(acc);
                                      if (success) onStateChanged();
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
        ),
      ],
    );
  }
}
