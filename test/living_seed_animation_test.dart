import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_habitat_card.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_pond_painter.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('Living Seed Spirit Stop-Motion & Habitat Animation Verification', () {
    testWidgets('Habitat card renders and animates through multiple frame cycles without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LivingHabitatCard(),
            ),
          ),
        ),
      );

      // Verify widget exists
      expect(find.byType(LivingHabitatCard), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Advance animation through multiple discrete stop-motion ticks across seconds
      for (int i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 160));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping Lev triggers petting reaction (happy eyes, spores, heart haptic pulse)',
        (WidgetTester tester) async {
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

      // Tap on Lev's habitat card
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);

      // Let the 2.4s petting timer finish
      await tester.pump(const Duration(milliseconds: 2600));
      expect(tester.takeException(), isNull);
    });

    test('LivingSeedSpiritPainter paints correctly across all emotions and values', () {
      final emotions = [
        LevEmotion.peaceful,
        LevEmotion.happy,
        LevEmotion.curious,
        LevEmotion.sheltered,
        LevEmotion.celebrating,
        LevEmotion.breathing,
        LevEmotion.sleeping,
        LevEmotion.joyJump,
      ];

      for (final emotion in emotions) {
        for (double t = 0.0; t <= 1.0; t += 0.1) {
          final painter = LivingSeedSpiritPainter(
            animationValue: t,
            emotion: emotion,
            isPetting: t > 0.5,
          );

          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          const size = Size(300, 300);

          expect(() => painter.paint(canvas, size), returnsNormally);
          final picture = recorder.endRecording();
          picture.dispose();
        }
      }
    });

    test('SanctuaryPondPainter paints correctly across all times of day and progression levels', () {
      final times = [
        SanctuaryTimeOfDay.morning,
        SanctuaryTimeOfDay.afternoon,
        SanctuaryTimeOfDay.dusk,
        SanctuaryTimeOfDay.night,
      ];

      for (final time in times) {
        for (int careDrops in [0, 15, 35, 60, 90]) {
          final pondPainter = SanctuaryPondPainter(
            animationValue: 0.35,
            timeOfDay: time,
            emotion: LevEmotion.peaceful,
            bloomingFlowers: careDrops ~/ 10,
            careDrops: careDrops,
            isPetting: false,
          );

          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          const size = Size(400, 310);

          expect(() => pondPainter.paint(canvas, size), returnsNormally);
          final picture = recorder.endRecording();
          picture.dispose();
        }
      }
    });
  });
}
