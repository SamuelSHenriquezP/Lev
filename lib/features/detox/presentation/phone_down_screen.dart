import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/audio/sanctuary_audio_service.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';

/// Opciones de tiempo para la desconexión consciente
enum DetoxGoal {
  dopamineReset(
    minutes: 5,
    title: 'Pausa de Dopamina',
    subtitle: '5 minutos',
    emoji: '🌿',
    psychologicalReason:
        'Interrumpe el piloto automático y los picos de dopamina del scroll. Permite que la corteza prefrontal descanse de la sobreestimulación visual.',
    groundingPrompt:
        'Deja tu teléfono boca abajo sobre la mesa. Siente tus pies en el suelo, mira a través de una ventana y respira hondo tres veces.',
    dropsReward: 1,
    xpReward: 10,
  ),
  sensoryReconnection(
    minutes: 15,
    title: 'Reconexión Sensorial',
    subtitle: '15 minutos',
    emoji: '🍃',
    psychologicalReason:
        'Reduce el cortisol acumulado y estimula el sistema parasimpático. Tu cerebro recupera la capacidad de conectar con sensaciones físicas reales.',
    groundingPrompt:
        'Coloca tu teléfono en otra habitación o fuera de tu alcance visual. Bebe un vaso de agua despacio o camina unos pasos sintiendo tu cuerpo.',
    dropsReward: 2,
    xpReward: 25,
  ),
  deepFocus(
    minutes: 25,
    title: 'Foco Analógico',
    subtitle: '25 minutos',
    emoji: '🕯️',
    psychologicalReason:
        'Bloque de trabajo profundo o lectura sin micro-interrupciones. Elimina la fatiga por fragmentación atencional.',
    groundingPrompt:
        'Silencia el dispositivo y déjalo fuera de tu campo visual. Dedícate por completo a una sola tarea real sin pantallas.',
    dropsReward: 3,
    xpReward: 40,
  ),
  realLifeLiving(
    minutes: 45,
    title: 'Vida en el Mundo Real',
    subtitle: '45 minutos',
    emoji: '🌳',
    psychologicalReason:
        'Desconexión prolongada que reequilibra la sensibilidad a los receptores dopaminérgicos naturales. Reconecta con el tiempo pausado.',
    groundingPrompt:
        'Guarda tu teléfono. Sal a caminar, conversa con alguien, cocina o lee un libro físico sintiendo el paso genuino del tiempo.',
    dropsReward: 5,
    xpReward: 70,
  ),
  nightRest(
    minutes: 60,
    title: 'Reposo Nocturno',
    subtitle: '60 minutos',
    emoji: '🌙',
    psychologicalReason:
        'Evita que la luz azul y los algoritmos hipervigilantes retrasen la melatonina. Prepara al cerebro para un sueño reparador.',
    groundingPrompt:
        'Deja tu teléfono cargando lejos de tu cama. Lev cuidará el santuario mientras tú duermes. Que descanses profundamente.',
    dropsReward: 6,
    xpReward: 90,
  );

  final int minutes;
  final String title;
  final String subtitle;
  final String emoji;
  final String psychologicalReason;
  final String groundingPrompt;
  final int dropsReward;
  final int xpReward;

  const DetoxGoal({
    required this.minutes,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.psychologicalReason,
    required this.groundingPrompt,
    required this.dropsReward,
    required this.xpReward,
  });
}

/// Estado de la sesión de desconexión
enum _SessionPhase {
  selection,
  groundingPreparation,
  restingAway,
  completed,
}

/// Pantalla insignia para "Soltar el Teléfono" (Digital Grounding & Presencia Real).
class PhoneDownScreen extends ConsumerStatefulWidget {
  final DetoxGoal initialGoal;

  const PhoneDownScreen({
    super.key,
    this.initialGoal = DetoxGoal.sensoryReconnection,
  });

  @override
  ConsumerState<PhoneDownScreen> createState() => _PhoneDownScreenState();
}

