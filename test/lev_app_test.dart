import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/main.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/companion/presentation/controllers/companion_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'lev_care_drops': 25,
      'lev_experience_points': 200,
      'lev_completed_habits_count': 5,
      'lev_favorite_habit_ids': ['doom_01', 'anx_01'],
    });
    await LocalStorageService.init();
    await initializeDateFormatting('es', null);
  });

  group('Expanded Clinical Habits & Somatic Minigames Suite (54 habits across 7 emotions)', () {
    test('All 7 core psychological categories are populated with 54 unique habits', () {
      final categories = HabitsDatabase.categories;
      expect(categories.length, 7);

      expect(HabitsDatabase.allHabits.length, equals(54));

      final uniqueIds = HabitsDatabase.allHabits.map((h) => h.id).toSet();
      expect(uniqueIds.length, equals(54));

      final doomHabits = HabitsDatabase.getByCategory('Doomscrolling / Sobrecarga Digital');
      expect(doomHabits.length, equals(8));

      final anxHabits = HabitsDatabase.getByCategory('Ansiedad / Ataque de Pánico / Agobio');
      expect(anxHabits.length, equals(9));

      final sadHabits = HabitsDatabase.getByCategory('Tristeza / Soledad / Desgano');
      expect(sadHabits.length, equals(9));

      final angHabits = HabitsDatabase.getByCategory('Frustración / Enojo / Irritabilidad');
      expect(angHabits.length, equals(7));

      final slpHabits = HabitsDatabase.getByCategory('Insomnio / Rumiación Nocturna');
      expect(slpHabits.length, equals(7));

      final crtHabits = HabitsDatabase.getByCategory('Culpa / Autocrítica / Impostor');
      expect(crtHabits.length, equals(7));

      final blkHabits = HabitsDatabase.getByCategory('Bloqueo / Procrastinación / Parálisis TDAH');
      expect(blkHabits.length, equals(7));
    });

    test('Habits contain step-by-step instructions, tags, psychological basis and interaction minigames', () {
      final usedInteractions = <dynamic>{};
      for (final habit in HabitsDatabase.allHabits) {
        expect(habit.id.isNotEmpty, isTrue);
        expect(habit.title.isNotEmpty, isTrue);
        expect(habit.levIntro.isNotEmpty, isTrue);
        expect(habit.steps.length, greaterThanOrEqualTo(3));
        expect(habit.psychologicalBasis.isNotEmpty, isTrue);
        expect(habit.tags.isNotEmpty, isTrue);
        expect(habit.durationSeconds, 60);
        usedInteractions.add(habit.interactionType);
      }

      // Verify all somatic minigame interaction types are leveraged
      expect(usedInteractions.length, greaterThanOrEqualTo(6));
    });

    test('Live search finds relevant micro-habits', () {
      final searchEyes = HabitsDatabase.searchHabits('ojos');
      expect(searchEyes.isNotEmpty, isTrue);
      expect(searchEyes.any((h) => h.id == 'doom_01' || h.id == 'doom_03'), isTrue);

      final searchSleep = HabitsDatabase.searchHabits('dormir');
      expect(searchSleep.isNotEmpty, isTrue);

      final searchBlock = HabitsDatabase.searchHabits('procrastin');
      expect(searchBlock.isNotEmpty, isTrue);
    });

    test('Mood recommendations map to relevant interventions across all 7 emotions', () {
      expect(HabitsDatabase.getRecommendedForMood('Mucho TikTok').id, 'doom_01');
      expect(HabitsDatabase.getRecommendedForMood('Me siento abrumado').id, 'anx_01');
      expect(HabitsDatabase.getRecommendedForMood('Estoy triste y solo').id, 'sad_01');
      expect(HabitsDatabase.getRecommendedForMood('Tengo enojo y rabia').id, 'ang_01');
      expect(HabitsDatabase.getRecommendedForMood('No puedo dormir, tengo insomnio').id, 'slp_01');
      expect(HabitsDatabase.getRecommendedForMood('Siento mucha culpa y soy un impostor').id, 'crt_01');
      expect(HabitsDatabase.getRecommendedForMood('Tengo bloqueo para empezar la tarea').id, 'blk_01');
    });

    test('Favorites storage toggling works properly', () async {
      final favsBefore = LocalStorageService.getFavoriteHabitIds();
      expect(favsBefore.contains('doom_01'), isTrue);

      await LocalStorageService.toggleFavoriteHabit('slp_01');
      final favsAfter = LocalStorageService.getFavoriteHabitIds();
      expect(favsAfter.contains('slp_01'), isTrue);

      await LocalStorageService.toggleFavoriteHabit('slp_01');
      final favsRemoved = LocalStorageService.getFavoriteHabitIds();
      expect(favsRemoved.contains('slp_01'), isFalse);
    });
  });

  group('Sanctuary Progression & Companion Intelligence', () {
    test('Sanctuary level evolves with care drops', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(sanctuaryProvider);
      expect(state.careDrops, 25);
      expect(state.sanctuaryLevelName, 'Planta Joven');
      expect(state.sanctuaryLevelEmoji, '🍃');
    });

    test('Companion handles insomnia, guilt and task paralysis with empathy', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Insomnia test
      await container.read(companionProvider.notifier).sendUserMessage('No puedo dormir');
      var chatState = container.read(companionProvider);
      expect(chatState.messages.last.recommendedHabit?.id, 'slp_01');

      // Guilt test
      await container.read(companionProvider.notifier).sendUserMessage('Siento mucha culpa y no sirvo para nada');
      chatState = container.read(companionProvider);
      expect(chatState.messages.last.recommendedHabit?.id, 'crt_01');

      // Task paralysis test
      await container.read(companionProvider.notifier).sendUserMessage('Tengo un bloqueo total para empezar');
      chatState = container.read(companionProvider);
      expect(chatState.messages.last.recommendedHabit?.id, 'blk_01');
    });
  });

  group('Widget Navigation & Timer UI', () {
    testWidgets('HabitTimerScreen renders 60s countdown and steps', (WidgetTester tester) async {
      final testHabit = HabitsDatabase.getById('slp_01')!;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HabitTimerScreen(habit: testHabit),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(testHabit.title), findsOneWidget);
      expect(find.text('60 s'), findsOneWidget);
    });

    testWidgets('Navigation bar displays all tabs and switches screens smoothly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: LevApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Santuario'), findsOneWidget);
      expect(find.text('Hábitos'), findsOneWidget);
      expect(find.text('Progreso'), findsOneWidget);

      // Open Hábitos tab
      await tester.tap(find.text('Hábitos'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sorpréndeme'), findsOneWidget);
      expect(find.text('Microhábitos (60s)'), findsOneWidget);
    });
  });
}
