import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/habits/presentation/habits_catalog_screen.dart';
import 'package:lev/features/habits/presentation/emotion_detail_screen.dart';
import 'package:lev/features/habits/presentation/widgets/somatic_focus_minigames.dart';
import 'package:lev/features/companion/presentation/companion_chat_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'lev_care_drops': 30,
      'lev_completed_habits_count': 7,
      'lev_favorite_habit_ids': ['doom_01', 'anx_01'],
    });
    await LocalStorageService.init();
    await initializeDateFormatting('es', null);
  });

  group('Somatic Focus Minigames & Tactile Square UI Suite', () {
    testWidgets('HabitsCatalogScreen displays search, minigames and square emotion tiles', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HabitsCatalogScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Search bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar por síntoma (ojos, pecho, dormir...)'), findsOneWidget);

      // Minigames quick cards
      expect(find.text('Minijuegos de Concentración'), findsOneWidget);
      expect(find.text('Burbujas Pop'), findsOneWidget);
      expect(find.text('Arena Zen'), findsOneWidget);
      expect(find.text('Foco de Luz'), findsOneWidget);

      // Emotion squares
      expect(find.text('¿Qué estás sintiendo ahora?'), findsOneWidget);
      expect(find.text('Ansiedad'), findsOneWidget);
      expect(find.text('Sobrecarga'), findsOneWidget);
      expect(find.text('Tristeza'), findsOneWidget);
      expect(find.text('Insomnio'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
    });

    testWidgets('Tapping on a minigame opens SomaticMinigamesContainer with all 3 games', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HabitsCatalogScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on Burbujas Pop
      await tester.tap(find.text('Burbujas Pop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Modal is visible with minigame selector
      expect(find.byType(SomaticMinigamesContainer), findsOneWidget);
      expect(find.byType(BubblePopMinigame), findsOneWidget);

      // Switch tab to Arena Zen
      await tester.tap(find.text('Arena Zen').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ZenSandMinigame), findsOneWidget);

      // Switch tab to Foco de Luz
      await tester.tap(find.text('Foco de Luz').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LightTrackerMinigame), findsOneWidget);
    });

    testWidgets('Tapping an emotion square navigates to EmotionDetailScreen with reactive Lev', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HabitsCatalogScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll to Ansiedad and tap
      await tester.ensureVisible(find.text('Ansiedad'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Ansiedad'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // In EmotionDetailScreen
      expect(find.byType(EmotionDetailScreen), findsOneWidget);
      expect(find.text('Lev está contigo'), findsOneWidget);
      expect(find.text('Pausas de 60 segundos'), findsOneWidget);
    });

    testWidgets('CompanionChatScreen renders reactive Lev header and message cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CompanionChatScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Lev'), findsAtLeastNWidgets(1));
      expect(find.text('Toca a Lev para acariciarlo 🌿'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
