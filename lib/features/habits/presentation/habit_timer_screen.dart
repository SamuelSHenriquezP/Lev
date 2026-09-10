import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/audio/sanctuary_audio_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/habits/presentation/widgets/breathing_circle.dart';
import 'package:lev/features/habits/presentation/widgets/petal_celebration_overlay.dart';
import 'package:lev/features/home/presentation/widgets/sanctuary_audio_dialog.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';

class HabitTimerScreen extends ConsumerStatefulWidget {
  final MicroHabit habit;

  const HabitTimerScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitTimerScreen> createState() => _HabitTimerScreenState();
}

class _HabitTimerScreenState extends ConsumerState<HabitTimerScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = true;
  bool _isCompleted = false;
  bool _triggerPetals = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.habit.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds % 15 == 0) {
          HapticsHelper.selection();
        }
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
    });
    _startTimer();
  }

  void _onFinish() {
    setState(() {
      _triggerPetals = true;
    });
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
              const SizedBox(height: 8),
              const _LevCelebrationView(),
              const SizedBox(height: 12),
              Text(
                '¡Increíble, lo lograste! 🎉',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lev está brincando de alegría por tu pausa consciente. Sumaste +1 💧 Gota de Cuidado para su crecimiento.',
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🧠 ', style: TextStyle(fontSize: 18)),
                    Expanded(
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
                          const SizedBox(height: 4),
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
                  child: const Text('Hecho, gracias Lev 💛'),
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
    super.dispose();
  }

  int get _activeStepIndex {
    final totalSteps = widget.habit.steps.length;
    if (totalSteps == 0) return 0;
    final elapsed = widget.habit.durationSeconds - _remainingSeconds;
    final secondsPerStep = widget.habit.durationSeconds / totalSteps;
    final step = (elapsed / secondsPerStep).floor();
    return step.clamp(0, totalSteps - 1);
  }

  bool get _isBreathingHabit {
    return widget.habit.id == 'anx_01' ||
        widget.habit.id == 'anx_04' ||
        widget.habit.id == 'slp_03' ||
        widget.habit.id == 'ang_03';
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(sanctuaryAudioProvider);
    final progress = 1.0 - (_remainingSeconds / widget.habit.durationSeconds);

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
            // Botón de audio ambiental relajante
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
              tooltip: 'Reiniciar 60 segundos',
              onPressed: _resetTimer,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge de categoría
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Text(
                    widget.habit.category,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LevTheme.levMatchaDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Título del microhábito
                Text(
                  widget.habit.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
                const SizedBox(height: 10),

                // Diálogo tierno de Lev
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: LevTheme.softShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${widget.habit.iconEmoji} ', style: const TextStyle(fontSize: 16)),
                      Flexible(
                        child: Text(
                          widget.habit.levIntro,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: LevTheme.levTextDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Temporizador circular o visualizador somático
                if (_isBreathingHabit) ...[
                  BreathingCircle(
                    totalSeconds: widget.habit.durationSeconds,
                    isPhysiologicalSigh: widget.habit.id == 'anx_01',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$_remainingSeconds s',
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levMatchaDark,
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 165,
                          height: 165,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: LevTheme.levMatchaLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(LevTheme.levMatcha),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_remainingSeconds',
                              style: GoogleFonts.quicksand(
                                fontSize: 50,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levTextDark,
                              ),
                            ),
                            Text(
                              'segundos',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: LevTheme.levTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // Pasos guiados interactivos
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pasos conscientes:',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.habit.steps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final isActive = index == _activeStepIndex && !_isCompleted;
                    final isDone = index < _activeStepIndex || _isCompleted;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : (isDone
                                ? LevTheme.levMatchaLight.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive ? LevTheme.levMatcha : LevTheme.levBorder,
                          width: isActive ? 1.8 : 1.0,
                        ),
                        boxShadow: isActive ? LevTheme.glowShadow : const [],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? LevTheme.levMatcha
                                  : (isActive ? LevTheme.levPeach : LevTheme.levBorder),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text(
                                      '${index + 1}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              widget.habit.steps[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                color: LevTheme.levTextDark,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Botones de control inferiores
                Row(
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget animado donde Lev brinca y celebra de alegría al terminar un microhábito
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
    // Ciclo de salto y baile alegre a 60 FPS (1300ms de período armónico)
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

