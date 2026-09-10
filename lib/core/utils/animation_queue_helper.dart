import 'dart:async';

/// Gestor de cola de animaciones para Lev.
/// Garantiza que ninguna animación comience antes de que la anterior termine.
/// Úsalo con [execute] para encolar una tarea animada.
class AnimationQueueHelper {
  AnimationQueueHelper._();
  static final AnimationQueueHelper instance = AnimationQueueHelper._();

  bool _isRunning = false;
  final List<Future<void> Function()> _queue = [];

  /// Encola una tarea animada. Si no hay ninguna en curso, la ejecuta inmediatamente.
  Future<void> execute(Future<void> Function() task) async {
    _queue.add(task);
    if (!_isRunning) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    _isRunning = true;
    while (_queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      try {
        await task();
      } catch (_) {}
    }
    _isRunning = false;
  }

  /// Limpia la cola (p.ej. al navegar de pantalla o en emergencia SOS).
  void cancelAll() {
    _queue.clear();
    _isRunning = false;
  }

  bool get isBusy => _isRunning;
}
