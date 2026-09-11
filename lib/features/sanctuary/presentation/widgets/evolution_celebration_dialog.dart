import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'living_seed_spirit_painter.dart';

/// Modal cinemático de celebración cuando Lev alcanza una nueva etapa evolutiva.
class EvolutionCelebrationDialog extends StatefulWidget {
  final LevGrowthStage stage;
  final VoidCallback onDismiss;

  const EvolutionCelebrationDialog({
    super.key,
    required this.stage,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required LevGrowthStage stage,
    required VoidCallback onDismiss,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'EvolutionCelebration',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 550),
      pageBuilder: (context, anim1, anim2) {
        return EvolutionCelebrationDialog(
          stage: stage,
          onDismiss: () {
            Navigator.of(context).pop();
            onDismiss();
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  State<EvolutionCelebrationDialog> createState() => _EvolutionCelebrationDialogState();
}

class _EvolutionCelebrationDialogState extends State<EvolutionCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getStageName(LevGrowthStage stage) {
    switch (stage) {
      case LevGrowthStage.seed: return 'Semilla de Luz';
      case LevGrowthStage.sprout: return 'Brote Tierno';
      case LevGrowthStage.seedling: return 'Plántula Radiante';
      case LevGrowthStage.youngPlant: return 'Planta Joven';
      case LevGrowthStage.vibrantPlant: return 'Planta en Floración';
      case LevGrowthStage.youngTree: return 'Árbol Juvenil';
      case LevGrowthStage.adultTree: return 'Guardián del Estanque';
      case LevGrowthStage.forestSpirit: return 'Espíritu Sagrado del Bosque';
    }
  }

  String _getStageDescription(LevGrowthStage stage) {
    switch (stage) {
      case LevGrowthStage.seed:
        return 'En la quietud de la tierra descansa la promesa de toda la vida.';
      case LevGrowthStage.sprout:
        return 'Tus pequeñas pausas han roto la cáscara. Una brizna de luz emerge con timidez.';
      case LevGrowthStage.seedling:
        return 'Lev abre sus ojos al mundo. Tus momentos de calma le dan fuerza para erguirse.';
      case LevGrowthStage.youngPlant:
        return 'Hojas verdes y firmes. La constancia ha transformado el esfuerzo en armonía.';
      case LevGrowthStage.vibrantPlant:
        return 'Brotan capullos de luz en las puntas. Tu autocuidado está floreciendo con color.';
      case LevGrowthStage.youngTree:
        return 'Raíces profundas y ramas generosas. Ya eres refugio para tu propia mente.';
      case LevGrowthStage.adultTree:
        return 'Una copa frondosa que protege el santuario. Has forjado un hogar de paz interior.';
      case LevGrowthStage.forestSpirit:
        return 'La cúspide de la maduración botánica. Eres calma viva, guardián y florecimiento eterno.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stageName = _getStageName(widget.stage);
    final stageDesc = _getStageDescription(widget.stage);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14211D) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: LevTheme.levMatcha.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: LevTheme.levMatcha.withValues(alpha: 0.35),
                blurRadius: 36,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge superior
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: LevTheme.levMatchaLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: LevTheme.levMatchaDark),
                    const SizedBox(width: 6),
                    Text(
                      '¡NUEVA ETAPA BOTÁNICA!',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: LevTheme.levMatchaDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Visual de Lev evolucionado con halo pulsante
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = sin(_pulseController.value * 2 * pi);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 190 + pulse * 14,
                        height: 190 + pulse * 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              LevTheme.levMatcha.withValues(alpha: 0.30 + pulse * 0.08),
                              LevTheme.levMatcha.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF1B2E28) : LevTheme.levCream,
                          border: Border.all(
                            color: LevTheme.levMatcha.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: CustomPaint(
                          size: const Size(150, 150),
                          painter: LivingSeedSpiritPainter(
                            animationValue: _pulseController.value,
                            emotion: LevEmotion.celebrating,
                            isPetting: false,
                            growthStage: widget.stage,
                            sizeScale: 0.88,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              Text(
                stageName,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  stageDesc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    height: 1.45,
                    color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón de agradecimiento
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticsHelper.medium();
                    widget.onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levMatcha,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.spa_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Continuar Floreciendo',
                        style: GoogleFonts.quicksand(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

