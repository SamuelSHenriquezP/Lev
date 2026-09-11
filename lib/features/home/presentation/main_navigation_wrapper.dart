import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/companion/presentation/lev_chat_bubble.dart';
import 'package:lev/features/habits/presentation/habits_catalog_screen.dart';
import 'package:lev/features/journal/presentation/journal_screen.dart';
import 'package:lev/features/onboarding/presentation/onboarding_screen.dart';
import 'package:lev/features/sanctuary/presentation/sanctuary_shop_screen.dart';
import 'home_screen.dart';

/// Navegación principal de Lev.
/// 4 tabs equilibradas: Santuario, Hábitos, Tienda, Progreso + FAB de Lev como chat flotante.
class MainNavigationWrapper extends StatefulWidget {
  final bool? showOnboarding;

  const MainNavigationWrapper({super.key, this.showOnboarding});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _indicatorController;
  late bool _showingOnboarding;

  @override
  void initState() {
    super.initState();
    _showingOnboarding = widget.showOnboarding ?? (!LocalStorageService.hasSeenOnboarding());
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..value = 0.0;
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    HapticsHelper.selection();
    setState(() => _currentIndex = index);
    _indicatorController.forward(from: 0.0);
  }

  static const _tabs = [
    _TabDef(icon: Icons.spa_outlined, activeIcon: Icons.spa_rounded, label: 'Santuario'),
    _TabDef(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome_rounded, label: 'Hábitos'),
    _TabDef(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: 'Tienda'),
    _TabDef(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Progreso'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_showingOnboarding) {
      return OnboardingScreen(
        onFinish: () {
          setState(() => _showingOnboarding = false);
        },
      );
    }

    final theme = Theme.of(context);
    final screens = [
      HomeScreen(onNavigateToTab: _onTabSelected),
      const HabitsCatalogScreen(),
      const SanctuaryShopScreen(),
      const JournalScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Pantallas principales
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // FAB de Lev (chat flotante) sobre todo
          const Positioned.fill(
            child: LevChatBubble(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? LevTheme.levDarkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? LevTheme.levDarkBorder : LevTheme.levBorder,
            width: 1.0,
          ),
        ),
        boxShadow: isDark
            ? const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x0A2D3748),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_tabs.length, (i) => _buildNavItem(i, theme)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _currentIndex == index;
    final tab = _tabs[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _indicatorController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? LevTheme.levMatchaNight.withValues(alpha: 0.18)
                            : LevTheme.levMatchaLight)
                        : Colors.transparent,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Icon(
                    isSelected ? tab.activeIcon : tab.icon,
                    size: 21,
                    color: isSelected
                        ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatchaDark)
                        : (isDark ? LevTheme.levDarkTextMuted : LevTheme.levTextMuted),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? LevTheme.levMatchaNight : LevTheme.levMatchaDark)
                        : (isDark ? LevTheme.levDarkTextMuted : LevTheme.levTextMuted),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabDef {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabDef({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
