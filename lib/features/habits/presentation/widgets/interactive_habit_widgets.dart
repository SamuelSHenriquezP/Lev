import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';

// ============================================================================
// WIDGET 1: RESPIRACIÓN GUIADA — Lev se expande/contrae, usuario sigue a Lev
// ============================================================================
class BreathGuideWidget extends StatefulWidget {
  final bool isPhysiologicalSigh;
  final ValueChanged<bool>? onCycleComplete;

  const BreathGuideWidget({
    super.key,
    this.isPhysiologicalSigh = false,
    this.onCycleComplete,
  });

  @override
  State<BreathGuideWidget> createState() => _BreathGuideWidgetState();
}

class _BreathGuideWidgetState extends State<BreathGuideWidget>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _levController;
  int _cycleCount = 0;

  @override
  void initState() {
    super.initState();
    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _breathController = AnimationController(
      vsync: this,
      duration: widget.isPhysiologicalSigh
          ? const Duration(milliseconds: 8000)
          : const Duration(milliseconds: 8000),
    )..addStatusListener(_onBreathStatus)..repeat();
  }

  void _onBreathStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.forward) {
      _cycleCount++;
      widget.onCycleComplete?.call(true);
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _levController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _levController]),
      builder: (context, child) {
        final t = _breathController.value;
        // Ciclo: 0.0-0.45 inhala, 0.45-0.55 sostén, 0.55-1.0 exhala
        String phase;
        Color phaseColor;
        double levScale;
        if (t < 0.45) {
          phase = widget.isPhysiologicalSigh && t > 0.30 ? 'Inhala más...' : 'Inhala...';
          phaseColor = const Color(0xFF6A994E);
          levScale = 0.7 + (t / 0.45) * 0.3; // crece de 0.7 a 1.0
        } else if (t < 0.55) {
          phase = 'Sostén...';
          phaseColor = const Color(0xFFB7A648);
          levScale = 1.0;
        } else {
          phase = 'Exhala...';
          phaseColor = const Color(0xFF5C85A0);
          levScale = 1.0 - ((t - 0.55) / 0.45) * 0.3; // reduce de 1.0 a 0.7
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lev animado que se expande/contrae como la respiración
            Transform.scale(
              scale: levScale,
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: LivingSeedSpiritPainter(
                    animationValue: _levController.value,
                    emotion: LevEmotion.breathing,
                    isPetting: false,
                    sizeScale: 0.9,
                    breathingProgress: levScale - 0.7,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Anillo de progreso de respiración
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: t,
                    strokeWidth: 6,
                    backgroundColor: LevTheme.levMatchaLight,
                    valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                    strokeCap: StrokeCap.round,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      phase,
                      key: ValueKey(phase),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: phaseColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ciclo $_cycleCount de 4',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: LevTheme.levTextMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// WIDGET 2: GOLPETEO BILATERAL — Mariposa EMDR con dos botones
// ============================================================================
class BilateralTapWidget extends StatefulWidget {
  const BilateralTapWidget({super.key});

  @override
  State<BilateralTapWidget> createState() => _BilateralTapWidgetState();
}

class _BilateralTapWidgetState extends State<BilateralTapWidget>
    with TickerProviderStateMixin {
  late final AnimationController _levController;
  late final AnimationController _leftPulse;
  late final AnimationController _rightPulse;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _leftPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rightPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _levController.dispose();
    _leftPulse.dispose();
    _rightPulse.dispose();
    super.dispose();
  }

  void _tap(bool isLeft) {
    HapticsHelper.light();
    if (isLeft) {
      _leftPulse.forward(from: 0.0);
    } else {
      _rightPulse.forward(from: 0.0);
    }
    setState(() {
      _tapCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_levController, _leftPulse, _rightPulse]),
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lev con hojas que se agitan al ritmo del golpeteo
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: LivingSeedSpiritPainter(
                  animationValue: _levController.value,
                  emotion: LevEmotion.happy,
                  isPetting: true,
                  sizeScale: 0.85,
                  happyProgress: (_tapCount % 2 == 0) ? _leftPulse.value : _rightPulse.value,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Golpeteos: $_tapCount',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: LevTheme.levMatchaDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alterna: izquierda... derecha... izquierda...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: LevTheme.levTextMuted,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón izquierdo
                GestureDetector(
                  onTapDown: (_) => _tap(true),
                  child: AnimatedBuilder(
                    animation: _leftPulse,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _leftPulse.value * 0.12,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LevTheme.levMatchaLight,
                            border: Border.all(
                              color: LevTheme.levMatcha,
                              width: 2.5 + _leftPulse.value * 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: LevTheme.levMatcha.withValues(alpha: _leftPulse.value * 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'IZQ',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levMatchaDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                // Botón derecho
                GestureDetector(
                  onTapDown: (_) => _tap(false),
                  child: AnimatedBuilder(
                    animation: _rightPulse,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _rightPulse.value * 0.12,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LevTheme.levMatchaLight,
                            border: Border.all(
                              color: LevTheme.levMatcha,
                              width: 2.5 + _rightPulse.value * 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: LevTheme.levMatcha.withValues(alpha: _rightPulse.value * 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'DER',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levMatchaDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// WIDGET 3: PRESIÓN SOSTENIDA — Mantener el dedo, Lev pulsa en sincronía
// ============================================================================
class HoldPressureWidget extends StatefulWidget {
  const HoldPressureWidget({super.key});

  @override
  State<HoldPressureWidget> createState() => _HoldPressureWidgetState();
}

class _HoldPressureWidgetState extends State<HoldPressureWidget>
    with TickerProviderStateMixin {
  late final AnimationController _levController;
  late final AnimationController _pulseController;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _levController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startHold() {
    HapticsHelper.light();
    setState(() => _isHolding = true);
    _pulseController.repeat(reverse: true);
  }

  void _endHold() {
    setState(() => _isHolding = false);
    _pulseController.stop();
    _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_levController, _pulseController]),
      builder: (context, child) {
        final pulseFactor = _isHolding ? _pulseController.value : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.85 + pulseFactor * 0.15,
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: LivingSeedSpiritPainter(
                    animationValue: _levController.value,
                    emotion: _isHolding ? LevEmotion.sheltered : LevEmotion.peaceful,
                    isPetting: _isHolding,
                    sizeScale: 0.9,
                    breathingProgress: pulseFactor,
                    leafWrapProgress: _isHolding ? pulseFactor * 0.6 : 0.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isHolding ? 'Lev siente tu calor...' : 'Mantén presionado',
                key: ValueKey(_isHolding),
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _isHolding ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onLongPressStart: (_) => _startHold(),
              onLongPressEnd: (_) => _endHold(),
              onTapDown: (_) => _startHold(),
              onTapUp: (_) => _endHold(),
              onTapCancel: () => _endHold(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHolding
                      ? LevTheme.levMatcha.withValues(alpha: 0.15)
                      : LevTheme.levMatchaLight,
                  border: Border.all(
                    color: LevTheme.levMatcha,
                    width: _isHolding ? 3.5 : 2.0,
                  ),
                  boxShadow: _isHolding
                      ? [
                          BoxShadow(
                            color: LevTheme.levMatcha.withValues(alpha: 0.35),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ]
                      : LevTheme.softShadow,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isHolding ? Icons.favorite_rounded : Icons.touch_app_rounded,
                        size: 40,
                        color: LevTheme.levMatchaDark,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isHolding ? 'Aquí estoy' : 'Presiona',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levMatchaDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// WIDGET 4: DESLIZAMIENTO DE TENSIÓN — Soltar la tensión arrastrando
// ============================================================================
class SlideReleaseWidget extends StatefulWidget {
  const SlideReleaseWidget({super.key});

  @override
  State<SlideReleaseWidget> createState() => _SlideReleaseWidgetState();
}

class _SlideReleaseWidgetState extends State<SlideReleaseWidget>
    with TickerProviderStateMixin {
  late final AnimationController _levController;
  late final AnimationController _shakeController;
  double _tensionLevel = 1.0; // 1.0 = máxima tensión, 0.0 = relajado
  bool _isReleased = false;

  @override
  void initState() {
    super.initState();
    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Arranca con sacudida para mostrar tensión
    _shakeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _levController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onSliderChange(double value) {
    setState(() {
      _tensionLevel = value;
      _isReleased = value < 0.15;
    });
    if (_isReleased && _shakeController.isAnimating) {
      _shakeController.stop();
    } else if (!_isReleased && !_shakeController.isAnimating) {
      _shakeController.repeat(reverse: true);
    }
    HapticsHelper.selection();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_levController, _shakeController]),
      builder: (context, child) {
        final shakeX = _tensionLevel > 0.2
            ? sin(_levController.value * 2 * pi * 10) * 6 * _tensionLevel
            : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lev: sacudida si tensión alta, calma si baja
            Transform.translate(
              offset: Offset(shakeX, 0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: LivingSeedSpiritPainter(
                    animationValue: _levController.value,
                    emotion: _isReleased ? LevEmotion.happy : LevEmotion.peaceful,
                    isPetting: _isReleased,
                    sizeScale: 0.9,
                    happyProgress: _isReleased ? 1.0 : 0.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _isReleased
                    ? 'Lev siente la calma en ti'
                    : 'Desliza hacia abajo para soltar',
                key: ValueKey(_isReleased),
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _isReleased ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Slider vertical de tensión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tensión', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFE76F51))),
                      Text('Calma', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LevTheme.levMatchaDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 18),
                      activeTrackColor: Color.lerp(const Color(0xFFE76F51), LevTheme.levMatcha, 1 - _tensionLevel),
                      inactiveTrackColor: LevTheme.levMatchaLight,
                      thumbColor: Color.lerp(const Color(0xFFE76F51), LevTheme.levMatcha, 1 - _tensionLevel),
                    ),
                    child: Slider(
                      value: _tensionLevel,
                      onChanged: _onSliderChange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// WIDGET 5: RASTREO OCULAR — Lev se mueve en figura 8, usuario lo sigue
// ============================================================================
class EyeTrackerWidget extends StatefulWidget {
  const EyeTrackerWidget({super.key});

  @override
  State<EyeTrackerWidget> createState() => _EyeTrackerWidgetState();
}

class _EyeTrackerWidgetState extends State<EyeTrackerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _levController;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _levController.dispose();
    super.dispose();
  }

  Offset _calcPosition(double t, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final cycle = t * 2 * pi;
    final x = cx + sin(cycle) * (size.width * 0.30);
    final y = cy + sin(cycle * 2) * (size.height * 0.20);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbitController, _levController]),
      builder: (context, child) {
        return SizedBox(
          width: 320,
          height: 320,
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sigue a Lev con los ojos y el dedo',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final pos = _calcPosition(_orbitController.value, size);

                  return GestureDetector(
                    onPanUpdate: (d) {
                      final dist = (d.localPosition - pos).distance;
                      setState(() => _isFollowing = dist < 60);
                    },
                    onPanEnd: (_) => setState(() => _isFollowing = false),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2D28),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Stack(
                        children: [
                          // Estela orbital
                          CustomPaint(
                            size: size,
                            painter: _OrbitalTrailPainter(_orbitController.value),
                          ),
                          // Lev flotando en la órbita
                          Positioned(
                            left: pos.dx - 44,
                            top: pos.dy - 44,
                            child: SizedBox(
                              width: 88,
                              height: 88,
                              child: CustomPaint(
                                painter: LivingSeedSpiritPainter(
                                  animationValue: _levController.value,
                                  emotion: _isFollowing ? LevEmotion.happy : LevEmotion.peaceful,
                                  isPetting: _isFollowing,
                                  sizeScale: 0.45,
                                  happyProgress: _isFollowing ? 1.0 : 0.0,
                                ),
                              ),
                            ),
                          ),
                          if (_isFollowing)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: LevTheme.levMatchaLight,
                                  borderRadius: LevTheme.pillRadius,
                                ),
                                child: Text(
                                  'En sintonía',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levMatchaDark,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
  }
}

class _OrbitalTrailPainter extends CustomPainter {
  final double progress;
  _OrbitalTrailPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final paint = Paint()
      ..color = const Color(0xFF7ACB9E).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    for (double i = 0; i <= 1.0; i += 0.02) {
      final cycle = i * 2 * pi;
      final x = cx + sin(cycle) * (size.width * 0.30);
      final y = cy + sin(cycle * 2) * (size.height * 0.20);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ============================================================================
// WIDGET 6: CONTADOR DE RESPIRACIÓN — Cuenta ciclos con Lev
// ============================================================================
class CountingBreathWidget extends StatefulWidget {
  final int targetCycles;
  const CountingBreathWidget({super.key, this.targetCycles = 6});

  @override
  State<CountingBreathWidget> createState() => _CountingBreathWidgetState();
}

class _CountingBreathWidgetState extends State<CountingBreathWidget>
    with TickerProviderStateMixin {
  late final AnimationController _levController;
  late final AnimationController _breathAnim;
  int _completedCycles = 0;
  bool _isInhaling = true;

  @override
  void initState() {
    super.initState();
    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _breathAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isInhaling = false);
          _breathAnim.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _isInhaling = true;
            _completedCycles++;
          });
          if (_completedCycles < widget.targetCycles) {
            _breathAnim.forward();
          }
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _levController.dispose();
    _breathAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_levController, _breathAnim]),
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.75 + _breathAnim.value * 0.25,
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: LivingSeedSpiritPainter(
                    animationValue: _levController.value,
                    emotion: LevEmotion.breathing,
                    isPetting: false,
                    sizeScale: 0.9,
                    breathingProgress: _breathAnim.value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isInhaling ? 'Inhala...' : 'Exhala...',
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _isInhaling ? const Color(0xFF6A994E) : const Color(0xFF5C85A0),
              ),
            ),
            const SizedBox(height: 12),
            // Indicador de ciclos como puntos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.targetCycles, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i < _completedCycles ? 12 : 8,
                    height: i < _completedCycles ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _completedCycles
                          ? LevTheme.levMatcha
                          : LevTheme.levBorder,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '$_completedCycles / ${widget.targetCycles} ciclos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: LevTheme.levTextMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}
