import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

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
  DecorCategory selectedCategory = DecorCategory.all;

  final stagesInfo = [
    {'stage': LevGrowthStage.seed, 'name': 'Semilla', 'xp': 0, 'desc': 'Bulbo dorado que descansa.'},
    {'stage': LevGrowthStage.sprout, 'name': 'Brote', 'xp': 50, 'desc': 'Primeras hojitas tiernas.'},
    {'stage': LevGrowthStage.seedling, 'name': 'Plántula', 'xp': 100, 'desc': 'Hojas medianas con cáliz.'},
    {'stage': LevGrowthStage.youngPlant, 'name': 'Planta Joven', 'xp': 200, 'desc': 'Alas canónicas completas.'},
    {'stage': LevGrowthStage.vibrantPlant, 'name': 'Planta Vibrante', 'xp': 350, 'desc': 'Flores en floración.'},
    {'stage': LevGrowthStage.youngTree, 'name': 'Árbol Juvenil', 'xp': 550, 'desc': '4 alas con nervaduras.'},
    {'stage': LevGrowthStage.adultTree, 'name': 'Árbol Adulto', 'xp': 800, 'desc': 'Corona y halo místico.'},
    {'stage': LevGrowthStage.forestSpirit, 'name': 'Espíritu del Bosque', 'xp': 1200, 'desc': '6 alas y 3 orbes sagrados.'},
  ];

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
          final nextXp = currentSanctuary.xpToNextStage;
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
                const SizedBox(height: 14),

                // Acceso directo a la Tienda & Armario
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateToTab?.call(2);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1B3B2B), const Color(0xFF162420)]
                            : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? LevTheme.levMatchaNight.withValues(alpha: 0.3)
                            : LevTheme.levMatcha.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 20,
                          color: isDark ? LevTheme.levMatchaNight : LevTheme.levMatchaDark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Abrir Tienda & Armario Completo',
                                style: GoogleFonts.quicksand(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Usa tus ${currentSanctuary.careDrops} gotas para vestir a Lev y decorar el santuario',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: isDark ? LevTheme.levDarkTextMuted : LevTheme.levTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? LevTheme.levMatchaNight : LevTheme.levMatchaDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Selector de pestañas internas del modal
                Container(
                  padding: const EdgeInsets.all(4),
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

                if (activeTab == 0) ...[
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
                            setModalState(() {});
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
                          setModalState(() {});
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
                ] else if (activeTab == 1) ...[
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
                          onTap: () => setModalState(() => selectedCategory = cat),
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
                                              setModalState(() {});
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
                                                    if (success) setModalState(() {});
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
                ] else if (activeTab == 2) ...[
                  // Pestaña Armario: Accesorios botánicos
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
                                          setModalState(() {});
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
                                                if (success) setModalState(() {});
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
                ] else ...[
                  // Pestaña Cielo: Ciclo circadiano
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
                          setModalState(() {});
                        },
                      ),
                      _buildCircadianChip(
                        label: 'Amanecer 🌅',
                        icon: Icons.wb_twilight_rounded,
                        isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.morning,
                        onTap: () {
                          HapticsHelper.selection();
                          controller.setCircadianOverride(SanctuaryTimeOfDay.morning);
                          setModalState(() {});
                        },
                      ),
                      _buildCircadianChip(
                        label: 'Día ☀️',
                        icon: Icons.wb_sunny_rounded,
                        isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.afternoon,
                        onTap: () {
                          HapticsHelper.selection();
                          controller.setCircadianOverride(SanctuaryTimeOfDay.afternoon);
                          setModalState(() {});
                        },
                      ),
                      _buildCircadianChip(
                        label: 'Ocaso 🌇',
                        icon: Icons.wb_cloudy_rounded,
                        isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.dusk,
                        onTap: () {
                          HapticsHelper.selection();
                          controller.setCircadianOverride(SanctuaryTimeOfDay.dusk);
                          setModalState(() {});
                        },
                      ),
                      _buildCircadianChip(
                        label: 'Noche Serena 🌙',
                        icon: Icons.bedtime_rounded,
                        isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.night,
                        onTap: () {
                          HapticsHelper.selection();
                          controller.setCircadianOverride(SanctuaryTimeOfDay.night);
                          setModalState(() {});
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
