import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';

export 'minigames/bubble_pop_minigame.dart';
export 'minigames/zen_sand_minigame.dart';
export 'minigames/light_tracker_minigame.dart';
export 'minigames/water_ripple_minigame.dart';
export 'minigames/tibetan_bowl_minigame.dart';
export 'minigames/dandelion_minigame.dart';
export 'minigames/stone_balance_minigame.dart';
export 'minigames/prayer_candle_minigame.dart';

import 'minigames/bubble_pop_minigame.dart';
import 'minigames/zen_sand_minigame.dart';
import 'minigames/light_tracker_minigame.dart';
import 'minigames/water_ripple_minigame.dart';
import 'minigames/tibetan_bowl_minigame.dart';
import 'minigames/dandelion_minigame.dart';
import 'minigames/stone_balance_minigame.dart';
import 'minigames/prayer_candle_minigame.dart';

/// Modal o pantalla para abrir cualquiera de los minijuegos somáticos de concentración.
class SomaticMinigameModal {
  static void open(BuildContext context, {required int initialGameIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SomaticMinigamesContainer(initialIndex: initialGameIndex),
    );
  }
}

class SomaticMinigamesContainer extends StatefulWidget {
  final int initialIndex;

  const SomaticMinigamesContainer({super.key, required this.initialIndex});

  @override
  State<SomaticMinigamesContainer> createState() => _SomaticMinigamesContainerState();
}

class _SomaticMinigamesContainerState extends State<SomaticMinigamesContainer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: LevTheme.levCream,
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Indicador de arrastre
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: LevTheme.levBorder,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Pestañas de minijuegos superiores (estilo cápsula táctil con scroll horizontal para los 7 juegos)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildGameTab(0, 'Burbujas', Icons.bubble_chart_rounded),
                const SizedBox(width: 8),
                _buildGameTab(1, 'Arena Zen', Icons.landscape_rounded),
                const SizedBox(width: 8),
                _buildGameTab(2, 'Foco de Luz', Icons.auto_awesome_rounded),
                const SizedBox(width: 8),
                _buildGameTab(3, 'Estanque', Icons.water_drop_rounded),
                const SizedBox(width: 8),
                _buildGameTab(4, 'Cuenco Zen', Icons.notifications_active_rounded),
                const SizedBox(width: 8),
                _buildGameTab(5, 'Diente León', Icons.nature_people_rounded),
                const SizedBox(width: 8),
                _buildGameTab(6, 'Piedras Zen', Icons.filter_hdr_rounded),
                const SizedBox(width: 8),
                _buildGameTab(7, 'Vela de Fe', Icons.lightbulb_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Área interactiva del anclaje activo
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                BubblePopMinigame(),
                ZenSandMinigame(),
                LightTrackerMinigame(),
                WaterRippleMinigame(),
                TibetanBowlMinigame(),
                DandelionMinigame(),
                StoneBalanceMinigame(),
                PrayerCandleMinigame(),
              ],
            ),
          ),

          // Invitación activa a soltar la pantalla y volver a la vida real
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticsHelper.medium();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LevTheme.levMatcha,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  'Ya me siento en calma, soltar teléfono 🌿',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTab(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        HapticsHelper.selection();
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: LevTheme.pillRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? LevTheme.levMatchaDark : Colors.white,
          borderRadius: LevTheme.pillRadius,
          border: Border.all(
            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
          ),
          boxShadow: isSelected ? LevTheme.glowShadow : LevTheme.softShadow,
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
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : LevTheme.levTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

