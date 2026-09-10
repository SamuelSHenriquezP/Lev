enum MoodLevel {
  disconnected(1, 'Desconectado', '🌫️'),
  overwhelmed(2, 'Agobiado', '🌧️'),
  calm(3, 'En Calma', '🍃'),
  grateful(4, 'Agradecido', '☀️'),
  radiant(5, 'Radiante', '🪷');

  const MoodLevel(this.score, this.label, this.emoji);
  final int score;
  final String label;
  final String emoji;

  static MoodLevel fromScore(int score) {
    return MoodLevel.values.firstWhere(
      (m) => m.score == score,
      orElse: () => MoodLevel.calm,
    );
  }
}

class MoodEntry {
  final String id;
  final MoodLevel mood;
  final List<String> tags;
  final String note;
  final DateTime timestamp;

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.tags,
    this.note = '',
    required this.timestamp,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      mood: MoodLevel.fromScore(json['score'] as int? ?? 3),
      tags: List<String>.from(json['tags'] as List? ?? []),
      note: json['note'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': mood.score,
      'tags': tags,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

