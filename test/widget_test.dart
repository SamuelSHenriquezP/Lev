import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/main.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/features/habits/data/habits_database.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'lev_care_drops': 15,
      'lev_completed_habits_count': 2,
    });
    await LocalStorageService.init();
    await initializeDateFormatting('es', null);
  });

  test('Habits database contains all clinical micro-habits', () {
    expect(HabitsDatabase.allHabits.length, greaterThanOrEqualTo(7));

    final doomHabit = HabitsDatabase.getById('doom_01');
    expect(doomHabit, isNotNull);
    expect(doomHabit!.title, contains('20-20-20'));
    expect(doomHabit.durationSeconds, 60);
    expect(doomHabit.steps.length, 3);

    final anxHabit = HabitsDatabase.getById('anx_01');
    expect(anxHabit, isNotNull);
    expect(anxHabit!.title, contains('Suspiro Fisiológico'));
    expect(anxHabit.psychologicalBasis, contains('nervio vago'));

    final sadHabit = HabitsDatabase.getById('sad_01');
    expect(sadHabit, isNotNull);
    expect(sadHabit!.title, contains('Abrazo de Presión'));

    final angHabit = HabitsDatabase.getById('ang_01');
    expect(angHabit, isNotNull);
    expect(angHabit!.title, contains('Jacobson'));
  });

  testWidgets('LevApp renders and displays navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LevApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar pestañas limpias de navegación
    expect(find.text('Santuario'), findsOneWidget);
    expect(find.text('Hábitos'), findsOneWidget);
    expect(find.text('Progreso'), findsOneWidget);

    // Pastillas de interacción somática
    expect(find.text('Respirar'), findsOneWidget);
    expect(find.text('Acariciar'), findsOneWidget);
    expect(find.text('Abrazo'), findsOneWidget);
    expect(find.text('Dormir'), findsOneWidget);
  });
}
