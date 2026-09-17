import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/profile/domain/user_profile.dart';
import 'package:lev/features/profile/presentation/user_profile_sheet.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/companion/presentation/controllers/companion_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    await LocalStorageService.prefs.clear();
  });

  group('User Profile & Age Adaptation Domain Suite', () {
    test('UserProfile correctly categorizes ages into LevUserStage', () {
      // Niñez (< 13)
      expect(const UserProfile(name: 'Lucas', age: 7).stage, LevUserStage.child);
      expect(const UserProfile(name: 'Lucas', age: 12).stage, LevUserStage.child);

      // Adolescencia (13 - 18)
      expect(const UserProfile(name: 'Emma', age: 13).stage, LevUserStage.teen);
      expect(const UserProfile(name: 'Emma', age: 16).stage, LevUserStage.teen);
      expect(const UserProfile(name: 'Emma', age: 18).stage, LevUserStage.teen);

      // Adulto (19 - 59)
      expect(const UserProfile(name: 'Samuel', age: 19).stage, LevUserStage.adult);
      expect(const UserProfile(name: 'Samuel', age: 35).stage, LevUserStage.adult);
      expect(const UserProfile(name: 'Samuel', age: 59).stage, LevUserStage.adult);

      // Plenitud (60+)
      expect(const UserProfile(name: 'Carmen', age: 60).stage, LevUserStage.senior);
      expect(const UserProfile(name: 'Carmen', age: 75).stage, LevUserStage.senior);
    });

    test('LocalStorageService persists name and age accurately', () async {
      expect(LocalStorageService.getUserName(), 'Humano');
      expect(LocalStorageService.getUserAge(), 25);
      expect(LocalStorageService.getUserStage(), LevUserStage.adult);

      await LocalStorageService.saveUserProfile(
        const UserProfile(name: 'Daniel', age: 15),
      );

      expect(LocalStorageService.getUserName(), 'Daniel');
      expect(LocalStorageService.getUserAge(), 15);
      expect(LocalStorageService.getUserStage(), LevUserStage.teen);
    });
  });

  group('SanctuaryController & Lev Behavior Adaptation Suite', () {
    test('SanctuaryController personalizes actions by user age and name', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(sanctuaryProvider.notifier);

      // 1. Perfil de Niñez
      controller.updateUserProfile(const UserProfile(name: 'Mateo', age: 9));
      expect(container.read(sanctuaryProvider).userProfile.name, 'Mateo');
      expect(container.read(sanctuaryProvider).userProfile.stage, LevUserStage.child);
      expect(container.read(sanctuaryProvider).dialogue, contains('Mateo'));
      expect(container.read(sanctuaryProvider).dialogue, contains('amigos'));

      await controller.startBreathing();
      expect(container.read(sanctuaryProvider).dialogue, contains('globo'));
      expect(container.read(sanctuaryProvider).dialogue, contains('Mateo'));

      await controller.hugLev();
      expect(container.read(sanctuaryProvider).dialogue, contains('Mateo'));
      expect(container.read(sanctuaryProvider).dialogue, contains('a salvo'));

      await controller.prayWithLev();
      expect(container.read(sanctuaryProvider).dialogue, contains('Mateo'));
      expect(container.read(sanctuaryProvider).dialogue, contains('Diosito me ama'));

      // 2. Perfil de Adolescencia
      controller.updateUserProfile(const UserProfile(name: 'Valeria', age: 15));
      expect(container.read(sanctuaryProvider).userProfile.stage, LevUserStage.teen);
      expect(container.read(sanctuaryProvider).dialogue, contains('Valeria'));
      expect(container.read(sanctuaryProvider).dialogue, contains('juicios'));

      await controller.startBreathing();
      expect(container.read(sanctuaryProvider).dialogue, contains('sobrecarga mental'));

      await controller.putToSleep();
      expect(container.read(sanctuaryProvider).dialogue, contains('pantallas'));
      expect(container.read(sanctuaryProvider).dialogue, contains('Valeria'));

      // 3. Perfil de Plenitud / Senior
      controller.updateUserProfile(const UserProfile(name: 'Don Carlos', age: 68));
      expect(container.read(sanctuaryProvider).userProfile.stage, LevUserStage.senior);
      expect(container.read(sanctuaryProvider).dialogue, contains('Don Carlos'));
      expect(container.read(sanctuaryProvider).dialogue, contains('sosiego'));

      await controller.hugLev();
      expect(container.read(sanctuaryProvider).dialogue, contains('sosiego'));
      expect(container.read(sanctuaryProvider).dialogue, contains('Don Carlos'));
    });
  });

  group('CompanionController Adaptation Suite', () {
    test('CompanionController personalizes dialogue to user name and stage', () async {
      await LocalStorageService.saveUserProfile(
        const UserProfile(name: 'Sofía', age: 16),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(companionProvider);
      expect(state.messages.first.text, contains('Sofía'));

      final controller = container.read(companionProvider.notifier);
      await controller.sendUserMessage('Quiero orar');

      final lastReply = container.read(companionProvider).messages.last.text;
      expect(lastReply, contains('Sofía'));
      expect(lastReply, contains('Filipenses 4:6-7'));
    });
  });

  group('UserProfileSheet Widget UI Suite', () {
    testWidgets('UserProfileSheet updates stage badge live when typing age and saves', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: UserProfileSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tu Perfil en Lev'), findsOneWidget);
      expect(find.text('¿Cómo te gustaría que Lev te llame?'), findsOneWidget);
      expect(find.text('¿Cuántos años tienes?'), findsOneWidget);

      // Ingresar nombre "Samuel"
      await tester.enterText(find.byType(TextField).first, 'Samuel');
      await tester.pump();

      // Ingresar edad 11 (Niñez)
      await tester.enterText(find.byType(TextField).last, '11');
      await tester.pump();
      expect(find.textContaining('Modo activo: Niñez (< 13 años)'), findsOneWidget);

      // Cambiar edad a 17 (Adolescencia)
      await tester.enterText(find.byType(TextField).last, '17');
      await tester.pump();
      expect(find.textContaining('Modo activo: Adolescencia (13 - 18 años)'), findsOneWidget);

      // Cambiar edad a 65 (Plenitud)
      await tester.enterText(find.byType(TextField).last, '65');
      await tester.pump();
      expect(find.textContaining('Modo activo: Plenitud (60+ años)'), findsOneWidget);

      // Tocar botón guardar
      final saveButton = find.text('Guardar y adaptar a Lev');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(LocalStorageService.getUserName(), 'Samuel');
      expect(LocalStorageService.getUserAge(), 65);
      expect(LocalStorageService.getUserStage(), LevUserStage.senior);
    });
  });
}
