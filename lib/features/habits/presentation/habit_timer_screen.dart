import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/audio/sanctuary_audio_service.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/habits/presentation/widgets/interactive_habit_widgets.dart';
import 'package:lev/features/habits/presentation/widgets/petal_celebration_overlay.dart';
import 'package:lev/features/home/presentation/widgets/sanctuary_audio_dialog.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';

/// Pantalla de Hábito completamente interactiva.
/// Lev está presente durante todo el hábito, haciendo lo mismo que el usuario.
/// Los pasos se muestran de uno en uno con animación slide.
class HabitTimerScreen extends ConsumerStatefulWidget {
  final MicroHabit habit;

  const HabitTimerScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitTimerScreen> createState() => _HabitTimerScreenState();
}

class _HabitTimerScreenState extends ConsumerState<HabitTimerScreen>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = true;
  bool _isCompleted = false;
  bool _triggerPetals = false;

  // Animaciones de paso
  late final AnimationController _stepSlideController;
  late final AnimationController _levController;
  bool _isAnimating = false; // Cola anti-colisión
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.habit.durationSeconds;

    _stepSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        final newStep = _getActiveStepIndex;
        if (newStep != _currentStepIndex && !_isAnimating) {
          _animateToStep(newStep);
        }
        setState(() => _remainingSeconds--);
        if (_remainingSeconds % 15 == 0) HapticsHelper.selection();
      } else {
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isCompleted = true;
          _triggerPetals = true;
        });
        _timer?.cancel();
        _onFinish();
      }
    });
  }

  Future<void> _animateToStep(int newStep) async {
    if (_isAnimating) return;
    _isAnimating = true;
    await _stepSlideController.forward(from: 0.0);
    setState(() => _currentStepIndex = newStep);
    await _stepSlideController.reverse();
    _isAnimating = false;
  }

  void _togglePlayPause() {
    HapticsHelper.light();
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    HapticsHelper.light();
    setState(() {
      _timer?.cancel();
      _remainingSeconds = widget.habit.durationSeconds;
      _isRunning = true;
      _isCompleted = false;
      _triggerPetals = false;
      _currentStepIndex = 0;
      _isAnimating = false;
    });
    _startTimer();
  }

  void _onFinish() {
    HapticsHelper.medium();
    setState(() => _triggerPetals = true);
    ref.read(sanctuaryProvider.notifier).onHabitCompleted(widget.habit.id);
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Celebration',
      barrierColor: Colors.black.withValues(alpha: 0.42),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, anim1, anim2) {
        return _LevCelebrationModal(
          habit: widget.habit,
          onClose: () {
            HapticsHelper.light();
            Navigator.of(dialogContext).pop();
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.86, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stepSlideController.dispose();
    _levController.dispose();
    super.dispose();
  }

  int get _getActiveStepIndex {
    final totalSteps = widget.habit.steps.length;
    if (totalSteps == 0) return 0;
    final elapsed = widget.habit.durationSeconds - _remainingSeconds;
    final secondsPerStep = widget.habit.durationSeconds / totalSteps;
    return (elapsed / secondsPerStep).floor().clamp(0, totalSteps - 1);
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(sanctuaryAudioProvider);
    final progress = 1.0 - (_remainingSeconds / widget.habit.durationSeconds);
    final accentColor = LevTheme.getEmotionAccentColor(widget.habit.category);

    return PetalCelebrationOverlay(
      showCelebration: _triggerPetals,
      child: Scaffold(
        backgroundColor: LevTheme.levCream,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Pausa Consciente',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Ambiente sonoro',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: audioState.isPlaying ? LevTheme.levMatcha : LevTheme.levMatchaLight,
                ),
                child: Icon(
                  audioState.isPlaying ? Icons.volume_up_rounded : Icons.music_note_rounded,
                  size: 18,
                  color: audioState.isPlaying ? Colors.white : LevTheme.levMatchaDark,
                ),
              ),
              onPressed: () => SanctuaryAudioDialog.show(context),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetTimer,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Badge + título
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: LevTheme.getEmotionBgColor(widget.habit.category),
                        borderRadius: LevTheme.pillRadius,
                      ),
                      child: Text(
                        widget.habit.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.habit.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Progreso de tiempo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: LevTheme.levMatchaLight,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_remainingSeconds s',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Área principal: widget interactivo con Lev
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _buildInteractiveArea(),
                    ),
                  ),
                ),
              ),

              // Paso actual (uno a la vez con slide)
              if (widget.habit.steps.isNotEmpty && !_isCompleted)
                _buildCurrentStep(),

              // Controles
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _togglePlayPause,
                        icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(_isRunning ? 'Pausar' : 'Continuar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onFinish,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Completar'),
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
  }

  Widget _buildInteractiveArea() {
    switch (widget.habit.interactionType) {
      case HabitInteractionType.breathGuided:
        return BreathGuideWidget(
          isPhysiologicalSigh: widget.habit.id == 'anx_01',
        );
      case HabitInteractionType.bilateralTap:
        return const BilateralTapWidget();
      case HabitInteractionType.holdPressure:
        return const HoldPressureWidget();
      case HabitInteractionType.slideRelease:
        return const SlideReleaseWidget();
      case HabitInteractionType.eyeTracker:
        return const EyeTrackerWidget();
      case HabitInteractionType.countingBreath:
        return const CountingBreathWidget(targetCycles: 6);
      case HabitInteractionType.gestureInput:
        return _buildGestureInputArea();
      case HabitInteractionType.timer:
        return _buildLevWithTimer();
    }
  }

  Widget _buildLevWithTimer() {
    return AnimatedBuilder(
      animation: _levController,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: LivingSeedSpiritPainter(
                  animationValue: _levController.value,
                  emotion: LevEmotion.peaceful,
                  isPetting: false,
                  sizeScale: 0.9,
                  taskAction: widget.habit.taskAction,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Frase introductoria de Lev
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: LevTheme.softShadow,
              ),
              child: Text(
                widget.habit.levIntro,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  color: LevTheme.levTextDark,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGestureInputArea() {
    final List<Offset> points = [];
    return Column(
      children: [
        AnimatedBuilder(
          animation: _levController,
          builder: (context, _) => SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: LivingSeedSpiritPainter(
                animationValue: _levController.value,
                emotion: LevEmotion.peaceful,
                isPetting: false,
                sizeScale: 0.55,
                taskAction: widget.habit.taskAction,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.habit.levIntro,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: LevTheme.levTextMuted,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 260,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: StatefulBuilder(
              builder: (context, setInner) {
                return GestureDetector(
                  onPanUpdate: (d) => setInner(() => points.add(d.localPosition)),
                  child: Container(
                    color: const Color(0xFFF2ECE1),
                    child: CustomPaint(
                      painter: _GesturePainter(List.from(points)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    final step = widget.habit.steps[_currentStepIndex];
    final totalSteps = widget.habit.steps.length;
    final accentColor = LevTheme.getEmotionAccentColor(widget.habit.category);

    return AnimatedBuilder(
      animation: _stepSlideController,
      builder: (context, child) {
        final slide = Curves.easeInOut.transform(_stepSlideController.value);
        return Transform.translate(
          offset: Offset(0, -slide * 20),
          child: Opacity(
            opacity: 1.0 - slide * 0.5,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                boxShadow: LevTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                    ),
                    child: Center(
                      child: Text(
                        '${_currentStepIndex + 1}',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: LevTheme.levTextDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                  Text(
                    '$_currentStepIndex/$totalSteps',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GesturePainter extends CustomPainter {
  final List<Offset> points;
  _GesturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final furrow = Paint()
      ..color = const Color(0xFFD4C8B5)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, furrow);
    }
  }

  @override
  bool shouldRepaint(_GesturePainter old) => true;
}

/// Pantalla modal de celebración orgánica y luminosa para Lev al terminar el hábito.
class _LevCelebrationModal extends ConsumerStatefulWidget {
  final MicroHabit habit;
  final VoidCallback onClose;

  const _LevCelebrationModal({
    required this.habit,
    required this.onClose,
  });

  @override
  ConsumerState<_LevCelebrationModal> createState() => _LevCelebrationModalState();
}

class _LevCelebrationModalState extends ConsumerState<_LevCelebrationModal>
    with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final AnimationController _glowController;
  late final AnimationController _badgePopController;
  String? _selectedRelief;
  String? _reliefValidationMsg;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _badgePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _glowController.dispose();
    _badgePopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sanctuary = ref.watch(sanctuaryProvider);
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: min(size.width * 0.90, 400.0),
          constraints: BoxConstraints(maxHeight: size.height * 0.88),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: LevTheme.levMatchaLight.withValues(alpha: 0.9),
              width: 1.8,
            ),
            boxShadow: [
              const BoxShadow(
                color: Color(0x332D3748),
                blurRadius: 36,
                offset: Offset(0, 14),
              ),
              const BoxShadow(
                color: Color(0x22FFE082),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Stack(
              children: [
                // Overlay sutil de pétalos flotantes dentro del modal
                const Positioned.fill(
                  child: IgnorePointer(
                    child: PetalCelebrationOverlay(),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Encabezado con insignia de felicitación
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: LevTheme.levMatchaLight,
                                borderRadius: LevTheme.pillRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, size: 14, color: LevTheme.levMatchaDark),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Pausa Consciente Completada',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: LevTheme.levMatchaDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                      // Medallón orgánico de Lev en salto de alegría
                      AnimatedBuilder(
                        animation: Listenable.merge([_jumpController, _glowController]),
                        builder: (context, child) {
                          final glowVal = _glowController.value;
                          return Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFF8E1),
                                  const Color(0xFFFFF3D6).withValues(alpha: 0.8),
                                  const Color(0xFFE8F5E9).withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.35, 0.65, 0.85, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD54F).withValues(alpha: 0.30 + glowVal * 0.20),
                                  blurRadius: 32 + glowVal * 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  size: const Size(170, 170),
                                  painter: LivingSeedSpiritPainter(
                                    animationValue: _jumpController.value,
                                    emotion: LevEmotion.joyJump,
                                    isPetting: true,
                                    sizeScale: 0.88,
                                    jumpProgress: _jumpController.value,
                                    happyProgress: 1.0,
                                    celebrateProgress: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Título cálido y cariñoso
                      Text(
                        '¡Lo lograste!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lev está saltando de alegría por tu pausa de cuidado.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: LevTheme.levTextMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bloque de Recompensas: +Gotas y +XP diferenciadas
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _badgePopController,
                          curve: Curves.elasticOut,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFBBDEFB)),
                                  boxShadow: LevTheme.softShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.water_drop_rounded, size: 18, color: Color(0xFF1976D2)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '+1 Gota 💧',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1976D2),
                                            ),
                                          ),
                                          Text(
                                            'Santuario',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              color: LevTheme.levTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: LevTheme.levMatchaLight),
                                  boxShadow: LevTheme.softShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.eco_rounded, size: 18, color: LevTheme.levMatchaDark),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '+25 XP 🌱',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: LevTheme.levMatchaDark,
                                            ),
                                          ),
                                          Text(
                                            'Evolución Lev',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              color: LevTheme.levTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Barra de progreso botánico
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: LevTheme.levBorder),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(sanctuary.stageMaterialIcon, size: 16, color: LevTheme.levMatchaDark),
                                    const SizedBox(width: 5),
                                    Text(
                                      sanctuary.stageName,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: LevTheme.levTextDark,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${sanctuary.experiencePoints} XP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levMatchaDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: sanctuary.growthFactor,
                                backgroundColor: LevTheme.levCream,
                                valueColor: const AlwaysStoppedAnimation<Color>(LevTheme.levMatcha),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tarjeta de base neurocientífica
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4ED),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: LevTheme.levBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology_outlined, size: 16, color: LevTheme.levMatchaDark),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Impacto en tu sistema nervioso:',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: LevTheme.levMatchaDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.habit.psychologicalBasis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: LevTheme.levTextDark,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Medición somática post-hábito (1-tap check-in)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedRelief != null ? LevTheme.levMatcha : LevTheme.levBorder,
                            width: _selectedRelief != null ? 1.6 : 1.0,
                          ),
                          boxShadow: LevTheme.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.self_improvement_rounded, size: 16, color: LevTheme.levMatchaDark),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '¿Cómo siente tu cuerpo esta pausa?',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: LevTheme.levTextDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildReliefOption('lighter', '🍃 Más ligero'),
                                const SizedBox(width: 6),
                                _buildReliefOption('same', '⚖️ Igual'),
                                const SizedBox(width: 6),
                                _buildReliefOption('tense', '🌧️ Aún tenso'),
                              ],
                            ),
                            if (_reliefValidationMsg != null) ...[
                              const SizedBox(height: 8),
                              AnimatedOpacity(
                                opacity: 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _reliefValidationMsg!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: LevTheme.levMatchaDark,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                    // Botón táctil para continuar siempre visible al pie
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: widget.onClose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LevTheme.levMatcha,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: LevTheme.pillRadius,
                            ),
                          ),
                          child: Text(
                            'Hecho, gracias Lev 🌿',
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReliefOption(String key, String label) {
    final isSelected = _selectedRelief == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticsHelper.selection();
          setState(() {
            _selectedRelief = key;
            if (key == 'lighter') {
              _reliefValidationMsg = 'Qué hermoso alivio. Tu cuerpo absorbió la calma.';
            } else if (key == 'same') {
              _reliefValidationMsg = 'Normal y válido. Cada pausa va sembrando alivio poco a poco.';
            } else {
              _reliefValidationMsg = 'Está bien, no te juzgues. Lev te acompaña con paciencia infinita.';
            }
          });
          LocalStorageService.recordHabitRelief(widget.habit.id, key);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? LevTheme.levMatchaLight : const Color(0xFFF9F9F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
