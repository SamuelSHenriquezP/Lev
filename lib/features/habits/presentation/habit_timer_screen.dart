import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/audio/sanctuary_audio_service.dart';
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
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: LevTheme.levBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              const _LevCelebrationView(),
              const SizedBox(height: 16),
              Text(
                'Lo lograste',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lev está celebrando tu pausa consciente. Sumaste +1 gota de cuidado para su crecimiento.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: LevTheme.levTextMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LevTheme.levCream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impacto en tu sistema nervioso:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levMatchaDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.habit.psychologicalBasis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: LevTheme.levTextDark,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticsHelper.light();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hecho, gracias Lev'),
                ),
              ),
            ],
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
                    OutlinedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(_isRunning ? 'Pausar' : 'Continuar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _onFinish,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Completar'),
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
        Expanded(
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

/// Widget de celebración de Lev al terminar el hábito
class _LevCelebrationView extends StatefulWidget {
  const _LevCelebrationView();

  @override
  State<_LevCelebrationView> createState() => _LevCelebrationViewState();
}

class _LevCelebrationViewState extends State<_LevCelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LevTheme.levCream,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipOval(
            child: CustomPaint(
              size: const Size(160, 160),
              painter: LivingSeedSpiritPainter(
                animationValue: _controller.value,
                emotion: LevEmotion.joyJump,
                isPetting: true,
                sizeScale: 0.85,
                jumpProgress: _controller.value,
                happyProgress: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
