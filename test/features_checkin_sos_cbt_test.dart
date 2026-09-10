import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/home/presentation/home_screen.dart';
import 'package:lev/features/journal/presentation/journal_screen.dart';
import 'package:lev/features/journal/presentation/cbt_reframer_screen.dart';
import 'package:lev/features/crisis/presentation/crisis_sos_modal.dart';
import 'package:lev/features/companion/presentation/lev_chat_bubble.dart';
import 'package:lev/features/companion/presentation/companion_chat_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'lev_care_drops': 25,
      'lev_completed_habits_count': 5,
    });
    await LocalStorageService.init();
    await initializeDateFormatting('es', null);
  });

  group('SOS, Offline Privacy & CBT Integration Suite', () {
    testWidgets('HomeScreen header displays SOS and Privacy buttons and opens dialogs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Header icons exist
      expect(find.byTooltip('Líneas de ayuda y SOS'), findsOneWidget);
      expect(find.byTooltip('Privacidad y datos'), findsOneWidget);
      expect(find.byTooltip('Sonidos del Santuario'), findsOneWidget);

      // Tap Privacy button
      await tester.tap(find.byTooltip('Privacidad y datos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Privacy dialog is displayed
      expect(find.text('Tu Espacio Seguro'), findsOneWidget);
      expect(find.text('100% Sin Conexión Obligatoria'), findsOneWidget);
      expect(find.text('Sin Cuentas ni Rastreadores'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Entendido'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Tap SOS button
      await tester.tap(find.byTooltip('Líneas de ayuda y SOS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Crisis SOS modal is displayed
      expect(find.byType(CrisisSosModal), findsOneWidget);
      expect(find.text('Ayuda Emocional'), findsOneWidget);
      expect(find.text('Colombia · Línea 106'), findsOneWidget);
    });

    testWidgets('JournalScreen renders Quick Mood Check-In with 5 moods and records selection', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JournalScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Quick Mood Check-In title and all 5 states
      expect(find.text('Check-in emocional'), findsOneWidget);
      expect(find.text('¿Cómo te encuentras en este momento?'), findsOneWidget);
      expect(find.text('Desconectado'), findsOneWidget);
      expect(find.text('Agobiado'), findsOneWidget);
      expect(find.text('En Calma'), findsOneWidget);
      expect(find.text('Agradecido'), findsOneWidget);
      expect(find.text('Radiante'), findsOneWidget);

      // Tap 'En Calma'
      await tester.tap(find.text('En Calma'));
      await tester.pump(const Duration(milliseconds: 200));

      // Toast confirms registration
      expect(find.text('Registrado'), findsOneWidget);

      // Scroll to CBT section
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 300));

      // CBT section is visible
      expect(find.text('Pensamientos & Compasión'), findsOneWidget);
      expect(find.text('Reestructuración Cognitiva TCC'), findsOneWidget);
      expect(find.text('Desactiva trampas mentales'), findsOneWidget);

      // Advance timer
      await tester.pump(const Duration(milliseconds: 2600));
    });

    testWidgets('Tapping on CBT Iniciar opens CbtReframerScreen with 3 steps', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JournalScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll to CBT section
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Iniciar
      await tester.tap(find.text('Iniciar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // CbtReframerScreen is displayed
      expect(find.byType(CbtReframerScreen), findsOneWidget);
      expect(find.text('Reestructuración TCC'), findsOneWidget);
      expect(find.text('1. Pensamiento'), findsOneWidget);
      expect(find.text('2. Trampa'), findsOneWidget);
      expect(find.text('3. Compasión'), findsOneWidget);
    });

    testWidgets('LevChatBubble opens popup with quick suggestions and fullscreen navigation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Center(child: Text('Main Content')),
                  LevChatBubble(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on Lev FAB gesture detector
      final fabFinder = find.descendant(
        of: find.byType(LevChatBubble),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(fabFinder.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Quick suggestions are visible
      expect(find.text('Me siento ansioso'), findsOneWidget);
      expect(find.text('Estoy triste'), findsOneWidget);
      expect(find.byTooltip('Pantalla completa'), findsOneWidget);

      // Tap fullscreen button
      await tester.tap(find.byTooltip('Pantalla completa'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Navigated to full companion chat screen
      expect(find.byType(CompanionChatScreen), findsOneWidget);
    });
  });
}
