import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/companion/presentation/lev_chat_bubble.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_pond_painter.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    await LocalStorageService.prefs.clear();
  });

  group('Experience Points (XP) vs Care Drops (??) Progression Suite', () {
    test('Growth stage is strictly governed by XP thresholds', () {
      final state0 = SanctuaryState(experiencePoints: 0, careDrops: 100);
      expect(state0.growthStage, equals(LevGrowthStage.seed));
      expect(state0.stageName, equals('Semilla'));

      final stateSprout = SanctuaryState(experiencePoints: 50, careDrops: 0);
      expect(stateSprout.growthStage, equals(LevGrowthStage.sprout));
      expect(stateSprout.stageName, equals('Brote de Paz'));

      final stateSeedling = SanctuaryState(experiencePoints: 100, careDrops: 0);
      expect(stateSeedling.growthStage, equals(LevGrowthStage.seedling));
      expect(stateSeedling.stageName, equals('Plántula de Luz'));

      final stateYoungPlant = SanctuaryState(experiencePoints: 200, careDrops: 0);
      expect(stateYoungPlant.growthStage, equals(LevGrowthStage.youngPlant));
      expect(stateYoungPlant.stageName, equals('Planta Joven'));

      final stateVibrant = SanctuaryState(experiencePoints: 350, careDrops: 0);
      expect(stateVibrant.growthStage, equals(LevGrowthStage.vibrantPlant));

      final stateYoungTree = SanctuaryState(experiencePoints: 550, careDrops: 0);
      expect(stateYoungTree.growthStage, equals(LevGrowthStage.youngTree));

      final stateAdultTree = SanctuaryState(experiencePoints: 800, careDrops: 0);
      expect(stateAdultTree.growthStage, equals(LevGrowthStage.adultTree));
      expect(stateAdultTree.stageName, equals('Árbol Sabio'));

      final stateForestSpirit = SanctuaryState(experiencePoints: 1200, careDrops: 0);
      expect(stateForestSpirit.growthStage, equals(LevGrowthStage.forestSpirit));
      expect(stateForestSpirit.stageName, equals('Espíritu del Bosque'));
    });

    test('Habit completion awards +25 XP and +1 Care Drop with persistent state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sanctuaryProvider.notifier);
      final initialDrops = container.read(sanctuaryProvider).careDrops;
      final initialXp = container.read(sanctuaryProvider).experiencePoints;

      await notifier.onHabitCompleted('box_breathing');

      final updated = container.read(sanctuaryProvider);
      expect(updated.experiencePoints, equals(initialXp + 25));
      expect(updated.careDrops, equals(initialDrops + 1));
      expect(LocalStorageService.getExperiencePoints(), equals(initialXp + 25));
      expect(LocalStorageService.getCareDrops(), equals(initialDrops + 1));
    });

    test('Sanctuary decors can be unlocked with Care Drops and toggled', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sanctuaryProvider.notifier);
      // Award drops to afford decors
      await notifier.setCareDrops(10);
      expect(container.read(sanctuaryProvider).careDrops, equals(10));

      // Unlock Lotus Pond (cost 8 drops)
      final success = await notifier.unlockDecor(SanctuaryDecorItem.lotusPond);
      expect(success, isTrue);

      var state = container.read(sanctuaryProvider);
      expect(state.careDrops, equals(2)); // 10 - 8
      expect(state.unlockedDecors.contains(SanctuaryDecorItem.lotusPond), isTrue);
      expect(state.activeDecors.contains(SanctuaryDecorItem.lotusPond), isTrue);

      // Toggle off Lotus Pond
      await notifier.toggleDecor(SanctuaryDecorItem.lotusPond);
      state = container.read(sanctuaryProvider);
      expect(state.activeDecors.contains(SanctuaryDecorItem.lotusPond), isFalse);
      expect(state.unlockedDecors.contains(SanctuaryDecorItem.lotusPond), isTrue);

      // Toggle on Lotus Pond
      await notifier.toggleDecor(SanctuaryDecorItem.lotusPond);
      state = container.read(sanctuaryProvider);
      expect(state.activeDecors.contains(SanctuaryDecorItem.lotusPond), isTrue);

      // Unlocking an unaffordable decor fails
      await notifier.setCareDrops(1);
      final failedUnlock = await notifier.unlockDecor(SanctuaryDecorItem.windChimes); // Cost is 20
      expect(failedUnlock, isFalse);
    });

    test('House items expansion: 19 items across all 4 categories render without errors', () {
      // 19 total items
      expect(SanctuaryDecorItem.values.length, equals(19));

      // Each category contains items
      for (final cat in [
        DecorCategory.furniture,
        DecorCategory.lighting,
        DecorCategory.companions,
        DecorCategory.nature,
      ]) {
        final itemsInCat = SanctuaryDecorItem.values.where((item) => item.category == cat);
        expect(itemsInCat, isNotEmpty);
      }

      // fromId works for all 19 items
      for (final item in SanctuaryDecorItem.values) {
        expect(SanctuaryDecorItem.fromId(item.id), equals(item));
      }

      // Test SanctuaryPondPainter rendering all 19 items active simultaneously
      final painter = SanctuaryPondPainter(
        animationValue: 0.5,
        timeOfDay: SanctuaryTimeOfDay.morning,
        emotion: LevEmotion.peaceful,
        bloomingFlowers: 5,
        careDrops: 99,
        isPetting: false,
        activeDecors: SanctuaryDecorItem.values.toSet(),
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      expect(() => painter.paint(canvas, const Size(400, 700)), returnsNormally);
      final picture = recorder.endRecording();
      picture.dispose();
    });
  });

  group('LevChatBubble & Celebration UI Verification', () {
    testWidgets('LevChatBubble supports vertical dragging and tap-outside backdrop dismiss',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(child: Text('Underlying Background Content')),
                  Positioned.fill(child: LevChatBubble()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // FAB is present
      final fabFinder = find.descendant(
        of: find.byType(LevChatBubble),
        matching: find.byType(GestureDetector),
      );
      expect(fabFinder, findsOneWidget);

      // Drag the FAB vertically
      await tester.drag(fabFinder.first, const Offset(0, -100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap to open chat overlay
      await tester.tap(fabFinder.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Chat overlay and backdrop are visible
      expect(find.text('Lev'), findsOneWidget);
      expect(find.text('Me siento ansioso'), findsOneWidget);

      // Tap outside overlay (backdrop) to dismiss
      await tester.tapAt(const Offset(50, 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      // Overlay dismissed smoothly
      expect(find.text('Me siento ansioso'), findsNothing);
    });

    testWidgets('Celebration modal displays dual rewards (+1 Gota ??, +25 XP ??) and finishes',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final habit = HabitsDatabase.allHabits.first;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => HabitTimerScreen(habit: habit),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open screen
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Find and tap complete button directly
      final completeButton = find.text('Completar');
      expect(completeButton, findsOneWidget);
      await tester.tap(completeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Celebration modal rendered with unique layout and dual rewards
      expect(find.text('Pausa Consciente Completada'), findsOneWidget);
      expect(find.text('¡Lo lograste!'), findsOneWidget);
      expect(find.textContaining('+1 Gota'), findsOneWidget);
      expect(find.textContaining('+25 XP'), findsOneWidget);

      // Somatic check-in 1-tap option
      expect(find.text('¿Cómo siente tu cuerpo esta pausa?'), findsOneWidget);
      final reliefFinder = find.textContaining('Más ligero');
      expect(reliefFinder, findsOneWidget);
      await tester.ensureVisible(reliefFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(reliefFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Qué hermoso alivio'), findsOneWidget);

      final finishButton = find.textContaining('Hecho, gracias Lev');
      expect(finishButton, findsOneWidget);
      await tester.ensureVisible(finishButton);
      await tester.pump(const Duration(milliseconds: 100));

      // Tap finish button
      await tester.tap(finishButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Modal is cleanly dismissed
      expect(find.text('Pausa Consciente Completada'), findsNothing);
    });
  });

  group('Circadian, Botanical Accessories, Somatic Relief & PIN Security Suite', () {
    test('Circadian cycle override controls effectiveTimeOfDay and persists', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sanctuaryProvider.notifier);
      expect(container.read(sanctuaryProvider).circadianOverride, isNull);

      // Force Night mode
      await notifier.setCircadianOverride(SanctuaryTimeOfDay.night);
      expect(container.read(sanctuaryProvider).circadianOverride, equals(SanctuaryTimeOfDay.night));
      expect(container.read(sanctuaryProvider).effectiveTimeOfDay, equals(SanctuaryTimeOfDay.night));
      expect(LocalStorageService.getCircadianOverride(), equals('night'));

      // Force Dusk mode
      await notifier.setCircadianOverride(SanctuaryTimeOfDay.dusk);
      expect(container.read(sanctuaryProvider).effectiveTimeOfDay, equals(SanctuaryTimeOfDay.dusk));

      // Return to automatic
      await notifier.setCircadianOverride(null);
      expect(container.read(sanctuaryProvider).circadianOverride, isNull);
      expect(LocalStorageService.getCircadianOverride(), isNull);
    });

    test('Lev botanical accessories can be unlocked with drops, equipped, and unequipped', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sanctuaryProvider.notifier);
      await notifier.setCareDrops(50); // Set enough drops

      final initialAcc = container.read(sanctuaryProvider).activeAccessory;
      expect(initialAcc, equals(LevAccessory.none));

      // Unlock Sakura flower (8 drops)
      final success = await notifier.unlockAccessory(LevAccessory.sakuraFlower);
      expect(success, isTrue);
      expect(container.read(sanctuaryProvider).unlockedAccessories.contains(LevAccessory.sakuraFlower), isTrue);
      expect(container.read(sanctuaryProvider).activeAccessory, equals(LevAccessory.sakuraFlower));
      expect(container.read(sanctuaryProvider).careDrops, equals(42));

      // Unequip to none
      await notifier.equipAccessory(LevAccessory.none);
      expect(container.read(sanctuaryProvider).activeAccessory, equals(LevAccessory.none));

      // Re-equip unlocked Sakura
      await notifier.equipAccessory(LevAccessory.sakuraFlower);
      expect(container.read(sanctuaryProvider).activeAccessory, equals(LevAccessory.sakuraFlower));
    });

    test('Somatic relief records are properly stored and computed', () async {
      expect(LocalStorageService.getHabitReliefEntries(), isEmpty);

      await LocalStorageService.recordHabitRelief('box_breathing', 'lighter');
      await LocalStorageService.recordHabitRelief('grounding_54321', 'lighter');
      await LocalStorageService.recordHabitRelief('shoulder_roll', 'same');

      final entries = LocalStorageService.getHabitReliefEntries();
      expect(entries.length, equals(3));
      expect(entries[0]['reliefLevel'], equals('lighter'));
      expect(entries[1]['reliefLevel'], equals('lighter'));
      expect(entries[2]['reliefLevel'], equals('same'));
    });

    test('Privacy PIN lock activation and validation works seamlessly', () async {
      expect(LocalStorageService.isPinProtectionActive(), isFalse);
      expect(LocalStorageService.getPrivacyPin(), isNull);

      // Set 4-digit PIN
      await LocalStorageService.setPrivacyPin('1234');
      expect(LocalStorageService.isPinProtectionActive(), isTrue);
      expect(LocalStorageService.getPrivacyPin(), equals('1234'));

      // Remove PIN
      await LocalStorageService.setPrivacyPin(null);
      expect(LocalStorageService.isPinProtectionActive(), isFalse);
      expect(LocalStorageService.getPrivacyPin(), isNull);
    });

    test('Gentle reminders configuration persists accurately', () async {
      final defaultConfig = LocalStorageService.getGentleReminders();
      expect(defaultConfig['enabled'], isFalse);

      await LocalStorageService.saveGentleReminders({
        'enabled': true,
        'morning': true,
        'afternoon': false,
        'night': true,
      });

      final updated = LocalStorageService.getGentleReminders();
      expect(updated['enabled'], isTrue);
      expect(updated['afternoon'], isFalse);
    });
  });

  group('Stage-Specific Independent Animations & Individual Reactions Suite', () {
    test('Every one of the 8 growth stages has unique pet dialogues and custom joy jump reactions', () async {
      final xpStages = [
        (0, LevGrowthStage.seed, 'tierra'),
        (50, LevGrowthStage.sprout, 'cotiledones'),
        (100, LevGrowthStage.seedling, 'antena'),
        (200, LevGrowthStage.youngPlant, 'orejitas'),
        (350, LevGrowthStage.vibrantPlant, 'flores'),
        (550, LevGrowthStage.youngTree, 'tronco'),
        (800, LevGrowthStage.adultTree, 'corona'),
        (1200, LevGrowthStage.forestSpirit, 'alas'),
      ];

      for (final item in xpStages) {
        final xp = item.$1;
        final expectedStage = item.$2;
        final expectedKeyword = item.$3;

        final container = ProviderContainer();
        final notifier = container.read(sanctuaryProvider.notifier);
        await LocalStorageService.saveExperiencePointsRaw(xp);
        container.read(sanctuaryProvider.notifier).state = container.read(sanctuaryProvider).copyWith(
          experiencePoints: xp,
          emotion: LevEmotion.peaceful,
        );

        expect(container.read(sanctuaryProvider).growthStage, equals(expectedStage));

        // Test Petting dialogue belongs to stage dialogue bank
        await notifier.petLev();
        final petDiag = container.read(sanctuaryProvider).dialogue;
        final expectedStageDialogues = SanctuaryController.getStagePetDialogues(expectedStage);
        expect(expectedStageDialogues.contains(petDiag), isTrue,
            reason: 'Stage $expectedStage should produce dialogue from its dedicated bank, got: $petDiag');

        // Test Joy Jump dialogue matches stage-specific cry
        await notifier.triggerJoyJump();
        final jumpDiag = container.read(sanctuaryProvider).dialogue;
        expect(jumpDiag, equals(SanctuaryController.getStageJoyDialogue(expectedStage)));

        container.dispose();
      }
    });

    test('LivingSeedSpiritPainter renders cleanly across all 8 stages with touch and petting interactions', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(380, 380);

      for (final stage in LevGrowthStage.values) {
        final painter = LivingSeedSpiritPainter(
          animationValue: 0.35,
          emotion: LevEmotion.happy,
          growthStage: stage,
          isPetting: true,
          isFingerActive: true,
          touchDistance: 40.0,
          touchNormalizedOffset: const Offset(0.4, -0.3),
        );

        // Rendering should execute without throwing any exception
        expect(() => painter.paint(canvas, size), returnsNormally);
      }
    });
  });
}
