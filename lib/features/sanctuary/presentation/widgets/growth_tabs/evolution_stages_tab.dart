import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

class EvolutionStagesTab extends StatelessWidget {
  final SanctuaryState currentSanctuary;
  final SanctuaryController controller;
  final VoidCallback onStateChanged;

  static const List<Map<String, dynamic>> stagesInfo = [
    {'stage': LevGrowthStage.seed, 'name': 'Semilla', 'xp': 0, 'desc': 'Bulbo dorado que descansa.'},
    {'stage': LevGrowthStage.sprout, 'name': 'Brote', 'xp': 50, 'desc': 'Primeras hojitas tiernas.'},
    {'stage': LevGrowthStage.seedling, 'name': 'Plántula', 'xp': 100, 'desc': 'Hojas medianas con cáliz.'},
    {'stage': LevGrowthStage.youngPlant, 'name': 'Planta Joven', 'xp': 200, 'desc': 'Alas canónicas completas.'},
    {'stage': LevGrowthStage.vibrantPlant, 'name': 'Planta Vibrante', 'xp': 350, 'desc': 'Flores en floración.'},
    {'stage': LevGrowthStage.youngTree, 'name': 'Árbol Juvenil', 'xp': 550, 'desc': '4 alas con nervaduras.'},
    {'stage': LevGrowthStage.adultTree, 'name': 'Árbol Adulto', 'xp': 800, 'desc': 'Corona y halo místico.'},
    {'stage': LevGrowthStage.forestSpirit, 'name': 'Espíritu', 'xp': 1200, 'desc': 'Deidad guardiana del bosque.'},
  ];

  const EvolutionStagesTab({
    super.key,
    required this.currentSanctuary,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final nextXp = currentSanctuary.xpToNextStage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Toca cualquier etapa para previsualizar su sprite o progresa ganando +25 XP por hábito.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: LevTheme.levTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: stagesInfo.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = stagesInfo[i];
              final stage = item['stage'] as LevGrowthStage;
              final isSelected = currentSanctuary.growthStage == stage;
              final minXp = item['xp'] as int;

              return InkWell(
                onTap: () {
                  HapticsHelper.selection();
                  controller.setExperiencePoints(minXp);
                  onStateChanged();
                },
                borderRadius: LevTheme.cardRadius,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 108,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? LevTheme.levMatchaLight
                        : const Color(0xFFFAF8F5),
                    borderRadius: LevTheme.cardRadius,
                    border: Border.all(
                      color: isSelected
                          ? LevTheme.levMatchaDark
                          : LevTheme.levBorder,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.eco_rounded,
                        size: 20,
                        color: isSelected
                            ? LevTheme.levMatchaDark
                            : LevTheme.levTextMuted,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['name'] as String,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? LevTheme.levMatchaDark
                              : LevTheme.levTextDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item['xp']}+ XP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: LevTheme.levTextMuted,
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
        if (nextXp != null)
          Text(
            'Faltan $nextXp XP para la siguiente evolución botánica.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: LevTheme.levMatchaDark,
            ),
          )
        else
          Text(
            'Lev ha alcanzado su forma final suprema. Sigue nutriendo tu bienestar.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: LevTheme.levMatchaDark,
            ),
          ),
        const SizedBox(height: 10),
        Center(
          child: TextButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: LevTheme.cardRadius),
                  title: Text('¿Comenzar de cero?', style: GoogleFonts.quicksand(fontWeight: FontWeight.w700)),
                  content: Text(
                    'Lev volverá a ser una pequeña semilla (0 Gotas, 0 XP) para iniciar tu camino desde cero.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE57373)),
                      child: const Text('Sí, reiniciar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await controller.resetAllToZero();
                onStateChanged();
              }
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 16, color: LevTheme.levTextMuted),
            label: Text(
              'Comenzar desde cero (Semilla, 0 Gotas)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: LevTheme.levTextMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
