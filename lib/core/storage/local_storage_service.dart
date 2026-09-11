import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de almacenamiento local offline-first para Lev.
/// La salud mental es privada: todo permanece en el dispositivo del usuario.
class LocalStorageService {
  static const String _keyCareDrops = 'lev_care_drops';
  static const String _keyExperiencePoints = 'lev_experience_points';
  static const String _keyUnlockedDecors = 'lev_unlocked_decors';
  static const String _keyActiveDecors = 'lev_active_decors';
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

  // --- GOTAS DE CUIDADO (RECURSO / MONEDA TÁCTIL) ---
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

  // --- PUNTOS DE EXPERIENCIA (XP BOTÁNICA ACUMULADA) ---
  static int getExperiencePoints() {
    final stored = _prefs?.getInt(_keyExperiencePoints);
    if (stored != null) return stored;
    // Si es primera vez, se deriva de las gotas existentes para no perder progreso
    final initialXp = getCareDrops() * 10;
    _prefs?.setInt(_keyExperiencePoints, initialXp);
    return initialXp;
  }

  static Future<void> addExperiencePoints(int amount) async {
    final current = getExperiencePoints();
    await _prefs?.setInt(_keyExperiencePoints, current + amount);
  }

  static Future<void> saveExperiencePointsRaw(int xp) async {
    await _prefs?.setInt(_keyExperiencePoints, xp);
  }

  // --- DESBLOQUEOS Y DECORACIONES DEL SANTUARIO ---
  static List<String> getUnlockedDecorIds() {
    return _prefs?.getStringList(_keyUnlockedDecors) ?? [];
  }

  static Future<void> saveUnlockedDecorIds(List<String> ids) async {
    await _prefs?.setStringList(_keyUnlockedDecors, ids);
  }

  static List<String> getActiveDecorIds() {
    return _prefs?.getStringList(_keyActiveDecors) ?? [];
  }

  static Future<void> saveActiveDecorIds(List<String> ids) async {
    await _prefs?.setStringList(_keyActiveDecors, ids);
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

  // --- ACCESORIOS BOTÁNICOS DE LEV ---
  static const String _keyActiveAccessory = 'lev_active_accessory';
  static const String _keyUnlockedAccessories = 'lev_unlocked_accessories';

  static String getActiveAccessoryId() {
    return _prefs?.getString(_keyActiveAccessory) ?? 'none';
  }

  static Future<void> saveActiveAccessoryId(String id) async {
    await _prefs?.setString(_keyActiveAccessory, id);
  }

  static List<String> getUnlockedAccessoryIds() {
    return _prefs?.getStringList(_keyUnlockedAccessories) ?? ['none'];
  }

  static Future<void> saveUnlockedAccessoryIds(List<String> ids) async {
    await _prefs?.setStringList(_keyUnlockedAccessories, ids);
  }

  // --- MEDICIÓN DE ALIVIO SOMÁTICO POST-HÁBITO ---
  static const String _keyHabitRelief = 'lev_habit_relief_ratings_json';

  static List<Map<String, dynamic>> getHabitReliefEntries() {
    final jsonStr = _prefs?.getString(_keyHabitRelief);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> recordHabitRelief(String habitId, String reliefLevel) async {
    final entries = getHabitReliefEntries();
    entries.add({
      'habitId': habitId,
      'reliefLevel': reliefLevel, // 'lighter', 'same', 'tense'
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs?.setString(_keyHabitRelief, jsonEncode(entries));
  }

  // --- ANULACIÓN / FORZADO DE CICLO CIRCADIANO ---
  static const String _keyCircadianOverride = 'lev_circadian_override';

  static String? getCircadianOverride() {
    return _prefs?.getString(_keyCircadianOverride);
  }

  static Future<void> saveCircadianOverride(String? override) async {
    if (override == null) {
      await _prefs?.remove(_keyCircadianOverride);
    } else {
      await _prefs?.setString(_keyCircadianOverride, override);
    }
  }

  // --- BLOQUEO DE PRIVACIDAD POR PIN DE 4 DÍGITOS ---
  static const String _keyPrivacyPin = 'lev_privacy_pin';

  static String? getPrivacyPin() {
    return _prefs?.getString(_keyPrivacyPin);
  }

  static bool isPinProtectionActive() {
    final pin = getPrivacyPin();
    return pin != null && pin.length == 4;
  }

  static Future<void> setPrivacyPin(String? pin) async {
    if (pin == null || pin.isEmpty) {
      await _prefs?.remove(_keyPrivacyPin);
    } else {
      await _prefs?.setString(_keyPrivacyPin, pin);
    }
  }

  // --- RECORDATORIOS GENTILES DE MICRO-PAUSA ---
  static const String _keyGentleReminders = 'lev_gentle_reminders_json';

  static Map<String, dynamic> getGentleReminders() {
    final jsonStr = _prefs?.getString(_keyGentleReminders);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {
        'enabled': false,
        'morning': true,
        'afternoon': true,
        'night': true,
        'rule20': false,
      };
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
    } catch (_) {
      return {'enabled': false};
    }
  }

  static Future<void> saveGentleReminders(Map<String, dynamic> config) async {
    await _prefs?.setString(_keyGentleReminders, jsonEncode(config));
  }
}
