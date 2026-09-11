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

/// Accesorios botánicos y de abrigo para personalizar a Lev.
enum LevAccessory {
  none(
    id: 'none',
    name: 'Natural',
    description: 'Lev en su estado botánico puro.',
    icon: Icons.eco_rounded,
    dropCost: 0,
  ),
  sakuraFlower(
    id: 'sakura_flower',
    name: 'Flor de Sakura',
    description: 'Delicada flor de cerezo rosada en la cabeza.',
    icon: Icons.local_florist_rounded,
    dropCost: 8,
  ),
  cloverSprout(
    id: 'clover_sprout',
    name: 'Trébol de Paz',
    description: 'Trébol de cuatro hojas que se mece con su respiración.',
    icon: Icons.yard_rounded,
    dropCost: 6,
  ),
  lavenderScarf(
    id: 'lavender_scarf',
    name: 'Bufanda Lavanda',
    description: 'Tejido suave de lana para días fríos o vulnerables.',
    icon: Icons.waves_rounded,
    dropCost: 12,
  ),
  nightCap(
    id: 'night_cap',
    name: 'Gorrito de Dormir',
    description: 'Gorro nocturno con borla suave para descansar.',
    icon: Icons.bedtime_rounded,
    dropCost: 10,
  ),
  goldenCrown(
    id: 'golden_crown',
    name: 'Corona Zen',
    description: 'Laurel dorado botánico para celebrar tu constancia.',
    icon: Icons.military_tech_rounded,
    dropCost: 16,
  );

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int dropCost;

  const LevAccessory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.dropCost,
  });

  static LevAccessory? fromId(String id) {
    for (final a in values) {
      if (a.id == id) return a;
    }
    return null;
  }
}

/// Categorías de objetos y decoraciones para la casa de Lev.
enum DecorCategory {
  all(label: 'Todos', icon: Icons.auto_awesome_mosaic_rounded),
  furniture(label: 'Muebles', icon: Icons.chair_rounded),
  lighting(label: 'Luces', icon: Icons.lightbulb_rounded),
  companions(label: 'Compañeros', icon: Icons.pets_rounded),
  nature(label: 'Jardín', icon: Icons.park_rounded);

  final String label;
  final IconData icon;
  const DecorCategory({required this.label, required this.icon});
}

/// Elementos botánicos, muebles y fauna desbloqueables para la casa de Lev.
enum SanctuaryDecorItem {
  // --- Jardín & Naturaleza ---
  lotusPond(
    id: 'lotus_pond',
    name: 'Estanque de Loto',
    description: 'Nenúfares flotantes y ondas cristalinas de agua.',
    icon: Icons.water_rounded,
    category: DecorCategory.nature,
    dropCost: 8,
    defaultNormalizedPosition: Offset(0.50, 0.85),
  ),
  zenStones(
    id: 'zen_stones',
    name: 'Rocas de Jardín Zen',
    description: 'Piedras de río pulidas que anclan la paz.',
    icon: Icons.filter_hdr_rounded,
    category: DecorCategory.nature,
    dropCost: 12,
    defaultNormalizedPosition: Offset(0.24, 0.84),
  ),
  bioMoss(
    id: 'bio_moss',
    name: 'Musgo Bioluminiscente',
    description: 'Suaves destellos de luz esmeralda en el suelo.',
    icon: Icons.flare_rounded,
    category: DecorCategory.nature,
    dropCost: 18,
    defaultNormalizedPosition: Offset(0.50, 0.86),
  ),
  windChimes(
    id: 'wind_chimes',
    name: 'Campanillas de Bambú',
    description: 'Susurros de viento que limpian pensamientos ruidosos.',
    icon: Icons.yard_rounded,
    category: DecorCategory.nature,
    dropCost: 20,
    defaultNormalizedPosition: Offset(0.85, 0.12),
  ),
  sakuraVase(
    id: 'sakura_vase',
    name: 'Jarrón de Sakura',
    description: 'Flores de cerezo con pétalos rosados flotantes.',
    icon: Icons.local_florist_rounded,
    category: DecorCategory.nature,
    dropCost: 13,
    defaultNormalizedPosition: Offset(0.82, 0.74),
  ),
  bambooPartition(
    id: 'bamboo_partition',
    name: 'Biombo de Bambú',
    description: 'Cañas verdes esbeltas que cobijan la estancia.',
    icon: Icons.density_small_rounded,
    category: DecorCategory.nature,
    dropCost: 9,
    defaultNormalizedPosition: Offset(0.10, 0.70),
  ),
  magicMushrooms(
    id: 'magic_mushrooms',
    name: 'Hongos Bioluminiscentes',
    description: 'Sombreros brillantes turquesa con aura suave.',
    icon: Icons.bubble_chart_rounded,
    category: DecorCategory.nature,
    dropCost: 14,
    defaultNormalizedPosition: Offset(0.28, 0.88),
  ),
  waterFountain(
    id: 'water_fountain',
    name: 'Fuente Shishi-Odoshi',
    description: 'Caña oscilante de bambú con flujo de agua en calma.',
    icon: Icons.opacity_rounded,
    category: DecorCategory.nature,
    dropCost: 22,
    defaultNormalizedPosition: Offset(0.78, 0.80),
  ),

