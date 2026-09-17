import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lev/core/audio/sanctuary_audio_service.dart';
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
    final xp = LocalStorageService.getExperiencePoints();
    final completed = LocalStorageService.getCompletedHabitsCount();
    final flowers = 3 + min<int>(completed, 12);

    final unlockedIds = LocalStorageService.getUnlockedDecorIds();
    final activeIds = LocalStorageService.getActiveDecorIds();
    final unlocked = unlockedIds
        .map((id) => SanctuaryDecorItem.fromId(id))
        .whereType<SanctuaryDecorItem>()
        .toSet();
    final active = activeIds
        .map((id) => SanctuaryDecorItem.fromId(id))
        .whereType<SanctuaryDecorItem>()
        .toSet();

    final rawPositions = LocalStorageService.getDecorPositionsRaw();
    final customPositions = <SanctuaryDecorItem, Offset>{};
    rawPositions.forEach((id, coords) {
      final item = SanctuaryDecorItem.fromId(id);
      if (item != null && coords.length >= 2) {
        customPositions[item] = Offset(coords[0], coords[1]);
      }
    });

    final activeAccId = LocalStorageService.getActiveAccessoryId();
    final unlockedAccIds = LocalStorageService.getUnlockedAccessoryIds();
    final activeAcc = LevAccessory.fromId(activeAccId) ?? LevAccessory.none;
    final unlockedAcc = unlockedAccIds
        .map((id) => LevAccessory.fromId(id))
        .whereType<LevAccessory>()
        .toSet();
    if (!unlockedAcc.contains(LevAccessory.none)) {
      unlockedAcc.add(LevAccessory.none);
    }

    final circadianStr = LocalStorageService.getCircadianOverride();
    SanctuaryTimeOfDay? circadianOverride;
    if (circadianStr != null) {
      for (final t in SanctuaryTimeOfDay.values) {
        if (t.name == circadianStr) {
          circadianOverride = t;
          break;
        }
      }
    }

    final weatherStr = LocalStorageService.getSanctuaryWeather();
    final weather = SanctuaryWeather.fromId(weatherStr);

    return SanctuaryState(
      careDrops: drops,
      experiencePoints: xp,
      bloomingFlowers: flowers,
      emotion: LevEmotion.peaceful,
      dialogue: _getGreeting(_calculateTimeOfDay()),
      timeOfDay: _calculateTimeOfDay(),
      unlockedDecors: unlocked,
      activeDecors: active,
      customDecorPositions: customPositions,
      activeAccessory: activeAcc,
      unlockedAccessories: unlockedAcc,
      circadianOverride: circadianOverride,
      weather: weather,
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

  static const List<String> _biblicalVersesAndPrayers = [
    '«El Señor es mi pastor; nada me faltará. En lugares de delicados pastos me hará descansar.» — Salmos 23:1-2',
    '«Por nada estéis afanosos, sino sean conocidas vuestras peticiones delante de Dios en toda oración y ruego... y la paz de Dios guardará vuestros corazones.» — Filipenses 4:6-7',
    '«Venid a mí todos los que estáis trabajados y cargados, y yo os haré descansar.» — Mateo 11:28',
    '«Mira que te mando que te esfuerces y seas valiente; no temas ni desmayes, porque el Señor tu Dios estará contigo dondequiera que vayas.» — Josué 1:9',
    '«Echando toda vuestra ansiedad sobre Él, porque Él tiene cuidado de vosotros.» — 1 Pedro 5:7',
    '«La paz os dejo, mi paz os doy; yo no os la doy como el mundo la da. No se turbe vuestro corazón, ni tenga miedo.» — Juan 14:27',
    '«Todo lo puedo en Cristo que me fortalece.» — Filipenses 4:13',
    '«Los que esperan a Jehová tendrán nuevas fuerzas; levantarán alas como las águilas; correrán, y no se cansarán.» — Isaías 40:31',
    '«En paz me acostaré, y asimismo dormiré; porque solo tú, Señor, me haces vivir confiado.» — Salmos 4:8',
    '«Dios es nuestro amparo y fortaleza, nuestro pronto auxilio en las tribulaciones.» — Salmos 46:1',
    '«Estad quietos, y conoced que yo soy Dios.» — Salmos 46:10. Respira hondo y reposa en Su amor.',
    '«Con sus plumas te cubrirá, y debajo de sus alas estarás seguro.» — Salmos 91:4',
    '«Clama a mí, y yo te responderé, y te enseñaré cosas grandes y ocultas que tú no conoces.» — Jeremías 33:3',
    '«Fíate de Jehová de todo tu corazón, y no te apoyes en tu propia prudencia.» — Proverbios 3:5',
    '«El Señor te bendiga y te guarde; haga resplandecer su rostro sobre ti y ponga en ti paz.» — Números 6:24-26',
    '«El gozo del Señor es vuestra fuerza.» — Nehemías 8:10. ¡Eres amado y sostenido hoy!',
    '«Este es el día que hizo el Señor; nos gozaremos y alegraremos en él.» — Salmos 118:24',
    '«Porque yo sé los pensamientos que tengo acerca de vosotros, dice el Señor, pensamientos de paz, y no de mal.» — Jeremías 29:11',
  ];

  static const List<String> _peacefulDialogues = [
    'Qué bendición este momento juntos. «El Señor es mi luz y mi salvación; ¿de quién temeré?» — Salmos 27:1',
    'No hay prisa en nuestro rinconcito. Respira a tu ritmo y descansa en la gracia de Dios.',
    'Cuidar de mí es aprender a cuidar del templo que Dios te dio.',
    '«La paz de Dios, que sobrepasa todo entendimiento, guardará vuestro corazón.» — Filipenses 4:7',
    'Mira cómo flotamos suavemente... «Estad quietos, y conoced que yo soy Dios.» — Salmos 46:10',
    'Si hoy solo pudiste respirar, ya es suficiente. Dios renueva tus fuerzas a cada instante.',
    'Me gusta cuando oramos y reposamos juntos en silencio ante el Creador.',
    '«Fíate de Jehová de todo tu corazón.» — Proverbios 3:5. No tienes que controlarlo todo hoy.',
    ..._biblicalVersesAndPrayers,
  ];

  static const List<String> _shelteredDialogues = [
    'Me abracé con mis hojitas para acompañarte. «Con sus plumas te cubrirá, y debajo de sus alas estarás seguro.» — Salmos 91:4',
    'No tienes que fingir que todo está bien. Dios conoce tu corazón y yo me quedo contigo.',
    'A veces el mundo pesa mucho. «Venid a mí... y yo os haré descansar.» — Mateo 11:28',
    'Aquí no hay nada que arreglar ahora mismo. Estás cobijado bajo la gracia divina.',
    '«El que habita al abrigo del Altísimo morará bajo la sombra del Omnipotente.» — Salmos 91:1',
  ];

  static const List<String> _sadDialogues = [
    'Veo que algo pesa en tu corazón. «Cercano está el Señor a los quebrantados de corazón.» — Salmos 34:18',
    'No tienes que estar fuerte todo el tiempo. «Él sana a los quebrantados de corazón, y venda sus heridas.» — Salmos 147:3',
    '«Bienaventurados los que lloran, porque ellos recibirán consolación.» — Mateo 5:4. Aquí estoy contigo.',
    'La tristeza tiene su tiempo, pero el gozo viene por la mañana. Descansa en Su amor.',
    'Oremos en silencio. Dios escucha cada suspiro que las palabras no alcanzan a decir.',
  ];

  static const List<String> _anxiousDialogues = [
    '«Echa sobre el Señor tu carga, y Él te sustentará.» — Salmos 55:22. Respira hondo y entrégaselo.',
    '«Por nada estéis afanosos... la paz de Dios guardará vuestros corazones.» — Filipenses 4:6-7',
    '«No temas, porque yo estoy contigo; no desmayes, porque yo soy tu Dios que te esfuerzo.» — Isaías 41:10',
    '«Cuando en mí la angustia iba en aumento, tu consuelo llenaba mi alma de alegría.» — Salmos 94:19',
    'Pies en el suelo. Dios sostiene este día. La ansiedad miente; Su fidelidad es para siempre.',
  ];

  static const List<String> _celebratingDialogues = [
    '¡Demos gracias a Dios, porque Él es bueno! Cada paso que das es fruto de Su bendición.',
    '«¡Grandes cosas ha hecho el Señor con nosotros; estaremos alegres!» — Salmos 126:3',
    'Una gota más de cuidado y gratitud. Juntos crecemos en fe y constancia.',
    '«El gozo del Señor es vuestra fuerza.» — Nehemías 8:10. ¡Celebremos con un corazón agradecido!',
  ];

  // Diálogos cariñosos y de reacción al acariciar específicos para cada una de las 8 etapas
  static const List<String> _seedPetDialogues = [
    'Siento el calor de tu dedito a través de la tierra tibia...',
    'Un pequeño latido en mi interior... gracias por darme tiempo para brotar.',
    'Aún duermo en mi cascarón, pero tu cariño me nutre de fuerza.',
    'Mmm... qué suave. La tierra está calientita cuando estás aquí.',
  ];

  static const List<String> _sproutPetDialogues = [
    '¡Cosquillas en mis primeros cotiledones! Qué lindo se siente despertar.',
    'Mira cómo me estiro hacia tu luz... ¡gracias por visitarme!',
    'El mundo es tan grande y verde cuando estás a mi lado.',
    '¡Mis hojitas tiemblan de alegría! Salpican rocío para ti.',
  ];

  static const List<String> _seedlingPetDialogues = [
    '¡Mi antena captó tu presencia al instante! ¿Viste mi pirueta?',
    '¡Qué alegría! Dan ganas de dar brincos cada vez que me acaricias.',
    'Estoy creciendo con mucha curiosidad gracias a tus pausas.',
    '¡Bip-bip botánico! Mi antena brilla más cuando estamos juntos.',
  ];

  static const List<String> _youngPlantPetDialogues = [
    'Mis orejitas atentas escuchan tu respiración. Qué bien me hace verte.',
    'Qué ricas caricias. Mis hojas están sanas y verdes por tu constancia.',
    'Juntos somos un equipo invencible de paz interior.',
    'Siento la savia fluir contenta por mis tallos. Gracias por cuidarme.',
    ..._peacefulDialogues,
  ];

  static const List<String> _vibrantPlantPetDialogues = [
    '¡Huele mis flores! Cada pétalo se abrió con un hábito que lograste.',
    'Los pétalos bailan en el aire cuando acaricias mi tallo.',
    'Tu constancia hace florecer rincones que antes estaban secos.',
    '¡Lluvia de aroma y polen dorado para celebrar tu constancia!',
  ];

  static const List<String> _youngTreePetDialogues = [
    'Siente la firmeza de mi tronco... ya puedo darte sombra y calma.',
    'La gema en mi frente vibra con tu serenidad. Nada nos derriba.',
    'Nuestras raíces son profundas. Gracias por regar este árbol cada día.',
    'El viento pasa entre mis ramas fuertes pero no nos mueve.',
  ];

  static const List<String> _adultTreePetDialogues = [
    'La corona ancestral gira en armonía. Respira la paz de los siglos.',
    'En cada mota de luz vive un momento de serenidad que cultivamos.',
    'El bosque susurra tu nombre con gratitud y honor.',
    'Paz inquebrantable. Hemos construido un santuario eterno en tu interior.',
  ];

  static const List<String> _forestSpiritPetDialogues = [
    'Mis alas celestiales te envuelven. Eres el alma y luz de este santuario.',
    'Has trascendido la prisa y el miedo. Gracias por tu luz infinita.',
    'La divinidad de este bosque es el reflejo vivo de tu cuidado personal.',
    'Los tres pares de alas cantan al unísono: estás a salvo, siempre.',
  ];

  static List<String> getStagePetDialogues(LevGrowthStage stage) {
    switch (stage) {
      case LevGrowthStage.seed:
        return _seedPetDialogues;
      case LevGrowthStage.sprout:
        return _sproutPetDialogues;
      case LevGrowthStage.seedling:
        return _seedlingPetDialogues;
      case LevGrowthStage.youngPlant:
        return _youngPlantPetDialogues;
      case LevGrowthStage.vibrantPlant:
        return _vibrantPlantPetDialogues;
      case LevGrowthStage.youngTree:
        return _youngTreePetDialogues;
      case LevGrowthStage.adultTree:
        return _adultTreePetDialogues;
      case LevGrowthStage.forestSpirit:
        return _forestSpiritPetDialogues;
    }
  }

  static String getStageJoyDialogue(LevGrowthStage stage) {
    switch (stage) {
      case LevGrowthStage.seed:
        return '¡Pop! ¡Una semilla feliz que brinca en la tierra!';
      case LevGrowthStage.sprout:
        return '¡Yuuuju! ¡Mira cuánto me estiro hacia el cielo!';
      case LevGrowthStage.seedling:
        return '¡Wooo! ¡Pirueta con la antena en el aire!';
      case LevGrowthStage.youngPlant:
        return '¡Qué alegría me da verte! Salto de energía renovada.';
      case LevGrowthStage.vibrantPlant:
        return '¡Bailan mis flores y pétalos de puro gozo!';
      case LevGrowthStage.youngTree:
        return '¡Fuerza y júbilo! Sentí la sacudida de alegría en mis ramas.';
      case LevGrowthStage.adultTree:
        return '¡El bosque entero celebra tu gran logro!';
      case LevGrowthStage.forestSpirit:
        return '¡Vuelo de luz divina para honrar tu constancia y tu paz!';
    }
  }

  static Future<void> _triggerStageHaptic(LevGrowthStage stage) async {
    switch (stage) {
      case LevGrowthStage.seed:
        await HapticsHelper.selection();
        break;
      case LevGrowthStage.sprout:
      case LevGrowthStage.seedling:
        await HapticsHelper.light();
        break;
      case LevGrowthStage.youngPlant:
      case LevGrowthStage.vibrantPlant:
        await HapticsHelper.medium();
        break;
      case LevGrowthStage.youngTree:
      case LevGrowthStage.adultTree:
        await HapticsHelper.heavy();
        break;
      case LevGrowthStage.forestSpirit:
        await HapticsHelper.heavy();
        await Future.delayed(const Duration(milliseconds: 60));
        await HapticsHelper.light();
        break;
    }
  }

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

  /// Acariciar a Lev con personalidad háptica y dialógica exclusiva por etapa
  Future<void> petLev() async {
    await _triggerStageHaptic(state.growthStage);
    final rand = Random();

    if (state.emotion == LevEmotion.sleeping) {
      state = state.copyWith(
        emotion: LevEmotion.peaceful,
        dialogue: state.growthStage == LevGrowthStage.seed
            ? 'Buenos días... gracias por calentar mi tierra con cariño.'
            : 'Buenos días... gracias por despertarme con cariño.',
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
      final stageDialogues = getStagePetDialogues(state.growthStage);
      newDialogue = stageDialogues[rand.nextInt(stageDialogues.length)];
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

  /// Abrazo protector según la anatomía de cada etapa
  Future<void> hugLev() async {
    await HapticsHelper.medium();
    final String hugText;
    switch (state.growthStage) {
      case LevGrowthStage.seed:
        hugText = 'Aquí estoy contigo, cobijadito tibio para darte calma.';
        break;
      case LevGrowthStage.sprout:
        hugText = 'Mis primeros cotiledones te dan un tierno micro-abrazo.';
        break;
      case LevGrowthStage.forestSpirit:
        hugText = 'Mis tres pares de alas celestiales te cobijan en paz infinita.';
        break;
      default:
        hugText = 'Aquí estoy contigo. Mis hojitas te cubren y te cuidan.';
        break;
    }
    state = state.copyWith(
      emotion: LevEmotion.sheltered,
      dialogue: hugText,
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

  /// Modo de oración y meditación bíblica cristiana con Lev
  Future<void> prayWithLev() async {
    await HapticsHelper.light();
    final rand = Random();
    final verse = _biblicalVersesAndPrayers[rand.nextInt(_biblicalVersesAndPrayers.length)];
    state = state.copyWith(
      emotion: LevEmotion.praying,
      dialogue: verse,
      tapCount: state.tapCount + 1,
      isPetting: false,
    );
  }

  /// Comparte un versículo bíblico reconfortante con su cita
  void shareBiblicalVerse() {
    final rand = Random();
    final verse = _biblicalVersesAndPrayers[rand.nextInt(_biblicalVersesAndPrayers.length)];
    state = state.copyWith(
      dialogue: verse,
      tapCount: state.tapCount + 1,
    );
  }

  /// Salto de alegría con voz exclusiva por etapa
  Future<void> triggerJoyJump() async {
    await HapticsHelper.selection();
    state = state.copyWith(
      emotion: LevEmotion.joyJump,
      dialogue: getStageJoyDialogue(state.growthStage),
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

  /// Al completar un microhábito — otorga +Gotas y +XP, chequea si subió de etapa
  Future<void> onHabitCompleted(String habitId) async {
    final prevStage = state.growthStage;
    await LocalStorageService.incrementCompletedHabits(habitId);
    await LocalStorageService.addExperiencePoints(25); // +25 XP botánica por hábito
    final drops = LocalStorageService.getCareDrops();
    final xp = LocalStorageService.getExperiencePoints();
    final completed = LocalStorageService.getCompletedHabitsCount();
    final flowers = 3 + min<int>(completed, 15);

    await HapticsHelper.medium();

    // Detectar si subió de etapa según XP
    final tempState = state.copyWith(careDrops: drops, experiencePoints: xp);
    final newStage = tempState.growthStage;
    final justLeveledUp = newStage.index > prevStage.index;

    final rand = Random();
    final celebrationQuote = justLeveledUp
        ? _getLevelUpDialogue(newStage)
        : _celebratingDialogues[rand.nextInt(_celebratingDialogues.length)];

    if (justLeveledUp) {
      ref.read(sanctuaryAudioProvider.notifier).playChimeSfx();
    }

    state = state.copyWith(
      careDrops: drops,
      experiencePoints: xp,
      bloomingFlowers: flowers,
      emotion: LevEmotion.celebrating,
      dialogue: celebrationQuote,
      tapCount: state.tapCount + 1,
      justLeveledUp: justLeveledUp,
      pendingEvolutionStage: justLeveledUp ? newStage : null,
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

  /// Regar a Lev con una gota de rocío — Cuidado directo y vínculo botánico
  Future<bool> waterLev() async {
    if (state.careDrops < 1) {
      await HapticsHelper.light();
      state = state.copyWith(
        dialogue: 'Necesitas al menos 1 gota de rocío para regarme. ¡Completa una pausa consciente!',
        emotion: LevEmotion.curious,
      );
      return false;
    }

    final prevStage = state.growthStage;
    await LocalStorageService.addCareDrops(-1);
    await LocalStorageService.addExperiencePoints(15); // +15 XP por riego amoroso
    final drops = LocalStorageService.getCareDrops();
    final xp = LocalStorageService.getExperiencePoints();

    await HapticsHelper.medium();
    ref.read(sanctuaryAudioProvider.notifier).playWaterDropSfx();

    final tempState = state.copyWith(careDrops: drops, experiencePoints: xp);
    final newStage = tempState.growthStage;
    final justLeveledUp = newStage.index > prevStage.index;

    if (justLeveledUp) {
      ref.read(sanctuaryAudioProvider.notifier).playChimeSfx();
    }

    final waterDialogues = [
      '¡Qué fresca se siente el agua! Siento mis hojas llenas de luz.',
      '¡Glup! Una gota de amor puro. Gracias por cuidar de mí.',
      'Siento la savia corriendo... florecemos juntos a cada paso.',
      'El rocío me llena de energía. ¡Mira cómo brillo!',
    ];
    final quote = waterDialogues[Random().nextInt(waterDialogues.length)];

    state = state.copyWith(
      careDrops: drops,
      experiencePoints: xp,
      emotion: LevEmotion.celebrating,
      isWatering: true,
      dialogue: quote,
      justLeveledUp: justLeveledUp,
      pendingEvolutionStage: justLeveledUp ? newStage : null,
    );

    Future.delayed(const Duration(milliseconds: 2400), () {
      try {
        state = state.copyWith(
          isWatering: false,
          emotion: LevEmotion.happy,
        );
      } catch (_) {}
    });

    return true;
  }

  /// Chequeo diario matutino / primera apertura del día
  Future<Map<String, dynamic>?> checkDailyGreeting() async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDate = LocalStorageService.getLastDailyGreetingDate();

    if (lastDate == todayStr) {
      return null; // Ya saludó hoy
    }

    await LocalStorageService.setLastDailyGreetingDate(todayStr);
    await LocalStorageService.addCareDrops(1); // Regalo de 1 gota de cortesía diaria
    final drops = LocalStorageService.getCareDrops();

    await HapticsHelper.light();
    ref.read(sanctuaryAudioProvider.notifier).playWaterDropSfx();

    String greetingTitle;
    String greetingBody;
    final time = _calculateTimeOfDay();

    switch (time) {
      case SanctuaryTimeOfDay.morning:
        greetingTitle = '¡Buenos días en el Santuario!';
        greetingBody = 'El sol despierta entre los nenúfares. Te obsequio esta gota de rocío matutina para comenzar con calma.';
        break;
      case SanctuaryTimeOfDay.afternoon:
        greetingTitle = '¡Buenas tardes!';
        greetingBody = 'Qué lindo verte por aquí. Tómate un segundo para soltar la prisa y recibe tu gota de rocío de hoy.';
        break;
      case SanctuaryTimeOfDay.dusk:
        greetingTitle = '¡Hermoso atardecer!';
        greetingBody = 'El día va cayendo suavemente. Lev te espera con una gota de rocío para acompañar tu descanso.';
        break;
      case SanctuaryTimeOfDay.night:
        greetingTitle = 'Noche estrellada en el estanque';
        greetingBody = 'Gracias por estar aquí antes de dormir. Que esta gota de rocío y el silencio te traigan paz.';
        break;
    }

    state = state.copyWith(
      careDrops: drops,
      emotion: LevEmotion.happy,
      dialogue: greetingBody,
    );

    return {
      'title': greetingTitle,
      'body': greetingBody,
      'rewardDrops': 1,
    };
  }

  /// Cambiar clima del santuario
  Future<void> setWeather(SanctuaryWeather weather) async {
    await LocalStorageService.setSanctuaryWeather(weather.id);
    await HapticsHelper.selection();
    state = state.copyWith(weather: weather);
  }

  /// Limpiar estado de evolución pendiente tras mostrar la ceremonia
  void clearPendingEvolution() {
    state = state.copyWith(clearPendingEvolution: true);
  }

  /// Desbloquear un elemento del entorno usando Gotas de Cuidado
  Future<bool> unlockDecor(SanctuaryDecorItem item) async {
    if (state.unlockedDecors.contains(item)) return true;
    if (state.careDrops < item.dropCost) {
      await HapticsHelper.light();
      return false;
    }

    final newDrops = state.careDrops - item.dropCost;
    await LocalStorageService.saveCareDropsRaw(newDrops);

    final updatedUnlocked = {...state.unlockedDecors, item};
    final updatedActive = {...state.activeDecors, item};

    await LocalStorageService.saveUnlockedDecorIds(
      updatedUnlocked.map((e) => e.id).toList(),
    );
    await LocalStorageService.saveActiveDecorIds(
      updatedActive.map((e) => e.id).toList(),
    );

    await HapticsHelper.medium();

    state = state.copyWith(
      careDrops: newDrops,
      unlockedDecors: updatedUnlocked,
      activeDecors: updatedActive,
      emotion: LevEmotion.celebrating,
      dialogue: '¡Qué hermoso! Desbloqueamos "${item.name}". Nuestro santuario se siente aún más vivo.',
    );
    return true;
  }

  /// Activar o desactivar un elemento decorativo ya desbloqueado
  Future<void> toggleDecor(SanctuaryDecorItem item) async {
    if (!state.unlockedDecors.contains(item)) return;

    final updatedActive = Set<SanctuaryDecorItem>.from(state.activeDecors);
    final isNowActive = !updatedActive.contains(item);
    if (isNowActive) {
      updatedActive.add(item);
    } else {
      updatedActive.remove(item);
    }

    await LocalStorageService.saveActiveDecorIds(
      updatedActive.map((e) => e.id).toList(),
    );

    await HapticsHelper.light();

    state = state.copyWith(
      activeDecors: updatedActive,
      dialogue: isNowActive
          ? 'Colocamos "${item.name}" en nuestro rinconcito.'
          : 'Guardamos "${item.name}" por ahora.',
    );
  }

  /// Establecer la posición normalizada (0.0-1.0) de un objeto decorativo libremente
  Future<void> setDecorPosition(SanctuaryDecorItem item, Offset normalizedOffset) async {
    final clampedPos = Offset(
      normalizedOffset.dx.clamp(0.06, 0.94),
      normalizedOffset.dy.clamp(0.08, 0.93),
    );

    final updated = Map<SanctuaryDecorItem, Offset>.from(state.customDecorPositions);
    updated[item] = clampedPos;

    state = state.copyWith(customDecorPositions: updated);

    final raw = <String, List<double>>{};
    updated.forEach((k, v) {
      raw[k.id] = [v.dx, v.dy];
    });
    await LocalStorageService.saveDecorPositionsRaw(raw);
  }

  /// Restablecer la ubicación de todos los objetos decorativos a sus coordenadas estéticas por defecto
  Future<void> resetDecorPositions() async {
    await LocalStorageService.resetDecorPositions();
    await HapticsHelper.light();
    state = state.copyWith(customDecorPositions: {});
  }

  /// Desbloquear un accesorio botánico para vestir a Lev con Gotas de Cuidado
  Future<bool> unlockAccessory(LevAccessory accessory) async {
    if (state.unlockedAccessories.contains(accessory)) {
      await equipAccessory(accessory);
      return true;
    }
    if (state.careDrops < accessory.dropCost) return false;

    final newDrops = state.careDrops - accessory.dropCost;
    final newUnlocked = Set<LevAccessory>.from(state.unlockedAccessories)..add(accessory);

    await LocalStorageService.saveCareDropsRaw(newDrops);
    await LocalStorageService.saveUnlockedAccessoryIds(newUnlocked.map((a) => a.id).toList());
    await LocalStorageService.saveActiveAccessoryId(accessory.id);

    await HapticsHelper.medium();

    state = state.copyWith(
      careDrops: newDrops,
      unlockedAccessories: newUnlocked,
      activeAccessory: accessory,
      emotion: LevEmotion.celebrating,
      dialogue: '¡Me encanta este nuevo detalle! Gracias por cuidarme 🌿',
    );
    return true;
  }

  /// Equipar o desequipar un accesorio ya desbloqueado
  Future<void> equipAccessory(LevAccessory accessory) async {
    if (!state.unlockedAccessories.contains(accessory)) return;
    await HapticsHelper.selection();
    final newAccessory = state.activeAccessory == accessory ? LevAccessory.none : accessory;
    await LocalStorageService.saveActiveAccessoryId(newAccessory.id);
    state = state.copyWith(
      activeAccessory: newAccessory,
      dialogue: newAccessory == LevAccessory.none
          ? 'Lev vuelve a su estado natural.'
          : '¡Qué lindo me veo con "${newAccessory.name}"!',
    );
  }

  /// Cambiar manualmente la atmósfera circadiana del Santuario (o volver a auto)
  Future<void> setCircadianOverride(SanctuaryTimeOfDay? override) async {
    await HapticsHelper.selection();
    if (override == null) {
      await LocalStorageService.saveCircadianOverride(null);
      state = state.copyWith(
        clearCircadianOverride: true,
        dialogue: 'Sincronizado con la hora natural de tu entorno.',
      );
    } else {
      await LocalStorageService.saveCircadianOverride(override.name);
      state = state.copyWith(
        circadianOverride: override,
        dialogue: override == SanctuaryTimeOfDay.night
            ? 'Modo noche profundo activado: descansamos bajo las estrellas.'
            : 'Atmósfera ajustada con calma.',
      );
    }
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
    state = state.copyWith(careDrops: drops);
  }

  Future<void> setExperiencePoints(int xp) async {
    await LocalStorageService.saveExperiencePointsRaw(xp);
    final prevStage = state.growthStage;
    final tempState = state.copyWith(experiencePoints: xp);
    final newStage = tempState.growthStage;
    final justLeveledUp = newStage.index != prevStage.index;

    state = state.copyWith(
      experiencePoints: xp,
      justLeveledUp: justLeveledUp,
      dialogue: justLeveledUp ? _getLevelUpDialogue(newStage) : state.dialogue,
    );
  }

  Future<void> setStage(LevGrowthStage stage) async {
    final minXp = switch (stage) {
      LevGrowthStage.seed => 0,
      LevGrowthStage.sprout => 50,
      LevGrowthStage.seedling => 100,
      LevGrowthStage.youngPlant => 200,
      LevGrowthStage.vibrantPlant => 350,
      LevGrowthStage.youngTree => 550,
      LevGrowthStage.adultTree => 800,
      LevGrowthStage.forestSpirit => 1200,
    };
    await setExperiencePoints(minXp);
  }

  /// Restablecer todo a cero absoluto (Semilla)
  Future<void> resetAllToZero() async {
    await LocalStorageService.saveCareDropsRaw(0);
    await LocalStorageService.saveExperiencePointsRaw(0);
    await LocalStorageService.saveUnlockedDecorIds([]);
    await LocalStorageService.saveActiveDecorIds([]);
    await LocalStorageService.resetDecorPositions();
    await LocalStorageService.saveActiveAccessoryId(LevAccessory.none.id);
    await LocalStorageService.saveUnlockedAccessoryIds([LevAccessory.none.id]);
    await HapticsHelper.medium();

    state = state.copyWith(
      careDrops: 0,
      experiencePoints: 0,
      unlockedDecors: {},
      activeDecors: {},
      customDecorPositions: {},
      activeAccessory: LevAccessory.none,
      unlockedAccessories: {LevAccessory.none},
      emotion: LevEmotion.peaceful,
      dialogue: 'Comenzamos desde cero. Como una pequeña semilla llena de vida y serenidad.',
    );
  }
}

final sanctuaryProvider =
    NotifierProvider<SanctuaryController, SanctuaryState>(
  SanctuaryController.new,
);
