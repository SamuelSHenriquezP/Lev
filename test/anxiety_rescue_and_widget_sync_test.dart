import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/profile/domain/user_profile.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('Anxiety Rescue & Widget Sync Domain Tests', () {
    test('triggerAnxietyRescue adapts dialogue and emotion according to user stage', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Probar con perfil de niño
      await LocalStorageService.saveUserProfile(const UserProfile(name: 'Mateo', age: 9));
      final rescueChild = await container.read(sanctuaryProvider.notifier).triggerAnxietyRescue(forcedTechniqueIndex: 1);

      expect(rescueChild['technique'], 1);
      expect(rescueChild['title'], 'Respiración 4-7-8');
      expect(container.read(sanctuaryProvider).emotion, LevEmotion.breathing);
      expect(container.read(sanctuaryProvider).dialogue, contains('Mateo'));
      expect(container.read(sanctuaryProvider).dialogue, contains('plantita'));

      // 2. Probar con perfil adulto y técnica de oración / paz
      await LocalStorageService.saveUserProfile(const UserProfile(name: 'Elena', age: 34));
      final rescueAdult = await container.read(sanctuaryProvider.notifier).triggerAnxietyRescue(forcedTechniqueIndex: 3);

      expect(rescueAdult['technique'], 3);
      expect(rescueAdult['title'], 'Paz y Confianza');
      expect(container.read(sanctuaryProvider).emotion, LevEmotion.praying);
      expect(container.read(sanctuaryProvider).dialogue, contains('Elena'));

      // 3. Probar técnica de abrazo somático
      final rescueHug = await container.read(sanctuaryProvider.notifier).triggerAnxietyRescue(forcedTechniqueIndex: 2);
      expect(rescueHug['technique'], 2);
      expect(rescueHug['title'], 'Abrazo Somático');
      expect(container.read(sanctuaryProvider).emotion, LevEmotion.sheltered);

      // 4. Probar minijuego somático
      final rescueMinigame = await container.read(sanctuaryProvider.notifier).triggerAnxietyRescue(forcedTechniqueIndex: 0);
      expect(rescueMinigame['technique'], 0);
      expect(rescueMinigame['title'], 'Minijuego Somático');
      expect(rescueMinigame['minigameIndex'], inInclusiveRange(0, 7));
    });
  });
}

