import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/audio/sanctuary_audio_service.dart';
import '../../../../core/theme/lev_theme.dart';
import '../../../../core/utils/haptics_helper.dart';

class SanctuaryAudioDialog extends ConsumerWidget {
  const SanctuaryAudioDialog({super.key});

  static void show(BuildContext context) {
    HapticsHelper.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
      ),
      builder: (context) => const SanctuaryAudioDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(sanctuaryAudioProvider);
    final audioNotifier = ref.read(sanctuaryAudioProvider.notifier);

    final sounds = SanctuarySound.values.where((s) => s != SanctuarySound.none).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: LevTheme.levBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LevTheme.levMatchaLight,
                ),
                child: const Icon(Icons.headphones_rounded, size: 22, color: LevTheme.levMatchaDark),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sonidos del Santuario',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  Text(
                    'Ambientes calmos para desconectar de las redes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lista de paisajes sonoros
          ...sounds.map((sound) {
            final isCurrent = audioState.currentSound == sound && audioState.isPlaying;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? LevTheme.levMatchaLight
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isCurrent ? LevTheme.levMatcha : LevTheme.levBorder,
                    width: isCurrent ? 1.8 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Text(sound.emoji, style: const TextStyle(fontSize: 26)),
                  title: Text(
                    sound.title,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  subtitle: Text(
                    sound.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isCurrent ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: LevTheme.levMatcha,
                      size: 32,
                    ),
                    onPressed: () {
                      HapticsHelper.selection();
                      audioNotifier.toggleSound(sound);
                    },
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Control de volumen
          if (audioState.isPlaying) ...[
            Row(
              children: [
                const Icon(Icons.volume_down_rounded, size: 20, color: LevTheme.levTextMuted),
                Expanded(
                  child: Slider(
                    value: audioState.volume,
                    activeColor: LevTheme.levMatcha,
                    inactiveColor: LevTheme.levMatchaLight,
                    onChanged: (val) => audioNotifier.setVolume(val),
                  ),
                ),
                const Icon(Icons.volume_up_rounded, size: 20, color: LevTheme.levTextMuted),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

