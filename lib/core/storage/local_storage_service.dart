import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de almacenamiento local offline-first para Lev.
/// La salud mental es privada: todo permanece en el dispositivo del usuario.
class LocalStorageService {
  static const String _keyCareDrops = 'lev_care_drops';
  static const String _keyCompletedHabitsCount = 'lev_completed_habits_count';
  static const String _keyMoodEntries = 'lev_mood_entries_json';
  static const String _keyCbtCards = 'lev_cbt_cards_json';
  static const String _keyCompletedHabitIds = 'lev_completed_habit_ids';
  static const String _keyFavoriteHabitIds = 'lev_favorite_habit_ids';
  static const String _keyUserName = 'lev_user_name';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('LocalStorageService must be initialized before use.');
    }
    return _prefs!;
  }

  // --- GOTAS DE CUIDADO (STREAK COMPASIVO) ---
  static int getCareDrops() {
    return _prefs?.getInt(_keyCareDrops) ?? 15; // Bienvenida cálida
  }

  static Future<void> addCareDrops(int amount) async {
    final current = getCareDrops();
    await _prefs?.setInt(_keyCareDrops, current + amount);
  }

  static Future<void> saveCareDropsRaw(int drops) async {
    await _prefs?.setInt(_keyCareDrops, drops);
  }

  // --- HÁBITOS COMPLETADOS ---
  static int getCompletedHabitsCount() {
    return _prefs?.getInt(_keyCompletedHabitsCount) ?? 0;
  }

  static Future<void> incrementCompletedHabits(String habitId) async {
    final count = getCompletedHabitsCount() + 1;
    await _prefs?.setInt(_keyCompletedHabitsCount, count);

    final ids = getCompletedHabitIds();
    ids.add('${habitId}_${DateTime.now().millisecondsSinceEpoch}');
    await _prefs?.setStringList(_keyCompletedHabitIds, ids);

    // Cada microhábito otorga 1 gota de cuidado
    await addCareDrops(1);
  }

  static List<String> getCompletedHabitIds() {
    return _prefs?.getStringList(_keyCompletedHabitIds) ?? [];
  }

  // --- HÁBITOS FAVORITOS ---
  static Set<String> getFavoriteHabitIds() {
    final list = _prefs?.getStringList(_keyFavoriteHabitIds) ?? [];
    return list.toSet();
  }

  static Future<void> toggleFavoriteHabit(String habitId) async {
    final favs = getFavoriteHabitIds();
    if (favs.contains(habitId)) {
      favs.remove(habitId);
    } else {
      favs.add(habitId);
    }
    await _prefs?.setStringList(_keyFavoriteHabitIds, favs.toList());
  }

  // --- ENTRADAS DEL DIARIO DE ÁNIMO ---
  static List<Map<String, dynamic>> getMoodEntriesRaw() {
    final jsonStr = _prefs?.getString(_keyMoodEntries);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMoodEntriesRaw(List<Map<String, dynamic>> entries) async {
    final jsonStr = jsonEncode(entries);
    await _prefs?.setString(_keyMoodEntries, jsonStr);
  }

  // --- TARJETAS DE REESTRUCTURACIÓN TCC ---
  static List<Map<String, dynamic>> getCbtCardsRaw() {
    final jsonStr = _prefs?.getString(_keyCbtCards);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCbtCardsRaw(List<Map<String, dynamic>> cards) async {
    final jsonStr = jsonEncode(cards);
    await _prefs?.setString(_keyCbtCards, jsonStr);
  }

  // --- NOMBRE DE USUARIO / APODO ---
  static String getUserName() {
    return _prefs?.getString(_keyUserName) ?? 'Humano';
  }

  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_keyUserName, name);
  }
}
