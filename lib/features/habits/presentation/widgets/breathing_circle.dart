import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/lev_theme.dart';
import '../../../../core/utils/haptics_helper.dart';

enum BreathPhase {
  inhale,
  hold,
  exhale,
}

class BreathingCircle extends StatefulWidget {
  final int totalSeconds;
  final bool isPhysiologicalSigh;

  const BreathingCircle({
    super.key,
    required this.totalSeconds,
    this.isPhysiologicalSigh = false,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  BreathPhase _currentPhase = BreathPhase.inhale;

  @override
  void initState() {
    super.initState();
    // Ciclo de respiración: 8 segundos para suspiro fisiológico o 8s estándar
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.isPhysiologicalSigh ? 8 : 8),
    )..addListener(_onAnimationTick);

    _controller.repeat();
  }

  void _onAnimationTick() {
    final value = _controller.value;
    BreathPhase newPhase;

    if (widget.isPhysiologicalSigh) {
      // 0.0 - 0.25 (2s): Inhala nariz
      // 0.25 - 0.375 (1s): Inhala extra
      // 0.375 - 1.0 (5s): Exhala largo boca
      if (value < 0.25) {
        newPhase = BreathPhase.inhale;
      } else if (value < 0.375) {
        newPhase = BreathPhase.hold;
      } else {
        newPhase = BreathPhase.exhale;
      }
    } else {
      // 4s inhala, 4s exhala
      if (value < 0.5) {
        newPhase = BreathPhase.inhale;
      } else {
        newPhase = BreathPhase.exhale;
      }
    }

    if (newPhase != _currentPhase) {
      setState(() {
        _currentPhase = newPhase;
      });
      HapticsHelper.selection();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _phaseLabel {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return 'Inhala profundo...';
      case BreathPhase.hold:
        return widget.isPhysiologicalSigh ? 'Un extra de aire...' : 'Sostén con calma...';
      case BreathPhase.exhale:
        return 'Exhala suave y largo...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        double scale;
        if (widget.isPhysiologicalSigh) {
          if (val < 0.25) {
            scale = 0.75 + (val / 0.25) * 0.25; // 0.75 a 1.0
          } else if (val < 0.375) {
            scale = 1.0 + ((val - 0.25) / 0.125) * 0.12; // 1.0 a 1.12
          } else {
            scale = 1.12 - ((val - 0.375) / 0.625) * 0.37; // 1.12 a 0.75
          }
        } else {
          scale = 0.8 + (sin(val * 2 * pi - pi / 2) + 1) * 0.15;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo exterior suave pulsante
                  Transform.scale(
                    scale: scale * 1.18,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LevTheme.levMatcha.withValues(alpha: 0.12),
                      ),
                    ),
                  ),

                  // Círculo somático central
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _currentPhase == BreathPhase.exhale
                                ? LevTheme.levSky
                                : LevTheme.levMatchaLight,
                            _currentPhase == BreathPhase.hold
                                ? LevTheme.levPeach.withValues(alpha: 0.8)
                                : LevTheme.levMatcha,
                          ],
                        ),
                        boxShadow: LevTheme.glowShadow,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.air_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _phaseLabel,
                key: ValueKey(_phaseLabel),
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

