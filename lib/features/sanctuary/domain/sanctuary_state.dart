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

/// Elementos botánicos de entorno desbloqueables para el Santuario.
enum SanctuaryDecorItem {
  lotusPond(
    id: 'lotus_pond',
    name: 'Estanque de Loto',
    description: 'Nenúfares flotantes y ondas cristalinas de agua.',
    icon: Icons.water_rounded,
    dropCost: 8,
  ),
  zenStones(
    id: 'zen_stones',
    name: 'Rocas de Jardín Zen',
    description: 'Piedras de río pulidas que anclan la paz.',
    icon: Icons.filter_hdr_rounded,
    dropCost: 12,
  ),
  bioMoss(
    id: 'bio_moss',
    name: 'Musgo Bioluminiscente',
    description: 'Suaves destellos de luz esmeralda en el suelo.',
    icon: Icons.flare_rounded,
    dropCost: 18,
  ),
  windChimes(
    id: 'wind_chimes',
    name: 'Campanillas de Bambú',
    description: 'Susurros de viento que limpian pensamientos ruidosos.',
    icon: Icons.yard_rounded,
    dropCost: 25,
  );

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int dropCost;

  const SanctuaryDecorItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.dropCost,
  });

  static SanctuaryDecorItem? fromId(String id) {
    for (final item in values) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Etapa de crecimiento de Lev (0-7) basada en la experiencia botánica acumulada (XP).
/// Las Gotas de Cuidado son el recurso táctil para desbloquear el entorno,
/// mientras que la Experiencia (XP) refleja tu constancia y maduración interior.
enum LevGrowthStage {
  seed,        // 0: Semilla (0-49 XP) — solo bulbo, sin hojas
  sprout,      // 1: Brote (50-99 XP) — hojas muy pequeñas
  seedling,    // 2: Plántula (100-199 XP) — hojas medianas, cara aparece
  youngPlant,  // 3: Planta Joven (200-349 XP) — hojas completas
  vibrantPlant,// 4: Planta Vibrante (350-549 XP) — flores en puntas de hojas
  youngTree,   // 5: Árbol Juvenil (550-799 XP) — hojas más grandes, aura mayor
  adultTree,   // 6: Árbol Adulto (800-1199 XP) — copa frondosa, partículas
  forestSpirit,// 7: Espíritu del Bosque (1200+ XP) — forma final, máximo resplandor
}

class SanctuaryState {
  final int careDrops;
  final int experiencePoints;
  final int bloomingFlowers;
  final LevEmotion emotion;
  final String dialogue;
  final SanctuaryTimeOfDay timeOfDay;
  final int tapCount;
  final bool isPetting;
  final bool justLeveledUp; // true por un ciclo cuando sube de etapa
  final Set<SanctuaryDecorItem> unlockedDecors;
  final Set<SanctuaryDecorItem> activeDecors;

  SanctuaryState({
    required this.careDrops,
    int? experiencePoints,
    this.bloomingFlowers = 3,
    this.emotion = LevEmotion.peaceful,
    this.dialogue = 'Respira hondo...',
    this.timeOfDay = SanctuaryTimeOfDay.morning,
    this.tapCount = 0,
    this.isPetting = false,
    this.justLeveledUp = false,
    Set<SanctuaryDecorItem>? unlockedDecors,
    Set<SanctuaryDecorItem>? activeDecors,
  })  : experiencePoints = experiencePoints ?? (careDrops * 10),
        unlockedDecors = unlockedDecors ?? const {},
        activeDecors = activeDecors ?? const {};

  /// Calcula la etapa de crecimiento según los puntos de experiencia acumulados.
  LevGrowthStage get growthStage {
    if (experiencePoints < 50) return LevGrowthStage.seed;
    if (experiencePoints < 100) return LevGrowthStage.sprout;
    if (experiencePoints < 200) return LevGrowthStage.seedling;
    if (experiencePoints < 350) return LevGrowthStage.youngPlant;
    if (experiencePoints < 550) return LevGrowthStage.vibrantPlant;
    if (experiencePoints < 800) return LevGrowthStage.youngTree;
    if (experiencePoints < 1200) return LevGrowthStage.adultTree;
    return LevGrowthStage.forestSpirit;
  }

  /// Factor de crecimiento 0.0-1.0 para interpolar visualmente dentro de la etapa actual.
  double get growthFactor {
    switch (growthStage) {
      case LevGrowthStage.seed:
        return (experiencePoints / 49.0).clamp(0.0, 1.0);
      case LevGrowthStage.sprout:
        return ((experiencePoints - 50) / 49.0).clamp(0.0, 1.0);
      case LevGrowthStage.seedling:
        return ((experiencePoints - 100) / 99.0).clamp(0.0, 1.0);
      case LevGrowthStage.youngPlant:
        return ((experiencePoints - 200) / 149.0).clamp(0.0, 1.0);
      case LevGrowthStage.vibrantPlant:
        return ((experiencePoints - 350) / 199.0).clamp(0.0, 1.0);
      case LevGrowthStage.youngTree:
        return ((experiencePoints - 550) / 249.0).clamp(0.0, 1.0);
      case LevGrowthStage.adultTree:
        return ((experiencePoints - 800) / 399.0).clamp(0.0, 1.0);
      case LevGrowthStage.forestSpirit:
        return 1.0;
    }
  }

  int get currentStageMinXp {
    switch (growthStage) {
      case LevGrowthStage.seed: return 0;
      case LevGrowthStage.sprout: return 50;
      case LevGrowthStage.seedling: return 100;
      case LevGrowthStage.youngPlant: return 200;
      case LevGrowthStage.vibrantPlant: return 350;
      case LevGrowthStage.youngTree: return 550;
      case LevGrowthStage.adultTree: return 800;
      case LevGrowthStage.forestSpirit: return 1200;
    }
  }

  int? get nextStageMinXp {
    switch (growthStage) {
      case LevGrowthStage.seed: return 50;
      case LevGrowthStage.sprout: return 100;
      case LevGrowthStage.seedling: return 200;
      case LevGrowthStage.youngPlant: return 350;
      case LevGrowthStage.vibrantPlant: return 550;
      case LevGrowthStage.youngTree: return 800;
      case LevGrowthStage.adultTree: return 1200;
      case LevGrowthStage.forestSpirit: return null;
    }
  }

  /// Puntos de experiencia que faltan para la siguiente etapa.
  int? get xpToNextStage {
    final nextMin = nextStageMinXp;
    if (nextMin == null) return null;
    return (nextMin - experiencePoints).clamp(0, 9999);
  }

  /// Gotas necesarias estimadas (compatibilidad legado).
  int? get dropsToNextStage {
    final xp = xpToNextStage;
    if (xp == null) return null;
    return (xp / 10).ceil();
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
    int? experiencePoints,
    int? bloomingFlowers,
    LevEmotion? emotion,
    String? dialogue,
    SanctuaryTimeOfDay? timeOfDay,
    int? tapCount,
    bool? isPetting,
    bool? justLeveledUp,
    Set<SanctuaryDecorItem>? unlockedDecors,
    Set<SanctuaryDecorItem>? activeDecors,
  }) {
    return SanctuaryState(
      careDrops: careDrops ?? this.careDrops,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      bloomingFlowers: bloomingFlowers ?? this.bloomingFlowers,
      emotion: emotion ?? this.emotion,
      dialogue: dialogue ?? this.dialogue,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      tapCount: tapCount ?? this.tapCount,
      isPetting: isPetting ?? this.isPetting,
      justLeveledUp: justLeveledUp ?? false,
      unlockedDecors: unlockedDecors ?? this.unlockedDecors,
      activeDecors: activeDecors ?? this.activeDecors,
    );
  }
}
