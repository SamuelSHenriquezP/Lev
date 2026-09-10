enum LevEmotion {
  peaceful,
  happy,
  sheltered, // Cobijado bajo sus hojas como mantita
  curious,
  celebrating,
  breathing, // Respiración somática guiada profunda
  sleeping,  // Siesta tranquila con burbujitas Zzz
  joyJump,   // Salto alegre y giro elástico
}

enum SanctuaryTimeOfDay {
  morning,
  afternoon,
  dusk,
  night,
}

class SanctuaryState {
  final int careDrops;
  final int bloomingFlowers;
  final LevEmotion emotion;
  final String dialogue;
  final SanctuaryTimeOfDay timeOfDay;
  final int tapCount;
  final bool isPetting;

  const SanctuaryState({
    required this.careDrops,
    required this.bloomingFlowers,
    required this.emotion,
    required this.dialogue,
    required this.timeOfDay,
    this.tapCount = 0,
    this.isPetting = false,
  });

  String get sanctuaryLevelName {
    if (careDrops < 20) return 'Brote de Paz';
    if (careDrops < 40) return 'Semilla de Luz';
    if (careDrops < 70) return 'Planta de Calma';
    return 'Espíritu de Armonía';
  }

  String get sanctuaryLevelEmoji {
    if (careDrops < 20) return '🌱';
    if (careDrops < 40) return '✨';
    if (careDrops < 70) return '🌿';
    return '🌸';
  }

  SanctuaryState copyWith({
    int? careDrops,
    int? bloomingFlowers,
    LevEmotion? emotion,
    String? dialogue,
    SanctuaryTimeOfDay? timeOfDay,
    int? tapCount,
    bool? isPetting,
  }) {
    return SanctuaryState(
      careDrops: careDrops ?? this.careDrops,
      bloomingFlowers: bloomingFlowers ?? this.bloomingFlowers,
      emotion: emotion ?? this.emotion,
      dialogue: dialogue ?? this.dialogue,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      tapCount: tapCount ?? this.tapCount,
      isPetting: isPetting ?? this.isPetting,
    );
  }
}
