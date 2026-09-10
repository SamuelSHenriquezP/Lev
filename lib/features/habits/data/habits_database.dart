import 'dart:math';
import '../domain/micro_habit.dart';

/// Base de datos clínica y somática de microhábitos de 60 segundos clasificados por emociones.
/// Cada hábito tiene un tipo de interacción dinámico que activa un widget específico.
class HabitsDatabase {
  static const List<HabitCategoryInfo> categories = [
    HabitCategoryInfo(
      name: 'Doomscrolling / Sobrecarga Digital',
      shortName: 'Pantallas',
      emoji: '📱',
      description: 'Pausas visuales, posturales y propioceptivas para cortar el bucle de dopamina rápida.',
    ),
    HabitCategoryInfo(
      name: 'Ansiedad / Ataque de Pánico / Agobio',
      shortName: 'Ansiedad',
      emoji: '🌊',
      description: 'Activación del nervio vago y anclaje sensorial para devolver el cuerpo al presente.',
    ),
    HabitCategoryInfo(
      name: 'Tristeza / Soledad / Desgano',
      shortName: 'Tristeza',
      emoji: '🕯️',
      description: 'Autocompasión somática, liberación de oxitocina y abrigo emocional sin exigencias.',
    ),
    HabitCategoryInfo(
      name: 'Frustración / Enojo / Irritabilidad',
      shortName: 'Enojo',
      emoji: '⚡',
      description: 'Descarga muscular controlada, drenaje de adrenalina y enfriamiento térmico.',
    ),
    HabitCategoryInfo(
      name: 'Insomnio / Rumiación Nocturna',
      shortName: 'Insomnio',
      emoji: '🌙',
      description: 'Pesadez ocular, soltar pensamientos en el agua y desactivación de ondas beta antes de dormir.',
    ),
    HabitCategoryInfo(
      name: 'Culpa / Autocrítica / Impostor',
      shortName: 'Autocrítica',
      emoji: '🪞',
      description: 'Defusión cognitiva de ACT, tacto C-táctil y perspectiva del amigo compasivo.',
    ),
    HabitCategoryInfo(
      name: 'Bloqueo / Procrastinación / Parálisis TDAH',
      shortName: 'Bloqueo',
      emoji: '🧱',
      description: 'Micro-paso motor de fricción cero para romper la inercia sin sobrecarga ejecutiva.',
    ),
  ];

