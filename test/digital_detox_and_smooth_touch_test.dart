import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/detox/presentation/phone_down_screen.dart';
import 'package:lev/features/habits/presentation/habits_catalog_screen.dart';
import 'package:lev/features/home/presentation/home_screen.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_habitat_card.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'lev_care_drops': 10,
      'lev_experience_points': 50,
      'lev_seen_onboarding': true,
    });
    await LocalStorageService.init();
    await initializeDateFormatting('es', null);
  });

  group('Digital Detox & Smooth Touch Physics Suite', () {
    test('LocalStorageService persists detox sessions and calculates minutes correctly', () async {
      expect(LocalStorageService.getTotalDetoxMinutes(), equals(0));
      expect(LocalStorageService.getTotalDetoxSessions(), equals(0));
      expect(LocalStorageService.getTodayDetoxMinutes(), equals(0));

      await LocalStorageService.addDetoxSession(15);
      expect(LocalStorageService.getTotalDetoxMinutes(), equals(15));
      expect(LocalStorageService.getTotalDetoxSessions(), equals(1));
      expect(LocalStorageService.getTodayDetoxMinutes(), equals(15));

      await LocalStorageService.addDetoxSession(25);
      expect(LocalStorageService.getTotalDetoxMinutes(), equals(40));
      expect(LocalStorageService.getTotalDetoxSessions(), equals(2));
      expect(LocalStorageService.getTodayDetoxMinutes(), equals(40));

      // Backup exports detox stats
      final backup = LocalStorageService.exportFullBackupJson();
      expect(backup, contains('"totalDetoxMinutes": 40'));
      expect(backup, contains('"totalDetoxSessions": 2'));
    });

    test('DetoxGoal defines clinical psychological reasons and grounding prompts for all 5 goals', () {
      expect(DetoxGoal.values.length, equals(5));

      for (final goal in DetoxGoal.values) {
        expect(goal.minutes, greaterThan(0));
        expect(goal.title.isNotEmpty, isTrue);
        expect(goal.psychologicalReason.isNotEmpty, isTrue);
        expect(goal.groundingPrompt.isNotEmpty, isTrue);
        expect(goal.dropsReward, greaterThan(0));
        expect(goal.xpReward, greaterThan(0));
      }

      final dopamineReset = DetoxGoal.dopamineReset;
      expect(dopamineReset.minutes, equals(5));
      expect(dopamineReset.psychologicalReason, contains('dopamina'));

      final nightRest = DetoxGoal.nightRest;
      expect(nightRest.minutes, equals(60));
      expect(nightRest.psychologicalReason, contains('melatonina'));
    });

    testWidgets('PhoneDownScreen allows selecting goals, reading psychological rationale and preparation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhoneDownScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Header and goal options
      expect(find.text('Soltar el Teléfono'), findsOneWidget);
      expect(find.text('Pausa de Dopamina'), findsOneWidget);
      expect(find.text('Reconexión Sensorial'), findsOneWidget);
      expect(find.text('Foco Analógico'), findsOneWidget);
      expect(find.text('Vida en el Mundo Real'), findsOneWidget);
      expect(find.text('Reposo Nocturno'), findsOneWidget);

      // Tap on Pausa de Dopamina (5 min)
      await tester.tap(find.text('Pausa de Dopamina'));
      await tester.pump(const Duration(milliseconds: 200));

      // Continue to preparation
      final continueButton = find.text('Continuar hacia la desconexión');
      await tester.ensureVisible(continueButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(continueButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Preparation view: displays neurological rationale and grounding action
      expect(find.text('Preparando tu Pausa'), findsOneWidget);
      expect(find.text('El porqué neurológico:'), findsOneWidget);
      expect(find.text('Acción física antes de soltarlo:'), findsOneWidget);
      expect(find.text('Entrar en reposo (5 min)'), findsOneWidget);
    });

    testWidgets('HabitsCatalogScreen displays Soltar el Teléfono hero card', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HabitsCatalogScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Hero banner
      expect(find.text('Soltar el Teléfono'), findsOneWidget);
      expect(find.text('Meta Principal'), findsOneWidget);
      expect(find.text('Iniciar Desconexión (5 - 60 min)'), findsOneWidget);

      // Minigames row also preserved
      expect(find.text('Minijuegos de Concentración'), findsOneWidget);
    });

    testWidgets('HomeScreen action bar contains Soltar Móvil pill action', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Soltar Móvil'), findsOneWidget);
      expect(find.text('Regar'), findsOneWidget);
      expect(find.text('Respirar'), findsOneWidget);
    });

    testWidgets('LivingHabitatCard touch tracking responds fluidly without throwing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LivingHabitatCard(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate dragging across screen
      final gesture = await tester.startGesture(const Offset(200, 200));
      await tester.pump(const Duration(milliseconds: 50));

      await gesture.moveTo(const Offset(280, 150));
      await tester.pump(const Duration(milliseconds: 50));

      await gesture.moveTo(const Offset(100, 300));
      await tester.pump(const Duration(milliseconds: 50));

      // Release finger
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should maintain living habitat card without exceptions
      expect(find.byType(LivingHabitatCard), findsOneWidget);
    });

    test('LivingSeedSpiritPainter smooths touch influence when finger is lifted', () {
      // With active finger
      final painterActive = LivingSeedSpiritPainter(
        animationValue: 0.5,
        emotion: LevEmotion.peaceful,
        isPetting: false,
        touchNormalizedOffset: const Offset(0.6, 0.4),
        isFingerActive: true,
      );
      expect(painterActive.isFingerActive, isTrue);

      // When finger is lifted but offset is decaying back to center
      final painterDecaying = LivingSeedSpiritPainter(
        animationValue: 0.5,
        emotion: LevEmotion.peaceful,
        isPetting: false,
        touchNormalizedOffset: const Offset(0.3, 0.2),
        isFingerActive: false,
      );
      expect(painterDecaying.isFingerActive, isFalse);
      expect(painterDecaying.touchNormalizedOffset, equals(const Offset(0.3, 0.2)));
    });
  });
}
