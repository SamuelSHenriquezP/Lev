import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/habits/presentation/widgets/petal_celebration_overlay.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';

class HabitCelebrationModal extends ConsumerStatefulWidget {
  final MicroHabit habit;
  final VoidCallback onClose;

  const HabitCelebrationModal({
    super.key,
    required this.habit,
    required this.onClose,
  });

  @override
  ConsumerState<HabitCelebrationModal> createState() => HabitCelebrationModalState();
}

class HabitCelebrationModalState extends ConsumerState<HabitCelebrationModal>
    with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final AnimationController _glowController;
  late final AnimationController _badgePopController;
  String? _selectedRelief;
  String? _reliefValidationMsg;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _badgePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _glowController.dispose();
    _badgePopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sanctuary = ref.watch(sanctuaryProvider);
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: min(size.width * 0.90, 400.0),
          constraints: BoxConstraints(maxHeight: size.height * 0.88),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: LevTheme.levMatchaLight.withValues(alpha: 0.9),
              width: 1.8,
            ),
            boxShadow: [
              const BoxShadow(
                color: Color(0x332D3748),
                blurRadius: 36,
                offset: Offset(0, 14),
              ),
              const BoxShadow(
                color: Color(0x22FFE082),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Stack(
              children: [
                // Overlay sutil de pétalos flotantes dentro del modal
                const Positioned.fill(
                  child: IgnorePointer(
                    child: PetalCelebrationOverlay(),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Encabezado con insignia de felicitación
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: LevTheme.levMatchaLight,
                                borderRadius: LevTheme.pillRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, size: 14, color: LevTheme.levMatchaDark),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Pausa Consciente Completada',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: LevTheme.levMatchaDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                      // Medallón orgánico de Lev en salto de alegría sin recortes
                      AnimatedBuilder(
                        animation: Listenable.merge([_jumpController, _glowController]),
                        builder: (context, child) {
                          final glowVal = _glowController.value;
                          return SizedBox(
                            width: 180,
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Halo de luz y fondo místico
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFFFF8E1),
                                        const Color(0xFFFFF3D6).withValues(alpha: 0.8),
                                        const Color(0xFFE8F5E9).withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.35, 0.65, 0.85, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD54F).withValues(alpha: 0.30 + glowVal * 0.20),
                                        blurRadius: 32 + glowVal * 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                // Sprite de Lev con espacio vertical holgado para el salto
                                Positioned(
                                  top: -8,
                                  bottom: -8,
                                  left: 0,
                                  right: 0,
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      size: const Size(180, 196),
                                      painter: LivingSeedSpiritPainter(
                                        animationValue: _jumpController.value,
                                        emotion: LevEmotion.joyJump,
                                        isPetting: true,
                                        sizeScale: 0.82,
                                        jumpProgress: _jumpController.value,
                                        happyProgress: 1.0,
                                        celebrateProgress: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Título cálido y cariñoso
                      Text(
                        '¡Lo lograste!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lev está saltando de alegría por tu pausa de cuidado.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: LevTheme.levTextMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bloque de Recompensas: +Gotas y +XP diferenciadas
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _badgePopController,
                          curve: Curves.elasticOut,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFBBDEFB)),
                                  boxShadow: LevTheme.softShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.water_drop_rounded, size: 18, color: Color(0xFF1976D2)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '+1 Gota 💧',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1976D2),
                                            ),
                                          ),
                                          Text(
                                            'Santuario',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              color: LevTheme.levTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: LevTheme.levMatchaLight),
                                  boxShadow: LevTheme.softShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.eco_rounded, size: 18, color: LevTheme.levMatchaDark),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '+25 XP 🌱',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: LevTheme.levMatchaDark,
                                            ),
                                          ),
                                          Text(
                                            'Evolución Lev',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              color: LevTheme.levTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Barra de progreso botánico
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: LevTheme.levBorder),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(sanctuary.stageMaterialIcon, size: 16, color: LevTheme.levMatchaDark),
                                    const SizedBox(width: 5),
                                    Text(
                                      sanctuary.stageName,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: LevTheme.levTextDark,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${sanctuary.experiencePoints} XP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levMatchaDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: sanctuary.growthFactor,
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? LevTheme.levDarkSurfaceVariant
                                    : LevTheme.levCream,
                                valueColor: const AlwaysStoppedAnimation<Color>(LevTheme.levMatcha),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tarjeta de base neurocientífica
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4ED),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: LevTheme.levBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology_outlined, size: 16, color: LevTheme.levMatchaDark),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Impacto en tu sistema nervioso:',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: LevTheme.levMatchaDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.habit.psychologicalBasis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: LevTheme.levTextDark,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Medición somática post-hábito (1-tap check-in)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedRelief != null ? LevTheme.levMatcha : LevTheme.levBorder,
                            width: _selectedRelief != null ? 1.6 : 1.0,
                          ),
                          boxShadow: LevTheme.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.self_improvement_rounded, size: 16, color: LevTheme.levMatchaDark),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '¿Cómo siente tu cuerpo esta pausa?',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: LevTheme.levTextDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildReliefOption('lighter', '🍃 Más ligero'),
                                const SizedBox(width: 6),
                                _buildReliefOption('same', '⚖️ Igual'),
                                const SizedBox(width: 6),
                                _buildReliefOption('tense', '🌧️ Aún tenso'),
                              ],
                            ),
                            if (_reliefValidationMsg != null) ...[
                              const SizedBox(height: 8),
                              AnimatedOpacity(
                                opacity: 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _reliefValidationMsg!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: LevTheme.levMatchaDark,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Mensaje guía: Apaga la pantalla y vuelve a la vida real
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: LevTheme.levMatcha.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: LevTheme.levMatcha.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('📵', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Has regulado tu cuerpo. Ahora apaga tu pantalla y continúa tu momento en el mundo real.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: LevTheme.levMatchaDark,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                    // Botón táctil para continuar siempre visible al pie
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: widget.onClose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LevTheme.levMatcha,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: LevTheme.pillRadius,
                            ),
                          ),
                          child: Text(
                            'Listo, volver a la vida real 🌿',
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReliefOption(String key, String label) {
    final isSelected = _selectedRelief == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticsHelper.selection();
          setState(() {
            _selectedRelief = key;
            if (key == 'lighter') {
              _reliefValidationMsg = 'Qué hermoso alivio. Tu cuerpo absorbió la calma.';
            } else if (key == 'same') {
              _reliefValidationMsg = 'Normal y válido. Cada pausa va sembrando alivio poco a poco.';
            } else {
              _reliefValidationMsg = 'Está bien, no te juzgues. Lev te acompaña con paciencia infinita.';
            }
          });
          LocalStorageService.recordHabitRelief(widget.habit.id, key);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? LevTheme.levMatchaLight : const Color(0xFFF9F9F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}