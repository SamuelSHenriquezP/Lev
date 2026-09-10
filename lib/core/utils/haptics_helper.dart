import 'package:flutter/services.dart';

/// Manejador de micro-interacciones hápticas suaves y sensoriales para Lev.
class HapticsHelper {
  /// Clic sutil para selección de chips, opciones de chat y pestañas
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Ignorar si el dispositivo no soporta háptica
    }
  }

  /// Impacto ligero para botones principales y cambio de pasos en temporizador
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignorar
    }
  }

  /// Impacto medio para la culminación de un microhábito o florecimiento
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignorar
    }
  }

  /// Doble pulso suave para respiración somática (inhalar y exhalar)
  static Future<void> breathingTick() async {
    try {
      await HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 70));
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Ignorar
    }
  }
}