  static final List<MicroHabit> allHabits = [
    // ----------------------------------------------------
    // 1. DOOMSCROLLING & SOBRECARGA DIGITAL
    // ----------------------------------------------------
    const MicroHabit(
      id: 'doom_01',
      title: 'La Mirada al Infinito (20-20-20)',
      levIntro: 'Tus ojos necesitan descansar de tanta luz azul. Miremos lejos juntos.',
      steps: [
        'Despega la vista de la pantalla ahora mismo.',
        'Busca el punto más lejano que veas por la ventana o tu habitación.',
        'Parpadea 5 veces muy suavemente y siente tus párpados hidratarse.',
      ],
      psychologicalBasis: 'Relajación del músculo ciliar y corte inmediato del bucle dopaminérgico visual.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '👁️',
      tags: ['ojos', 'pantalla', 'luz azul', 'scroll', 'visión'],
      interactionType: HabitInteractionType.eyeTracker,
    ),
    const MicroHabit(
      id: 'doom_02',
      title: 'El Chequeo Físico de Realidad',
      levIntro: 'Regresemos a este mundo por un momento. Siente tu cuerpo conmigo.',
      steps: [
        'Coloca ambos pies planos sobre el suelo firme.',
        'Siente el peso de tu espalda contra la silla o cama.',
        'Haz 1 inhalación profunda sintiendo el aire en tu nariz.',
      ],
      psychologicalBasis: 'Grounding somático para desactivar la disociación y el trance de pantalla.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '🦶',
      tags: ['cuerpo', 'pies', 'postura', 'realidad', 'grounding'],
      interactionType: HabitInteractionType.gestureInput,
    ),
    const MicroHabit(
      id: 'doom_03',
      title: 'Palming Ocular Térmico',
      levIntro: 'Vamos a darle una noche oscura y tibia a tus ojos cansados.',
      steps: [
        'Frota las palmas rápidamente hasta sentir calor agradable.',
        'Coloca las palmas ahuecadas sobre tus ojos cerrados sin presionar.',
        'Respira en esa oscuridad cálida durante 40 segundos, soltando el ceño.',
      ],
      psychologicalBasis: 'Desactivación de fotorreceptores hiperestimulados y vasodilatación ocular.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '🤲',
      tags: ['ojos', 'oscuridad', 'calor', 'manos', 'descanso'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'doom_04',
      title: 'Apertura de Pecho Anti-Encorvamiento',
      levIntro: 'Tu cuerpo se dobló mirando el móvil. Abramos espacio para tus pulmones.',
      steps: [
        'Entrelaza los dedos detrás de tu nuca o espalda baja.',
        'Lleva los codos hacia atrás abriendo el pecho hacia arriba.',
        'Toma 3 respiraciones profundas sintiendo tu diafragma estirarse.',
      ],
      psychologicalBasis: 'Inversión de postura de sumisión digital y descompresión del nervio frénico.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '🌿',
      tags: ['postura', 'cuello', 'pecho', 'espalda', 'estiramiento'],
      interactionType: HabitInteractionType.breathGuided,
    ),

    // ----------------------------------------------------
    // 2. ANSIEDAD, PÁNICO & AGOBIO
    // ----------------------------------------------------
    const MicroHabit(
      id: 'anx_01',
      title: 'El Suspiro Fisiológico Guiado',
      levIntro: 'Vamos a calmar tu sistema nervioso en 3 respiraciones exactas.',
      steps: [
        'Inhala profundo por la nariz (2 segundos).',
        'Inhala un extra de aire encima sin soltar (1 segundo).',
        'Exhala todo el aire por la boca con un suspiro largo (5 segundos).',
        'Repítelo 4 veces a mi ritmo suave.',
      ],
      psychologicalBasis: 'Apertura de alvéolos colapsados y activación inmediata del nervio vago.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '🫁',
      tags: ['respiración', 'vago', 'corazón', 'pánico', 'suspiro'],
      interactionType: HabitInteractionType.breathGuided,
    ),
    const MicroHabit(
      id: 'anx_02',
      title: 'Anclaje 3-2-1 con Lev',
      levIntro: 'Tu mente viaja al futuro, pero tú estás a salvo aquí. Busquemos juntos:',
      steps: [
        'Nombra 3 cosas que veas a tu alrededor ahora mismo.',
        'Toca 2 texturas diferentes (tu ropa, una mesa o tus dedos).',
        'Identifica 1 sonido de fondo en este instante.',
      ],
      psychologicalBasis: 'Redirección atencional de la amígdala hacia la corteza sensorial prefrontal.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '🎯',
      tags: ['anclaje', 'sentidos', 'mente', 'presente', 'grounding'],
      interactionType: HabitInteractionType.gestureInput,
    ),
    const MicroHabit(
      id: 'anx_03',
      title: 'Mano al Esternón con Pulso Somático',
      levIntro: 'Siente la vida dentro de ti. No tienes que huir de este momento.',
      steps: [
        'Coloca la palma abierta sobre el centro de tu pecho.',
        'Aplica una presión suave pero firme, sintiendo el calor de tu piel.',
        'Sincroniza las inhalaciones con tu latido, repitiendo: "Estoy aquí, estoy a salvo".',
      ],
      psychologicalBasis: 'Biofeedback háptico del eje neurocardíaco que reduce la taquicardia por ansiedad.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '💗',
      tags: ['pecho', 'corazón', 'tacto', 'calma', 'somática'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'anx_04',
      title: 'Exhalación con Labios Fruncidos',
      levIntro: 'Vamos a soplar despacito, como enfriando una sopita caliente.',
      steps: [
        'Inhala normal por la nariz contando 1... 2.',
        'Coloca los labios como si fueras a silbar o soplar una vela sin apagarla.',
        'Exhala un hilo de aire muy delgado durante 6 a 8 segundos.',
      ],
      psychologicalBasis: 'Creación de presión espiratoria positiva (PEEP) que desacelera la frecuencia cardíaca.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '🎐',
      tags: ['respiración', 'soplo', 'labios', 'calma', 'ansiedad'],
      interactionType: HabitInteractionType.countingBreath,
    ),

    // ----------------------------------------------------
    // 3. TRISTEZA, SOLEDAD & DESGANO
    // ----------------------------------------------------
    const MicroHabit(
      id: 'sad_01',
      title: 'El Abrazo de Presión Firme',
      levIntro: 'Hoy no tienes que ser fuerte para nadie. Yo te acompaño.',
      steps: [
        'Cruza los brazos sobre tu pecho, agarrando tus hombros con fuerza media.',
        'Aplica una presión suave y sostenida como si te arroparas a ti mismo.',
        'Cierra los ojos y haz 3 respiraciones lentas sintiendo tu propio calor.',
      ],
      psychologicalBasis: 'Estimulación propioceptiva profunda y liberación de oxitocina mediante autocompasión táctil.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '🫂',
      tags: ['abrazo', 'calor', 'tristeza', 'autocompasión', 'soledad'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'sad_02',
      title: 'Luz Solar en los Párpados',
      levIntro: 'Vamos a buscar un rayito de claridad para Lev y para ti.',
      steps: [
        'Acércate a una ventana o sal al aire libre.',
        'Cierra los ojos y orienta el rostro hacia la luminosidad del cielo.',
        'Deja que la luz y el aire tibio toquen tu piel durante 45 segundos en silencio.',
      ],
      psychologicalBasis: 'Ajuste circadiano y estimulación de serotonina por células ganglionares fotosensibles.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '☀️',
      tags: ['sol', 'luz', 'ánimo', 'serotonina', 'claridad'],
      interactionType: HabitInteractionType.timer,
    ),
    const MicroHabit(
      id: 'sad_03',
      title: 'El Abrazo de la Mariposa (EMDR Suave)',
      levIntro: 'Acompañemos a ese dolor con un aleteo compasivo.',
      steps: [
        'Cruza las manos sobre el pecho enganchando los pulgares como alas de mariposa.',
        'Da golpecitos rítmicos y suaves en tus clavículas: izquierda... derecha... izquierda.',
        'Mantén el ritmo mientras dejas que cualquier emoción fluya sin retenerla.',
      ],
      psychologicalBasis: 'Estimulación bilateral táctil de baja frecuencia para procesar cargas afectivas densas.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '🦋',
      tags: ['mariposa', 'emdr', 'llanto', 'soledad', 'alivio'],
      interactionType: HabitInteractionType.bilateralTap,
    ),
    const MicroHabit(
      id: 'sad_04',
      title: 'La Taza Caliente Imaginaria',
      levIntro: 'Vamos a calentar tus manos y tu centro con una bebida tibia.',
      steps: [
        'Junta las manos en forma de cuenco frente a tu pecho.',
        'Imagina sostener una taza humeante de té de manzanilla.',
        'Inhala el aroma suave imaginario y exhala dejando caer los hombros.',
      ],
      psychologicalBasis: 'Regulación térmica y efecto parasimpático mediante sugestión somatosensorial cálida.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '🍵',
      tags: ['té', 'calor', 'imaginación', 'confort', 'pesadumbre'],
      interactionType: HabitInteractionType.holdPressure,
    ),

    // ----------------------------------------------------
    // 4. FRUSTRACIÓN, RABIA & ENOJO
    // ----------------------------------------------------
    const MicroHabit(
      id: 'ang_01',
      title: 'Tensión y Soltura Relámpago (Jacobson)',
      levIntro: 'Ese enojo está acumulado en tus músculos. Vamos a descargarlo.',
      steps: [
        'Aprieta puños, hombros y dientes con fuerza durante 6 segundos. ¡Fuerte!',
        'Suelta todo de golpe, abriendo las manos y exhalando con fuerza por la boca.',
        'Siente el cosquilleo de la relajación. Repítelo 2 veces más.',
      ],
      psychologicalBasis: 'Relajación Muscular Progresiva (RMP) que drena el exceso de adrenalina acumulada.',
      category: 'Frustración / Enojo / Irritabilidad',
      iconEmoji: '⚡',
      tags: ['tensión', 'enojo', 'músculos', 'jacobson', 'descarga'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'ang_02',
      title: 'Sacudida Somática de Extremidades',
      levIntro: 'Los animalitos tiemblan para liberar tensión. Hagámoslo.',
      steps: [
        'Sacude manos y muñecas como si tuvieran gotas de agua.',
        'Suelta los hombros y da pequeños rebotes con los talones.',
        'Haz un suspiro audible mientras sacudes los brazos durante 30 segundos.',
      ],
      psychologicalBasis: 'Terminación del ciclo de estrés motriz (tremoring neurogénico) post-frustración.',
      category: 'Frustración / Enojo / Irritabilidad',
      iconEmoji: '🐾',
      tags: ['sacudida', 'estrés', 'movimiento', 'rabia', 'adrenalina'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'ang_03',
      title: 'Respiración de Enfriamiento (Sitali)',
      levIntro: 'Vamos a bajar la temperatura interna de esa molestia.',
      steps: [
        'Inhala aire lentamente por la boca haciendo un tubito con la lengua.',
        'Siente cómo el aire fresco acaricia tu garganta y pecho.',
        'Cierra la boca y exhala aire tibio por la nariz lentamente.',
      ],
      psychologicalBasis: 'Disminución térmica de mucosas orales que envía señal hipotérmica tranquilizante.',
      category: 'Frustración / Enojo / Irritabilidad',
      iconEmoji: '❄️',
      tags: ['enfriamiento', 'respiración', 'enojo', 'calor', 'paciencia'],
      interactionType: HabitInteractionType.breathGuided,
    ),

    // ----------------------------------------------------
    // 5. INSOMNIO, CANSANCIO & RUMIACIÓN NOCTURNA
    // ----------------------------------------------------
    const MicroHabit(
      id: 'slp_01',
      title: 'Pesadez Progresiva de Párpados',
      levIntro: 'El día ya terminó. La noche es tu espacio seguro para descansar.',
      steps: [
        'Acuéstate o recuéstate cómodamente y cierra los ojos suavemente.',
        'Enfoca la atención en tus párpados; imagínalos hechos de plomo tibio.',
        'A cada exhalación, siente que pesan el doble y no hay nada que mirar.',
      ],
      psychologicalBasis: 'Inducción de ondas cerebrales Alfa y reducción del tono simpático en nervios craneales.',
      category: 'Insomnio / Rumiación Nocturna',
      iconEmoji: '🌙',
      tags: ['dormir', 'noche', 'insomnio', 'ojos', 'descanso'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'slp_02',
      title: 'Soltar el Día en las Aguas de Lev',
      levIntro: 'Entrégale a mi estanque lo que hoy no se pudo resolver.',
      steps: [
        'Piensa en la preocupación que no te deja dormir como una hojita seca.',
        'Visualiza cómo la colocas en el agua tibia junto a mí; el arroyo se la lleva.',
        'Dite: "Mañana me ocuparé; esta noche solo me pertenece descansar".',
      ],
      psychologicalBasis: 'Técnica de defusión y clausura cognitiva para frenar la rumiación pre-sueño.',
      category: 'Insomnio / Rumiación Nocturna',
      iconEmoji: '🌊',
      tags: ['dormir', 'rumiación', 'pensamientos', 'noche', 'paz'],
      interactionType: HabitInteractionType.gestureInput,
    ),
    const MicroHabit(
      id: 'slp_03',
      title: 'Respiración 4-7-8 Relámpago',
      levIntro: 'Ralenticemos el pulso para invitar a los sueños.',
      steps: [
        'Inhala silenciosamente por la nariz contando hasta 4.',
        'Sostén el aire con calma en los pulmones contando hasta 7.',
        'Exhala haciendo un sonido suave por la boca durante 8 segundos completos.',
      ],
      psychologicalBasis: 'Saturación de oxígeno tisular y estimulación vagal profunda inductora del sueño.',
      category: 'Insomnio / Rumiación Nocturna',
      iconEmoji: '🕯️',
      tags: ['dormir', '4-7-8', 'respiración', 'nocturno', 'pesadez'],
      interactionType: HabitInteractionType.countingBreath,
    ),

    // ----------------------------------------------------
    // 6. CULPA, AUTOCRÍTICA & IMPOSTOR
    // ----------------------------------------------------
    const MicroHabit(
      id: 'crt_01',
      title: 'El Tacto Calmante en la Nuca',
      levIntro: 'Esa vocecita interna está asustada, no tiene razón. Cuidémosla.',
      steps: [
        'Lleva una mano a la parte posterior de tu cuello o nuca.',
        'Acaricia muy despacio hacia abajo, sintiendo la temperatura de tus yemas.',
        'Respira profundo reconociendo que haces lo mejor que puedes con la energía que tienes.',
      ],
      psychologicalBasis: 'Activación de fibras C-táctiles que atenúan la autocrítica y liberan dopamina calmante.',
      category: 'Culpa / Autocrítica / Impostor',
      iconEmoji: '🌿',
      tags: ['culpa', 'autocrítica', 'nuca', 'ternura', 'amabilidad'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'crt_02',
      title: 'Agradecer a la Mente Crítica (ACT)',
      levIntro: 'Tu mente te critica porque intenta protegerte a su manera torpe.',
      steps: [
        'Escucha la frase hiriente que apareció en tu cabeza.',
        'Sonríe con compasión y dite: "Gracias, mente, por intentar mantenerme a salvo".',
        'Inhala profundo y déjala pasar como una nube sin poder sobre ti.',
      ],
      psychologicalBasis: 'Defusión cognitiva de Terapia de Aceptación y Compromiso (ACT) para desarmar la culpa.',
      category: 'Culpa / Autocrítica / Impostor',
      iconEmoji: '🪞',
      tags: ['mente', 'defusión', 'act', 'culpa', 'impostor'],
      interactionType: HabitInteractionType.timer,
    ),
    const MicroHabit(
      id: 'crt_03',
      title: 'La Perspectiva del Amigo Amable',
      levIntro: 'Si yo estuviera triste, ¿me hablarías así de feo? Seguro que no.',
      steps: [
        'Cierra los ojos y piensa en alguien que quieras con todo tu corazón.',
        'Imagínalo con la misma duda o error que cometiste hoy.',
        'Dite a ti mismo exactamente las palabras de perdón que él o ella merece.',
      ],
      psychologicalBasis: 'Descentramiento del sesgo negativo mediante empatía hacia terceras personas.',
      category: 'Culpa / Autocrítica / Impostor',
      iconEmoji: '💛',
      tags: ['amigo', 'perdón', 'compasión', 'autocuidado', 'amor'],
      interactionType: HabitInteractionType.timer,
    ),

    // ----------------------------------------------------
    // 7. BLOQUEO, PROCRASTINACIÓN & PARÁLISIS TDAH
    // ----------------------------------------------------
    const MicroHabit(
      id: 'blk_01',
      title: 'El Micro-Paso de 10 Segundos',
      levIntro: 'No tienes que terminar la montaña hoy. Solo mueve un granito de arena.',
      steps: [
        'Elige solo UNA micro-acción ridículamente pequeña de tu tarea.',
        'Respira hondo y hazla durante 10 segundos exactos sin juzgar el resultado.',
        'Detente y celebra ese micro-avance: ya venciste la inercia del reposo.',
      ],
      psychologicalBasis: 'Reducción drástica del umbral de activación del cuerpo estriado (reducción de fricción límbica).',
      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
      iconEmoji: '🧱',
      tags: ['bloqueo', 'procrastinar', 'tdah', 'acción', 'inercia'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'blk_02',
      title: 'Despertar Sensorial Térmico',
      levIntro: 'Saquemos a tu sistema nervioso de la niebla mental.',
      steps: [
        'Coloca las yemas de tus dedos en agua fría o frota las muñecas con algo fresco.',
        'Lleva ese frescor a las sienes y a los lados del cuello.',
        'Haz una inhalación vigorosa sintiendo cómo se aclara tu foco mental.',
      ],
      psychologicalBasis: 'Reflejo de inmersión mamífero moderado que reconfigura el tono autonómico.',
      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
      iconEmoji: '💧',
      tags: ['agua', 'foco', 'niebla', 'despertar', 'energía'],
      interactionType: HabitInteractionType.countingBreath,
    ),
    const MicroHabit(
      id: 'blk_03',
      title: 'Oxigenación Dinámica de Lev',
      levIntro: 'Vamos a bombear aire nuevo y fresco a tu cerebro dormido.',
      steps: [
        'Ponte de pie o siéntate muy erguido estirando los brazos al techo.',
        'Inhala profundamente por la nariz mientras abres los dedos de las manos.',
        'Exhala con un sonido de alivio bajando los brazos. Repite 3 veces.',
      ],
      psychologicalBasis: 'Estimulación del flujo carotídeo y liberación de dopamina postural.',
      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
      iconEmoji: '🚀',
      tags: ['oxígeno', 'estiramiento', 'energía', 'foco', 'arranque'],
      interactionType: HabitInteractionType.breathGuided,
    ),
  ];

  static MicroHabit? getById(String id) {
    try {
      return allHabits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<MicroHabit> getByCategory(String category) {
    return allHabits.where((h) => h.category == category).toList();
  }

  static MicroHabit getRandomHabit() {
    final rand = Random();
    return allHabits[rand.nextInt(allHabits.length)];
  }

  static List<MicroHabit> searchHabits(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allHabits;

    return allHabits.where((habit) {
      final titleMatch = habit.title.toLowerCase().contains(q);
      final introMatch = habit.levIntro.toLowerCase().contains(q);
      final basisMatch = habit.psychologicalBasis.toLowerCase().contains(q);
      final categoryMatch = habit.category.toLowerCase().contains(q);
      final tagsMatch = habit.tags.any((tag) => tag.toLowerCase().contains(q));
      return titleMatch || introMatch || basisMatch || categoryMatch || tagsMatch;
    }).toList();
  }

  static MicroHabit getRecommendedForMood(String moodTag) {
    final m = moodTag.toLowerCase();
    if (m.contains('tiktok') || m.contains('scroll') || m.contains('redes') || m.contains('pantalla')) {
      return allHabits[0];
    }
    if (m.contains('abrumado') || m.contains('ansiedad') || m.contains('pánico') || m.contains('angustia')) {
      return allHabits[4];
    }
    if (m.contains('triste') || m.contains('soledad') || m.contains('desgano') || m.contains('llorar')) {
      return allHabits[8];
    }
    if (m.contains('enojo') || m.contains('rabia') || m.contains('frustra') || m.contains('ira')) {
      return allHabits[12];
    }
    if (m.contains('dormir') || m.contains('insomnio') || m.contains('noche') || m.contains('desvelo')) {
      return allHabits[15];
    }
    if (m.contains('culpa') || m.contains('impostor') || m.contains('error') || m.contains('crítica')) {
      return allHabits[18];
    }
    if (m.contains('bloqueo') || m.contains('procrastin') || m.contains('parálisis') || m.contains('empezar')) {
      return allHabits[21];
    }
    return getRandomHabit();
  }
}
