import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/journal/domain/cbt_thought_card.dart';
import 'package:lev/features/journal/domain/mood_entry.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

class JournalState {
  final List<MoodEntry> moodEntries;
  final List<CbtThoughtCard> cbtCards;

  const JournalState({
    required this.moodEntries,
    required this.cbtCards,
  });

  JournalState copyWith({
    List<MoodEntry>? moodEntries,
    List<CbtThoughtCard>? cbtCards,
  }) {
    return JournalState(
      moodEntries: moodEntries ?? this.moodEntries,
      cbtCards: cbtCards ?? this.cbtCards,
    );
  }
}

class JournalController extends Notifier<JournalState> {
  static JournalState _buildInitialSeed() {
    final now = DateTime.now();
    final seedMoods = [
      MoodEntry(
        id: 'seed_1',
        mood: MoodLevel.overwhelmed,
        tags: ['Pantallas', 'Trabajo'],
        note: 'Día largo pegado a la pantalla sin descanso.',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      MoodEntry(
        id: 'seed_2',
        mood: MoodLevel.calm,
        tags: ['Dormir'],
        note: 'Pausa de respiración con Lev por la mañana.',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      MoodEntry(
        id: 'seed_3',
        mood: MoodLevel.grateful,
        tags: ['Familia', 'Salud'],
        note: 'Caminata corta mirando el cielo.',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      MoodEntry(
        id: 'seed_4',
        mood: MoodLevel.calm,
        tags: ['Pantallas'],
        note: 'Interrumpí el scroll compulsivo a tiempo.',
        timestamp: now,
      ),
    ];

    final seedCards = [
      CbtThoughtCard(
        id: 'seed_card_1',
        automaticThought: 'Si no termino todo hoy, soy un irresponsable y no sirvo.',
        distortionName: 'Todo o Nada (Polarización)',
        compassionateReframe:
            'Mi valor humano no se mide por una lista de tareas. Mi cuerpo necesita descanso y avanzar un poco ya es suficiente.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    return JournalState(moodEntries: seedMoods, cbtCards: seedCards);
  }

  @override
  JournalState build() {
    final rawMoods = LocalStorageService.getMoodEntriesRaw();
    final rawCards = LocalStorageService.getCbtCardsRaw();

    final seed = _buildInitialSeed();

    List<MoodEntry> moods = seed.moodEntries;
    if (rawMoods.isNotEmpty) {
      moods = rawMoods.map((m) => MoodEntry.fromJson(m)).toList();
    }

    List<CbtThoughtCard> cards = seed.cbtCards;
    if (rawCards.isNotEmpty) {
      cards = rawCards.map((c) => CbtThoughtCard.fromJson(c)).toList();
    }

    return JournalState(moodEntries: moods, cbtCards: cards);
  }

  Future<void> addMoodEntry({
    required MoodLevel mood,
    required List<String> tags,
    String note = '',
  }) async {
    final newEntry = MoodEntry(
      id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
      mood: mood,
      tags: tags,
      note: note,
      timestamp: DateTime.now(),
    );

    final updated = [...state.moodEntries, newEntry];
    state = state.copyWith(moodEntries: updated);

    // Persistencia local
    await LocalStorageService.saveMoodEntriesRaw(
      updated.map((e) => e.toJson()).toList(),
    );

    // Reacción de Lev en el Santuario
    if (mood == MoodLevel.overwhelmed || mood == MoodLevel.disconnected) {
      ref.read(sanctuaryProvider.notifier).setShelteredState();
    } else {
      ref.read(sanctuaryProvider.notifier).setPeacefulState();
    }
  }

  Future<void> addCbtCard({
    required String automaticThought,
    required String distortionName,
    required String compassionateReframe,
  }) async {
    final newCard = CbtThoughtCard(
      id: 'cbt_${DateTime.now().millisecondsSinceEpoch}',
      automaticThought: automaticThought,
      distortionName: distortionName,
      compassionateReframe: compassionateReframe,
      createdAt: DateTime.now(),
    );

    final updated = [newCard, ...state.cbtCards];
    state = state.copyWith(cbtCards: updated);

    // Persistencia local
    await LocalStorageService.saveCbtCardsRaw(
      updated.map((c) => c.toJson()).toList(),
    );
  }
}

final journalProvider =
    NotifierProvider<JournalController, JournalState>(
  JournalController.new,
);

