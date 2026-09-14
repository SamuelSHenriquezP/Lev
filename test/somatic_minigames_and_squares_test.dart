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
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';

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

      // Somatic tools quick cards
      expect(find.text('Herramientas Somáticas de Calma'), findsOneWidget);
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

    testWidgets('Tapping on a minigame opens SomaticMinigamesContainer with all 7 games', (tester) async {
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
      await tester.ensureVisible(find.text('Arena Zen').last);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Arena Zen').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ZenSandMinigame), findsOneWidget);

      // Switch tab to Foco de Luz
      await tester.ensureVisible(find.text('Foco de Luz').last);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Foco de Luz').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LightTrackerMinigame), findsOneWidget);

      // Switch tab to Estanque
      await tester.ensureVisible(find.text('Estanque'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Estanque'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(WaterRippleMinigame), findsOneWidget);

      // Switch tab to Cuenco Zen
      await tester.ensureVisible(find.text('Cuenco Zen'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Cuenco Zen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TibetanBowlMinigame), findsOneWidget);

      // Switch tab to Diente León
      await tester.ensureVisible(find.text('Diente León'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Diente León'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(DandelionMinigame), findsOneWidget);

      // Switch tab to Piedras Zen
      await tester.ensureVisible(find.text('Piedras Zen'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Piedras Zen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(StoneBalanceMinigame), findsOneWidget);
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

    testWidgets('CompanionChatScreen renders clean conversation interface without distracting Lev avatar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CompanionChatScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Espacio de Diálogo'), findsOneWidget);
      expect(find.text('Toca a Lev para acariciarlo 🌿'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('New minigames handle taps, pan gestures, and button triggers', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      // 1. WaterRippleMinigame
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WaterRippleMinigame()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Gotas de calma'), findsOneWidget);
      // Tap on pond
      await tester.tapAt(const Offset(200, 400));
      await tester.pump(const Duration(milliseconds: 100));
      // Toggle rain
      await tester.tap(find.text('Lluvia serena'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Pausar lluvia'), findsOneWidget);

      // 2. TibetanBowlMinigame
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TibetanBowlMinigame()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Resonancia'), findsOneWidget);
      // Gong strike
      await tester.tapAt(const Offset(215, 450));
      await tester.pump(const Duration(milliseconds: 100));

      // 3. DandelionMinigame
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DandelionMinigame()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Pensamientos soltados'), findsOneWidget);
      // Pan to blow seeds
      await tester.dragFrom(const Offset(215, 500), const Offset(0, -120));
      await tester.pump(const Duration(milliseconds: 100));
      // Reset
      await tester.tap(find.text('Nuevo brote'));
      await tester.pump(const Duration(milliseconds: 100));

      // 4. StoneBalanceMinigame
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StoneBalanceMinigame()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Piedras en calma'), findsOneWidget);
      // Drag next stone towards stack
      await tester.dragFrom(const Offset(215, 750), const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 200));
      // Reset tower
      await tester.tap(find.text('Reiniciar'));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('SomaticMinigamesContainer provides prominent exit button to release phone', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SomaticMinigamesContainer(initialIndex: 0),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Ya me siento en calma, soltar teléfono 🌿'), findsOneWidget);
    });

    testWidgets('HabitTimerScreen provides Cerrar Ojos / Dejar Móvil toggle and zen screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      const testHabit = MicroHabit(
        id: 'test_somatic_01',
        title: 'Mirada Lejana al Horizonte',
        levIntro: 'Lev mira a lo lejos contigo.',
        steps: ['Mira por la ventana', 'Parpadea suavemente', 'Respira tres veces'],
        psychologicalBasis: 'Descanso ciliar y corte de dopamina rápida.',
        category: 'Doomscrolling / Sobrecarga Digital',
        interactionType: HabitInteractionType.audioGrounding,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HabitTimerScreen(habit: testHabit),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Toggle button is displayed
      expect(find.text('Cerrar Ojos / Dejar Móvil 📵'), findsOneWidget);
      expect(find.text('Acción Fuera de Pantalla'), findsOneWidget);

      // Tap toggle to activate eyes-closed mode
      await tester.tap(find.text('Cerrar Ojos / Dejar Móvil 📵'));
      await tester.pump(const Duration(milliseconds: 200));

      // Zen screen is displayed with sleeping Lev and instruction
      expect(find.text('Ojos Cerrados'), findsOneWidget);
      expect(find.textContaining('Deja tu teléfono a un lado y respira'), findsOneWidget);
      expect(find.text('Ver pantalla'), findsOneWidget);

      // Tap Ver pantalla to return
      await tester.tap(find.text('Ver pantalla'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Cerrar Ojos / Dejar Móvil 📵'), findsOneWidget);
    });
  });
}
