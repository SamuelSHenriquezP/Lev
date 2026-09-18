import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';

// ============================================================================
// 1. GUÍA DE RESPIRACIÓN SOMÁTICA — Pensada para realizar con ojos cerrados
enum BreathPattern {
  physiologicalSigh, // Inhala 2s + Inhala extra 1s + Exhala largo 5s = 8s
  boxBreathing,      // Inhala 4s + Retén 4s + Exhala 4s + Pausa vacío 4s = 16s
  fourSevenEight,    // Inhala 4s + Retén 7s + Exhala 8s = 19s
  coherent,          // Inhala 5s + Exhala 5s = 10s
  standardCalm,      // Inhala 4s + Retén 2s + Exhala 5s = 11s
}

// ============================================================================
// 1. GUÍA DE RESPIRACIÓN SOMÁTICA — Calibración precisa y tiempos realistas
// ============================================================================
class BreathGuideWidget extends StatefulWidget {
  final BreathPattern pattern;
  final bool isPhysiologicalSigh;
  final ValueChanged<bool>? onCycleComplete;

  const BreathGuideWidget({
    super.key,
    this.pattern = BreathPattern.standardCalm,
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
  String _lastPhase = '';

  BreathPattern get _effectivePattern {
    if (widget.isPhysiologicalSigh) return BreathPattern.physiologicalSigh;
    return widget.pattern;
  }

  int get _patternDurationMs {
    switch (_effectivePattern) {
      case BreathPattern.physiologicalSigh:
        return 8000; // 2s + 1s + 5s
      case BreathPattern.boxBreathing:
        return 16000; // 4s + 4s + 4s + 4s
      case BreathPattern.fourSevenEight:
        return 19000; // 4s + 7s + 8s
      case BreathPattern.coherent:
        return 10000; // 5s + 5s
      case BreathPattern.standardCalm:
        return 11000; // 4s + 2s + 5s
    }
  }

  @override
  void initState() {
    super.initState();
    _levController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _breathController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _patternDurationMs),
    )..addStatusListener(_onBreathStatus)..repeat();
  }

