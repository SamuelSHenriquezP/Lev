import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
class BubblePopMinigame extends StatefulWidget {
  const BubblePopMinigame({super.key});

  @override
  State<BubblePopMinigame> createState() => _BubblePopMinigameState();
}

class _BubbleItem {
  final int id;
  double x;
  double y;
  final double radius;
  final double speed;
  final Color color;
  bool isPopped = false;

  _BubbleItem({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.color,
  });
}

class _BubblePopMinigameState extends State<BubblePopMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final List<_BubbleItem> _bubbles = [];
  int _poppedCount = 0;
  final Random _rnd = Random();

  final List<Color> _bubbleColors = [
    const Color(0xFFD0E8F2),
    const Color(0xFFEAF2E8),
    const Color(0xFFFDECE6),
    const Color(0xFFEAE5F7),
    const Color(0xFFFFF2D6),
  ];

  @override
  void initState() {
    super.initState();
    _spawnInitialBubbles();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePhysics)..repeat();
  }

  void _spawnInitialBubbles() {
    for (int i = 0; i < 9; i++) {
      _bubbles.add(_createRandomBubble(randomY: true));
    }
  }

  _BubbleItem _createRandomBubble({bool randomY = false}) {
    return _BubbleItem(
      id: _rnd.nextInt(1000000),
      x: 0.10 + (_rnd.nextDouble() * 0.80),
      y: randomY ? (0.10 + _rnd.nextDouble() * 0.80) : (1.05 + _rnd.nextDouble() * 0.20),
      radius: 28.0 + (_rnd.nextDouble() * 26.0),
      speed: 0.0022 + (_rnd.nextDouble() * 0.0028),
      color: _bubbleColors[_rnd.nextInt(_bubbleColors.length)],
    );
  }

  void _updatePhysics() {
    for (int i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      b.y -= b.speed;
      b.x += sin(b.y * 10) * 0.0012; // suave deriva lateral

      // Si sube más allá del borde superior, renace abajo
      if (b.y < -0.15 || b.isPopped) {
        _bubbles[i] = _createRandomBubble();
      }
    }
    setState(() {});
  }

  void _popBubble(int index) {
    HapticsHelper.light();
    setState(() {
      _bubbles[index].isPopped = true;
      _poppedCount++;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Indicador superior de progreso sereno
        Positioned(
          top: 8,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tensión disuelta: $_poppedCount burbujas',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Explota a tu ritmo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: LevTheme.levTextMuted,
                ),
              ),
            ],
          ),
        ),

        // Lienzo táctil con las burbujas flotantes
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: _bubbles.asMap().entries.map((entry) {
                final idx = entry.key;
                final bubble = entry.value;
                if (bubble.isPopped) return const SizedBox.shrink();

                final px = bubble.x * w;
                final py = bubble.y * h;

                return Positioned(
                  left: px - bubble.radius,
                  top: py - bubble.radius,
                  child: GestureDetector(
                    onTapDown: (_) => _popBubble(idx),
                    child: Container(
                      width: bubble.radius * 2,
                      height: bubble.radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bubble.color.withValues(alpha: 0.65),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: bubble.color.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: bubble.radius * 0.45,
                          height: bubble.radius * 0.45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================