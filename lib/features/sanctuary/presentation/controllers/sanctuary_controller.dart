import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';

class SanctuaryController extends Notifier<SanctuaryState> {
  static SanctuaryTimeOfDay _calculateTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return SanctuaryTimeOfDay.morning;
    } else if (hour >= 12 && hour < 18) {
      return SanctuaryTimeOfDay.afternoon;
    } else if (hour >= 18 && hour < 21) {
      return SanctuaryTimeOfDay.dusk;
    } else {
      return SanctuaryTimeOfDay.night;
    }
  }

  @override
  SanctuaryState build() {
    final drops = LocalStorageService.getCareDrops();
    final completed = LocalStorageService.getCompletedHabitsCount();
    final flowers = 3 + min<int>(completed, 12);
    return SanctuaryState(
      careDrops: drops,
      bloomingFlowers: flowers,
      emotion: LevEmotion.peaceful,
      dialogue: 'Qué rico se siente este momento. Gracias por estar aquí conmigo.',
      timeOfDay: _calculateTimeOfDay(),
    );
  }

  static const List<String> _peacefulDialogues = [
    'Qué rico se siente este momento. Gracias por estar aquí conmigo.',
    'No hay prisa en nuestro rinconcito. Respira a tu ritmo.',
    'Cuidar de mí es aprender a cuidar de ti.',
    'Mira cómo flotamos suavemente... todo pasa, esto también pasará.',
    'Si hoy solo pudiste respirar, ya es suficiente.',
    'Me gusta cuando nos sentamos juntos sin hacer nada.',
    '¿Tomaste un vasito de agua hoy? Recuerda aflojar los hombros.',
  ];

  static const List<String> _shelteredDialogues = [
    'Me abracé con mis hojitas para acompañarte en tu silencio.',
    'No tienes que fingir que todo está bien. Yo me quedo contigo.',
    'A veces el mundo pesa mucho. Descansemos aquí un ratito.',
    'Aquí no hay nada que arreglar ahora mismo. Estás a salvo.',
  ];

  static const List<String> _celebratingDialogues = [
    '¡Sentí tu energía renovarse! Gracias por regalarte esta pausa.',
    'Sentí tu respiración profunda... qué paz me da estar contigo.',
    'Una gota más de cuidado para nosotros. ¡Gracias, humano!',
  ];

  /// Interacción de acariciar / cosquillear a Lev
  Future<void> petLev() async {
    await HapticsHelper.light();
    final rand = Random();

    // Si está durmiendo, se despierta tiernamente
    if (state.emotion == LevEmotion.sleeping) {
      state = state.copyWith(
        emotion: LevEmotion.peaceful,
        dialogue: 'Buenos días... gracias por despertarme con cariño.',
        isPetting: true,
        tapCount: state.tapCount + 1,
      );
      Future.delayed(const Duration(milliseconds: 2000), () {
        try {
          state = state.copyWith(isPetting: false);
        } catch (_) {}
      });
      return;
    }

    String newDialogue;
    if (state.emotion == LevEmotion.sheltered) {
      newDialogue = _shelteredDialogues[rand.nextInt(_shelteredDialogues.length)];
    } else {
      newDialogue = _peacefulDialogues[rand.nextInt(_peacefulDialogues.length)];
    }

    state = state.copyWith(
      dialogue: newDialogue,
      tapCount: state.tapCount + 1,
      isPetting: true,
      emotion: state.emotion == LevEmotion.sheltered ? LevEmotion.sheltered : LevEmotion.happy,
    );

    // Regresar de la animación de acariciar a los 2.0s
    Future.delayed(const Duration(milliseconds: 2000), () {
      try {
        state = state.copyWith(
          isPetting: false,
          emotion: state.emotion == LevEmotion.happy ? LevEmotion.peaceful : state.emotion,
        );
      } catch (_) {}
    });
  }

  /// Activar respiración somática guiada con Lev
  Future<void> startBreathing() async {
    await HapticsHelper.medium();
    state = state.copyWith(
      emotion: LevEmotion.breathing,
      dialogue: 'Inhala conmigo cuando me expanda... y exhala cuando me contraiga.',
      tapCount: state.tapCount + 1,
    );
  }

  /// Activar abrazo protector de hojas
  Future<void> hugLev() async {
    await HapticsHelper.medium();
    state = state.copyWith(
      emotion: LevEmotion.sheltered,
      dialogue: 'Aquí estoy contigo. Mis hojitas te cubren y te cuidan.',
      tapCount: state.tapCount + 1,
    );
  }

  /// Modo siesta y descanso nocturno
  Future<void> putToSleep() async {
    await HapticsHelper.light();
    state = state.copyWith(
      emotion: LevEmotion.sleeping,
      dialogue: 'Zzz... momento de soltar la mente y aflojar el cuerpo.',
      tapCount: state.tapCount + 1,
    );
  }

  /// Salto elástico de alegría
  Future<void> triggerJoyJump() async {
    await HapticsHelper.selection();
    state = state.copyWith(
      emotion: LevEmotion.joyJump,
      dialogue: '¡Wooo! ¡Qué alegría me da verte!',
      tapCount: state.tapCount + 1,
    );

    Future.delayed(const Duration(milliseconds: 2400), () {
      try {
        state = state.copyWith(emotion: LevEmotion.peaceful);
      } catch (_) {}
    });
  }

  /// Celebrar la culminación de un microhábito
  Future<void> onHabitCompleted(String habitId) async {
    await LocalStorageService.incrementCompletedHabits(habitId);
    final drops = LocalStorageService.getCareDrops();
    final completed = LocalStorageService.getCompletedHabitsCount();
    final flowers = 3 + min<int>(completed, 15);

    final rand = Random();
    final celebrationQuote = _celebratingDialogues[rand.nextInt(_celebratingDialogues.length)];

    await HapticsHelper.medium();

    state = state.copyWith(
      careDrops: drops,
      bloomingFlowers: flowers,
      emotion: LevEmotion.celebrating,
      dialogue: celebrationQuote,
      tapCount: state.tapCount + 1,
    );

    // Luego de 5 segundos de celebración, regresar al estado calmo
    Future.delayed(const Duration(seconds: 5), () {
      try {
        state = state.copyWith(emotion: LevEmotion.peaceful);
      } catch (_) {}
    });
  }

  /// Ajustar el estado de Lev si el usuario registra tristeza o sobrecarga
  void setShelteredState() {
    state = state.copyWith(
      emotion: LevEmotion.sheltered,
      dialogue: 'Me pongo bajo esta hojita contigo. No tienes que demostrar nada hoy.',
    );
  }

  void setPeacefulState() {
    state = state.copyWith(
      emotion: LevEmotion.peaceful,
      dialogue: 'Siento mucha serenidad compartiendo este rincón contigo.',
    );
  }
}

final sanctuaryProvider =
    NotifierProvider<SanctuaryController, SanctuaryState>(
  SanctuaryController.new,
);

