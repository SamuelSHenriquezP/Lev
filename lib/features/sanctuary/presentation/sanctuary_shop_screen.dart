import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

/// Pantalla dedicada de la Tienda y Armario de Lev.
/// Permite adquirir decoraciones botánicas para el hábitat y vestir a Lev con accesorios.
class SanctuaryShopScreen extends ConsumerStatefulWidget {
  const SanctuaryShopScreen({super.key});

  @override
  ConsumerState<SanctuaryShopScreen> createState() => _SanctuaryShopScreenState();
}

enum _ShopTab {
  all('Todos', Icons.auto_awesome_mosaic_rounded),
  wardrobe('Armario', Icons.checkroom_rounded),
  nature('Jardín', Icons.park_rounded),
  furniture('Muebles', Icons.chair_rounded),
  lighting('Luces', Icons.lightbulb_rounded),
  companions('Fauna', Icons.pets_rounded);

  final String label;
  final IconData icon;
  const _ShopTab(this.label, this.icon);
}

class _SanctuaryShopScreenState extends ConsumerState<SanctuaryShopScreen> {
  _ShopTab _selectedTab = _ShopTab.all;

  @override
  Widget build(BuildContext context) {
    final sanctuary = ref.watch(sanctuaryProvider);
    final controller = ref.read(sanctuaryProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accessories = LevAccessory.values.where((a) => a != LevAccessory.none).toList();
    final decorItems = SanctuaryDecorItem.values;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Cabecera estilizada
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tienda & Armario',
                              style: GoogleFonts.quicksand(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Viste a Lev y personaliza tu santuario',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark ? LevTheme.levDarkTextMuted : LevTheme.levTextMuted,
                              ),
                            ),
                          ],
                        ),
                        // Contador de Gotas de Cuidado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF132A3A)
                                : const Color(0xFFE1F5FE),
                            borderRadius: LevTheme.pillRadius,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E88E5).withValues(alpha: 0.5)
                                  : const Color(0xFF81D4FA),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0288D1).withValues(alpha: isDark ? 0.2 : 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.water_drop_rounded,
                                size: 18,
                                color: Color(0xFF0288D1),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${sanctuary.careDrops}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF0277BD),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Gotas',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0288D1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Píldoras de Categorías
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _ShopTab.values.map((tab) {
                          final isSelected = _selectedTab == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                HapticsHelper.selection();
                                setState(() => _selectedTab = tab);
                              },
                              borderRadius: LevTheme.pillRadius,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatcha)
                                      : (isDark ? LevTheme.levDarkSurfaceVariant : Colors.white),
                                  borderRadius: LevTheme.pillRadius,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : (isDark ? LevTheme.levDarkBorder : LevTheme.levBorder),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tab.icon,
                                      size: 15,
                                      color: isSelected
                                          ? (isDark ? LevTheme.levDarkBg : Colors.white)
                                          : (isDark ? LevTheme.levDarkTextMuted : LevTheme.levTextMuted),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tab.label,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected
                                            ? (isDark ? LevTheme.levDarkBg : Colors.white)
                                            : (isDark ? LevTheme.levDarkText : LevTheme.levTextDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido dinámico según categoría
            if (_selectedTab == _ShopTab.wardrobe || _selectedTab == _ShopTab.all) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.checkroom_rounded, size: 18, color: LevTheme.levPeachDark),
                      const SizedBox(width: 8),
                      Text(
                        'Armario de Lev (Accesorios)',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.86,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = accessories[index];
                      final isUnlocked = sanctuary.unlockedAccessories.contains(item);
                      final isEquipped = sanctuary.activeAccessory == item;
                      final canAfford = sanctuary.careDrops >= item.dropCost;

                      return _buildAccessoryCard(
                        context: context,
                        item: item,
                        isUnlocked: isUnlocked,
                        isEquipped: isEquipped,
                        canAfford: canAfford,
                        isDark: isDark,
                        theme: theme,
                        onAction: () async {
                          if (isUnlocked) {
                            await controller.equipAccessory(item);
                          } else {
                            if (!canAfford) {
                              _showInsufficientDrops(context, item.dropCost - sanctuary.careDrops);
                              return;
                            }
                            final ok = await controller.unlockAccessory(item);
                            if (ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('¡Equipaste "${item.name}" en Lev! 🌿'),
                                  backgroundColor: LevTheme.levMatchaDark,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                    childCount: accessories.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],

            if (_selectedTab != _ShopTab.wardrobe) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.yard_rounded, size: 18, color: LevTheme.levMatchaDark),
                      const SizedBox(width: 8),
                      Text(
                        'Elementos del Santuario',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildDecorGrid(
                context: context,
                sanctuary: sanctuary,
                controller: controller,
                decorItems: _filterDecorItems(decorItems, _selectedTab),
                isDark: isDark,
                theme: theme,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }

  List<SanctuaryDecorItem> _filterDecorItems(List<SanctuaryDecorItem> items, _ShopTab tab) {
    switch (tab) {
      case _ShopTab.all:
        return items;
      case _ShopTab.nature:
        return items.where((i) => i.category == DecorCategory.nature).toList();
      case _ShopTab.furniture:
        return items.where((i) => i.category == DecorCategory.furniture).toList();
      case _ShopTab.lighting:
        return items.where((i) => i.category == DecorCategory.lighting).toList();
      case _ShopTab.companions:
        return items.where((i) => i.category == DecorCategory.companions).toList();
      case _ShopTab.wardrobe:
        return [];
    }
  }

  Widget _buildAccessoryCard({
    required BuildContext context,
    required LevAccessory item,
    required bool isUnlocked,
    required bool isEquipped,
    required bool canAfford,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? LevTheme.levDarkSurface : Colors.white,
        borderRadius: LevTheme.cardRadius,
        border: Border.all(
          color: isEquipped
              ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatcha)
              : (isDark ? LevTheme.levDarkBorder : LevTheme.levBorder),
          width: isEquipped ? 2 : 1,
        ),
        boxShadow: isDark ? LevTheme.darkSoftShadow : LevTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isEquipped
                      ? (isDark ? LevTheme.levMatchaNight.withValues(alpha: 0.2) : LevTheme.levMatchaLight)
                      : (isDark ? LevTheme.levDarkSurfaceVariant : const Color(0xFFF7F5F0)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: isEquipped
                      ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatchaDark)
                      : (isDark ? LevTheme.levPeachNight : LevTheme.levPeachDark),
                ),
              ),
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? LevTheme.levMatchaNight : LevTheme.levMatcha,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Text(
                    'Puesto',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? LevTheme.levDarkBg : Colors.white,
                    ),
                  ),
                )
              else if (!isUnlocked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop_rounded, size: 12, color: Color(0xFF0288D1)),
                    const SizedBox(width: 2),
                    Text(
                      '${item.dropCost}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0288D1),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Spacer(),
          Text(
            item.name,
            style: GoogleFonts.quicksand(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: isDark ? LevTheme.levDarkTextMuted : LevTheme.levTextMuted,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEquipped
                    ? (isDark ? LevTheme.levDarkSurfaceVariant : const Color(0xFFEDE8E1))
                    : isUnlocked
                        ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatcha)
                        : canAfford
                            ? const Color(0xFF0288D1)
                            : (isDark ? Colors.white12 : const Color(0xFFCFD8DC)),
                foregroundColor: isEquipped
                    ? (isDark ? LevTheme.levDarkText : LevTheme.levTextDark)
                    : isUnlocked
                        ? (isDark ? LevTheme.levDarkBg : Colors.white)
                        : canAfford
                            ? Colors.white
                            : (isDark ? Colors.white38 : LevTheme.levTextMuted),
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isEquipped
                    ? 'Quitar'
                    : isUnlocked
                        ? 'Poner'
                        : canAfford
                            ? 'Desbloquear'
                            : 'Faltan Gotas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorGrid({
    required BuildContext context,
    required SanctuaryState sanctuary,
    required SanctuaryController controller,
    required List<SanctuaryDecorItem> decorItems,
    required bool isDark,
    required ThemeData theme,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.86,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = decorItems[index];
            final isUnlocked = sanctuary.unlockedDecors.contains(item);
            final isActive = sanctuary.activeDecors.contains(item);
            final canAfford = sanctuary.careDrops >= item.dropCost;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? LevTheme.levDarkSurface : Colors.white,
                borderRadius: LevTheme.cardRadius,
                border: Border.all(
                  color: isActive
                      ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatcha)
                      : (isDark ? LevTheme.levDarkBorder : LevTheme.levBorder),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isDark ? LevTheme.darkSoftShadow : LevTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isDark ? LevTheme.levMatchaNight.withValues(alpha: 0.2) : LevTheme.levMatchaLight)
                              : (isDark ? LevTheme.levDarkSurfaceVariant : const Color(0xFFF7F5F0)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: isActive
                              ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatchaDark)
                              : (isDark ? LevTheme.levSkyNight : LevTheme.levMatchaDark),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? LevTheme.levMatchaNight : LevTheme.levMatcha,
                            borderRadius: LevTheme.pillRadius,
                          ),
                          child: Text(
                            'Activo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? LevTheme.levDarkBg : Colors.white,
                            ),
                          ),
                        )
                      else if (!isUnlocked)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.water_drop_rounded, size: 12, color: Color(0xFF0288D1)),
                            const SizedBox(width: 2),
                            Text(
                              '${item.dropCost}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0288D1),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.name,
                    style: GoogleFonts.quicksand(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? LevTheme.levDarkTextMuted : LevTheme.levTextMuted,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isUnlocked) {
                          await controller.toggleDecor(item);
                        } else {
                          if (!canAfford) {
                            _showInsufficientDrops(context, item.dropCost - sanctuary.careDrops);
                            return;
                          }
                          final ok = await controller.unlockDecor(item);
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡Desbloqueaste "${item.name}" para tu santuario! ✨'),
                                backgroundColor: LevTheme.levMatchaDark,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? (isDark ? LevTheme.levDarkSurfaceVariant : const Color(0xFFEDE8E1))
                            : isUnlocked
                                ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatcha)
                                : canAfford
                                    ? const Color(0xFF0288D1)
                                    : (isDark ? Colors.white12 : const Color(0xFFCFD8DC)),
                        foregroundColor: isActive
                            ? (isDark ? LevTheme.levDarkText : LevTheme.levTextDark)
                            : isUnlocked
                                ? (isDark ? LevTheme.levDarkBg : Colors.white)
                                : canAfford
                                    ? Colors.white
                                    : (isDark ? Colors.white38 : LevTheme.levTextMuted),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        isActive
                            ? 'Guardar'
                            : isUnlocked
                                ? 'Colocar'
                                : canAfford
                                    ? 'Desbloquear'
                                    : 'Faltan Gotas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: decorItems.length,
        ),
      ),
    );
  }

  void _showInsufficientDrops(BuildContext context, int missing) {
    HapticsHelper.light();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te faltan $missing gotas. ¡Completa un microhábito para obtenerlas! 💧'),
        backgroundColor: const Color(0xFF0288D1),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

