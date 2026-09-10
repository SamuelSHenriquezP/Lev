import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';

class SanctuaryController extends Notifier<SanctuaryState> {
  static SanctuaryTimeOfDay _calculateTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return SanctuaryTimeOfDay.morning;
    if (hour >= 12 && hour < 18) return SanctuaryTimeOfDay.afternoon;
    if (hour >= 18 && hour < 21) return SanctuaryTimeOfDay.dusk;
    return SanctuaryTimeOfDay.night;
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
      dialogue: _getGreeting(_calculateTimeOfDay()),
      timeOfDay: _calculateTimeOfDay(),
    );
  }

  static String _getGreeting(SanctuaryTimeOfDay time) {
    switch (time) {
      case SanctuaryTimeOfDay.morning:
        return 'Buenos días. Qué bien empezar el día juntos.';
      case SanctuaryTimeOfDay.afternoon:
        return 'Buenas tardes. Este rincón siempre es tuyo.';
      case SanctuaryTimeOfDay.dusk:
        return 'El atardecer es mi momento favorito. Gracias por estar aquí.';
      case SanctuaryTimeOfDay.night:
        return 'La noche llegó. Respira conmigo y suelta lo que cargaste hoy.';
    }
  }

  static const List<String> _peacefulDialogues = [
    'Qué rico se siente este momento. Gracias por estar aquí conmigo.',
    'No hay prisa en nuestro rinconcito. Respira a tu ritmo.',
    'Cuidar de mí es aprender a cuidar de ti.',
    'Mira cómo flotamos suavemente... todo pasa, esto también pasará.',
    'Si hoy solo pudiste respirar, ya es suficiente.',
    'Me gusta cuando nos sentamos juntos sin hacer nada.',
    '¿Tomaste un vasito de agua hoy? Recuerda aflojar los hombros.',
    'No tienes que ser perfecto. Estar aquí ya es un logro.',
  ];

  static const List<String> _shelteredDialogues = [
    'Me abracé con mis hojitas para acompañarte en tu silencio.',
    'No tienes que fingir que todo está bien. Yo me quedo contigo.',
    'A veces el mundo pesa mucho. Descansemos aquí un ratito.',
    'Aquí no hay nada que arreglar ahora mismo. Estás a salvo.',
    'Las hojas más fuertes también se doblan con el viento.',
  ];

  static const List<String> _sadDialogues = [
    'Veo que algo pesa en tu corazón hoy. Te escucho.',
    'No tienes que estar bien todo el tiempo. Yo también tengo días grises.',
    'La tristeza tiene un ritmo propio. No hay que apresurarla.',
    'Estoy aquí contigo en silencio. Sin prisa, sin presión.',
    'A veces simplemente acompañar ya es mucho. Aquí estoy.',
  ];

  static const List<String> _anxiousDialogues = [
    'Respira conmigo. Inhala... sostén... exhala. Una vez más.',
    'Ese pensamiento no es la realidad entera. Solo una parte.',
    'Tu sistema nervioso está trabajando duro. Ayudémoslo a calmarse.',
    'Pies en el suelo. Espalda en la silla. Estás físicamente a salvo.',
    'La ansiedad miente sobre el futuro. Tú estás aquí, ahora.',
  ];

  static const List<String> _celebratingDialogues = [
    '¡Sentí tu energía renovarse! Gracias por regalarte esta pausa.',
    'Una gota más de cuidado para nosotros. Juntos crecemos.',
    'Cada microhábito es una semilla de cambio real. Lo siento en mis raíces.',
    'Tu sistema nervioso acaba de respirar. Yo también.',
  ];

  // Diálogos al subir de etapa de crecimiento
  static String _getLevelUpDialogue(LevGrowthStage stage) {
    switch (stage) {
      case LevGrowthStage.sprout:
        return '¡Mis primeras hojitas! Gracias a tus pausas estoy brotando.';
      case LevGrowthStage.seedling:
        return 'Ya soy una plántula. Puedo ver el mundo desde aquí.';
      case LevGrowthStage.youngPlant:
        return 'Mis hojas ya son grandes y fuertes, como tu constancia.';
      case LevGrowthStage.vibrantPlant:
        return '¡Flores! Tu cuidado me está haciendo florecer de verdad.';
      case LevGrowthStage.youngTree:
        return 'Soy un arbolito. Juntos hemos llegado muy lejos.';
      case LevGrowthStage.adultTree:
        return 'Árbol adulto. Tus pausas me hicieron fuerte y sabio.';
      case LevGrowthStage.forestSpirit:
        return 'Espíritu del Bosque. Esto es el resultado de todo tu cuidado. Gracias.';
      default:
        return '¡Crecí! Tus pausas conscientes me nutren cada día.';
    }
  }

  /// Acariciar a Lev
  Future<void> petLev() async {
    await HapticsHelper.light();
    final rand = Random();

    if (state.emotion == LevEmotion.sleeping) {
      state = state.copyWith(
        emotion: LevEmotion.peaceful,
        dialogue: 'Buenos días... gracias por despertarme con cariño.',
        isPetting: true,
        tapCount: state.tapCount + 1,
      );
      Future.delayed(const Duration(milliseconds: 2000), () {
        try { state = state.copyWith(isPetting: false); } catch (_) {}
      });
      return;
    }

    String newDialogue;
    if (state.emotion == LevEmotion.sheltered || state.emotion == LevEmotion.sad) {
      newDialogue = _shelteredDialogues[rand.nextInt(_shelteredDialogues.length)];
    } else {
      newDialogue = _peacefulDialogues[rand.nextInt(_peacefulDialogues.length)];
    }

    state = state.copyWith(
      dialogue: newDialogue,
      tapCount: state.tapCount + 1,
      isPetting: true,
      emotion: (state.emotion == LevEmotion.sheltered || state.emotion == LevEmotion.sad)
          ? state.emotion
          : LevEmotion.happy,
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      try {
        state = state.copyWith(
          isPetting: false,
          emotion: state.emotion == LevEmotion.happy ? LevEmotion.peaceful : state.emotion,
        );
      } catch (_) {}
    });
  }

  /// Activar respiración guiada
  Future<void> startBreathing() async {
    await HapticsHelper.medium();
    state = state.copyWith(
      emotion: LevEmotion.breathing,
      dialogue: 'Inhala conmigo cuando me expanda... exhala cuando me contraiga.',
      tapCount: state.tapCount + 1,
    );
  }

  /// Abrazo protector de hojas
  Future<void> hugLev() async {
    await HapticsHelper.medium();
    state = state.copyWith(
      emotion: LevEmotion.sheltered,
      dialogue: 'Aquí estoy contigo. Mis hojitas te cubren y te cuidan.',
      tapCount: state.tapCount + 1,
    );
  }

  /// Modo siesta
  Future<void> putToSleep() async {
    await HapticsHelper.light();
    state = state.copyWith(
      emotion: LevEmotion.sleeping,
      dialogue: 'Zzz... momento de soltar la mente y aflojar el cuerpo.',
      tapCount: state.tapCount + 1,
    );
  }

  /// Salto de alegría
  Future<void> triggerJoyJump() async {
    await HapticsHelper.selection();
    state = state.copyWith(
      emotion: LevEmotion.joyJump,
      dialogue: 'Wooo! Qué alegría me da verte!',
      tapCount: state.tapCount + 1,
    );
    Future.delayed(const Duration(milliseconds: 2400), () {
      try { state = state.copyWith(emotion: LevEmotion.peaceful); } catch (_) {}
    });
  }

  /// Cuando el usuario registra tristeza — Lev responde
  void onUserFeelsSad() {
    final rand = Random();
    state = state.copyWith(
      emotion: LevEmotion.sad,
      dialogue: _sadDialogues[rand.nextInt(_sadDialogues.length)],
    );
  }

  /// Cuando el usuario registra ansiedad — Lev activa respiración automática
  void onUserFeelsAnxious() {
    final rand = Random();
    state = state.copyWith(
      emotion: LevEmotion.anxious,
      dialogue: _anxiousDialogues[rand.nextInt(_anxiousDialogues.length)],
    );
  }

  /// Al completar un microhábito — chequea si subió de etapa
  Future<void> onHabitCompleted(String habitId) async {
    final prevStage = state.growthStage;
    await LocalStorageService.incrementCompletedHabits(habitId);
    final drops = LocalStorageService.getCareDrops();
    final completed = LocalStorageService.getCompletedHabitsCount();
    final flowers = 3 + min<int>(completed, 15);

    await HapticsHelper.medium();

    // Detectar si subió de etapa
    final tempState = state.copyWith(careDrops: drops);
    final newStage = tempState.growthStage;
    final justLeveledUp = newStage.index > prevStage.index;

    final rand = Random();
    final celebrationQuote = justLeveledUp
        ? _getLevelUpDialogue(newStage)
        : _celebratingDialogues[rand.nextInt(_celebratingDialogues.length)];

    state = state.copyWith(
      careDrops: drops,
      bloomingFlowers: flowers,
      emotion: justLeveledUp ? LevEmotion.celebrating : LevEmotion.celebrating,
      dialogue: celebrationQuote,
      tapCount: state.tapCount + 1,
      justLeveledUp: justLeveledUp,
    );

    Future.delayed(const Duration(seconds: 5), () {
      try {
        state = state.copyWith(
          emotion: LevEmotion.peaceful,
          justLeveledUp: false,
        );
      } catch (_) {}
    });
  }

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

  void setCuriousState() {
    HapticsHelper.light();
    state = state.copyWith(
      emotion: LevEmotion.curious,
      dialogue: '¿Qué descubriremos juntos hoy? Todo me da curiosidad a tu lado.',
      tapCount: state.tapCount + 1,
    );
  }

  void setCelebratingState() {
    HapticsHelper.selection();
    state = state.copyWith(
      emotion: LevEmotion.celebrating,
      dialogue: '¡Qué gran momento para celebrar! Cada paso cuenta.',
      tapCount: state.tapCount + 1,
    );
    Future.delayed(const Duration(milliseconds: 3500), () {
      try {
        if (state.emotion == LevEmotion.celebrating) {
          state = state.copyWith(emotion: LevEmotion.peaceful);
        }
      } catch (_) {}
    });
  }

  void setEmotion(LevEmotion emotion) {
    HapticsHelper.selection();
    state = state.copyWith(
      emotion: emotion,
      tapCount: state.tapCount + 1,
    );
  }

  Future<void> setCareDrops(int drops) async {
    await LocalStorageService.saveCareDropsRaw(drops);
    final prevStage = state.growthStage;
    final tempState = state.copyWith(careDrops: drops);
    final newStage = tempState.growthStage;
    final justLeveledUp = newStage.index != prevStage.index;

    state = state.copyWith(
      careDrops: drops,
      justLeveledUp: justLeveledUp,
      dialogue: justLeveledUp ? _getLevelUpDialogue(newStage) : state.dialogue,
    );
  }
}

final sanctuaryProvider =
    NotifierProvider<SanctuaryController, SanctuaryState>(
  SanctuaryController.new,
);
