import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/sanctuary_shop_screen.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';
import 'package:lev/features/home/presentation/main_navigation_wrapper.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'lev_seen_onboarding': true,
    });
    await LocalStorageService.init();
    await LocalStorageService.prefs.clear();
    await LocalStorageService.setSeenOnboarding(true);
    await initializeDateFormatting('es', null);
  });

  group('Shop, Circadian Dark Theme & Touch Reactivity Suite', () {
    testWidgets('SanctuaryShopScreen renders and displays categories and drop balance', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SanctuaryShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica título de la tienda
      expect(find.text('Tienda & Armario'), findsOneWidget);
      expect(find.text('Viste a Lev y personaliza tu santuario'), findsOneWidget);

      // Verifica píldoras de categorías
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Armario'), findsOneWidget);
      expect(find.text('Jardín'), findsOneWidget);
      expect(find.text('Muebles'), findsOneWidget);
      expect(find.text('Luces'), findsOneWidget);
      expect(find.text('Fauna'), findsOneWidget);

      // Filtra por Armario
      await tester.tap(find.text('Armario'));
      await tester.pumpAndSettle();
      expect(find.text('Armario de Lev (Accesorios)'), findsOneWidget);
    });

    testWidgets('MainNavigationWrapper contains 4 tabs and switches to Tienda', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationWrapper(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 4 tabs
      expect(find.text('Santuario'), findsOneWidget);
      expect(find.text('Hábitos'), findsOneWidget);
      expect(find.text('Tienda'), findsOneWidget);
      expect(find.text('Progreso'), findsOneWidget);

      // Tocar tab de Tienda
      await tester.tap(find.text('Tienda'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Tienda & Armario'), findsOneWidget);
    });

    test('LevTheme darkTheme defines botanical nocturnal palette and contrast', () {
      final dark = LevTheme.darkTheme;
      expect(dark.brightness, equals(Brightness.dark));
      expect(dark.scaffoldBackgroundColor, equals(LevTheme.levDarkBg));
      expect(dark.cardTheme.color, equals(LevTheme.levDarkSurface));
      expect(dark.colorScheme.primary, equals(LevTheme.levMatchaNight));
      expect(dark.colorScheme.onSurface, equals(LevTheme.levDarkText));
    });

    test('LivingSeedSpiritPainter paints without throwing on small containers and finger touch', () {
      final painter = LivingSeedSpiritPainter(
        animationValue: 0.5,
        emotion: LevEmotion.peaceful,
        isPetting: true,
        growthStage: LevGrowthStage.forestSpirit,
        isFingerActive: true,
        touchNormalizedOffset: const Offset(0.7, -0.4),
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Prueba en contenedor pequeño (150x150) para verificar auto-escalado
      expect(() => painter.paint(canvas, const Size(150, 150)), returnsNormally);

      // Prueba en lienzo grande (400x400)
      expect(() => painter.paint(canvas, const Size(400, 400)), returnsNormally);
    });
  });
}
