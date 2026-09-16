import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
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
