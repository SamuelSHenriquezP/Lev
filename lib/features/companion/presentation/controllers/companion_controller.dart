import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/companion/domain/chat_message.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

class CompanionState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const CompanionState({
    required this.messages,
    this.isTyping = false,
  });

  CompanionState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return CompanionState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class CompanionController extends Notifier<CompanionState> {
  static CompanionState _buildInitialState() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Buenos días, humano. El agua está tibia hoy. ¿Cómo amanece tu cuerpo?';
    } else if (hour >= 12 && hour < 19) {
      greeting = 'Hola humano, noté que llevas un día activo. ¿Me dejas acompañarte 1 minuto?';
    } else {
      greeting = 'Buenas noches. Ya es momento de bajar el ritmo. ¿Cómo te sientes antes de descansar?';
    }

    final initialMessage = ChatMessage(
      id: 'init_0',
      text: greeting,
      isFromLev: true,
      timestamp: DateTime.now(),
      quickReplies: const [
        'Me siento abrumado',
        'Mucho TikTok/procrastinando',
        'No puedo dormir',
        'Bloqueo para empezar',
        'Triste o solo',
        'Solo pasaba a verte',
      ],
    );

    return CompanionState(messages: [initialMessage]);
  }

  @override
  CompanionState build() {
    return _buildInitialState();
  }

  Future<void> sendUserMessage(String text) async {
    await HapticsHelper.light();

    final userMsg = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isFromLev: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    // Simular escritura reflexiva de Lev
    await Future.delayed(const Duration(milliseconds: 850));

    final reply = _generateLevResponse(text);

    state = state.copyWith(
      messages: [...state.messages, reply],
      isTyping: false,
    );
  }

  ChatMessage _generateLevResponse(String text) {
    final lower = text.toLowerCase();
    String levReply;
    MicroHabit? habit;
    List<String> nextReplies = ['Hacer la pausa (60s)', 'Prefiero solo charlar', 'Gracias, Lev 💛'];

    if (lower.contains('dormir') || lower.contains('insomnio') || lower.contains('desvelo') || lower.contains('no puedo dormir')) {
      ref.read(sanctuaryProvider.notifier).putToSleep();
      levReply =
          'La noche es el momento en que la mente intenta resolver lo que el cuerpo ya no puede sostener. Es normal que te sientas inquieto.\n\nEntrégale tus preocupaciones a las aguas de mi estanque. No tienes que forzarte a dormir de golpe; solo dejemos que tus párpados pesen un poco.';
      habit = HabitsDatabase.getById('slp_01');
      nextReplies = ['Pesadez de párpados (60s)', 'Soltar el día en el agua', 'Respiración 4-7-8'];
    } else if (lower.contains('bloqueo') || lower.contains('parálisis') || lower.contains('procrastin') || lower.contains('empezar')) {
      ref.read(sanctuaryProvider.notifier).setPeacefulState();
      levReply =
          'La parálisis ante una tarea no es pereza ni falta de fuerza de voluntad; es tu sistema nervioso sintiendo que la tarea es una amenaza abrumadora.\n\nNo tenemos que escalar la montaña entera hoy. Vamos a dar un micro-paso de 10 segundos exactos juntos.';
      habit = HabitsDatabase.getById('blk_01');
      nextReplies = ['Hacer micro-paso de 10s', 'Despertar con agua fría', 'Respirar y estirar'];
    } else if (lower.contains('culpa') || lower.contains('inútil') || lower.contains('autocrítica') || lower.contains('todo lo hago mal') || lower.contains('impostor')) {
      ref.read(sanctuaryProvider.notifier).setShelteredState();
      levReply =
          'Esa voz crítica que tienes adentro está asustada e intenta protegerte de la peor manera posible: castigándote.\n\nPero nadie sana a través de la dureza. Yo te miro con ternura. ¿Probamos una caricia suave en la nuca para calmar a ese niño interno?';
      habit = HabitsDatabase.getById('crt_01');
      nextReplies = ['Tacto calmante en la nuca', 'Agradecer a la mente (ACT)', 'Verdades de un amigo'];
    } else if (lower.contains('abrumado') || lower.contains('ansiedad') || lower.contains('pánico') || lower.contains('angustia')) {
      ref.read(sanctuaryProvider.notifier).startBreathing();
      levReply =
          'Es comprensible que te sientas así. Cuando todo parece demasiado, tu cuerpo intenta protegerte acelerando. No tienes que resolver tu vida en este instante.\n\n¿Me dejas guiarte con 3 respiraciones exactas para darle una señal de seguridad a tu corazón?';
      habit = HabitsDatabase.getById('anx_01');
      nextReplies = ['Comenzar el Suspiro (60s)', 'Quiero intentar anclarme (3-2-1)', 'Mano al pecho'];
    } else if (lower.contains('tiktok') || lower.contains('scroll') || lower.contains('pantalla') || lower.contains('reels')) {
      ref.read(sanctuaryProvider.notifier).setPeacefulState();
      levReply =
          'Las pantallas están diseñadas para atrapar tu atención con dopamina artificial. No eres culpable ni débil por haber caído en el bucle.\n\nPero tus ojitos y tu cuello merecen un respiro real de 60 segundos. Miremos juntos hacia el infinito.';
      habit = HabitsDatabase.getById('doom_01');
      nextReplies = ['Probar Regla 20-20-20', 'Palming ocular cálido', 'Chequeo de realidad'];
    } else if (lower.contains('triste') || lower.contains('soledad') || lower.contains('solo') || lower.contains('desgano') || lower.contains('bajón') || lower.contains('llorar')) {
      ref.read(sanctuaryProvider.notifier).setShelteredState();
      levReply =
          'La tristeza a veces llega como la neblina sobre el estanque: suave, densa y sin pedir permiso. No tienes que forzarte a estar alegre hoy.\n\nYo me quedo contigo bajo la hojita. ¿Probamos un abrazo de presión suave para darte contención física?';
      habit = HabitsDatabase.getById('sad_01');
      nextReplies = ['Abrazo de presión suave', 'Abrazo de la mariposa', 'Taza caliente imaginaria'];
    } else if (lower.contains('enojo') || lower.contains('rabia') || lower.contains('frustra') || lower.contains('molest') || lower.contains('ira')) {
      ref.read(sanctuaryProvider.notifier).startBreathing();
      levReply =
          'La frustración es energía que busca salir. No es mala; solo necesita un canal seguro para no quemarte por dentro.\n\nVamos a descargar esa tensión de tus puños y hombros con la técnica de Jacobson en 60 segundos.';
      habit = HabitsDatabase.getById('ang_01');
      nextReplies = ['Descargar tensión ahora', 'Sacudida de extremidades', 'Respiración de enfriamiento'];
    } else if (lower.contains('verte') || lower.contains('hola') || lower.contains('saludar')) {
      ref.read(sanctuaryProvider.notifier).setPeacefulState();
      levReply =
          '¡Qué bonito que pases a visitarme! El estanque se siente más cálido contigo.\n\nSi te apetece, podemos hacer un chequeo físico rápido para sentir la tierra bajo nuestros pies y volver al presente.';
      habit = HabitsDatabase.getById('doom_02');
      nextReplies = ['Hacer chequeo de realidad', '¿Cómo estás tú, Lev?', 'Solo quería saludarte'];
    } else if (lower.contains('gracias') || lower.contains('hecho') || lower.contains('mejor')) {
      ref.read(sanctuaryProvider.notifier).triggerJoyJump();
      levReply =
          'Gracias a ti por concederte este minuto de compasión. Cada pequeña pausa es una semilla que florece en tu bienestar. Siempre estaré aquí cuando lo necesites.';
      nextReplies = ['Me siento abrumado', 'Mucho TikTok/procrastinando', 'No puedo dormir', 'Ir al estanque'];
    } else {
      ref.read(sanctuaryProvider.notifier).setPeacefulState();
      levReply =
          'Te escucho con todo mi corazón. No tienes que guardar las cosas solo para ti. ¿Te gustaría regalarte una micro-pausa de 60 segundos para conectar con tu respiración?';
      habit = HabitsDatabase.getRandomHabit();
      nextReplies = ['Hagamos 60s juntos', 'Contarte un poco más', 'Ir al diario TCC'];
    }

    return ChatMessage(
      id: 'lev_${DateTime.now().millisecondsSinceEpoch}',
      text: levReply,
      isFromLev: true,
      timestamp: DateTime.now(),
      quickReplies: nextReplies,
      recommendedHabit: habit,
    );
  }
}

final companionProvider =
    NotifierProvider<CompanionController, CompanionState>(
  CompanionController.new,
);