  void _onBreathStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.forward) {
      HapticsHelper.light();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _levController]),
      builder: (context, child) {
        final t = _breathController.value;
        final totalSec = _patternDurationMs / 1000.0;
        final currentSec = t * totalSec;

        String phase;
        int remainingSecInPhase;
        Color phaseColor;
        double levScale;

        switch (_effectivePattern) {
          case BreathPattern.physiologicalSigh:
            // 0s - 2s: Inhala (2s)
            // 2s - 3s: Inhala extra (1s)
            // 3s - 8s: Exhala largo (5s)
            if (currentSec < 2.0) {
              phase = 'Inhala profundo...';
              remainingSecInPhase = (2.0 - currentSec).ceil();
              phaseColor = const Color(0xFF6A994E);
              levScale = 0.70 + (currentSec / 2.0) * 0.22;
            } else if (currentSec < 3.0) {
              phase = 'Inhala un poco más...';
              remainingSecInPhase = (3.0 - currentSec).ceil();
              phaseColor = const Color(0xFF80B918);
              levScale = 0.92 + ((currentSec - 2.0) / 1.0) * 0.08;
            } else {
              phase = 'Exhala largo y suelta...';
              remainingSecInPhase = (8.0 - currentSec).ceil();
              phaseColor = const Color(0xFF5C85A0);
              levScale = 1.0 - ((currentSec - 3.0) / 5.0) * 0.30;
            }
            break;

          case BreathPattern.boxBreathing:
            // 0s - 4s: Inhala (4s)
            // 4s - 8s: Sostén lleno (4s)
            // 8s - 12s: Exhala (4s)
            // 12s - 16s: Pausa vacío (4s)
            if (currentSec < 4.0) {
              phase = 'Inhala...';
              remainingSecInPhase = (4.0 - currentSec).ceil();
              phaseColor = const Color(0xFF6A994E);
              levScale = 0.70 + (currentSec / 4.0) * 0.30;
            } else if (currentSec < 8.0) {
              phase = 'Sostén lleno...';
              remainingSecInPhase = (8.0 - currentSec).ceil();
              phaseColor = const Color(0xFFD4A373);
              levScale = 1.0;
            } else if (currentSec < 12.0) {
              phase = 'Exhala suave...';
              remainingSecInPhase = (12.0 - currentSec).ceil();
              phaseColor = const Color(0xFF5C85A0);
              levScale = 1.0 - ((currentSec - 8.0) / 4.0) * 0.30;
            } else {
              phase = 'Pausa en quietud...';
              remainingSecInPhase = (16.0 - currentSec).ceil();
              phaseColor = const Color(0xFF9E8FB2);
              levScale = 0.70;
            }
            break;

          case BreathPattern.fourSevenEight:
            // 0s - 4s: Inhala (4s)
            // 4s - 11s: Sostén (7s)
            // 11s - 19s: Exhala en 8s
            if (currentSec < 4.0) {
              phase = 'Inhala por la nariz...';
              remainingSecInPhase = (4.0 - currentSec).ceil();
              phaseColor = const Color(0xFF6A994E);
              levScale = 0.70 + (currentSec / 4.0) * 0.30;
            } else if (currentSec < 11.0) {
              phase = 'Retén en calma...';
              remainingSecInPhase = (11.0 - currentSec).ceil();
              phaseColor = const Color(0xFFD4A373);
              levScale = 1.0;
            } else {
              phase = 'Exhala por la boca...';
              remainingSecInPhase = (19.0 - currentSec).ceil();
              phaseColor = const Color(0xFF5C85A0);
              levScale = 1.0 - ((currentSec - 11.0) / 8.0) * 0.30;
            }
            break;

          case BreathPattern.coherent:
            // 0s - 5s: Inhala
            // 5s - 10s: Exhala
            if (currentSec < 5.0) {
              phase = 'Inhala continuo...';
              remainingSecInPhase = (5.0 - currentSec).ceil();
              phaseColor = const Color(0xFF6A994E);
              levScale = 0.70 + (currentSec / 5.0) * 0.30;
            } else {
              phase = 'Exhala sereno...';
              remainingSecInPhase = (10.0 - currentSec).ceil();
              phaseColor = const Color(0xFF5C85A0);
              levScale = 1.0 - ((currentSec - 5.0) / 5.0) * 0.30;
            }
            break;

          case BreathPattern.standardCalm:
            // 0s - 4s: Inhala
            // 4s - 6s: Sostén
            // 6s - 11s: Exhala
            if (currentSec < 4.0) {
              phase = 'Inhala paz...';
              remainingSecInPhase = (4.0 - currentSec).ceil();
              phaseColor = const Color(0xFF6A994E);
              levScale = 0.70 + (currentSec / 4.0) * 0.30;
            } else if (currentSec < 6.0) {
              phase = 'Sostén...';
              remainingSecInPhase = (6.0 - currentSec).ceil();
              phaseColor = const Color(0xFFB7A648);
              levScale = 1.0;
            } else {
              phase = 'Exhala tensión...';
              remainingSecInPhase = (11.0 - currentSec).ceil();
              phaseColor = const Color(0xFF5C85A0);
              levScale = 1.0 - ((currentSec - 6.0) / 5.0) * 0.30;
            }
            break;
        }

        // Háptica al cambiar de fase
        if (phase != _lastPhase) {
          _lastPhase = phase;
          HapticsHelper.selection();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lev animado que respira con el usuario
            Transform.scale(
              scale: levScale,
              child: SizedBox(
                width: 170,
                height: 170,
                child: CustomPaint(
                  painter: LivingSeedSpiritPainter(
                    animationValue: _levController.value,
                    emotion: LevEmotion.breathing,
                    isPetting: false,
                    sizeScale: 0.85,
                    breathingProgress: (levScale - 0.70) / 0.30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fase actual y segundero realista
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: phaseColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: phaseColor.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phase,
                    style: GoogleFonts.quicksand(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: phaseColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: phaseColor.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${remainingSecInPhase}s',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: phaseColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Indicación para no mirar la pantalla
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bedtime_outlined, size: 14, color: LevTheme.levMatchaDark),
                const SizedBox(width: 6),
                Text(
                  'Puedes cerrar tus ojos y seguir el pulso suave',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : LevTheme.levTextMuted,
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
// 2. GUÍA DE ACCIÓN EN EL ENTORNO REAL (Audio & Grounding Fuera de Pantalla)
// ============================================================================
class AudioGroundingCard extends StatelessWidget {
  final String title;
  final String actionPrompt;
  final String physiologicalNote;

  const AudioGroundingCard({
    super.key,
    required this.title,
    required this.actionPrompt,
    this.physiologicalNote = 'Deja tu teléfono a un lado y conecta con lo tangible.',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.3)),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: LevTheme.levMatcha.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📵', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  'Acción Fuera de Pantalla',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            actionPrompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : const Color(0xFFF7F5EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              physiologicalNote,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: isDark ? Colors.white60 : LevTheme.levTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. GUÍA DE LIBERACIÓN POSTURAL FÍSICA
// ============================================================================
class PostureReleaseCard extends StatelessWidget {
  final String focusArea;
  final String instructions;

  const PostureReleaseCard({
    super.key,
    required this.focusArea,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.35)),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A373).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌿', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  'Liberación Física: $focusArea',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8C5824),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            instructions,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aleja el teléfono de tus ojos. Suelta la tensión muscular.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. GUÍA DE ANCLAJE SENSORIAL EN EL MUNDO REAL
// ============================================================================
class SensoryAnchorCard extends StatelessWidget {
  final String sensoryPrompt;

  const SensoryAnchorCard({
    super.key,
    required this.sensoryPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF5C85A0).withValues(alpha: 0.35)),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5C85A0).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👁️', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  'Conexión con el Entorno Real',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B5B7E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            sensoryPrompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Despega la mirada de la pantalla hacia tu alrededor físico.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. GOLPETEO BILATERAL (ABRAZO DE LA MARIPOSA EMDR EN EL CUERPO REAL)
// Ya no es un juego de botones en la pantalla, sino una guía para tu cuerpo
// ============================================================================
class BilateralTapWidget extends StatefulWidget {
  const BilateralTapWidget({super.key});

  @override
  State<BilateralTapWidget> createState() => _BilateralTapWidgetState();
}

class _BilateralTapWidgetState extends State<BilateralTapWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isLeftTurn = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isLeftTurn = !_isLeftTurn);
          HapticsHelper.light();
          _pulseController.forward(from: 0.0);
        }
      })..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.3)),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: LevTheme.levMatcha.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🦋', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  'Abrazo de la Mariposa (EMDR)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cruza tus brazos sobre el pecho, apoyando tus manos sobre tus hombros.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 18),
          // Indicador de ritmo bilateral sutil
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShoulderIndicator('Hombro Izquierdo', _isLeftTurn, isDark),
              const SizedBox(width: 16),
              _buildShoulderIndicator('Hombro Derecho', !_isLeftTurn, isDark),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Da toquecitos alternados en tu cuerpo. Cierra los ojos si lo deseas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoulderIndicator(String label, bool isActive, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? LevTheme.levMatcha.withValues(alpha: 0.25)
            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? LevTheme.levMatcha : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 12.5,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? LevTheme.levMatchaDark : (isDark ? Colors.white54 : LevTheme.levTextMuted),
        ),
      ),
    );
  }
}

