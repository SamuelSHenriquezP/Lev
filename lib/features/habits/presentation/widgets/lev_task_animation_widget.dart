import 'package:flutter/material.dart';
import '../../domain/micro_habit.dart';
import '../../../sanctuary/domain/sanctuary_state.dart';
import '../../../sanctuary/presentation/widgets/living_seed_spirit_painter.dart';

/// Widget interactivo y continuo a 60 FPS que muestra a Lev ejecutando
/// una acción somática específica según la tarea que el usuario va a realizar.
class LevTaskAnimationWidget extends StatefulWidget {
  final LevTaskAction action;
  final double size;
  final bool isMini;

  const LevTaskAnimationWidget({
    super.key,
    required this.action,
    this.size = 140.0,
    this.isMini = false,
  });

  @override
  State<LevTaskAnimationWidget> createState() => _LevTaskAnimationWidgetState();
}

class _LevTaskAnimationWidgetState extends State<LevTaskAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LevEmotion _getEmotionForAction(LevTaskAction action) {
    switch (action) {
      case LevTaskAction.breathing:
        return LevEmotion.breathing;
      case LevTaskAction.eyeRest:
      case LevTaskAction.sleepDrift:
        return LevEmotion.sleeping;
      case LevTaskAction.soothingTouch:
        return LevEmotion.sheltered;
      case LevTaskAction.coldSplash:
        return LevEmotion.happy;
      case LevTaskAction.tensionShake:
        return LevEmotion.curious;
      case LevTaskAction.chestStretch:
      case LevTaskAction.grounding:
      case LevTaskAction.warmTeaHold:
        return LevEmotion.peaceful;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion = _getEmotionForAction(widget.action);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: LivingSeedSpiritPainter(
            animationValue: _controller.value,
            emotion: emotion,
            isPetting: false,
            taskAction: widget.action,
            sizeScale: widget.isMini ? 0.72 : 0.88,
            leafWrapProgress: widget.action == LevTaskAction.soothingTouch ? 0.85 : 0.0,
            sleepProgress: widget.action == LevTaskAction.sleepDrift
                ? 1.0
                : (widget.action == LevTaskAction.eyeRest ? 0.45 : 0.0),
            breathingProgress: widget.action == LevTaskAction.breathing ? 1.0 : 0.0,
          ),
        );
      },
    );
  }
}

/// Insignia compacta que muestra a Lev ejecutando la acción somática
/// en tiempo real para las tarjetas de microhábitos.
class LevTaskBadge extends StatelessWidget {
  final LevTaskAction action;
  final Color bgColor;
  final Color accentColor;
  final double size;

  const LevTaskBadge({
    super.key,
    required this.action,
    required this.bgColor,
    required this.accentColor,
    this.size = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lev somático en miniatura animándose
          Positioned.fill(
            child: OverflowBox(
              maxWidth: size * 1.55,
              maxHeight: size * 1.55,
              child: LevTaskAnimationWidget(
                action: action,
                size: size * 1.55,
                isMini: true,
              ),
            ),
          ),
          // Pequeña insignia de emoji en la esquina superior derecha
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: Text(
                action.badgeEmoji,
                style: const TextStyle(fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

