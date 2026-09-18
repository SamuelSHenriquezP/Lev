import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/onboarding/presentation/onboarding_screen.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_pond_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    await LocalStorageService.prefs.clear();
  });

  group('Experience, Daily Greeting & Evolution Suite', () {
    test('onHabitCompleted awards +25 XP, +1 drop and triggers evolution when threshold is reached', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sanctuaryProvider.notifier);

      expect(container.read(sanctuaryProvider).careDrops, equals(0));
      expect(container.read(sanctuaryProvider).experiencePoints, equals(0));
      expect(container.read(sanctuaryProvider).growthStage, equals(LevGrowthStage.seed));

      // Completar primer hábito: 0 XP -> 25 XP, +1 gota (sigue en Semilla)
      await notifier.onHabitCompleted('habit_01');
      expect(container.read(sanctuaryProvider).careDrops, equals(1));
      expect(container.read(sanctuaryProvider).experiencePoints, equals(25));
      expect(container.read(sanctuaryProvider).growthStage, equals(LevGrowthStage.seed));
      expect(container.read(sanctuaryProvider).pendingEvolutionStage, isNull);

      // Completar segundo hábito: 25 XP -> 50 XP, +1 gota (cruza el umbral de Sprout >= 50 XP)
      await notifier.onHabitCompleted('habit_02');
      expect(container.read(sanctuaryProvider).careDrops, equals(2));
      expect(container.read(sanctuaryProvider).experiencePoints, equals(50));
      expect(container.read(sanctuaryProvider).growthStage, equals(LevGrowthStage.sprout));
      expect(container.read(sanctuaryProvider).pendingEvolutionStage, equals(LevGrowthStage.sprout));

      // Limpiamos la evolución tras la ceremonia
      notifier.clearPendingEvolution();
      expect(container.read(sanctuaryProvider).pendingEvolutionStage, isNull);
    });

    test('checkDailyGreeting grants 1 drop on first check today and does not duplicate', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sanctuaryProvider.notifier);

      expect(container.read(sanctuaryProvider).careDrops, equals(0));

      // Primer saludo del día
      final greeting1 = await notifier.checkDailyGreeting();
      expect(greeting1, isNotNull);
      expect(greeting1!['rewardDrops'], equals(1));
      expect(container.read(sanctuaryProvider).careDrops, equals(1));

      // Segundo saludo el mismo día -> no entrega gotas duplicadas
      final greeting2 = await notifier.checkDailyGreeting();
      expect(greeting2, isNull);
      expect(container.read(sanctuaryProvider).careDrops, equals(1));
    });

    test('setWeather updates SanctuaryWeather and persists to storage', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sanctuaryProvider.notifier);

      expect(container.read(sanctuaryProvider).weather, equals(SanctuaryWeather.calm));
      expect(LocalStorageService.getSanctuaryWeather(), equals('calm'));

      await notifier.setWeather(SanctuaryWeather.rain);
      expect(container.read(sanctuaryProvider).weather, equals(SanctuaryWeather.rain));
      expect(LocalStorageService.getSanctuaryWeather(), equals('rain'));

      await notifier.setWeather(SanctuaryWeather.breeze);
      expect(container.read(sanctuaryProvider).weather, equals(SanctuaryWeather.breeze));
      expect(LocalStorageService.getSanctuaryWeather(), equals('breeze'));

      await notifier.setWeather(SanctuaryWeather.starry);
      expect(container.read(sanctuaryProvider).weather, equals(SanctuaryWeather.starry));
      expect(LocalStorageService.getSanctuaryWeather(), equals('starry'));
    });
  });

  group('Backup, Export & Import Suite', () {
    test('exportFullBackupJson produces structured JSON and import restores it accurately', () async {
      // Configuramos estado previo
      await LocalStorageService.saveCareDropsRaw(42);
      await LocalStorageService.saveExperiencePointsRaw(350);
      await LocalStorageService.saveUnlockedDecorIds(['decor_lantern', 'decor_lotus']);
      await LocalStorageService.saveActiveDecorIds(['decor_lotus']);
      await LocalStorageService.setSanctuaryWeather('rain');
      await LocalStorageService.setSeenOnboarding(true);

      // Exportamos
      final exportedJson = LocalStorageService.exportFullBackupJson();
      expect(exportedJson.isNotEmpty, isTrue);

      final parsed = jsonDecode(exportedJson) as Map<String, dynamic>;
      expect(parsed['careDrops'], equals(42));
      expect(parsed['experiencePoints'], equals(350));
      expect(parsed['sanctuaryWeather'], equals('rain'));
      expect(parsed['hasSeenOnboarding'], isTrue);

      // Reiniciamos todo
      await LocalStorageService.resetAllProgress();
      await LocalStorageService.saveCareDropsRaw(0);
      await LocalStorageService.saveExperiencePointsRaw(0);

      expect(LocalStorageService.getCareDrops(), equals(0));
      expect(LocalStorageService.getExperiencePoints(), equals(0));

      // Importamos el respaldo
      final importSuccess = await LocalStorageService.importFullBackupJson(exportedJson);
      expect(importSuccess, isTrue);

      expect(LocalStorageService.getCareDrops(), equals(42));
      expect(LocalStorageService.getExperiencePoints(), equals(350));
      expect(LocalStorageService.getUnlockedDecorIds(), containsAll(['decor_lantern', 'decor_lotus']));
      expect(LocalStorageService.getActiveDecorIds(), contains('decor_lotus'));
      expect(LocalStorageService.getSanctuaryWeather(), equals('rain'));
    });
  });

  group('Onboarding & Weather Rendering UI Suite', () {
    testWidgets('OnboardingScreen renders slides and marks hasSeenOnboarding upon completion', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onFinish: () => completed = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Conoce a Lev'), findsOneWidget);
      expect(find.text('Saltar'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);

      // Presionamos Saltar
      await tester.tap(find.text('Saltar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(completed, isTrue);
      expect(LocalStorageService.hasSeenOnboarding(), isTrue);
    });

    testWidgets('SanctuaryPondPainter paints without errors with weather and isWatering active', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(400, 700),
              painter: SanctuaryPondPainter(
                animationValue: 0.5,
                timeOfDay: SanctuaryTimeOfDay.morning,
                emotion: LevEmotion.celebrating,
                bloomingFlowers: 5,
                careDrops: 3,
                isPetting: false,
                weather: SanctuaryWeather.rain,
                isWatering: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
