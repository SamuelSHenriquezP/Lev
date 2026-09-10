import '../../habits/domain/micro_habit.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isFromLev;
  final DateTime timestamp;
  final List<String> quickReplies;
  final MicroHabit? recommendedHabit;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromLev,
    required this.timestamp,
    this.quickReplies = const [],
    this.recommendedHabit,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isFromLev,
    DateTime? timestamp,
    List<String>? quickReplies,
    MicroHabit? recommendedHabit,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isFromLev: isFromLev ?? this.isFromLev,
      timestamp: timestamp ?? this.timestamp,
      quickReplies: quickReplies ?? this.quickReplies,
      recommendedHabit: recommendedHabit ?? this.recommendedHabit,
    );
  }
}

