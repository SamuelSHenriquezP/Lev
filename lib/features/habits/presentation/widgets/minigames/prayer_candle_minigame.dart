import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';

/// Partícula brillante de oración que asciende suavemente hacia lo alto
class _PrayerSpark {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  Color color;

  _PrayerSpark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

/// Minijuego somático interactivo: Vela de Oración y Meditación Bíblica
/// Permite encender una vela tocándola, mantener presionado para elevar plegarias
/// con chispas doradas ascendentes, y meditar en promesas bíblicas reconfortantes.
class PrayerCandleMinigame extends StatefulWidget {
  const PrayerCandleMinigame({super.key});

  @override
  State<PrayerCandleMinigame> createState() => _PrayerCandleMinigameState();
}

class _PrayerCandleMinigameState extends State<PrayerCandleMinigame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_PrayerSpark> _sparks = [];
  final Random _rnd = Random();

  bool _isLit = true;
  double _flameFlicker = 0.0;
  int _verseIndex = 0;
  DateTime _lastHaptic = DateTime.now();

  static const List<Map<String, String>> _verses = [
    {
      'text': '«Lámpara es a mis pies tu palabra, y lumbrera a mi camino.»',
      'citation': 'Salmos 119:105',
    },
    {
      'text': '«El Señor es mi luz y mi salvación; ¿de quién temeré?»',
      'citation': 'Salmos 27:1',
    },
    {
      'text': '«Venid a mí todos los que estáis trabajados y cargados, y yo os haré descansar.»',
      'citation': 'Mateo 11:28',
    },
    {
      'text': '«Echa sobre el Señor tu carga, y él te sustentará; no dejará para siempre caído al justo.»',
      'citation': 'Salmos 55:22',
    },
    {
      'text': '«La paz os dejo, mi paz os doy; yo no os la doy como el mundo la da. No se turbe vuestro corazón.»',
      'citation': 'Juan 14:27',
    },
    {
      'text': '«Por nada estéis afanosos, sino sean conocidas vuestras peticiones delante de Dios en oración.»',
      'citation': 'Filipenses 4:6',
    },
    {
      'text': '«En Dios solamente está acallada mi alma; de él viene mi salvación.»',
      'citation': 'Salmos 62:1',
    },
    {
      'text': '«El Señor es mi pastor; nada me faltará. En lugares de delicados pastos me hará descansar.»',
      'citation': 'Salmos 23:1-2',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(_tick)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;

    // Oscilación orgánica de la llama
    _flameFlicker = sin(_controller.value * 2 * pi * 4) * 0.08 +
        cos(_controller.value * 2 * pi * 7) * 0.04;

    // Actualizar partículas ascendentes de oración
    for (int i = _sparks.length - 1; i >= 0; i--) {
      final s = _sparks[i];
      s.x += s.vx + sin((s.y * 0.03) + _controller.value * 2 * pi) * 0.6;
      s.y += s.vy;
      s.vy *= 0.98;
      s.opacity -= 0.015;

      if (s.opacity <= 0.0 || s.y < -20) {
        _sparks.removeAt(i);
      }
    }

    // Auto-generación suave de sutiles brasas cuando está encendida
    if (_isLit && _rnd.nextDouble() < 0.28) {
      _spawnSpark(isTouch: false);
    }

    setState(() {});
  }

  void _spawnSpark({required bool isTouch, Offset? customPos}) {
    final cx = customPos?.dx ?? 150.0;
    final cy = customPos?.dy ?? 160.0;

    final goldenPalette = [
      const Color(0xFFFFD54F), // Oro cálido
      const Color(0xFFFFE082), // Ámbar suave
      const Color(0xFFFFCA28), // Sol celestial
      const Color(0xFFFFF9C4), // Luz blanca dorada
    ];

    _sparks.add(
      _PrayerSpark(
        x: cx + (_rnd.nextDouble() - 0.5) * (isTouch ? 40.0 : 16.0),
        y: cy + (_rnd.nextDouble() - 0.5) * (isTouch ? 30.0 : 10.0),
        vx: (_rnd.nextDouble() - 0.5) * (isTouch ? 1.6 : 0.6),
        vy: -1.8 - _rnd.nextDouble() * (isTouch ? 2.8 : 1.4),
        size: isTouch ? (2.8 + _rnd.nextDouble() * 3.5) : (1.6 + _rnd.nextDouble() * 2.2),
        opacity: 0.95,
        color: goldenPalette[_rnd.nextInt(goldenPalette.length)],
      ),
    );
  }

  void _handleTouch(Offset localPos, Size areaSize) {
    if (!_isLit) {
      setState(() => _isLit = true);
      HapticsHelper.medium();
      return;
    }

    final candleCenter = Offset(areaSize.width * 0.5, areaSize.height * 0.44);
    final dist = (localPos - candleCenter).distance;

    // Pulsación háptica amortiguada para sensación de recogimiento
    final now = DateTime.now();
    if (now.difference(_lastHaptic).inMilliseconds > 180) {
      _lastHaptic = now;
      HapticsHelper.light();
    }

    // Generar ráfaga de plegarias luminosas
    for (int i = 0; i < 4; i++) {
      _spawnSpark(
        isTouch: true,
        customPos: dist < 120 ? candleCenter : localPos,
      );
    }
  }

  void _nextVerse() {
    HapticsHelper.selection();
    setState(() {
      _verseIndex = (_verseIndex + 1) % _verses.length;
    });
  }

  void _toggleCandle() {
    HapticsHelper.selection();
    setState(() {
      _isLit = !_isLit;
      if (!_isLit) _sparks.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentVerse = _verses[_verseIndex];

    return Column(
      children: [
        // Encabezado con instrucción y controles sutiles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isLit ? 'Toca para elevar una plegaria' : 'Toca para encender la luz',
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
                onPressed: _nextVerse,
                icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                label: const Text('Promesa'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB78103),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _toggleCandle,
                icon: Icon(
                  _isLit ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: _isLit ? const Color(0xFFD4AF37) : LevTheme.levTextMuted,
                ),
                tooltip: _isLit ? 'Apagar' : 'Encender',
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Área interactiva inmersiva: Altar nocturno sereno
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final areaSize = Size(constraints.maxWidth, constraints.maxHeight);

                  return GestureDetector(
                    onTapDown: (details) => _handleTouch(details.localPosition, areaSize),
                    onPanUpdate: (details) => _handleTouch(details.localPosition, areaSize),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, -0.15),
                          radius: 1.1,
                          colors: [
                            Color(0xFF262018), // Sombra cálida acogedora
                            Color(0xFF141210), // Profundidad de santuario
                            Color(0xFF0C0B0A), // Noche serena
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Lienzo de la vela, halo y partículas
                          CustomPaint(
                            size: Size.infinite,
                            painter: _PrayerCandlePainter(
                              isLit: _isLit,
                              flameFlicker: _flameFlicker,
                              sparks: _sparks,
                            ),
                          ),

                          // Tarjeta de versículo bíblico contemplativo
                          Positioned(
                            bottom: 18,
                            left: 20,
                            right: 20,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.15),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey(currentVerse['citation']),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD54F).withValues(alpha: 0.08),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentVerse['text']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFFFF8E1),
                                        height: 1.35,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      currentVerse['citation']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFFD54F),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
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
          ),
        ),
      ],
    );
  }
}

