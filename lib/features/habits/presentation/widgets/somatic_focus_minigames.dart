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

          // Pestañas de minijuegos superiores (estilo cápsula táctil con scroll horizontal para los 7 juegos)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildGameTab(0, 'Burbujas', Icons.bubble_chart_rounded),
                const SizedBox(width: 8),
                _buildGameTab(1, 'Arena Zen', Icons.landscape_rounded),
                const SizedBox(width: 8),
                _buildGameTab(2, 'Foco de Luz', Icons.auto_awesome_rounded),
                const SizedBox(width: 8),
                _buildGameTab(3, 'Estanque', Icons.water_drop_rounded),
                const SizedBox(width: 8),
                _buildGameTab(4, 'Cuenco Zen', Icons.notifications_active_rounded),
                const SizedBox(width: 8),
                _buildGameTab(5, 'Diente León', Icons.nature_people_rounded),
                const SizedBox(width: 8),
                _buildGameTab(6, 'Piedras Zen', Icons.filter_hdr_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Área interactiva del anclaje activo
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                BubblePopMinigame(),
                ZenSandMinigame(),
                LightTrackerMinigame(),
                WaterRippleMinigame(),
                TibetanBowlMinigame(),
                DandelionMinigame(),
                StoneBalanceMinigame(),
              ],
            ),
          ),

          // Invitación activa a soltar la pantalla y volver a la vida real
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticsHelper.medium();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LevTheme.levMatcha,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  'Ya me siento en calma, soltar teléfono 🌿',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTab(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        HapticsHelper.selection();
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: LevTheme.pillRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? LevTheme.levMatchaDark : Colors.white,
          borderRadius: LevTheme.pillRadius,
          border: Border.all(
            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
          ),
          boxShadow: isSelected ? LevTheme.glowShadow : LevTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : LevTheme.levMatchaDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : LevTheme.levTextDark,
              ),
            ),
          ],
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 13, color: LevTheme.levMatchaDark),
                      const SizedBox(width: 4),
                      Text(
                        'En sintonía',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levMatchaDark,
                        ),
                      ),
                    ],
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

// ============================================================================
// 4. MINIJUEGO: GOTAS EN EL ESTANQUE (HIDROTERAPIA Y ONDAS FLUIDAS)
// ============================================================================

class WaterRippleMinigame extends StatefulWidget {
  const WaterRippleMinigame({super.key});

  @override
  State<WaterRippleMinigame> createState() => _WaterRippleMinigameState();
}

class _WaterRipple {
  final Offset center;
  double radius = 0.0;
  final double maxRadius;
  double alpha = 0.85;
  final double speed;
  final Color color;

  _WaterRipple({
    required this.center,
    required this.maxRadius,
    required this.speed,
    required this.color,
  });
}

