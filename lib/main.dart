import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/lev_theme.dart';
import 'features/home/presentation/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización defensiva para que la app siempre abra incluso si falla el almacenamiento
  try {
    await LocalStorageService.init();
  } catch (e) {
    debugPrint('Aviso: Fallback en inicialización de almacenamiento local: $e');
  }

  // Inicialización defensiva de fechas en español
  try {
    await initializeDateFormatting('es', null);
  } catch (e) {
    debugPrint('Aviso: Fallback en formato de fecha: $e');
  }

  runApp(
    const ProviderScope(
      child: LevApp(),
    ),
  );
}

class LevApp extends StatelessWidget {
  const LevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lev: Mental Health & Micro-Habit Companion',
      debugShowCheckedModeBanner: false,
      theme: LevTheme.lightTheme,
      home: const MainNavigationWrapper(),
    );
  }
}
