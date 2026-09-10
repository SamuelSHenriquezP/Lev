/// Entidad que modela un microhábito consciente de 60 segundos.
class MicroHabit {
  final String id;
  final String title;
  final String levIntro;
  final List<String> steps;
  final String psychologicalBasis;
  final String category;
  final int durationSeconds;
  final String iconEmoji;
  final List<String> tags;
  final bool isFavorite;

  const MicroHabit({
    required this.id,
    required this.title,
    required this.levIntro,
    required this.steps,
    required this.psychologicalBasis,
    required this.category,
    this.durationSeconds = 60,
    this.iconEmoji = '🌱',
    this.tags = const [],
    this.isFavorite = false,
  });

  MicroHabit copyWith({
    String? id,
    String? title,
    String? levIntro,
    List<String>? steps,
    String? psychologicalBasis,
    String? category,
    int? durationSeconds,
    String? iconEmoji,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return MicroHabit(
      id: id ?? this.id,
      title: title ?? this.title,
      levIntro: levIntro ?? this.levIntro,
      steps: steps ?? this.steps,
      psychologicalBasis: psychologicalBasis ?? this.psychologicalBasis,
      category: category ?? this.category,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory MicroHabit.fromJson(Map<String, dynamic> json) {
    return MicroHabit(
      id: json['id'] as String,
      title: json['title'] as String,
      levIntro: json['lev_intro'] as String,
      steps: List<String>.from(json['steps'] as List),
      psychologicalBasis: json['psychological_basis'] as String,
      category: json['category'] as String? ?? 'General',
      durationSeconds: json['duration_seconds'] as int? ?? 60,
      iconEmoji: json['icon_emoji'] as String? ?? '🌱',
      tags: List<String>.from(json['tags'] as List? ?? []),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lev_intro': levIntro,
      'steps': steps,
      'psychological_basis': psychologicalBasis,
      'category': category,
      'duration_seconds': durationSeconds,
      'icon_emoji': iconEmoji,
      'tags': tags,
      'is_favorite': isFavorite,
    };
  }

  LevTaskAction get taskAction {
    if (id == 'doom_01' || id == 'doom_03') return LevTaskAction.eyeRest;
    if (id == 'doom_04' || id == 'ang_03') return LevTaskAction.chestStretch;
    if (id == 'doom_02' || id == 'anx_02') return LevTaskAction.grounding;
    if (id == 'anx_01' || id == 'slp_03' || id == 'ang_02') return LevTaskAction.breathing;
    if (id == 'anx_04' || id == 'blk_02') return LevTaskAction.coldSplash;
    if (id == 'sad_01' || id == 'sad_02' || id == 'crt_01') return LevTaskAction.soothingTouch;
    if (id == 'sad_03' || id == 'crt_02') return LevTaskAction.warmTeaHold;
    if (id == 'ang_01' || id == 'blk_01') return LevTaskAction.tensionShake;
    if (id == 'slp_01' || id == 'slp_02') return LevTaskAction.sleepDrift;
    if (category.contains('Doomscrolling')) return LevTaskAction.eyeRest;
    if (category.contains('Ansiedad')) return LevTaskAction.breathing;
    if (category.contains('Tristeza') || category.contains('Culpa')) return LevTaskAction.soothingTouch;
    if (category.contains('Frustración')) return LevTaskAction.tensionShake;
    if (category.contains('Insomnio')) return LevTaskAction.sleepDrift;
    if (category.contains('Bloqueo')) return LevTaskAction.tensionShake;
    return LevTaskAction.breathing;
  }
}

enum LevTaskAction {
  breathing(label: 'Respiración', badgeEmoji: '🫁'),
  eyeRest(label: 'Descanso Ocular', badgeEmoji: '👁️'),
  chestStretch(label: 'Estiramiento', badgeEmoji: '🌿'),
  soothingTouch(label: 'Tacto Calmante', badgeEmoji: '🤲'),
  coldSplash(label: 'Agua Fresca', badgeEmoji: '💧'),
  tensionShake(label: 'Sacudida', badgeEmoji: '⚡'),
  sleepDrift(label: 'Modo Siesta', badgeEmoji: '🌙'),
  grounding(label: 'Anclaje', badgeEmoji: '🦶'),
  warmTeaHold(label: 'Calor Suave', badgeEmoji: '🍵');

  final String label;
  final String badgeEmoji;

  const LevTaskAction({required this.label, required this.badgeEmoji});
}

class HabitCategoryInfo {
  final String name;
  final String emoji;
  final String description;
  final String shortName;

  const HabitCategoryInfo({
    required this.name,
    required this.emoji,
    required this.description,
    required this.shortName,
  });
}