// ============================================================================
// 6. AUTOCOMPASIÓN SOMÁTICA (MANO EN EL PECHO) — Reemplazo de HoldPressure
// ============================================================================
class HoldPressureWidget extends StatelessWidget {
  const HoldPressureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE76F51).withValues(alpha: 0.3)),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE76F51).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🤲', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  'Tacto Calmante (Liberación de Oxitocina)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD65A31),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Coloca una o ambas manos sobre el centro de tu pecho o sobre tus mejillas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Siente el calor de tus manos y el latido tranquilo de tu corazón. Deja el teléfono a tu lado.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 7. DESCARGA FÍSICA DE TENSIÓN — Reemplazo de SlideRelease
// ============================================================================
class SlideReleaseWidget extends StatelessWidget {
  const SlideReleaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE9C46A).withValues(alpha: 0.35)),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9C46A).withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  'Soltar Tensión Muscular',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB08924),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Inhala profundo tensando tus hombros hacia las orejas... y al exhalar, suéltalos de golpe con un suspiro sonoro.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Repite 3 veces en tu cuerpo real sin tocar la pantalla.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 8. DESCANSO OCULAR HACIA EL HORIZONTE — Reemplazo de EyeTracker
// ============================================================================
class EyeTrackerWidget extends StatelessWidget {
  const EyeTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF2A9D8F).withValues(alpha: 0.35)),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A9D8F).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👁️', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  'Regla 20-20-20 (Descanso Lejano)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B6A60),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Despega la mirada de tu teléfono. Mira hacia una ventana o hacia el objeto más lejano que veas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Parpadea suavemente para hidratar tus ojos cansados de la pantalla.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 9. CONTADOR DE RESPIRACIONES SERENO
// ============================================================================
class CountingBreathWidget extends StatefulWidget {
  final int targetCycles;
  const CountingBreathWidget({super.key, this.targetCycles = 6});

  @override
  State<CountingBreathWidget> createState() => _CountingBreathWidgetState();
}

class _CountingBreathWidgetState extends State<CountingBreathWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathAnim;
  int _completedCycles = 0;
  bool _isInhaling = true;

  @override
  void initState() {
    super.initState();
    _breathAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isInhaling = false);
          HapticsHelper.light();
          _breathAnim.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _isInhaling = true;
            _completedCycles++;
          });
          HapticsHelper.selection();
          if (_completedCycles < widget.targetCycles) {
            _breathAnim.forward();
          }
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _breathAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: _isInhaling
                ? const Color(0xFF6A994E).withValues(alpha: 0.15)
                : const Color(0xFF5C85A0).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isInhaling ? 'Inhala suavemente...' : 'Exhala y suelta...',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _isInhaling ? const Color(0xFF6A994E) : const Color(0xFF5C85A0),
            ),
          ),
        ),
        const SizedBox(height: 14),
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
                      : (isDark ? Colors.white24 : LevTheme.levBorder),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          '$_completedCycles / ${widget.targetCycles} respiraciones conscientes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: isDark ? Colors.white60 : LevTheme.levTextMuted,
          ),
        ),
      ],
    );
  }
}
