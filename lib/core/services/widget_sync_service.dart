import 'package:flutter/services.dart';
import 'package:lev/core/storage/local_storage_service.dart';

/// Servicio de sincronización con el Widget nativo de la pantalla de inicio (Android).
class WidgetSyncService {
  static const MethodChannel _channel = MethodChannel('com.lev.lev/widget');
  static bool _initialized = false;
  static Function(String action)? _actionListener;

  static void init({Function(String action)? onAction}) {
    if (_initialized) return;
    _initialized = true;
    _actionListener = onAction;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onWidgetAction') {
        final action = call.arguments as String?;
        if (action != null && _actionListener != null) {
          _actionListener!(action);
        }
      }
    });

    // Comprobar si la app fue lanzada desde el widget
    checkInitialAction();
  }

  static Future<void> checkInitialAction() async {
    try {
      final action = await _channel.invokeMethod<String>('getInitialAction');
      if (action != null && action.isNotEmpty && _actionListener != null) {
        _actionListener!(action);
      }
    } catch (_) {
      // Ignorar en plataformas sin canal nativo
    }
  }

  /// Notifica al widget nativo que refresque su contenido con los datos actuales
  static Future<void> syncWidgetData({String? dialogue}) async {
    try {
      if (dialogue != null && dialogue.isNotEmpty) {
        await LocalStorageService.prefs.setString('lev_widget_dialogue', dialogue);
      }
      await _channel.invokeMethod('updateWidget');
    } catch (_) {
      // Ignorar si el widget no está soportado o instalado
    }
  }
}
