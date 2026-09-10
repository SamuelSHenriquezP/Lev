import 'package:flutter/material.dart';

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

  IconData get icon {
    switch (this) {
      case MoodLevel.disconnected:
        return Icons.cloud_outlined;
      case MoodLevel.overwhelmed:
        return Icons.waves_rounded;
      case MoodLevel.calm:
        return Icons.spa_rounded;
      case MoodLevel.grateful:
        return Icons.favorite_rounded;
      case MoodLevel.radiant:
        return Icons.wb_sunny_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MoodLevel.disconnected:
        return const Color(0xFF94A3B8);
      case MoodLevel.overwhelmed:
        return const Color(0xFF5C85A0);
      case MoodLevel.calm:
        return const Color(0xFF6A994E);
      case MoodLevel.grateful:
        return const Color(0xFFE57373);
      case MoodLevel.radiant:
        return const Color(0xFFE5A93C);
    }
  }

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

