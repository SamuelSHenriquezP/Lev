import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/lev_theme.dart';
import '../../../../core/utils/haptics_helper.dart';
import '../../domain/mood_entry.dart';
import '../controllers/journal_controller.dart';

class QuickMoodCheckInSection extends ConsumerStatefulWidget {
  const QuickMoodCheckInSection({super.key});

  @override
  ConsumerState<QuickMoodCheckInSection> createState() =>
      _QuickMoodCheckInSectionState();
}

class _QuickMoodCheckInSectionState
    extends ConsumerState<QuickMoodCheckInSection> {
  MoodLevel? _lastSelected;
  bool _showSavedToast = false;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _onSelectMood(MoodLevel mood) {
    HapticsHelper.selection();
    _toastTimer?.cancel();
    setState(() {
      _lastSelected = mood;
      _showSavedToast = true;
    });

    ref.read(journalProvider.notifier).addMoodEntry(
      mood: mood,
      tags: ['Check-in'],
      note: '',
    );

    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showSavedToast = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Check-in emocional',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_showSavedToast)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showSavedToast ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 13, color: LevTheme.levMatchaDark),
                      const SizedBox(width: 4),
                      Text(
                        'Registrado',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levMatchaDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '¿Cómo te encuentras en este momento?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: LevTheme.levTextMuted,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodLevel.values.map((level) {
              final isSelected = _lastSelected == level;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _onSelectMood(level),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? level.color.withValues(alpha: 0.35)
                                : level.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? LevTheme.levMatchaDark : Colors.transparent,
                              width: 2.0,
                            ),
                            boxShadow: isSelected ? LevTheme.glowShadow : const [],
                          ),
                          child: Icon(
                            level.icon,
                            size: 20,
                            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          level.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextDark,
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
    );
  }
}