class _PhoneDownScreenState extends ConsumerState<PhoneDownScreen>
    with TickerProviderStateMixin {
  late DetoxGoal _selectedGoal;
  _SessionPhase _phase = _SessionPhase.selection;

  Timer? _timer;
  int _secondsRemaining = 0;
  int _totalSessionSeconds = 0;

  late final AnimationController _levSleepController;
  late final AnimationController _pulseController;

  static const List<String> _peacefulQuotes = [
    'Lev está durmiendo plácidamente. Tu vida real está esperándote afuera.',
    'No te estás perdiendo de nada importante. Estás recuperando tu propia presencia.',
    'Nota la textura de lo que tocas, el sonido del viento o el silencio a tu alrededor.',
    'Tu mente se está desintoxicando del ruido digital. Respira hondo.',
    'El aburrimiento no es una falla; es el espacio donde renace tu creatividad.',
  ];
  int _quoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal;

    _levSleepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quoteTimer?.cancel();
    _levSleepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPreparation() {
    HapticsHelper.selection();
    setState(() => _phase = _SessionPhase.groundingPreparation);
  }

  void _startRestingSession() {
    HapticsHelper.medium();
    _totalSessionSeconds = _selectedGoal.minutes * 60;
    _secondsRemaining = _totalSessionSeconds;

    setState(() {
      _phase = _SessionPhase.restingAway;
      _quoteIndex = Random().nextInt(_peacefulQuotes.length);
    });

    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _peacefulQuotes.length;
        });
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _quoteTimer?.cancel();
        _finishSession();
      }
    });
  }

  Future<void> _finishSession() async {
    setState(() {
      _secondsRemaining = 0;
      _phase = _SessionPhase.completed;
    });

    // Guardar estadísticas de desconexión
    await LocalStorageService.addDetoxSession(_selectedGoal.minutes);

    // Otorgar recompensas en el Santuario
    final currentDrops = ref.read(sanctuaryProvider).careDrops;
    final currentXP = ref.read(sanctuaryProvider).experiencePoints;

    await LocalStorageService.saveCareDropsRaw(currentDrops + _selectedGoal.dropsReward);
    await LocalStorageService.saveExperiencePointsRaw(currentXP + _selectedGoal.xpReward);

    ref.invalidate(sanctuaryProvider);

    // Reproducir campanilla de logro
    await HapticsHelper.heavy();
    ref.read(sanctuaryAudioProvider.notifier).playChimeSfx();
  }

  void _handleScreenTouchDuringSleep() {
    HapticsHelper.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildImpulseCompassionDialog(),
    );
  }

  Widget _buildImpulseCompassionDialog() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF14201C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LevTheme.levMatcha.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    color: LevTheme.levMatcha,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '¿Sentiste el impulso automático?',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Es completamente normal. Tu cerebro está habituado a buscar dopamina rápida cada vez que hay una pausa de estimulación.\n\nNo te juzgues. Respira hondo con Lev. ¿Te gustaría regalarte el resto de tu tiempo o necesitas parar por hoy?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                height: 1.45,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _cancelSessionEarly();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Terminar por hoy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      HapticsHelper.selection();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LevTheme.levMatcha,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Continuar descanso',
                      style: GoogleFonts.quicksand(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _cancelSessionEarly() {
    _timer?.cancel();
    _quoteTimer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatTime(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _SessionPhase.selection:
        return _buildSelectionView();
      case _SessionPhase.groundingPreparation:
        return _buildPreparationView();
      case _SessionPhase.restingAway:
        return _buildRestingView();
      case _SessionPhase.completed:
        return _buildCompletedView();
    }
  }

  // --- VISTA 1: SELECCIÓN DE META ---
  Widget _buildSelectionView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101915) : LevTheme.levCream,
      appBar: AppBar(
        title: Text(
          'Soltar el Teléfono',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner introductorio clínico
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: LevTheme.levMatcha.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: LevTheme.levMatcha.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu vida ocurre fuera de la pantalla',
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : LevTheme.levTextDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lev está aquí para ayudarte a alejarte, no para atraparte. Elige cuánto tiempo quieres regalarle a tu mente en el mundo real.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              height: 1.4,
                              color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              Text(
                'Elige tu pausa consciente:',
                style: GoogleFonts.quicksand(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 12),

              // Lista de metas
              ...DetoxGoal.values.map((goal) {
                final isSelected = _selectedGoal == goal;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      HapticsHelper.selection();
                      setState(() => _selectedGoal = goal);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? LevTheme.levMatcha.withValues(alpha: 0.16)
                            : (isDark ? const Color(0xFF162520) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? LevTheme.levMatcha
                              : (isDark ? Colors.white12 : LevTheme.levBorder),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? LevTheme.softShadow : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? LevTheme.levMatcha
                                  : (isDark ? Colors.white10 : LevTheme.levCream),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                goal.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.quicksand(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : LevTheme.levTextDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSelected ? LevTheme.levMatchaDark : Colors.grey.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        goal.subtitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : LevTheme.levTextMuted),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal.psychologicalReason,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    height: 1.35,
                                    color: isDark ? Colors.white60 : LevTheme.levTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startPreparation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levMatcha,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    'Continuar hacia la desconexión',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- VISTA 2: CÁPSULA PSICOEDUCATIVA & PREPARACIÓN FÍSICA ---
  Widget _buildPreparationView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101915) : LevTheme.levCream,
      appBar: AppBar(
        title: Text(
          'Preparando tu Pausa',
          style: GoogleFonts.quicksand(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _phase = _SessionPhase.selection),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Mini espíritu Lev flotando
              SizedBox(
                width: 140,
                height: 140,
                child: AnimatedBuilder(
                  animation: _levSleepController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: LivingSeedSpiritPainter(
                        animationValue: _levSleepController.value,
                        emotion: LevEmotion.peaceful,
                        isPetting: false,
                        sizeScale: 0.65,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'El porqué neurológico:',
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levMatchaDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedGoal.psychologicalReason,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.45,
                  color: isDark ? Colors.white70 : LevTheme.levTextDark,
                ),
              ),

              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2B24) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.3)),
                  boxShadow: LevTheme.softShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.screen_lock_portrait_rounded, color: LevTheme.levMatcha),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Acción física antes de soltarlo:',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : LevTheme.levTextDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedGoal.groundingPrompt,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startRestingSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levMatcha,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.bedtime_rounded),
                  label: Text(
                    'Entrar en reposo (${_selectedGoal.minutes} min)',
                    style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // --- VISTA 3: PANTALLA DE REPOSO ZEN (LEJOS DE LA PANTALLA) ---
  Widget _buildRestingView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleScreenTouchDuringSleep,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1310), // Penumbra relajante
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Barra superior con aviso discreto
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: LevTheme.levMatcha,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Desconexión Activa',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white38,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white24, size: 20),
                      onPressed: _handleScreenTouchDuringSleep,
                    ),
                  ],
                ),

                // Centro: Lev durmiendo en el estanque
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: AnimatedBuilder(
                        animation: _levSleepController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: LivingSeedSpiritPainter(
                              animationValue: _levSleepController.value,
                              emotion: LevEmotion.peaceful,
                              isPetting: false,
                              sizeScale: 0.85,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: GoogleFonts.quicksand(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _peacefulQuotes[_quoteIndex],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ],
                ),

                // Parte inferior: instrucción sutil
                Text(
                  'Deja tu teléfono boca abajo. Lev te avisará con una campanilla suave.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- VISTA 4: SESIÓN COMPLETADA & RECOMPENSA ---
  Widget _buildCompletedView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LevTheme.levMatcha.withValues(alpha: 0.2),
                ),
                child: const Center(
                  child: Icon(Icons.spa_rounded, color: LevTheme.levMatcha, size: 36),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '¡Bienvenido de vuelta!',
                style: GoogleFonts.quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Has regalado ${_selectedGoal.minutes} minutos de verdadera presencia a tu vida. Tu sistema nervioso te lo agradece.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 28),

              // Tarjeta de Recompensas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Text('💧', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          '+${_selectedGoal.dropsReward} Gotas',
                          style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 28, color: Colors.white12),
                    Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          '+${_selectedGoal.xpReward} XP',
                          style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levMatcha,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 2,
                  ),
                  child: Text(
                    'Volver al Santuario',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
