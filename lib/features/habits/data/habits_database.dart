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
    const MicroHabit(
      id: 'doom_05',
      title: 'Descompresión de Cuello Búho Sabio',
      levIntro: 'Tu cuello cargó el peso de la pantalla todo el rato. Giremos despacio.',
      steps: [
        'Deja el móvil sobre la mesa con la pantalla hacia abajo.',
        'Gira suavemente la cabeza hacia la derecha mirando por encima del hombro.',
        'Inhala contando 3, regresa al centro y gira despacio a la izquierda.',
        'Siente cómo se afloja la base de tu cráneo.',
      ],
      psychologicalBasis: 'Descompresión de la fascia suboccipital y alivio de la sobrecarga propioceptiva cervical.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '🦉',
      tags: ['cuello', 'postura', 'cabeza', 'pantalla', 'alivio'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'doom_06',
      title: 'El Horizonte Periférico',
      levIntro: 'La pantalla encierra tu mirada en un túnel. Vamos a abrir el campo visual.',
      steps: [
        'Mantén la mirada al frente sin mover la cabeza.',
        'Abre los brazos a los lados a la altura de las orejas moviendo los dedos.',
        'Intenta notar el movimiento de tus manos usando solo tu visión lateral.',
        'Respira hondo mientras tu cerebro amplía su percepción.',
      ],
      psychologicalBasis: 'Activación de la visión periférica para modular el tono simpático y desactivar la visión túnel de estrés.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '🔭',
      tags: ['visión', 'ojos', 'amplitud', 'periférica', 'estrés'],
      interactionType: HabitInteractionType.eyeTracker,
    ),
    const MicroHabit(
      id: 'doom_07',
      title: 'Reset de Mandíbula y Lengua',
      levIntro: 'A veces apretamos los dientes sin darnos cuenta mientras scrolleamos.',
      steps: [
        'Separa los labios y deja caer la mandíbula inferior con suavidad.',
        'Apoya la punta de la lengua relajada en el paladar, detrás de los dientes frontales.',
        'Haz una exhalación soltando todo el aire por la boca con un suspiro tibio.',
      ],
      psychologicalBasis: 'Inhibición refleja del nervio trigémino y relajación del músculo masetero hipertenso.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '👄',
      tags: ['mandíbula', 'dientes', 'lengua', 'tensión', 'relax'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'doom_08',
      title: 'Anclaje Auditivo de Tres Sonidos',
      levIntro: 'Apaguemos el ruido de los vídeos. Escuchemos la vida que te rodea.',
      steps: [
        'Cierra los ojos durante 10 segundos y busca el sonido más lejano que alcances.',
        'Ahora busca un sonido cercano dentro de tu propia habitación.',
        'Por último, escucha el murmullo suave de tu propia respiración.',
      ],
      psychologicalBasis: 'Reorientación de la red atencional dorsal hacia el entorno acústico real presente.',
      category: 'Doomscrolling / Sobrecarga Digital',
      iconEmoji: '👂',
      tags: ['oído', 'sonido', 'escucha', 'atención', 'silencio'],
      interactionType: HabitInteractionType.countingBreath,
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
    const MicroHabit(
      id: 'anx_05',
      title: 'El Abrazo de la Mariposa EMDR',
      levIntro: 'Tus manos pueden ser dos alas que traen tu mente de vuelta a la calma.',
      steps: [
        'Cruza los brazos sobre tu pecho, apoyando las manos bajo tus clavículas.',
        'Alterna toquecitos rítmicos: izquierda... derecha... izquierda... derecha.',
        'Respira lento y siente cómo la tormenta interna empieza a disolverse.',
      ],
      psychologicalBasis: 'Estimulación bilateral táctil alternada que sincroniza hemisferios y reduce el secuestro amigdalino.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '🦋',
      tags: ['emdr', 'mariposa', 'tapping', 'pánico', 'calma'],
      interactionType: HabitInteractionType.bilateralTap,
    ),
    const MicroHabit(
      id: 'anx_06',
      title: 'Suspiro Doble con Retención',
      levIntro: 'Vaciemos el aire viejo que se quedó atrapado en tu pecho.',
      steps: [
        'Inhala por la nariz llenando la mitad de tus pulmones.',
        'Toma un sorbo más de aire al máximo sin soltar el primero.',
        'Sostén el aire 2 segundos y luego suéltalo como una cascada larga.',
        'Repite 3 veces sintiendo la pesadez de tus hombros caer.',
      ],
      psychologicalBasis: 'Apertura de los sacos alveolares colapsados y aceleración de la recaptación de CO2.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '🌬️',
      tags: ['respiración', 'suspiro', 'vago', 'pulmones', 'oxígeno'],
      interactionType: HabitInteractionType.breathGuided,
    ),
    const MicroHabit(
      id: 'anx_07',
      title: 'Presión Pectoral Calmante',
      levIntro: 'Pon tu manita en tu corazón. Siente que aquí no hay peligro.',
      steps: [
        'Coloca la palma firme y tibia justo en el centro del esternón.',
        'Aplica una presión constante y agradable, como una mantita con peso.',
        'Siente el latido rítmico y repite en silencio: "Este momento pasará".',
      ],
      psychologicalBasis: 'Activación de mecanorreceptores de presión profunda que inducen tono parasimpático cardíaco.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '🤲',
      tags: ['pecho', 'tacto', 'presión', 'anclaje', 'seguridad'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'anx_08',
      title: 'La Caja de 4 Tiempos (Box Breathing)',
      levIntro: 'Vamos a dibujar un cuadrado perfecto con nuestro aire.',
      steps: [
        'Inhala contando 1, 2, 3, 4.',
        'Sostén el aire lleno contando 1, 2, 3, 4.',
        'Exhala despacio contando 1, 2, 3, 4.',
        'Sostén en vacío contando 1, 2, 3, 4.',
      ],
      psychologicalBasis: 'Autorregulación neurovegetativa usada por unidades de alto rendimiento para controlar el cortisol.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '📦',
      tags: ['caja', '4x4', 'cuadrado', 'respiración', 'control'],
      interactionType: HabitInteractionType.countingBreath,
    ),
    const MicroHabit(
      id: 'anx_09',
      title: 'Trazado del Laberinto Calmo',
      levIntro: 'Sigue mi estela con tu dedito. Dejemos que el movimiento aquiete tu pulso.',
      steps: [
        'Desliza tu dedo lentamente siguiendo los surcos suaves en la pantalla.',
        'Siente la textura del deslizamiento y acompásala con tu respiración.',
        'No hay prisa por llegar al final; lo que importa es este trazo presente.',
      ],
      psychologicalBasis: 'Grounding visomotor y motricidad fina que desvía la rumiación ansiosa hacia el córtex motor.',
      category: 'Ansiedad / Ataque de Pánico / Agobio',
      iconEmoji: '🌀',
      tags: ['trazo', 'dedo', 'laberinto', 'motricidad', 'calma'],
      interactionType: HabitInteractionType.gestureInput,
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
    const MicroHabit(
      id: 'sad_05',
      title: 'Manto Cálido de Manos',
      levIntro: 'Cuando el alma siente frío, tus propias palmas pueden abrigarte.',
      steps: [
        'Frota las palmas de tus manos con energía hasta generar un calor vivo.',
        'Posa las manos tibias cubriendo tus mejillas y mandíbula con ternura.',
        'Permítete recibir ese calor sin pedirte nada a cambio durante 30 segundos.',
      ],
      psychologicalBasis: 'Termorregulación somatosensorial y estimulación del sistema de apego seguro interno.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '🔥',
      tags: ['calor', 'manos', 'ternura', 'rostro', 'abrigo'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'sad_06',
      title: 'Respiración Compasiva del Amigo',
      levIntro: 'Imagina que inhalas comprensión para ti y exhalas suavidad.',
      steps: [
        'Inhala hondo pensando: "Esto también duele, pero no estoy roto".',
        'Exhala dejando salir un aliento suave que relaje tu garganta.',
        'Repite acompasado sintiendo el abrazo invisible de la naturaleza.',
      ],
      psychologicalBasis: 'Autocompasión de Neff integrada con modulación vagal y reducción del afecto negativo.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '🌸',
      tags: ['compasión', 'amabilidad', 'tristeza', 'respiración', 'duelo'],
      interactionType: HabitInteractionType.breathGuided,
    ),
    const MicroHabit(
      id: 'sad_07',
      title: 'Balanceo Rítmico de Tronco',
      levIntro: 'Como las ramas que se mecen con el viento, déjate llevar suavemente.',
      steps: [
        'Siéntate con los pies en el suelo y cierra los ojos.',
        'Balancea el torso muy suavemente de izquierda a derecha en un ritmo lento.',
        'Siente la inercia calmante de tu cuerpo meciéndose como en una barca.',
      ],
      psychologicalBasis: 'Estimulación vestibular rítmica de baja frecuencia que imita la contención maternal infantil.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '⛵',
      tags: ['balanceo', 'ritmo', 'mecer', 'soledad', 'vestibular'],
      interactionType: HabitInteractionType.bilateralTap,
    ),
    const MicroHabit(
      id: 'sad_08',
      title: 'Nube que Pasa (Defusión ACT)',
      levIntro: 'No eres la tristeza que sientes. Eres el cielo inmenso donde pasa la nube.',
      steps: [
        'Ponle forma y color al peso que sientes en el pecho.',
        'Visualízalo subiendo como una nube que flota en la pantalla.',
        'Desliza tu dedo para dejarla navegar por el cielo abierto.',
      ],
      psychologicalBasis: 'Defusión cognitiva de Terapia de Aceptación y Compromiso (ACT) respecto al estado de ánimo deprimido.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '☁️',
      tags: ['nube', 'act', 'defusión', 'soltar', 'desgano'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'sad_09',
      title: 'Trazado de Luz en la Ventana',
      levIntro: 'Busquemos un rayito de luz. La oscuridad no dura para siempre.',
      steps: [
        'Mira hacia la fuente de luz más cercana en tu espacio.',
        'Con tu dedo en el aire o en la pantalla, dibuja un contorno suave y dorado.',
        'Toma una bocanada de aire sintiendo la claridad entrar en tus ojos.',
      ],
      psychologicalBasis: 'Fotobiomodulación retiniana e interrupción del bucle de retraimiento conductual.',
      category: 'Tristeza / Soledad / Desgano',
      iconEmoji: '🌤️',
      tags: ['luz', 'claridad', 'ventana', 'ánimo', 'esperanza'],
      interactionType: HabitInteractionType.gestureInput,
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
    const MicroHabit(
      id: 'ang_04',
      title: 'La Pinza Isométrica y Soltado Rápido',
      levIntro: 'Apretemos con ganas para que el cuerpo entienda que ya es hora de soltar.',
      steps: [
        'Empuña las dos manos con fuerza, apretando los dedos hacia las palmas.',
        'Contrae antebrazos y hombros contando 1, 2, 3, 4, 5.',
        '¡Abre las manos de golpe y exhala un "ahhh" sonoro!',
        'Siente el calor y el hormigueo relajante en tus palmas.',
      ],
      psychologicalBasis: 'Fatiga refleja neuromuscular que agota el arco reflejo simpático de agresión.',
      category: 'Frustración / Enojo / Irritabilidad',
      iconEmoji: '✊',
      tags: ['puños', 'soltar', 'rabia', 'isometría', 'fuerza'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'ang_05',
      title: 'Descarga Alternada en los Talones',
      levIntro: 'Tus pies saben descargar la electricidad hacia la tierra.',
      steps: [
        'Ponte de pie y eleva suavemente los talones.',
        'Deja caer un talón con firmeza contra el suelo: ¡pum! Luego el otro: ¡pum!',
        'Alterna 10 golpes firmes sintiendo cómo la irritabilidad baja por tus piernas.',
      ],
      psychologicalBasis: 'Descarga propioceptiva por impacto plantar que canaliza el impulso de lucha (fight response).',
      category: 'Frustración / Enojo / Irritabilidad',
      iconEmoji: '🦶',
      tags: ['talones', 'tierra', 'descarga', 'enojo', 'impacto'],
      interactionType: HabitInteractionType.bilateralTap,
    ),
    const MicroHabit(
      id: 'ang_06',
      title: 'Enfriamiento con Aliento en O',
      levIntro: 'Sopla como si quisieras enfriar una taza de té hirviendo.',
      steps: [
        'Forma una pequeña "O" con tus labios.',
        'Inhala aire fresco por la comisura de los labios sintiendo el frío en el paladar.',
        'Exhala un flujo constante y frío sobre la palma de tu mano.',
        'Siente la brisa enfriar tu calor interior.',
      ],
      psychologicalBasis: 'Disminución térmica de receptores bucofaríngeos que aplaca la respuesta hipertensiva de ira.',
      category: 'Frustración / Enojo / Irritabilidad',
      iconEmoji: '❄️',
      tags: ['frío', 'soplo', 'calor', 'enfriar', 'ira'],
      interactionType: HabitInteractionType.breathGuided,
    ),
    const MicroHabit(
      id: 'ang_07',
      title: 'Drenaje en Garabato Furioso',
      levIntro: 'Toda esa energía atrapada necesita salir. Dibújala con fuerza aquí.',
      steps: [
        'Traza con tu dedo líneas rápidas, zigzags y círculos con energía.',
        'Ponle toda la intensidad a ese movimiento continuo sin parar.',
        'Al terminar los 20 segundos, suelta el dedo y haz un suspiro largo.',
      ],
      psychologicalBasis: 'Externalización grafo-motora del exceso adrenérgico sin conductas dañinas.',
      category: 'Frustración / Enojo / Irritabilidad',
      iconEmoji: '⚡',
      tags: ['garabato', 'trazado', 'fuerza', 'descarga', 'frustración'],
      interactionType: HabitInteractionType.gestureInput,
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
    const MicroHabit(
      id: 'slp_04',
      title: 'El Escaneo de los Dedos de los Pies',
      levIntro: 'Bajemos la energía de tu cabeza hasta el punto más lejano de tu cuerpo.',
      steps: [
        'Lleva toda tu atención a los dedos de tu pie izquierdo; siente su peso y temperatura.',
        'Pasa al pie derecho; afloja los tobillos y deja caer las piernas hacia afuera.',
        'Siente cómo la sangre y el calor se alejan de tu mente hacia tus pies.',
      ],
      psychologicalBasis: 'Redistribución atencional somatotópica distal que inhibe la hiperactividad del córtex dorsolateral.',
      category: 'Insomnio / Rumiación Nocturna',
      iconEmoji: '👣',
      tags: ['pies', 'atención', 'somatotópico', 'sueño', 'noche'],
      interactionType: HabitInteractionType.countingBreath,
    ),
    const MicroHabit(
      id: 'slp_05',
      title: 'Respiración de Ondas Lentas (4-8)',
      levIntro: 'Imagina una ola suave que sube despacio y se retira muy lento.',
      steps: [
        'Inhala contando mentalmente 1, 2, 3, 4.',
        'Exhala muy lento y suave contando 1, 2, 3, 4, 5, 6, 7, 8.',
        'Con cada exhalación el colchón te sostiene con más firmeza.',
      ],
      psychologicalBasis: 'Relación I:E de 1:2 que maximiza la arritmia sinusal respiratoria y la bradicardia inductora del sueño.',
      category: 'Insomnio / Rumiación Nocturna',
      iconEmoji: '🌊',
      tags: ['ondas', 'respiración', 'lento', '4-8', 'insomnio'],
      interactionType: HabitInteractionType.breathGuided,
    ),
    const MicroHabit(
      id: 'slp_06',
      title: 'La Piedra en el Fondo del Lago',
      levIntro: 'Siente tu cuerpo hundiéndose con suavidad en aguas tibias y calmas.',
      steps: [
        'Mantén una presión suave con el pulgar en el centro de tu otra palma.',
        'Imagina una piedra lisa que desciende despacio hasta reposar en el fondo de arena.',
        'Siente cómo tus músculos imitan ese descenso suave y descansan.',
      ],
      psychologicalBasis: 'Sugestión propioceptiva gravitatoria que facilita la desconexión del tono postural pre-sueño.',
      category: 'Insomnio / Rumiación Nocturna',
      iconEmoji: '🪨',
      tags: ['piedra', 'lago', 'gravedad', 'peso', 'descanso'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'slp_07',
      title: 'La Estantería de Preocupaciones',
      levIntro: 'Tus tareas no se van a ir, pero esta noche no pueden dormir contigo.',
      steps: [
        'Visualiza un estante de madera cálida fuera de tu habitación.',
        'Desliza cada pensamiento pendiente hacia el estante con tu dedo.',
        'Cierra la puerta imaginaria: "Hasta mañana a las 8 am. Buenas noches".',
      ],
      psychologicalBasis: 'Técnica de externalización de TCC (Worry Postponement) para disolver el insomnio de mantenimiento.',
      category: 'Insomnio / Rumiación Nocturna',
      iconEmoji: '🚪',
      tags: ['estantería', 'preocupación', 'mañana', 'tcc', 'cerrar'],
      interactionType: HabitInteractionType.slideRelease,
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
    const MicroHabit(
      id: 'crt_04',
      title: 'Mano en el Corazón con Presión Tierna',
      levIntro: 'No necesitas castigarte para aprender. Háblate con la ternura de Lev.',
      steps: [
        'Coloca tu mano dominante sobre tu corazón y la otra sobre tu abdomen.',
        'Presiona con suavidad sintiendo el calor y la vida que laten dentro de ti.',
        'Dite con sinceridad: "Cometo errores porque soy humano, y merezco paz".',
      ],
      psychologicalBasis: 'Estimulación de fibras C-táctiles y apaciguamiento de la Red Neuronal por Defecto (DMN).',
      category: 'Culpa / Autocrítica / Impostor',
      iconEmoji: '💖',
      tags: ['corazón', 'ternura', 'calma', 'perdón', 'autocompasión'],
      interactionType: HabitInteractionType.holdPressure,
    ),
    const MicroHabit(
      id: 'crt_05',
      title: 'La Pregunta del Mejor Amigo',
      levIntro: 'Si tu mejor amigo estuviera en tu lugar, ¿qué le dirías?',
      steps: [
        'Piensa en la voz dura que te está juzgando ahora mismo.',
        'Imagina a tu mejor amigo con el mismo problema o duda.',
        'Escribe o traza en la pantalla las palabras comprensivas que le regalarías.',
      ],
      psychologicalBasis: 'Descentramiento cognitivo que elude el sesgo egocéntrico de autocrítica destructiva.',
      category: 'Culpa / Autocrítica / Impostor',
      iconEmoji: '💌',
      tags: ['amigo', 'carta', 'escribir', 'compasión', 'impostor'],
      interactionType: HabitInteractionType.gestureInput,
    ),
    const MicroHabit(
      id: 'crt_06',
      title: 'Separar el Hecho del Juicio',
      levIntro: 'Una cosa es lo que pasó, y otra muy distinta la historia fea que te cuentas.',
      steps: [
        'Identifica el hecho concreto en una sola frase objetiva (sin adjetivos).',
        'Sepáralo de la etiqueta ("soy un desastre", "no sirvo").',
        'Desliza el juicio hacia afuera y quédate solo con el dato real.',
      ],
      psychologicalBasis: 'Desfusión semántica de Terapia Cognitiva basada en Mindfulness (MBCT).',
      category: 'Culpa / Autocrítica / Impostor',
      iconEmoji: '⚖️',
      tags: ['juicio', 'hecho', 'realidad', 'mindfulness', 'claridad'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'crt_07',
      title: 'Respiración de Humanidad Compartida',
      levIntro: 'Millones de personas sienten lo mismo que tú en este mismo instante.',
      steps: [
        'Inhala profundo reconociendo tu fragilidad como parte de la vida.',
        'Exhala sintiendo conexión con todas las personas que hoy intentan mejorar.',
        'Siente que no estás solo en tu imperfección; estamos juntos en esto.',
      ],
      psychologicalBasis: 'Componente de Humanidad Compartida (Kristin Neff) que desarma el aislamiento de la vergüenza.',
      category: 'Culpa / Autocrítica / Impostor',
      iconEmoji: '🌍',
      tags: ['humanidad', 'conexión', 'vergüenza', 'unión', 'paz'],
      interactionType: HabitInteractionType.breathGuided,
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
    const MicroHabit(
      id: 'blk_04',
      title: 'La Cuenta Regresiva 5-4-3-2-1',
      levIntro: 'Cuando contemos hasta 1, el cuerpo se moverá sin pedir permiso a la duda.',
      steps: [
        'Mira hacia adelante y cuenta con Lev: 5... 4... 3... 2... 1...',
        '¡Al llegar a 1, levántate de la silla o mueve la mano hacia la tarea!',
        'El secreto no es tener ganas, sino iniciar el micro-impulso físico.',
      ],
      psychologicalBasis: 'Regla del impulso motor que burla el bucle de sobreanálisis de la corteza prefrontal dorsolateral.',
      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
      iconEmoji: '🚀',
      tags: ['54321', 'impulso', 'arranque', 'tdah', 'acción'],
      interactionType: HabitInteractionType.countingBreath,
    ),
    const MicroHabit(
      id: 'blk_05',
      title: 'Despejar el Espacio de 1 Metro',
      levIntro: 'El desorden visual satura tu memoria de trabajo. Hagamos espacio.',
      steps: [
        'Mira el metro cuadrado frente a ti en tu mesa o suelo.',
        'Elige solo UN objeto que no deba estar ahí y muévelo con tu mano.',
        'Desliza tu mano sobre la superficie despejada sintiendo el espacio limpio.',
      ],
      psychologicalBasis: 'Reducción de la carga cognitiva exógena en la memoria de trabajo de personas con TDAH.',
      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
      iconEmoji: '🧹',
      tags: ['orden', 'espacio', 'limpieza', 'tdah', 'memoria'],
      interactionType: HabitInteractionType.slideRelease,
    ),
    const MicroHabit(
      id: 'blk_06',
      title: 'Batería Motora de Dedos',
      levIntro: 'Despertemos la chispa de tus neuronas motoras con un ritmo rápido.',
      steps: [
        'Apoya las manos en la mesa o en tus muslos.',
        'Tamborilea los dedos alternando derecha e izquierda a velocidad creciente.',
        'Siente la estimulación táctil rápida bombeando dopamina a tu foco.',
      ],
      psychologicalBasis: 'Retroalimentación táctil y propioceptiva de alta frecuencia que eleva la activación dopaminérgica.',
      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
      iconEmoji: '🥁',
      tags: ['dedos', 'batería', 'dopamina', 'foco', 'ritmo'],
      interactionType: HabitInteractionType.bilateralTap,
    ),
    const MicroHabit(
      id: 'blk_07',
      title: 'Tocar la Herramienta sin Exigencia',
      levIntro: 'Solo toma el lápiz o pon las manos en el teclado. No tienes que escribir.',
      steps: [
        'Acerca tu mano al objeto de trabajo (cuaderno, pantalla, herramienta).',
        'Tócalo suavemente durante 20 segundos sintiendo su forma y peso.',
        'Dite: "Solo estoy aquí con esto, no tengo que ser brillante ahora".',
      ],
      psychologicalBasis: 'Desensibilización sistemática de la respuesta de evitación ante estímulos de trabajo.',
      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
      iconEmoji: '✍️',
      tags: ['herramienta', 'teclado', 'lápiz', 'evitación', 'arranque'],
      interactionType: HabitInteractionType.holdPressure,
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
      return getById('doom_01') ?? allHabits.first;
    }
    if (m.contains('abrumado') || m.contains('ansiedad') || m.contains('pánico') || m.contains('angustia')) {
      return getById('anx_01') ?? allHabits.first;
    }
    if (m.contains('triste') || m.contains('soledad') || m.contains('desgano') || m.contains('llorar')) {
      return getById('sad_01') ?? allHabits.first;
    }
    if (m.contains('enojo') || m.contains('rabia') || m.contains('frustra') || m.contains('ira')) {
      return getById('ang_01') ?? allHabits.first;
    }
    if (m.contains('dormir') || m.contains('insomnio') || m.contains('noche') || m.contains('desvelo')) {
      return getById('slp_01') ?? allHabits.first;
    }
    if (m.contains('culpa') || m.contains('impostor') || m.contains('error') || m.contains('crítica')) {
      return getById('crt_01') ?? allHabits.first;
    }
    if (m.contains('bloqueo') || m.contains('procrastin') || m.contains('parálisis') || m.contains('empezar')) {
      return getById('blk_01') ?? allHabits.first;
    }
    return getRandomHabit();
  }
}
