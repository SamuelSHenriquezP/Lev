import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'sanctuary_pond_painter.dart';

class LivingHabitatCard extends ConsumerStatefulWidget {
  const LivingHabitatCard({super.key});

  @override
  ConsumerState<LivingHabitatCard> createState() => _LivingHabitatCardState();
}

class _LivingHabitatCardState extends ConsumerState<LivingHabitatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Física continua de seguimiento suave con inercia acuática y muelle elástico de retorno
  Offset _currentSmoothedOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  Offset _touchVelocity = Offset.zero;
  double _currentInfluence = 0.0;
  double _targetInfluence = 0.0;
  Offset? _touchPosition;
  bool _isFingerActive = false;
  final DateTime _animStartTime = DateTime.now();
  double get _continuousTime =>
      DateTime.now().difference(_animStartTime).inMicroseconds / 3600000.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..addListener(_onTick)..repeat();
  }

  void _onTick() {
    if (!mounted) return;

    Offset nextOffset;
    if (_isFingerActive) {
      nextOffset = Offset.lerp(_currentSmoothedOffset, _targetOffset, 0.20)!;
      _touchVelocity = nextOffset - _currentSmoothedOffset;
    } else {
      // Retorno elástico amortiguado orgánico al soltar el dedo
      const double springStiffness = 0.12;
      const double fluidDamping = 0.82;
      _touchVelocity = (_touchVelocity + (_targetOffset - _currentSmoothedOffset) * springStiffness) * fluidDamping;
      if (_touchVelocity.distance > 0.12) {
        _touchVelocity = (_touchVelocity / _touchVelocity.distance) * 0.12;
      }
      nextOffset = _currentSmoothedOffset + _touchVelocity;

      if (nextOffset.distanceSquared < 0.00002 && _touchVelocity.distanceSquared < 0.00002) {
        nextOffset = Offset.zero;
        _touchVelocity = Offset.zero;
      }
    }

    final nextInfluence = (lerpDouble(_currentInfluence, _targetInfluence, 0.14) ?? 0.0);

    if ((nextOffset - _currentSmoothedOffset).distanceSquared > 0.000001 ||
        (nextInfluence - _currentInfluence).abs() > 0.001) {
      setState(() {
        _currentSmoothedOffset = nextOffset;
        _currentInfluence = nextInfluence;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  ({String label, IconData icon}) _getTimeOfDayBadge(SanctuaryTimeOfDay time) {
    switch (time) {
      case SanctuaryTimeOfDay.morning:
        return (label: 'Mañana', icon: Icons.wb_sunny_rounded);
      case SanctuaryTimeOfDay.afternoon:
        return (label: 'Tarde', icon: Icons.wb_cloudy_rounded);
      case SanctuaryTimeOfDay.dusk:
        return (label: 'Atardecer', icon: Icons.nights_stay_outlined);
      case SanctuaryTimeOfDay.night:
        return (label: 'Noche', icon: Icons.nights_stay_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sanctuary = ref.watch(sanctuaryProvider);

    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: LevTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Lienzo interactivo del estanque con reactividad táctil continua y fluida
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth;
                  final cardHeight = constraints.maxHeight;
                  final centerX = cardWidth * 0.5;
                  final centerY = cardHeight * 0.48;

                  double touchDist = 999.0;
                  if (_touchPosition != null) {
                    final dx = _touchPosition!.dx - centerX;
                    final dy = _touchPosition!.dy - centerY;
                    touchDist = sqrt(dx * dx + dy * dy);
                  }

                  void handleTouch(Offset localPos) {
                    _touchPosition = localPos;
                    _isFingerActive = true;
                    _targetInfluence = 1.0;

                    final dx = localPos.dx - centerX;
                    final dy = localPos.dy - centerY;
                    _targetOffset = Offset(
                      (dx / (cardWidth * 0.5)).clamp(-1.0, 1.0),
                      (dy / (cardHeight * 0.48)).clamp(-1.0, 1.0),
                    );

                    final dist = sqrt(dx * dx + dy * dy);
                    if (dist < 85.0) {
                      ref.read(sanctuaryProvider.notifier).petLev();
                    }
                  }

                  void handleTouchEnd() {
                    // Al levantar el dedo, el objetivo vuelve suavemente al centro
                    _isFingerActive = false;
                    _targetInfluence = 0.0;
                    _targetOffset = Offset.zero;
                    _touchPosition = null;
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (details) => handleTouch(details.localPosition),
                    onPanUpdate: (details) => handleTouch(details.localPosition),
                    onPanEnd: (_) => handleTouchEnd(),
                    onPanCancel: () => handleTouchEnd(),
                    onTapDown: (details) => handleTouch(details.localPosition),
                    onTapUp: (_) => handleTouchEnd(),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(cardWidth, cardHeight),
                          painter: SanctuaryPondPainter(
                            animationValue: _continuousTime,
                            timeOfDay: sanctuary.effectiveTimeOfDay,
                            emotion: sanctuary.emotion,
                            bloomingFlowers: sanctuary.bloomingFlowers,
                            careDrops: sanctuary.careDrops,
                            isPetting: sanctuary.isPetting,
                            growthStage: sanctuary.growthStage,
                            growthFactor: sanctuary.growthFactor,
                            activeDecors: sanctuary.activeDecors,
                            activeAccessory: sanctuary.activeAccessory,
                            touchNormalizedOffset: _currentSmoothedOffset,
                            touchLocalPosition: _touchPosition,
                            isFingerActive: _isFingerActive,
                            touchDistance: _touchPosition != null ? touchDist : (_currentSmoothedOffset.distance * 100.0),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Insignia de Momento del Día en la esquina superior izquierda
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: LevTheme.pillRadius,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final timeInfo = _getTimeOfDayBadge(sanctuary.timeOfDay);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(timeInfo.icon, size: 14, color: LevTheme.levMatchaDark),
                        const SizedBox(width: 5),
                        Text(
                          timeInfo.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: LevTheme.levTextDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(sanctuary.stageMaterialIcon, size: 13, color: LevTheme.levMatchaDark),
                        const SizedBox(width: 4),
                        Text(
                          sanctuary.sanctuaryLevelName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: LevTheme.levMatchaDark,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Flores florecidas en la esquina superior derecha
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: LevTheme.pillRadius,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.spa_rounded, size: 14, color: LevTheme.levMatchaDark),
                    const SizedBox(width: 5),
                    Text(
                      'En calma',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levMatchaDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Burbuja de diálogo tierna de Lev en la parte inferior
            Positioned(
              bottom: 16,
              left: 18,
              right: 18,
              child: GestureDetector(
                onTap: () {
                  ref.read(sanctuaryProvider.notifier).petLev();
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey(sanctuary.dialogue),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sanctuary.isPetting
                            ? LevTheme.levPeach
                            : Colors.white.withValues(alpha: 0.7),
                        width: sanctuary.isPetting ? 1.5 : 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          sanctuary.isPetting ? Icons.favorite_rounded : Icons.chat_bubble_outline_rounded,
                          size: 16,
                          color: sanctuary.isPetting ? LevTheme.levPeach : LevTheme.levMatchaDark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            sanctuary.dialogue,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: LevTheme.levTextDark,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 16,
                          color: LevTheme.levTextMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
