import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';

/// Modal o pantalla para abrir cualquiera de los minijuegos somáticos de concentración.
class SomaticMinigameModal {
  static void open(BuildContext context, {required int initialGameIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SomaticMinigamesContainer(initialIndex: initialGameIndex),
    );
  }
}

class SomaticMinigamesContainer extends StatefulWidget {
  final int initialIndex;

  const SomaticMinigamesContainer({super.key, required this.initialIndex});

  @override
  State<SomaticMinigamesContainer> createState() => _SomaticMinigamesContainerState();
}

class _SomaticMinigamesContainerState extends State<SomaticMinigamesContainer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: LevTheme.levCream,
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Indicador de arrastre
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: LevTheme.levBorder,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Pestañas de minijuegos superiores (estilo cápsula táctil)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGameTab(0, '🫧 Burbujas'),
                const SizedBox(width: 8),
                _buildGameTab(1, '🪨 Arena Zen'),
                const SizedBox(width: 8),
                _buildGameTab(2, '✨ Foco de Luz'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Área interactiva del juego activo
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                BubblePopMinigame(),
                ZenSandMinigame(),
                LightTrackerMinigame(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTab(int index, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticsHelper.selection();
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: LevTheme.pillRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? LevTheme.levMatchaDark : Colors.white,
            borderRadius: LevTheme.pillRadius,
            border: Border.all(
              color: isSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
            ),
            boxShadow: isSelected ? LevTheme.glowShadow : LevTheme.softShadow,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : LevTheme.levTextDark,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. MINIJUEGO: POP DE BURBUJAS SOMÁTICAS (DESCARGA MOTORA Y DE DOPAMINA)
// ============================================================================

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
// 2. MINIJUEGO: EL JARDÍN DE ARENA ZEN (TRAZADO TÁCTIL Y GROUNDING)
// ============================================================================

class ZenSandMinigame extends StatefulWidget {
  const ZenSandMinigame({super.key});

  @override
  State<ZenSandMinigame> createState() => _ZenSandMinigameState();
}

class _ZenSandMinigameState extends State<ZenSandMinigame> {
  final List<Offset> _points = [];

  void _clearSand() {
    HapticsHelper.light();
    setState(() {
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Traza ondas lentas con tu dedo',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _clearSand,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Limpiar arena'),
                style: TextButton.styleFrom(
                  foregroundColor: LevTheme.levMatchaDark,
                  textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: GestureDetector(
                onPanDown: (details) {
                  HapticsHelper.selection();
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF2ECE1), // Arena zen cálida
                  child: CustomPaint(
                    painter: _ZenSandPainter(points: _points),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ZenSandPainter extends CustomPainter {
  final List<Offset> points;

  _ZenSandPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Textura de arena suave con sutiles líneas de rastrillo
    final sandPaint = Paint()
      ..color = const Color(0xFFE5DCCE).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (double y = 20; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), sandPaint);
    }

    // 2. Tres piedras de río con musgo
    _drawRiverStone(canvas, Offset(size.width * 0.32, size.height * 0.38), 34, const Color(0xFF5A626A));
    _drawRiverStone(canvas, Offset(size.width * 0.72, size.height * 0.58), 28, const Color(0xFF4C555E));
    _drawRiverStone(canvas, Offset(size.width * 0.45, size.height * 0.72), 22, const Color(0xFF6B7280));

    // 3. Trazo del dedo del usuario (surco de rastreo)
    if (points.length > 1) {
      final furrowPaint = Paint()
        ..color = const Color(0xFFD4C8B5)
        ..strokeWidth = 16.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final innerPaint = Paint()
        ..color = const Color(0xFFC7B9A3)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      canvas.drawPath(path, furrowPaint);
      canvas.drawPath(path, innerPaint);
    }
  }

  void _drawRiverStone(Canvas canvas, Offset center, double radius, Color color) {
    // Sombra suave de la piedra
    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 4), width: radius * 2.2, height: radius * 1.5),
      shadowPaint,
    );

    // Cuerpo de la piedra
    final stonePaint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2.0, height: radius * 1.4),
      stonePaint,
    );

    // Toque de musgo botánico en la orilla
    final mossPaint = Paint()..color = const Color(0xFF7A9A60).withValues(alpha: 0.75);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.35, center.dy - radius * 0.2), width: radius * 0.8, height: radius * 0.5),
      mossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ZenSandPainter oldDelegate) => true;
}

// ============================================================================
// 3. MINIJUEGO: EL FOCO DE LUZ / LUCIÉRNAGA DE LEV (RASTREO EMDR)
// ============================================================================

class LightTrackerMinigame extends StatefulWidget {
  const LightTrackerMinigame({super.key});

  @override
  State<LightTrackerMinigame> createState() => _LightTrackerMinigameState();
}

class _LightTrackerMinigameState extends State<LightTrackerMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    // Órbita armónica lenta en figura 8 (6 segundos por ciclo completo)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sigue la luz con tu mirada y tu dedo',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isFollowing ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Text(
                    '✨ En sintonía',
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
        const SizedBox(height: 8),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: GestureDetector(
                onPanDown: (details) => _checkTouch(details.localPosition),
                onPanUpdate: (details) => _checkTouch(details.localPosition),
                onPanEnd: (_) => setState(() => _isFollowing = false),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF22352E), // Bosque nocturno relajante
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _LightOrbPainter(
                          progress: _controller.value,
                          isFollowing: _isFollowing,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _checkTouch(Offset touch) {
    // Comprobar cercanía a la órbita de luz
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final orbPos = _LightOrbPainter.calculateOrbPosition(
        _controller.value,
        renderBox.size,
      );
      final dist = (touch - orbPos).distance;
      if (dist < 60) {
        if (!_isFollowing) {
          HapticsHelper.light();
        }
        setState(() => _isFollowing = true);
      } else {
        setState(() => _isFollowing = false);
      }
    }
  }
}

class _LightOrbPainter extends CustomPainter {
  final double progress;
  final bool isFollowing;

  _LightOrbPainter({required this.progress, required this.isFollowing});

  static Offset calculateOrbPosition(double t, Size size) {
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final cycle = t * 2 * pi;

    // Curva de Lissajous armónica suave (figura 8)
    final x = centerX + sin(cycle) * (size.width * 0.35);
    final y = centerY + sin(cycle * 2) * (size.height * 0.28);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final orbPos = calculateOrbPosition(progress, size);

    // 1. Estela de luz tenue
    final trailPaint = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 0.12)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double i = 0; i <= 1.0; i += 0.02) {
      final p = calculateOrbPosition(i, size);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, trailPaint);

    // 2. Halo áurico brillante
    final haloRadius = isFollowing ? 54.0 : 38.0;
    final haloPaint = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: isFollowing ? 0.55 : 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(orbPos, haloRadius, haloPaint);

    // 3. Núcleo de la luciérnaga
    final corePaint = Paint()..color = const Color(0xFFFFFDE7);
    canvas.drawCircle(orbPos, 8.0, corePaint);
  }

  @override
  bool shouldRepaint(covariant _LightOrbPainter oldDelegate) => true;
}