class _WaterRippleMinigameState extends State<WaterRippleMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_WaterRipple> _ripples = [];
  final Random _rnd = Random();
  int _dropsCount = 0;
  bool _isRainActive = false;
  int _rainTick = 0;
  Offset? _lastDragPoint;

  final List<Color> _rippleColors = [
    const Color(0xFF64B5F6),
    const Color(0xFF81D4FA),
    const Color(0xFF80CBC4),
    const Color(0xFFB2DFDB),
    const Color(0xFFE0F7FA),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();
  }

  void _tick() {
    // Actualizar ondas activas
    for (int i = _ripples.length - 1; i >= 0; i--) {
      final r = _ripples[i];
      r.radius += r.speed;
      r.alpha = (1.0 - (r.radius / r.maxRadius)).clamp(0.0, 1.0) * 0.85;
      if (r.radius >= r.maxRadius) {
        _ripples.removeAt(i);
      }
    }

    // Lógica de lluvia serena automática
    if (_isRainActive) {
      _rainTick++;
      if (_rainTick % 22 == 0) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          final x = 40.0 + _rnd.nextDouble() * (size.width - 80.0);
          final y = 40.0 + _rnd.nextDouble() * (size.height - 80.0);
          _spawnRipple(Offset(x, y), isRain: true);
        }
      }
    }

    setState(() {});
  }

  void _spawnRipple(Offset point, {bool isRain = false}) {
    if (!isRain) {
      HapticsHelper.selection();
    }
    _dropsCount++;
    final color = _rippleColors[_rnd.nextInt(_rippleColors.length)];
    _ripples.add(
      _WaterRipple(
        center: point,
        maxRadius: 110.0 + _rnd.nextDouble() * 50.0,
        speed: 1.9 + _rnd.nextDouble() * 1.1,
        color: color,
      ),
    );
    if (_ripples.length > 25) {
      _ripples.removeRange(0, _ripples.length - 25);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lastDragPoint == null || (details.localPosition - _lastDragPoint!).distance > 40) {
      _lastDragPoint = details.localPosition;
      _spawnRipple(details.localPosition);
    }
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
                  'Gotas de calma: $_dropsCount',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticsHelper.light();
                  setState(() => _isRainActive = !_isRainActive);
                },
                icon: Icon(
                  _isRainActive ? Icons.pause_circle_rounded : Icons.grain_rounded,
                  size: 16,
                  color: _isRainActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                ),
                label: Text(
                  _isRainActive ? 'Pausar lluvia' : 'Lluvia serena',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isRainActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
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
                onTapDown: (details) {
                  _lastDragPoint = details.localPosition;
                  _spawnRipple(details.localPosition);
                },
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _lastDragPoint = null,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF132A26), // Agua profunda y tranquila
                  child: CustomPaint(
                    painter: _WaterRipplePainter(
                      ripples: List.from(_ripples),
                      timeProgress: _controller.value,
                    ),
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

class _WaterRipplePainter extends CustomPainter {
  final List<_WaterRipple> ripples;
  final double timeProgress;

  _WaterRipplePainter({required this.ripples, required this.timeProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gradiente del fondo del estanque
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: const [
          Color(0xFF1B3833),
          Color(0xFF0F211E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Dibujar hojas de loto flotantes
    _drawLilyPad(canvas, Offset(size.width * 0.25, size.height * 0.30), 38, 0.4, 0);
    _drawLilyPad(canvas, Offset(size.width * 0.78, size.height * 0.42), 44, -0.6, 1);
    _drawLilyPad(canvas, Offset(size.width * 0.35, size.height * 0.76), 34, 1.2, 2);

    // 3. Dibujar flor de loto rosada
    _drawLotusFlower(canvas, Offset(size.width * 0.78, size.height * 0.40));

    // 4. Ondas concéntricas de agua
    for (final r in ripples) {
      if (r.radius <= 0) continue;

      // Anillo principal
      final mainPaint = Paint()
        ..color = r.color.withValues(alpha: r.alpha)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(r.center, r.radius, mainPaint);

      // Anillo de eco secundario
      if (r.radius > 16) {
        final echoPaint = Paint()
          ..color = r.color.withValues(alpha: r.alpha * 0.55)
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(r.center, r.radius * 0.70, echoPaint);
      }

      // Destello central
      if (r.radius < 26) {
        final flashPaint = Paint()
          ..color = Colors.white.withValues(alpha: (1.0 - (r.radius / 26)).clamp(0.0, 1.0) * 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(r.center, 3.5, flashPaint);
      }
    }
  }

  void _drawLilyPad(Canvas canvas, Offset baseCenter, double radius, double angle, int id) {
    final bob = sin((timeProgress + (id * 0.33)) * 2 * pi) * 2.5;
    final center = Offset(baseCenter.dx, baseCenter.dy + bob);

    // Sombra del nenúfar
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(center.dx, center.dy + 3), radius, shadowPaint);

    // Cuerpo de la hoja
    final padPaint = Paint()..color = const Color(0xFF2A574A);
    canvas.drawCircle(center, radius, padPaint);

    // Borde más claro
    final edgePaint = Paint()
      ..color = const Color(0xFF3F7766)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, edgePaint);

    // Muesca triangular de la hoja
    final cutPath = Path();
    cutPath.moveTo(center.dx, center.dy);
    cutPath.lineTo(center.dx + cos(angle - 0.22) * radius * 1.05, center.dy + sin(angle - 0.22) * radius * 1.05);
    cutPath.lineTo(center.dx + cos(angle + 0.22) * radius * 1.05, center.dy + sin(angle + 0.22) * radius * 1.05);
    cutPath.close();

    final cutPaint = Paint()..color = const Color(0xFF1B3833);
    canvas.drawPath(cutPath, cutPaint);
  }

  void _drawLotusFlower(Canvas canvas, Offset center) {
    final bob = sin((timeProgress + 0.33) * 2 * pi) * 2.5;
    final c = Offset(center.dx, center.dy + bob);

    final petalPaint = Paint()..color = const Color(0xFFFFD1DC).withValues(alpha: 0.9);
    for (int i = 0; i < 6; i++) {
      final a = i * (pi / 3);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + cos(a) * 9, c.dy + sin(a) * 9),
          width: 14,
          height: 8,
        ),
        petalPaint,
      );
    }

    final heartPaint = Paint()..color = const Color(0xFFFFE082);
    canvas.drawCircle(c, 4.5, heartPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterRipplePainter oldDelegate) => true;
}

// ============================================================================
// 5. MINIJUEGO: CUENCO TIBETANO RESONANTE (VIBRACIÓN ARMÓNICA Y CIRCULAR)
// ============================================================================

class TibetanBowlMinigame extends StatefulWidget {
  const TibetanBowlMinigame({super.key});

  @override
  State<TibetanBowlMinigame> createState() => _TibetanBowlMinigameState();
}

class _TibetanBowlMinigameState extends State<TibetanBowlMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _resonance = 0.0;
  double? _lastAngle;
  double _gongWaveRadius = 0.0;
  double _gongWaveAlpha = 0.0;
  Offset? _touchPos;
  int _hapticCooldown = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();
  }

  void _tick() {
    // Decaimiento suave de la resonancia si no se frota
    _resonance = (_resonance - 0.0035).clamp(0.0, 1.0);

    // Onda expansiva del gong
    if (_gongWaveAlpha > 0.0) {
      _gongWaveRadius += 4.8;
      _gongWaveAlpha = (_gongWaveAlpha - 0.024).clamp(0.0, 1.0);
    }

    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    _touchPos = details.localPosition;
    _lastAngle = _calculateAngle(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _touchPos = details.localPosition;
    final newAngle = _calculateAngle(details.localPosition);

    if (_lastAngle != null) {
      double diff = (newAngle - _lastAngle!).abs();
      if (diff > pi) diff = (2 * pi - diff).abs();

      // Si gira a velocidad armónica
      if (diff > 0.03 && diff < 0.9) {
        _resonance = (_resonance + diff * 0.20).clamp(0.0, 1.0);
        _hapticCooldown++;
        if (_hapticCooldown % 9 == 0) {
          HapticsHelper.light();
        }
      }
    }
    _lastAngle = newAngle;
  }

  void _onPanEnd(DragEndDetails details) {
    _touchPos = null;
    _lastAngle = null;
  }

  void _onTapDown(TapDownDetails details) {
    _touchPos = details.localPosition;
    // Toque seco: Gong
    HapticsHelper.medium();
    _gongWaveRadius = 60.0;
    _gongWaveAlpha = 0.95;
    _resonance = (_resonance + 0.28).clamp(0.0, 1.0);
  }

  double _calculateAngle(Offset touch) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return 0.0;
    final center = Offset(renderBox.size.width * 0.5, renderBox.size.height * 0.5);
    return atan2(touch.dy - center.dy, touch.dx - center.dx);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resonancePct = (_resonance * 100).toInt();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Resonancia: $resonancePct%',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _resonance > 0.6 ? const Color(0xFFC59B27) : LevTheme.levTextDark,
                  ),
                ),
              ),
              Text(
                'Toca o gira el borde',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: LevTheme.levTextMuted,
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
                onTapDown: _onTapDown,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF1F1A17), // Tatami oscuro de templo
                  child: CustomPaint(
                    painter: _TibetanBowlPainter(
                      resonance: _resonance,
                      gongRadius: _gongWaveRadius,
                      gongAlpha: _gongWaveAlpha,
                      touchPos: _touchPos,
                      animValue: _controller.value,
                    ),
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

class _TibetanBowlPainter extends CustomPainter {
  final double resonance;
  final double gongRadius;
  final double gongAlpha;
  final Offset? touchPos;
  final double animValue;

  _TibetanBowlPainter({
    required this.resonance,
    required this.gongRadius,
    required this.gongAlpha,
    required this.touchPos,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final bowlRadius = min(size.width, size.height) * 0.32;

    // 1. Ondas armónicas doradas emanando del cuenco
    if (resonance > 0.05) {
      for (int i = 0; i < 3; i++) {
        final progress = (animValue + (i * 0.33)) % 1.0;
        final waveRadius = bowlRadius + progress * 75.0;
        final waveAlpha = (1.0 - progress) * resonance * 0.65;

        final soundPaint = Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: waveAlpha)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, waveRadius, soundPaint);
      }
    }

    // 2. Onda expansiva del Gong seco
    if (gongAlpha > 0.0) {
      final gongPaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: gongAlpha)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, gongRadius, gongPaint);
    }

    // 3. Cojín de seda roja bajo el cuenco
    final cushionPaint = Paint()..color = const Color(0xFF8B2522);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + bowlRadius * 0.75), width: bowlRadius * 1.8, height: bowlRadius * 0.45),
        const Radius.circular(16),
      ),
      cushionPaint,
    );
    // Borde dorado del cojín
    final cushionTrim = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + bowlRadius * 0.75), width: bowlRadius * 1.8, height: bowlRadius * 0.45),
        const Radius.circular(16),
      ),
      cushionTrim,
    );

    // 4. Halo dorado brillante cuando hay alta resonancia
    if (resonance > 0.2) {
      final pulse = sin(animValue * 8 * pi) * 6.0;
      final haloPaint = Paint()
        ..color = const Color(0xFFFFC107).withValues(alpha: resonance * 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28 + pulse);
      canvas.drawCircle(center, bowlRadius + 14, haloPaint);
    }

    // 5. Cuerpo del Cuenco Tibetano de Bronce
    final bowlPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.88,
        colors: const [
          Color(0xFFE5C06E),
          Color(0xFFB38F39),
          Color(0xFF6B4F1A),
          Color(0xFF38290E),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: bowlRadius));
    canvas.drawCircle(center, bowlRadius, bowlPaint);

    // 6. Interior cóncavo del cuenco
    final interiorPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.8,
        colors: const [
          Color(0xFF2C1E0D),
          Color(0xFF523D17),
          Color(0xFF8A6A29),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: bowlRadius * 0.82));
    canvas.drawCircle(center, bowlRadius * 0.82, interiorPaint);

    // 7. Borde brillante del cuenco (reborde de bronce pulido)
    final rimPaint = Paint()
      ..color = const Color(0xFFFFF1C5)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, bowlRadius * 0.83, rimPaint);

    // 8. Toque del mazo de madera
    if (touchPos != null) {
      final malletPaint = Paint()..color = const Color(0xFFD7CCC8);
      canvas.drawCircle(touchPos!, 14.0, malletPaint);
      final malletInner = Paint()..color = const Color(0xFF8D6E63);
      canvas.drawCircle(touchPos!, 8.0, malletInner);
    }
  }

  @override
  bool shouldRepaint(covariant _TibetanBowlPainter oldDelegate) => true;
}

