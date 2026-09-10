import 'package:flutter/material.dart';
import 'package:lev/core/theme/lev_theme.dart';

class CognitiveDistortion {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final IconData icon;
  final Color color;

  const CognitiveDistortion({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.icon,
    required this.color,
  });

  static const List<CognitiveDistortion> standardDistortions = [
    CognitiveDistortion(
      id: 'catastrophism',
      name: 'Catastrofismo',
      description: 'Anticipar el peor escenario posible como si fuera inevitable.',
      emoji: '🌋',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFF4A28C),
    ),
    CognitiveDistortion(
      id: 'mental_filter',
      name: 'Filtro Negativo',
      description: 'Enfocar toda la atención en un detalle adverso, borrando lo positivo.',
      emoji: '🔍',
      icon: Icons.filter_alt_outlined,
      color: Color(0xFF81D4FA),
    ),
    CognitiveDistortion(
      id: 'all_or_nothing',
      name: 'Todo o Nada (Polarización)',
      description: 'Ver las cosas en blanco o negro; si no es perfecto, es un fracaso.',
      emoji: '⚖️',
      icon: Icons.balance_rounded,
      color: Color(0xFFFFF176),
    ),
    CognitiveDistortion(
      id: 'mind_reading',
      name: 'Lectura del Pensamiento',
      description: 'Asumir que los demás tienen juicios críticos sobre ti sin comprobarlo.',
      emoji: '🔮',
      icon: Icons.psychology_outlined,
      color: LevTheme.levLavanda,
    ),
    CognitiveDistortion(
      id: 'emotional_reasoning',
      name: 'Razonamiento Emocional',
      description: 'Creer que porque sientes algo angustiante, necesariamente es real.',
      emoji: '💭',
      icon: Icons.water_drop_outlined,
      color: LevTheme.levSky,
    ),
    CognitiveDistortion(
      id: 'rigid_shoulds',
      name: '"Deberías" Rígidos',
      description: 'Exigencias inflexibles hacia ti mismo que provocan culpa constante.',
      emoji: '📏',
      icon: Icons.rule_rounded,
      color: LevTheme.levMatchaLight,
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
