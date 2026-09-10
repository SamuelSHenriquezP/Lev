class CognitiveDistortion {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const CognitiveDistortion({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });

  static const List<CognitiveDistortion> standardDistortions = [
    CognitiveDistortion(
      id: 'catastrophism',
      name: 'Catastrofismo',
      description: 'Anticipar el peor escenario posible como si fuera inevitable.',
      emoji: '🌋',
    ),
    CognitiveDistortion(
      id: 'mental_filter',
      name: 'Filtro Negativo',
      description: 'Enfocar toda la atención en un detalle adverso, borrando lo positivo.',
      emoji: '🔍',
    ),
    CognitiveDistortion(
      id: 'all_or_nothing',
      name: 'Todo o Nada (Polarización)',
      description: 'Ver las cosas en blanco o negro; si no es perfecto, es un fracaso.',
      emoji: '⚖️',
    ),
    CognitiveDistortion(
      id: 'mind_reading',
      name: 'Lectura del Pensamiento',
      description: 'Asumir que los demás tienen juicios críticos sobre ti sin comprobarlo.',
      emoji: '🔮',
    ),
    CognitiveDistortion(
      id: 'emotional_reasoning',
      name: 'Razonamiento Emocional',
      description: 'Creer que porque sientes algo angustiante, necesariamente es real.',
      emoji: '💭',
    ),
    CognitiveDistortion(
      id: 'rigid_shoulds',
      name: '"Deberías" Rígidos',
      description: 'Exigencias inflexibles hacia ti mismo que provocan culpa constante.',
      emoji: '📏',
    ),
  ];
}

class CbtThoughtCard {
  final String id;
  final String automaticThought;
  final String distortionName;
  final String compassionateReframe;
  final DateTime createdAt;

  const CbtThoughtCard({
    required this.id,
    required this.automaticThought,
    required this.distortionName,
    required this.compassionateReframe,
    required this.createdAt,
  });

  factory CbtThoughtCard.fromJson(Map<String, dynamic> json) {
    return CbtThoughtCard(
      id: json['id'] as String,
      automaticThought: json['automatic_thought'] as String,
      distortionName: json['distortion_name'] as String,
      compassionateReframe: json['compassionate_reframe'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'automatic_thought': automaticThought,
      'distortion_name': distortionName,
      'compassionate_reframe': compassionateReframe,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

