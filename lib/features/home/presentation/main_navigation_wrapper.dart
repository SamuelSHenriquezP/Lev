import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/companion/presentation/lev_chat_bubble.dart';
import 'package:lev/features/habits/presentation/habits_catalog_screen.dart';
import 'package:lev/features/journal/presentation/journal_screen.dart';
import 'home_screen.dart';

/// Navegación principal de Lev.
/// 3 tabs con iconos limpios + FAB de Lev como chat flotante.
/// Sin emojis en la barra de navegación.
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _indicatorController;

  @override
  void initState() {
    super.initState();
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
    _TabDef(icon: Icons.spa_rounded, activeIcon: Icons.spa, label: 'Santuario'),
    _TabDef(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'Hábitos'),
    _TabDef(icon: Icons.bar_chart_rounded, activeIcon: Icons.bar_chart_rounded, label: 'Progreso'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _onTabSelected),
      const HabitsCatalogScreen(),
      const JournalScreen(),
    ];

    return Scaffold(
      backgroundColor: LevTheme.levCream,
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: LevTheme.levBorder, width: 1.0),
        ),
        boxShadow: const [
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
            children: List.generate(_tabs.length, (i) => _buildNavItem(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? LevTheme.levMatchaLight
                        : Colors.transparent,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Icon(
                    isSelected ? tab.activeIcon : tab.icon,
                    size: 22,
                    color: isSelected
                        ? LevTheme.levMatchaDark
                        : LevTheme.levTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? LevTheme.levMatchaDark
                        : LevTheme.levTextMuted,
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
