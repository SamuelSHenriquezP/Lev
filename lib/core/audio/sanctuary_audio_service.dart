import 'dart:io' show Platform;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tipos de paisajes sonoros para la relajación en el Santuario de Lev.
enum SanctuarySound {
  none(
    id: 'none',
    title: 'Silencio Calmo',
    description: 'Tranquilidad serena sin estímulos auditivos.',
    emoji: '🌿',
    assetPath: '',
  ),
  rain(
    id: 'rain',
    title: 'Lluvia en el Estanque',
    description: 'Gotas de agua acariciando las hojas y los nenúfares.',
    emoji: '🌧️',
    assetPath: 'audio/rain.wav',
  ),
  forest(
    id: 'forest',
    title: 'Brisa del Bosque',
    description: 'Viento tibio cruzando copas de bambú y pinos.',
    emoji: '🍃',
    assetPath: 'audio/forest.wav',
  ),
  stream(
    id: 'stream',
    title: 'Manantial de Montaña',
    description: 'Murmullo rítmico y constante de agua viva.',
    emoji: '💧',
    assetPath: 'audio/stream.wav',
  ),
  purr(
    id: 'purr',
    title: 'Ronroneo de Lev',
    description: 'Vibración cálida de baja frecuencia, reconfortante.',
    emoji: '🐾',
    assetPath: 'audio/purr.wav',
  );

  const SanctuarySound({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.assetPath,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final String assetPath;
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
  AudioPlayer? _ambientPlayer;
  AudioPlayer? _sfxPlayer;

  static bool get _isTest {
    try {
      return !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  SanctuaryAudioState build() {
    ref.onDispose(() {
      try {
        _ambientPlayer?.dispose();
        _sfxPlayer?.dispose();
      } catch (_) {}
    });
    return const SanctuaryAudioState();
  }

  AudioPlayer? _getAmbientPlayer() {
    if (_isTest) return null;
    return _ambientPlayer ??= AudioPlayer();
  }

  AudioPlayer? _getSfxPlayer() {
    if (_isTest) return null;
    return _sfxPlayer ??= AudioPlayer();
  }

  Future<void> toggleSound(SanctuarySound sound) async {
    if (state.currentSound == sound && state.isPlaying) {
      await stop();
    } else {
      await playSound(sound);
    }
  }

  Future<void> playSound(SanctuarySound sound) async {
    if (sound == SanctuarySound.none) {
      await stop();
      return;
    }

    state = state.copyWith(
      currentSound: sound,
      isPlaying: true,
    );

    if (_isTest) return;

    try {
      final player = _getAmbientPlayer();
      if (player == null) return;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(state.volume);
      await player.play(AssetSource(sound.assetPath));
    } catch (e) {
      debugPrint('SanctuaryAudioNotifier: Error al reproducir audio ambiental: $e');
    }
  }

  Future<void> stop() async {
    state = state.copyWith(isPlaying: false, currentSound: SanctuarySound.none);
    if (_isTest) return;
    try {
      await _ambientPlayer?.stop();
    } catch (e) {
      debugPrint('SanctuaryAudioNotifier: Error al detener audio: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped);
    if (_isTest) return;
    try {
      await _ambientPlayer?.setVolume(clamped);
    } catch (e) {
      debugPrint('SanctuaryAudioNotifier: Error al cambiar volumen: $e');
    }
  }

  /// Reproduce un efecto táctil sutil (SFX de gota de agua)
  Future<void> playWaterDropSfx() async {
    if (_isTest) return;
    try {
      final sfx = _getSfxPlayer();
      if (sfx == null) return;
      await sfx.setVolume((state.volume * 0.9).clamp(0.1, 1.0));
      await sfx.play(AssetSource('audio/water_drop.wav'), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('SanctuaryAudioNotifier: Error al reproducir SFX de agua: $e');
    }
  }

  /// Reproduce una campanilla de logro / evolución / compra
  Future<void> playChimeSfx() async {
    if (_isTest) return;
    try {
      final sfx = _getSfxPlayer();
      if (sfx == null) return;
      await sfx.setVolume(state.volume.clamp(0.2, 1.0));
      await sfx.play(AssetSource('audio/chime.wav'), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('SanctuaryAudioNotifier: Error al reproducir SFX de chime: $e');
    }
  }
}

final sanctuaryAudioProvider =
    NotifierProvider<SanctuaryAudioNotifier, SanctuaryAudioState>(
  SanctuaryAudioNotifier.new,
);