class _PrayerCandlePainter extends CustomPainter {
  final bool isLit;
  final double flameFlicker;
  final List<_PrayerSpark> sparks;

  _PrayerCandlePainter({
    required this.isLit,
    required this.flameFlicker,
    required this.sparks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final candleTopY = size.height * 0.44;
    final candleBottomY = size.height * 0.76;
    const candleWidth = 52.0;

    // 1. Halo áureo expansivo cuando la vela está encendida
    if (isLit) {
      final haloRadius = 140.0 + flameFlicker * 35.0;
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD54F).withValues(alpha: 0.32),
            const Color(0xFFFFB300).withValues(alpha: 0.16),
            const Color(0xFFFF8F00).withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, candleTopY - 24), radius: haloRadius));

      canvas.drawCircle(Offset(cx, candleTopY - 24), haloRadius, haloPaint);
    }

    // 2. Base de cerámica / plato de arcilla
    final baseRect = Rect.fromCenter(
      center: Offset(cx, candleBottomY + 4),
      width: candleWidth * 2.2,
      height: 18,
    );
    final basePaint = Paint()..color = const Color(0xFF2A231C);
    canvas.drawRRect(RRect.fromRectAndRadius(baseRect, const Radius.circular(9)), basePaint);

    // 3. Cuerpo de la vela (cera botánica marfil)
    final candleRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - candleWidth * 0.5, candleTopY, cx + candleWidth * 0.5, candleBottomY),
      const Radius.circular(8),
    );

    final candleGrad = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFDED5C4), // Sombra lateral
        const Color(0xFFFFFDF8), // Brillo central
        const Color(0xFFE8DFD0),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
    canvas.drawRRect(candleRect, Paint()..shader = candleGrad.createShader(candleRect.outerRect));

    // Gotas de cera derretida decorativa
    final waxDripPaint = Paint()..color = const Color(0xFFFFFDF8);
    canvas.drawCircle(Offset(cx - 14, candleTopY + 16), 5, waxDripPaint);
    canvas.drawCircle(Offset(cx + 12, candleTopY + 22), 6, waxDripPaint);

    // 4. Mecha
    final wickPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, candleTopY), Offset(cx + flameFlicker * 4, candleTopY - 12), wickPaint);

    // 5. Llama en gota de agua viva
    if (isLit) {
      final flameCenterY = candleTopY - 28.0;
      final flameWidth = 18.0 + flameFlicker * 4.0;
      final flameHeight = 34.0 + flameFlicker * 8.0;

      // Llama exterior dorada
      final outerFlamePath = Path()
        ..moveTo(cx + flameFlicker * 6, flameCenterY - flameHeight * 0.6)
        ..cubicTo(
          cx + flameWidth * 0.9, flameCenterY - flameHeight * 0.1,
          cx + flameWidth * 0.8, flameCenterY + flameHeight * 0.5,
          cx, flameCenterY + flameHeight * 0.5,
        )
        ..cubicTo(
          cx - flameWidth * 0.8, flameCenterY + flameHeight * 0.5,
          cx - flameWidth * 0.9, flameCenterY - flameHeight * 0.1,
          cx + flameFlicker * 6, flameCenterY - flameHeight * 0.6,
        )
        ..close();

      final outerFlamePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, 0.4),
          colors: [
            const Color(0xFFFFF9C4), // Núcleo claro
            const Color(0xFFFFD54F), // Amarillo cálido
            const Color(0xFFFF6F00).withValues(alpha: 0.85), // Naranja suave
          ],
        ).createShader(outerFlamePath.getBounds());

      canvas.drawPath(outerFlamePath, outerFlamePaint);

      // Núcleo interno azul/blanco de calor puro
      final innerFlamePath = Path()
        ..moveTo(cx + flameFlicker * 3, flameCenterY - flameHeight * 0.25)
        ..cubicTo(
          cx + flameWidth * 0.45, flameCenterY,
          cx + flameWidth * 0.4, flameCenterY + flameHeight * 0.4,
          cx, flameCenterY + flameHeight * 0.45,
        )
        ..cubicTo(
          cx - flameWidth * 0.4, flameCenterY + flameHeight * 0.4,
          cx - flameWidth * 0.45, flameCenterY,
          cx + flameFlicker * 3, flameCenterY - flameHeight * 0.25,
        )
        ..close();

      canvas.drawPath(
        innerFlamePath,
        Paint()..color = const Color(0xFFE1F5FE).withValues(alpha: 0.9),
      );
    }

    // 6. Chispas luminosas ascendentes de oración
    for (final s in sparks) {
      final sparkPaint = Paint()
        ..color = s.color.withValues(alpha: s.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(s.x, s.y), s.size, sparkPaint);

      // Destello aureolar tenue alrededor de cada chispa grande
      if (s.size > 2.4) {
        canvas.drawCircle(
          Offset(s.x, s.y),
          s.size * 2.2,
          Paint()
            ..color = s.color.withValues(alpha: (s.opacity * 0.35).clamp(0.0, 1.0))
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PrayerCandlePainter oldDelegate) => true;
}
