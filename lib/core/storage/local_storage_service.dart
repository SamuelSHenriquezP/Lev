import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lev/features/profile/domain/user_profile.dart';

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
  static const String _keyUserAge = 'lev_user_age';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Si la app tenía 15 gotas por defecto de versiones anteriores, normalizar a cero absoluto
    if (_prefs?.getInt(_keyCareDrops) == 15 && (_prefs?.getInt(_keyExperiencePoints) == 150 || _prefs?.getInt(_keyExperiencePoints) == null)) {
      await _prefs?.setInt(_keyCareDrops, 0);
      await _prefs?.setInt(_keyExperiencePoints, 0);
    }
  }

  /// Limpieza total para reiniciar desde cero (Semilla)
  static Future<void> resetAllProgress() async {
    await _prefs?.setInt(_keyCareDrops, 0);
    await _prefs?.setInt(_keyExperiencePoints, 0);
    await _prefs?.setStringList(_keyUnlockedDecors, []);
    await _prefs?.setStringList(_keyActiveDecors, []);
    await _prefs?.remove(_keyCompletedHabitIds);
    await _prefs?.setInt(_keyCompletedHabitsCount, 0);
    await _prefs?.setString('lev_active_accessory', 'none');
    await _prefs?.setStringList('lev_unlocked_accessories', ['none']);
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('LocalStorageService must be initialized before use.');
    }
    return _prefs!;
  }

  // --- GOTAS DE CUIDADO (RECURSO / MONEDA TÁCTIL) ---
  static int getCareDrops() {
    return _prefs?.getInt(_keyCareDrops) ?? 0; // Comienza desde cero
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
    return _prefs?.getInt(_keyExperiencePoints) ?? 0; // Comienza desde cero
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

  // --- NOMBRE Y EDAD DEL USUARIO ---
  static String getUserName() {
    return _prefs?.getString(_keyUserName) ?? 'Humano';
  }

  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_keyUserName, name);
  }

  static int getUserAge() {
    return _prefs?.getInt(_keyUserAge) ?? 25;
  }

  static Future<void> setUserAge(int age) async {
    await _prefs?.setInt(_keyUserAge, age);
  }

  static UserProfile getUserProfile() {
    final name = getUserName();
    final age = getUserAge();
    return UserProfile(name: name, age: age);
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    await setUserName(profile.name);
    await setUserAge(profile.age);
  }

  static LevUserStage getUserStage() {
    return getUserProfile().stage;
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

  // --- POSICIONAMIENTO PERSONALIZADO DE DECORACIONES (DRAG & DROP) ---
  static const String _keyDecorPositions = 'lev_decor_positions_json';

  static Map<String, List<double>> getDecorPositionsRaw() {
    final jsonStr = _prefs?.getString(_keyDecorPositions);
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final result = <String, List<double>>{};
      decoded.forEach((key, val) {
        if (val is List && val.length >= 2) {
          result[key] = [
            (val[0] as num).toDouble(),
            (val[1] as num).toDouble(),
          ];
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveDecorPositionsRaw(Map<String, List<double>> positions) async {
    final jsonStr = jsonEncode(positions);
    await _prefs?.setString(_keyDecorPositions, jsonStr);
  }

  static Future<void> resetDecorPositions() async {
    await _prefs?.remove(_keyDecorPositions);
  }

  // --- TUTORIAL / ONBOARDING ---
  static const String _keySeenOnboarding = 'lev_seen_onboarding';

  static bool hasSeenOnboarding() {
    return _prefs?.getBool(_keySeenOnboarding) ?? false;
  }

  static Future<void> setSeenOnboarding(bool seen) async {
    await _prefs?.setBool(_keySeenOnboarding, seen);
  }

  // --- SALUDO DIARIO ---
  static const String _keyLastDailyGreetingDate = 'lev_last_daily_greeting_date';

  static String? getLastDailyGreetingDate() {
    return _prefs?.getString(_keyLastDailyGreetingDate);
  }

  static Future<void> setLastDailyGreetingDate(String dateStr) async {
    await _prefs?.setString(_keyLastDailyGreetingDate, dateStr);
  }

  // --- CLIMA DEL SANTUARIO ---
  static const String _keySanctuaryWeather = 'lev_sanctuary_weather';

  static String getSanctuaryWeather() {
    return _prefs?.getString(_keySanctuaryWeather) ?? 'calm';
  }

  static Future<void> setSanctuaryWeather(String weatherId) async {
    await _prefs?.setString(_keySanctuaryWeather, weatherId);
  }

  // --- DESCONEXIÓN CONSCIENTE (SOLTAR EL TELÉFONO) ---
  static const String _keyTotalDetoxMinutes = 'lev_total_detox_minutes';
  static const String _keyTotalDetoxSessions = 'lev_total_detox_sessions';
  static const String _keyTodayDetoxMinutes = 'lev_today_detox_minutes';
  static const String _keyLastDetoxDate = 'lev_last_detox_date';

  static int getTotalDetoxMinutes() {
    return _prefs?.getInt(_keyTotalDetoxMinutes) ?? 0;
  }

  static int getTotalDetoxSessions() {
    return _prefs?.getInt(_keyTotalDetoxSessions) ?? 0;
  }

  static int getTodayDetoxMinutes() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = _prefs?.getString(_keyLastDetoxDate) ?? '';
    if (lastDate != todayStr) {
      return 0;
    }
    return _prefs?.getInt(_keyTodayDetoxMinutes) ?? 0;
  }

  static Future<void> addDetoxSession(int minutes) async {
    if (minutes <= 0) return;
    final currentTotal = getTotalDetoxMinutes();
    final currentSessions = getTotalDetoxSessions();
    await _prefs?.setInt(_keyTotalDetoxMinutes, currentTotal + minutes);
    await _prefs?.setInt(_keyTotalDetoxSessions, currentSessions + 1);

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = _prefs?.getString(_keyLastDetoxDate) ?? '';
    if (lastDate != todayStr) {
      await _prefs?.setString(_keyLastDetoxDate, todayStr);
      await _prefs?.setInt(_keyTodayDetoxMinutes, minutes);
    } else {
      final todayMins = _prefs?.getInt(_keyTodayDetoxMinutes) ?? 0;
      await _prefs?.setInt(_keyTodayDetoxMinutes, todayMins + minutes);
    }
  }

  // --- COPIA DE SEGURIDAD INTEGRAL (EXPORTAR / IMPORTAR) ---
  static String exportFullBackupJson() {
    final data = <String, dynamic>{
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'careDrops': getCareDrops(),
      'experiencePoints': getExperiencePoints(),
      'unlockedDecors': getUnlockedDecorIds(),
      'activeDecors': getActiveDecorIds(),
      'completedHabitsCount': getCompletedHabitsCount(),
      'completedHabitIds': getCompletedHabitIds(),
      'favoriteHabitIds': getFavoriteHabitIds().toList(),
      'decorPositions': getDecorPositionsRaw(),
      'sanctuaryWeather': getSanctuaryWeather(),
      'hasSeenOnboarding': hasSeenOnboarding(),
      'totalDetoxMinutes': getTotalDetoxMinutes(),
      'totalDetoxSessions': getTotalDetoxSessions(),
      'activeAccessory': _prefs?.getString('lev_active_accessory') ?? 'none',
      'unlockedAccessories': _prefs?.getStringList('lev_unlocked_accessories') ?? ['none'],
      'moodEntries': _prefs?.getString(_keyMoodEntries) ?? '[]',
      'cbtCards': _prefs?.getString(_keyCbtCards) ?? '[]',
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<bool> importFullBackupJson(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (data['careDrops'] is int) await saveCareDropsRaw(data['careDrops'] as int);
      if (data['experiencePoints'] is int) await saveExperiencePointsRaw(data['experiencePoints'] as int);
      if (data['unlockedDecors'] is List) {
        await saveUnlockedDecorIds((data['unlockedDecors'] as List).map((e) => e.toString()).toList());
      }
      if (data['activeDecors'] is List) {
        await saveActiveDecorIds((data['activeDecors'] as List).map((e) => e.toString()).toList());
      }
      if (data['completedHabitsCount'] is int) {
        await _prefs?.setInt(_keyCompletedHabitsCount, data['completedHabitsCount'] as int);
      }
      if (data['completedHabitIds'] is List) {
        await _prefs?.setStringList(
          _keyCompletedHabitIds,
          (data['completedHabitIds'] as List).map((e) => e.toString()).toList(),
        );
      }
      if (data['favoriteHabitIds'] is List) {
        await _prefs?.setStringList(
          _keyFavoriteHabitIds,
          (data['favoriteHabitIds'] as List).map((e) => e.toString()).toList(),
        );
      }
      if (data['decorPositions'] is Map) {
        final posMap = <String, List<double>>{};
        (data['decorPositions'] as Map).forEach((k, v) {
          if (v is List && v.length >= 2) {
            posMap[k.toString()] = [(v[0] as num).toDouble(), (v[1] as num).toDouble()];
          }
        });
        await saveDecorPositionsRaw(posMap);
      }
      if (data['sanctuaryWeather'] is String) {
        await setSanctuaryWeather(data['sanctuaryWeather'] as String);
      }
      if (data['activeAccessory'] is String) {
        await _prefs?.setString('lev_active_accessory', data['activeAccessory'] as String);
      }
      if (data['unlockedAccessories'] is List) {
        await _prefs?.setStringList(
          'lev_unlocked_accessories',
          (data['unlockedAccessories'] as List).map((e) => e.toString()).toList(),
        );
      }
      if (data['moodEntries'] is String) {
        await _prefs?.setString(_keyMoodEntries, data['moodEntries'] as String);
      }
      if (data['cbtCards'] is String) {
        await _prefs?.setString(_keyCbtCards, data['cbtCards'] as String);
      }
      if (data['totalDetoxMinutes'] is int) {
        await _prefs?.setInt(_keyTotalDetoxMinutes, data['totalDetoxMinutes'] as int);
      }
      if (data['totalDetoxSessions'] is int) {
        await _prefs?.setInt(_keyTotalDetoxSessions, data['totalDetoxSessions'] as int);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
