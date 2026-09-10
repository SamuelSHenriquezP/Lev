import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tipos de paisajes sonoros para la relajación en el Santuario de Lev.
enum SanctuarySound {
  none(
    id: 'none',
    title: 'Silencio Calmo',
    description: 'Tranquilidad serena sin estímulos auditivos.',
    emoji: '🌿',
  ),
  rain(
    id: 'rain',
    title: 'Lluvia en el Estanque',
    description: 'Gotas de agua acariciando las hojas y los nenúfares.',
    emoji: '🌧️',
  ),
  forest(
    id: 'forest',
    title: 'Brisa del Bosque',
    description: 'Viento tibio cruzando copas de bambú y pinos.',
    emoji: '🍃',
  ),
  stream(
    id: 'stream',
    title: 'Manantial de Montaña',
    description: 'Murmullo rítmico y constante de agua viva.',
    emoji: '💧',
  ),
  purr(
    id: 'purr',
    title: 'Ronroneo de Lev',
    description: 'Vibración cálida de baja frecuencia, reconfortante.',
    emoji: '🐾',
  );

  const SanctuarySound({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
}

class SanctuaryAudioState {
  final SanctuarySound currentSound;
  final bool isPlaying;
  final double volume;

  const SanctuaryAudioState({
    this.currentSound = SanctuarySound.none,
    this.isPlaying = false,
    this.volume = 0.7,
  });

  SanctuaryAudioState copyWith({
    SanctuarySound? currentSound,
    bool? isPlaying,
    double? volume,
  }) {
    return SanctuaryAudioState(
      currentSound: currentSound ?? this.currentSound,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }
}

class SanctuaryAudioNotifier extends Notifier<SanctuaryAudioState> {
  @override
  SanctuaryAudioState build() {
    return const SanctuaryAudioState();
  }

  void toggleSound(SanctuarySound sound) {
    if (state.currentSound == sound && state.isPlaying) {
      // Pausar
      state = state.copyWith(isPlaying: false);
    } else {
      // Activar nuevo sonido
      state = state.copyWith(
        currentSound: sound,
        isPlaying: true,
      );
    }
  }

  void stop() {
    state = state.copyWith(isPlaying: false, currentSound: SanctuarySound.none);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }
}

final sanctuaryAudioProvider =
    NotifierProvider<SanctuaryAudioNotifier, SanctuaryAudioState>(
  SanctuaryAudioNotifier.new,
);

