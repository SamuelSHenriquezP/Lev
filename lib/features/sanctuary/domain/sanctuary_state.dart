import 'package:flutter/material.dart';

enum LevEmotion {
  peaceful,
  happy,
  sheltered,   // Cobijado bajo sus hojas como mantita
  curious,
  celebrating,
  breathing,   // Respiración somática guiada profunda
  sleeping,    // Siesta tranquila con burbujitas Zzz
  joyJump,     // Salto alegre y giro elástico
  sad,         // Decaído pero intentando dar ánimo
  anxious,     // Agitado, respiración acelerada
  tired,       // Cansado, ojos entrecerrados
}

enum SanctuaryTimeOfDay {
  morning,
  afternoon,
  dusk,
  night,
}

/// Etapa de crecimiento de Lev (0-7) basada en gotas acumuladas.
/// Cada etapa cambia la forma visual de Lev en el painter.
enum LevGrowthStage {
  seed,        // 0: Semilla (0-4 gotas) — solo bulbo, sin hojas
  sprout,      // 1: Brote (5-9) — hojas muy pequeñas
  seedling,    // 2: Plántula (10-19) — hojas medianas, cara aparece
  youngPlant,  // 3: Planta Joven (20-34) — hojas completas
  vibrantPlant,// 4: Planta Vibrante (35-54) — flores en puntas de hojas
  youngTree,   // 5: Árbol Juvenil (55-79) — hojas más grandes, aura mayor
  adultTree,   // 6: Árbol Adulto (80-119) — copa frondosa, partículas
  forestSpirit,// 7: Espíritu del Bosque (120+) — forma final, máximo resplandor
}

class SanctuaryState {
  final int careDrops;
  final int bloomingFlowers;
  final LevEmotion emotion;
  final String dialogue;
  final SanctuaryTimeOfDay timeOfDay;
  final int tapCount;
  final bool isPetting;
  final bool justLeveledUp; // true por un ciclo cuando sube de etapa

  const SanctuaryState({
    required this.careDrops,
    required this.bloomingFlowers,
    required this.emotion,
    required this.dialogue,
    required this.timeOfDay,
    this.tapCount = 0,
    this.isPetting = false,
    this.justLeveledUp = false,
  });

  /// Calcula la etapa de crecimiento según las gotas acumuladas.
  LevGrowthStage get growthStage {
    if (careDrops < 5) return LevGrowthStage.seed;
    if (careDrops < 10) return LevGrowthStage.sprout;
    if (careDrops < 20) return LevGrowthStage.seedling;
    if (careDrops < 35) return LevGrowthStage.youngPlant;
    if (careDrops < 55) return LevGrowthStage.vibrantPlant;
    if (careDrops < 80) return LevGrowthStage.youngTree;
    if (careDrops < 120) return LevGrowthStage.adultTree;
    return LevGrowthStage.forestSpirit;
  }

  /// Factor de crecimiento 0.0-1.0 para interpolar visualmente dentro de la etapa actual.
  double get growthFactor {
    switch (growthStage) {
      case LevGrowthStage.seed:
        return careDrops / 4.0;
      case LevGrowthStage.sprout:
        return (careDrops - 5) / 4.0;
      case LevGrowthStage.seedling:
        return (careDrops - 10) / 9.0;
      case LevGrowthStage.youngPlant:
        return (careDrops - 20) / 14.0;
      case LevGrowthStage.vibrantPlant:
        return (careDrops - 35) / 19.0;
      case LevGrowthStage.youngTree:
        return (careDrops - 55) / 24.0;
      case LevGrowthStage.adultTree:
        return (careDrops - 80) / 39.0;
      case LevGrowthStage.forestSpirit:
        return 1.0;
    }
  }

  /// Gotas necesarias para la siguiente etapa (null si ya es máximo).
  int? get dropsToNextStage {
    switch (growthStage) {
      case LevGrowthStage.seed: return 5 - careDrops;
      case LevGrowthStage.sprout: return 10 - careDrops;
      case LevGrowthStage.seedling: return 20 - careDrops;
      case LevGrowthStage.youngPlant: return 35 - careDrops;
      case LevGrowthStage.vibrantPlant: return 55 - careDrops;
      case LevGrowthStage.youngTree: return 80 - careDrops;
      case LevGrowthStage.adultTree: return 120 - careDrops;
      case LevGrowthStage.forestSpirit: return null;
    }
  }

  String get stageName {
    switch (growthStage) {
      case LevGrowthStage.seed: return 'Semilla';
      case LevGrowthStage.sprout: return 'Brote de Paz';
      case LevGrowthStage.seedling: return 'Plántula de Luz';
      case LevGrowthStage.youngPlant: return 'Planta Joven';
      case LevGrowthStage.vibrantPlant: return 'Planta Vibrante';
      case LevGrowthStage.youngTree: return 'Árbol Juvenil';
      case LevGrowthStage.adultTree: return 'Árbol Sabio';
      case LevGrowthStage.forestSpirit: return 'Espíritu del Bosque';
    }
  }

  String get growthStageName => stageName;

  String get stageIcon {
    switch (growthStage) {
      case LevGrowthStage.seed: return '🌰';
      case LevGrowthStage.sprout: return '🌱';
      case LevGrowthStage.seedling: return '🌿';
      case LevGrowthStage.youngPlant: return '🍃';
      case LevGrowthStage.vibrantPlant: return '🌺';
      case LevGrowthStage.youngTree: return '🌳';
      case LevGrowthStage.adultTree: return '🌲';
      case LevGrowthStage.forestSpirit: return '✨';
    }
  }

  IconData get stageMaterialIcon {
    switch (growthStage) {
      case LevGrowthStage.seed: return Icons.radio_button_unchecked_rounded;
      case LevGrowthStage.sprout: return Icons.spa_rounded;
      case LevGrowthStage.seedling: return Icons.eco_rounded;
      case LevGrowthStage.youngPlant: return Icons.park_outlined;
      case LevGrowthStage.vibrantPlant: return Icons.local_florist_rounded;
      case LevGrowthStage.youngTree: return Icons.forest_outlined;
      case LevGrowthStage.adultTree: return Icons.forest_rounded;
      case LevGrowthStage.forestSpirit: return Icons.auto_awesome_rounded;
    }
  }

  // Compatibilidad con código legado
  String get sanctuaryLevelName => stageName;
  String get sanctuaryLevelEmoji => stageIcon;

  SanctuaryState copyWith({
    int? careDrops,
    int? bloomingFlowers,
    LevEmotion? emotion,
    String? dialogue,
    SanctuaryTimeOfDay? timeOfDay,
    int? tapCount,
    bool? isPetting,
    bool? justLeveledUp,
  }) {
    return SanctuaryState(
      careDrops: careDrops ?? this.careDrops,
      bloomingFlowers: bloomingFlowers ?? this.bloomingFlowers,
      emotion: emotion ?? this.emotion,
      dialogue: dialogue ?? this.dialogue,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      tapCount: tapCount ?? this.tapCount,
      isPetting: isPetting ?? this.isPetting,
      justLeveledUp: justLeveledUp ?? false,
    );
  }
}