  // --- Mobiliario & Confort Zen ---
  meditationCushion(
    id: 'meditation_cushion',
    name: 'Cojín Zafu',
    description: 'Cojín redondo acolchado de lino matcha.',
    icon: Icons.circle_outlined,
    category: DecorCategory.furniture,
    dropCost: 6,
    defaultNormalizedPosition: Offset(0.33, 0.86),
  ),
  matchaTable(
    id: 'matcha_table',
    name: 'Mesa de Té Matcha',
    description: 'Mesita baja con cuenco y vapor animado ondeante.',
    icon: Icons.coffee_rounded,
    category: DecorCategory.furniture,
    dropCost: 10,
    defaultNormalizedPosition: Offset(0.67, 0.86),
  ),
  bonsaiTree(
    id: 'bonsai_tree',
    name: 'Bonsái Ancestral',
    description: 'Árbol miniatura en maceta de barro cocido.',
    icon: Icons.nature_rounded,
    category: DecorCategory.furniture,
    dropCost: 14,
    defaultNormalizedPosition: Offset(0.18, 0.75),
  ),
  readingBooks(
    id: 'reading_books',
    name: 'Rincón de Libros',
    description: 'Pila de lecturas botánicas con marcapáginas.',
    icon: Icons.menu_book_rounded,
    category: DecorCategory.furniture,
    dropCost: 8,
    defaultNormalizedPosition: Offset(0.22, 0.84),
  ),

  // --- Iluminación & Fuego Vivo ---
  paperLantern(
    id: 'paper_lantern',
    name: 'Farolillo de Papel',
    description: 'Farol colgante que oscila con luz dorada suave.',
    icon: Icons.light_mode_rounded,
    category: DecorCategory.lighting,
    dropCost: 12,
    defaultNormalizedPosition: Offset(0.15, 0.12),
  ),
  aromaCandle(
    id: 'aroma_candle',
    name: 'Vela Aromática',
    description: 'Llama viva parpadeante de lavanda y cera pura.',
    icon: Icons.wb_incandescent_rounded,
    category: DecorCategory.lighting,
    dropCost: 7,
    defaultNormalizedPosition: Offset(0.38, 0.90),
  ),
  saltLamp(
    id: 'salt_lamp',
    name: 'Lámpara de Sal',
    description: 'Cristal ámbar del Himalaya con resplandor cálido.',
    icon: Icons.wb_twilight_rounded,
    category: DecorCategory.lighting,
    dropCost: 15,
    defaultNormalizedPosition: Offset(0.62, 0.90),
  ),

  // --- Compañeros & Fauna ---
  fireflies(
    id: 'fireflies',
    name: 'Enjambre de Luciérnagas',
    description: 'Destellos de luz que revolotean por la casa.',
    icon: Icons.auto_awesome_rounded,
    category: DecorCategory.companions,
    dropCost: 16,
    defaultNormalizedPosition: Offset(0.50, 0.48),
  ),
  spiritButterfly(
    id: 'spirit_butterfly',
    name: 'Mariposa de Cristal',
    description: 'Alas translúcidas que aletean con gentileza.',
    icon: Icons.flutter_dash_rounded,
    category: DecorCategory.companions,
    dropCost: 11,
    defaultNormalizedPosition: Offset(0.76, 0.65),
  ),
  zenBird(
    id: 'zen_bird',
    name: 'Pajarito Cantor',
    description: 'Pajarito azul en rama que acompaña tus pausas.',
    icon: Icons.cruelty_free_rounded,
    category: DecorCategory.companions,
    dropCost: 15,
    defaultNormalizedPosition: Offset(0.86, 0.18),
  ),
  cozyCat(
    id: 'cozy_cat',
    name: 'Gatito en Siesta',
    description: 'Bolita de pelo dormida que respira acompasada.',
    icon: Icons.pets_rounded,
    category: DecorCategory.companions,
    dropCost: 20,
    defaultNormalizedPosition: Offset(0.74, 0.88),
  );

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final DecorCategory category;
  final int dropCost;
  final Offset defaultNormalizedPosition;

