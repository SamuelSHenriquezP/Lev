import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/companion/presentation/companion_chat_screen.dart';
import 'package:lev/features/habits/presentation/habits_catalog_screen.dart';
import 'package:lev/features/journal/presentation/journal_screen.dart';
import 'home_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticsHelper.selection();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _onTabSelected),
      const CompanionChatScreen(),
      const HabitsCatalogScreen(),
      const JournalScreen(),
    ];

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  emoji: '🌿',
                  label: 'Santuario',
                ),
                _buildNavItem(
                  index: 1,
                  emoji: '💬',
                  label: 'Lev',
                ),
                _buildNavItem(
                  index: 2,
                  emoji: '⏱️',
                  label: 'Hábitos',
                ),
                _buildNavItem(
                  index: 3,
                  emoji: '📖',
                  label: 'Diario',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String emoji,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? LevTheme.levMatchaLight : Colors.transparent,
          borderRadius: LevTheme.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: isSelected ? 18 : 16,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