// ============================================================================
// 6. MINIJUEGO: DIENTES DE LEÓN AL VIENTO (SOLTAR PENSAMIENTOS Y LIGEREZA)
// ============================================================================

class DandelionMinigame extends StatefulWidget {
  const DandelionMinigame({super.key});

  @override
  State<DandelionMinigame> createState() => _DandelionMinigameState();
}

class _DandelionSeed {
  final double angle;
  final double length;
  double x;
  double y;
  double vx = 0.0;
  double vy = 0.0;
  double rotation;
  double spin = 0.0;
  bool isFlying = false;
  double opacity = 0.95;

  _DandelionSeed({
    required this.angle,
    required this.length,
    required this.x,
    required this.y,
    required this.rotation,
  });
}

class _DandelionMinigameState extends State<DandelionMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_DandelionSeed> _seeds = [];
  final Random _rnd = Random();
  int _releasedCount = 0;
  Offset _flowerCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();
  }

  void _initSeeds(Size size) {
    if (_seeds.isNotEmpty) return;
    _flowerCenter = Offset(size.width * 0.5, size.height * 0.62);

    // Generar 36 vilanos de diente de león
    for (int i = 0; i < 36; i++) {
      final a = (i / 36) * 2 * pi;
      final dist = 18.0 + _rnd.nextDouble() * 32.0;
      final sx = _flowerCenter.dx + cos(a) * dist;
      final sy = _flowerCenter.dy + sin(a) * dist;

      _seeds.add(
        _DandelionSeed(
          angle: a,
          length: dist,
          x: sx,
          y: sy,
          rotation: a,
        ),
      );
    }
  }

  void _tick() {
    for (final s in _seeds) {
      if (s.isFlying) {
        s.x += s.vx + sin(s.y * 0.04) * 0.9;
        s.y += s.vy;
        s.rotation += s.spin;
        s.vy = (s.vy * 0.985) - 0.04; // flotación aerodinámica ascendente

        if (s.y < 30) {
          s.opacity = (s.opacity - 0.02).clamp(0.0, 1.0);
        }
      }
    }
    setState(() {});
  }

  void _releaseNearbySeeds(Offset touch) {
    bool releasedAny = false;
    for (final s in _seeds) {
      if (!s.isFlying) {
        final d = (Offset(s.x, s.y) - touch).distance;
        if (d < 65) {
          s.isFlying = true;
          s.vx = (s.x - touch.dx) * 0.06 + (_rnd.nextDouble() - 0.4) * 1.5;
          s.vy = -3.2 - _rnd.nextDouble() * 2.6;
          s.spin = (_rnd.nextDouble() - 0.5) * 0.12;
          _releasedCount++;
          releasedAny = true;
        }
      }
    }
    if (releasedAny) {
      HapticsHelper.light();
    }
  }

  void _resetDandelion() {
    HapticsHelper.medium();
    setState(() {
      _seeds.clear();
    });
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
                  'Pensamientos soltados: $_releasedCount',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _resetDandelion,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Nuevo brote'),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _initSeeds(Size(constraints.maxWidth, constraints.maxHeight));

                  return GestureDetector(
                    onTapDown: (details) => _releaseNearbySeeds(details.localPosition),
                    onPanUpdate: (details) => _releaseNearbySeeds(details.localPosition),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFE8F2EA), // Cielo suave salvia
                            Color(0xFFF9F6F0), // Calidez terrena
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _DandelionPainter(
                          seeds: _seeds,
                          flowerCenter: _flowerCenter,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DandelionPainter extends CustomPainter {
  final List<_DandelionSeed> seeds;
  final Offset flowerCenter;

  _DandelionPainter({required this.seeds, required this.flowerCenter});

  @override
  void paint(Canvas canvas, Size size) {
    final fc = flowerCenter.dx == 0 ? Offset(size.width * 0.5, size.height * 0.62) : flowerCenter;

    // 1. Tallo verde botánico curvado
    final stemPaint = Paint()
      ..color = const Color(0xFF7A9E7E)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(fc.dx, fc.dy);
    stemPath.quadraticBezierTo(fc.dx - 12, size.height * 0.82, fc.dx - 6, size.height);
    canvas.drawPath(stemPath, stemPaint);

    // 2. Receptáculo central de la flor
    final centerPaint = Paint()..color = const Color(0xFF5A755D);
    canvas.drawCircle(fc, 11.0, centerPaint);
    final corePaint = Paint()..color = const Color(0xFF8DA38A);
    canvas.drawCircle(fc, 6.0, corePaint);

    // 3. Semillas y vilanos plumosos
    for (final s in seeds) {
      if (s.opacity <= 0.0) continue;

      canvas.save();
      canvas.translate(s.x, s.y);
      canvas.rotate(s.rotation);

      // Filamento
      final filPaint = Paint()
        ..color = const Color(0xFF37474F).withValues(alpha: s.opacity * 0.55)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset.zero, const Offset(0, 14), filPaint);

      // Plumón esponjoso (brácteas blancas de paracaídas)
      final fluffPaint = Paint()
        ..color = Colors.white.withValues(alpha: s.opacity * 0.85)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;

      for (int i = -3; i <= 3; i++) {
        canvas.drawLine(
          Offset.zero,
          Offset(i * 3.5, -8.0 - (i.abs() * 1.5)),
          fluffPaint,
        );
      }

      // Semilla marrón diminuta en la base
      final seedDotPaint = Paint()..color = const Color(0xFF6D4C41).withValues(alpha: s.opacity);
      canvas.drawCircle(const Offset(0, 14), 2.2, seedDotPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DandelionPainter oldDelegate) => true;
}

// ============================================================================
// 7. MINIJUEGO: PIEDRAS EN EQUILIBRIO (TORRE ZEN Y PACIENCIA)
// ============================================================================

class StoneBalanceMinigame extends StatefulWidget {
  const StoneBalanceMinigame({super.key});

  @override
  State<StoneBalanceMinigame> createState() => _StoneBalanceMinigameState();
}

class _ZenStoneData {
  final int id;
  final double width;
  final double height;
  final Color primaryColor;
  final Color highlightColor;
  bool isPlaced;

  _ZenStoneData({
    required this.id,
    required this.width,
    required this.height,
    required this.primaryColor,
    required this.highlightColor,
    this.isPlaced = false,
  });
}

class _StoneBalanceMinigameState extends State<StoneBalanceMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final List<_ZenStoneData> _stones;
  int _stackedCount = 1; // La piedra base ya está colocada
  Offset? _draggingPos;
  double _wobble = 0.0;

  @override
  void initState() {
    super.initState();
    _stones = [
      _ZenStoneData(
        id: 0,
        width: 155,
        height: 52,
        primaryColor: const Color(0xFF424949),
        highlightColor: const Color(0xFF5B6565),
        isPlaced: true, // Base
      ),
      _ZenStoneData(
        id: 1,
        width: 125,
        height: 46,
        primaryColor: const Color(0xFF566573),
        highlightColor: const Color(0xFF708090),
      ),
      _ZenStoneData(
        id: 2,
        width: 98,
        height: 40,
        primaryColor: const Color(0xFF6E685E),
        highlightColor: const Color(0xFF8B8477),
      ),
      _ZenStoneData(
        id: 3,
        width: 76,
        height: 35,
        primaryColor: const Color(0xFF4A5D4E),
        highlightColor: const Color(0xFF657E6B),
      ),
      _ZenStoneData(
        id: 4,
        width: 52,
        height: 30,
        primaryColor: const Color(0xFF34495E),
        highlightColor: const Color(0xFF4F6982),
      ),
    ];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        setState(() {
          _wobble = sin(_animController.value * 4 * pi) * (1.0 - _animController.value) * 0.05;
        });
      });
  }

  void _resetTower() {
    HapticsHelper.medium();
    setState(() {
      for (int i = 1; i < _stones.length; i++) {
        _stones[i].isPlaced = false;
      }
      _stackedCount = 1;
      _draggingPos = null;
    });
  }

  void _checkPlacement(Offset dropPos, Size size) {
    if (_stackedCount >= _stones.length) return;

    final targetCenter = _getStackPosition(_stackedCount, size);
    final dist = (dropPos - targetCenter).distance;

    // Si se suelta cerca del centro de gravedad de la torre
    if (dist < 60) {
      HapticsHelper.medium();
      setState(() {
        _stones[_stackedCount].isPlaced = true;
        _stackedCount++;
        _draggingPos = null;
      });
      _animController.forward(from: 0.0);
    } else {
      HapticsHelper.light();
      setState(() {
        _draggingPos = null;
      });
    }
  }

  Offset _getStackPosition(int index, Size size) {
    final baseX = size.width * 0.5;
    double currentY = size.height * 0.76;
    for (int i = 0; i < index; i++) {
      currentY -= (_stones[i].height * 0.82);
    }
    return Offset(baseX, currentY);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allBalanced = _stackedCount == _stones.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  allBalanced ? '¡Equilibrio zen alcanzado! 🌿' : 'Piedras en calma: $_stackedCount/5',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: allBalanced ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _resetTower,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reiniciar'),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);

                  return GestureDetector(
                    onPanStart: (details) {
                      if (_stackedCount < _stones.length) {
                        setState(() => _draggingPos = details.localPosition);
                      }
                    },
                    onPanUpdate: (details) {
                      if (_stackedCount < _stones.length) {
                        setState(() => _draggingPos = details.localPosition);
                      }
                    },
                    onPanEnd: (details) {
                      if (_draggingPos != null) {
                        _checkPlacement(_draggingPos!, size);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFE5DDD0), // Orilla zen con niebla suave
                            Color(0xFFCCC0B0),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _StoneBalancePainter(
                          stones: _stones,
                          stackedCount: _stackedCount,
                          draggingPos: _draggingPos,
                          wobble: _wobble,
                          allBalanced: allBalanced,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoneBalancePainter extends CustomPainter {
  final List<_ZenStoneData> stones;
  final int stackedCount;
  final Offset? draggingPos;
  final double wobble;
  final bool allBalanced;

  _StoneBalancePainter({
    required this.stones,
    required this.stackedCount,
    required this.draggingPos,
    required this.wobble,
    required this.allBalanced,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width * 0.5;
    final baseY = size.height * 0.78;

    // 1. Suelo de arena del río zen
    final sandPaint = Paint()..color = const Color(0xFFB5A693);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(baseX, baseY + 20), width: size.width * 0.85, height: 42),
      sandPaint,
    );

    // 2. Halo de celebración si la torre está completa
    if (allBalanced) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawCircle(Offset(baseX, size.height * 0.44), 85, glowPaint);
    }

    // 3. Dibujar piedras ya apiladas
    double currentY = baseY;
    for (int i = 0; i < stackedCount; i++) {
      final stone = stones[i];
      final isTop = i == stackedCount - 1 && stackedCount > 1;
      final stoneCenter = Offset(
        baseX + (isTop ? wobble * 30.0 : 0.0),
        currentY,
      );

      _drawOrganicStone(canvas, stoneCenter, stone);
      currentY -= (stone.height * 0.82);
    }

    // 4. Indicador sutil de posición de encaje si se está arrastrando
    if (draggingPos != null && stackedCount < stones.length) {
      final targetPos = Offset(baseX, currentY);
      final guidePaint = Paint()
        ..color = const Color(0xFF7A9E7E).withValues(alpha: 0.45)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(targetPos, 22, guidePaint);
    }

    // 5. Piedra que se está arrastrando
    if (draggingPos != null && stackedCount < stones.length) {
      final draggingStone = stones[stackedCount];
      _drawOrganicStone(canvas, draggingPos!, draggingStone, isDragging: true);
    } else if (stackedCount < stones.length) {
      // Mostrar la siguiente piedra esperando abajo en la bandeja
      final trayPos = Offset(baseX, size.height * 0.90);
      final nextStone = stones[stackedCount];
      _drawOrganicStone(canvas, trayPos, nextStone);
    }
  }

  void _drawOrganicStone(Canvas canvas, Offset center, _ZenStoneData stone, {bool isDragging = false}) {
    // Sombra de la piedra
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDragging ? 12 : 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 4), width: stone.width * 1.02, height: stone.height * 1.02),
      shadowPaint,
    );

    // Cuerpo de la piedra con forma elipsoide redondeada
    final stonePaint = Paint()..color = stone.primaryColor;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: stone.width, height: stone.height),
      stonePaint,
    );

    // Veta / reflejo de luz superior
    final lightPaint = Paint()..color = stone.highlightColor.withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - stone.width * 0.12, center.dy - stone.height * 0.18),
        width: stone.width * 0.65,
        height: stone.height * 0.45,
      ),
      lightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StoneBalancePainter oldDelegate) => true;
}