  const SanctuaryDecorItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.dropCost,
    required this.defaultNormalizedPosition,
  });

  static SanctuaryDecorItem? fromId(String id) {
    for (final item in values) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Climas y atmósferas vivas para el Santuario de Lev.
enum SanctuaryWeather {
  calm(id: 'calm', label: 'Sereno', emoji: '🌿', icon: Icons.wb_sunny_outlined),
  rain(id: 'rain', label: 'Lluvia Zen', emoji: '🌧️', icon: Icons.water_drop_outlined),
  breeze(id: 'breeze', label: 'Brisa de Pétalos', emoji: '🍃', icon: Icons.air_rounded),
  starry(id: 'starry', label: 'Noche Estrellada', emoji: '✨', icon: Icons.auto_awesome_rounded);

  const SanctuaryWeather({
    required this.id,
    required this.label,
    required this.emoji,
    required this.icon,
  });

  final String id;
  final String label;
  final String emoji;
  final IconData icon;

  static SanctuaryWeather fromId(String id) {
    return SanctuaryWeather.values.firstWhere(
      (w) => w.id == id,
      orElse: () => SanctuaryWeather.calm,
    );
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
  final Map<SanctuaryDecorItem, Offset> customDecorPositions;
  final LevAccessory activeAccessory;
  final Set<LevAccessory> unlockedAccessories;
  final SanctuaryTimeOfDay? circadianOverride;
  final SanctuaryWeather weather;
  final bool isWatering;
  final LevGrowthStage? pendingEvolutionStage;

  SanctuaryState({
    required this.careDrops,
    this.experiencePoints = 0,
    this.bloomingFlowers = 3,
    this.emotion = LevEmotion.peaceful,
    this.dialogue = 'Respira hondo...',
    this.timeOfDay = SanctuaryTimeOfDay.morning,
    this.tapCount = 0,
    this.isPetting = false,
    this.justLeveledUp = false,
    Set<SanctuaryDecorItem>? unlockedDecors,
    Set<SanctuaryDecorItem>? activeDecors,
    Map<SanctuaryDecorItem, Offset>? customDecorPositions,
    this.activeAccessory = LevAccessory.none,
    Set<LevAccessory>? unlockedAccessories,
    this.circadianOverride,
    this.weather = SanctuaryWeather.calm,
    this.isWatering = false,
    this.pendingEvolutionStage,
  })  : unlockedDecors = unlockedDecors ?? const {},
        activeDecors = activeDecors ?? const {},
        customDecorPositions = customDecorPositions ?? const {},
        unlockedAccessories = unlockedAccessories ?? const {LevAccessory.none};

  /// Obtiene la posición normalizada (0.0-1.0) de un objeto decorativo (personalizada o por defecto).
  Offset getDecorPosition(SanctuaryDecorItem item) {
    return customDecorPositions[item] ?? item.defaultNormalizedPosition;
  }

  /// Momento del día efectivo (con soporte para anulación/previsualización manual).
  SanctuaryTimeOfDay get effectiveTimeOfDay => circadianOverride ?? timeOfDay;

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
    Map<SanctuaryDecorItem, Offset>? customDecorPositions,
    LevAccessory? activeAccessory,
    Set<LevAccessory>? unlockedAccessories,
    SanctuaryTimeOfDay? circadianOverride,
    bool clearCircadianOverride = false,
    SanctuaryWeather? weather,
    bool? isWatering,
    LevGrowthStage? pendingEvolutionStage,
    bool clearPendingEvolution = false,
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
      customDecorPositions: customDecorPositions ?? this.customDecorPositions,
      activeAccessory: activeAccessory ?? this.activeAccessory,
      unlockedAccessories: unlockedAccessories ?? this.unlockedAccessories,
      circadianOverride: clearCircadianOverride ? null : (circadianOverride ?? this.circadianOverride),
      weather: weather ?? this.weather,
      isWatering: isWatering ?? this.isWatering,
      pendingEvolutionStage: clearPendingEvolution ? null : (pendingEvolutionStage ?? this.pendingEvolutionStage),
    );
  }
}
