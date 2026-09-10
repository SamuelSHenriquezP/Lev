import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';
import 'package:lev/features/home/presentation/widgets/sanctuary_audio_dialog.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_pond_painter.dart';

/// Pantalla Principal del Santuario:
/// Lev como protagonista absoluto en el centro con transiciones somáticas orgánicas
/// a 60 FPS, los 8 sprites de crecimiento y barra de acciones táctiles limpias.
class HomeScreen extends ConsumerStatefulWidget {
  final void Function(int)? onNavigateToTab;
  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _wrapController;
  late final AnimationController _sleepController;
  late final AnimationController _happyController;
  late final AnimationController _breathingController;
  late final AnimationController _jumpController;
  late final AnimationController _curiousController;
  late final AnimationController _sadController;
  late final AnimationController _anxiousController;
  late final AnimationController _tiredController;
  late final AnimationController _celebrateController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _wrapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _sleepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _happyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _curiousController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _sadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _anxiousController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _tiredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _wrapController.dispose();
    _sleepController.dispose();
    _happyController.dispose();
    _breathingController.dispose();
    _jumpController.dispose();
    _curiousController.dispose();
    _sadController.dispose();
    _anxiousController.dispose();
    _tiredController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  void _triggerRandomHabit() {
    HapticsHelper.light();
    final randHabit = HabitsDatabase.getRandomHabit();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HabitTimerScreen(habit: randHabit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sanctuary = ref.watch(sanctuaryProvider);
    final controller = ref.read(sanctuaryProvider.notifier);

    // Escucha de cambios de estado emocional con transiciones naturales
    ref.listen<SanctuaryState>(sanctuaryProvider, (previous, next) {
      // Abrazo protector
      if (next.emotion == LevEmotion.sheltered) {
        _wrapController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _wrapController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Siesta
      if (next.emotion == LevEmotion.sleeping) {
        _sleepController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _sleepController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Respiración
      if (next.emotion == LevEmotion.breathing) {
        _breathingController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _breathingController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Cosquillas / Alegría
      if (next.isPetting || next.emotion == LevEmotion.happy) {
        _happyController.animateTo(1.0, curve: Curves.easeOutBack);
      } else {
        _happyController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Curiosidad
      if (next.emotion == LevEmotion.curious) {
        _curiousController.animateTo(1.0, curve: Curves.easeOutBack);
      } else {
        _curiousController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Tristeza
      if (next.emotion == LevEmotion.sad) {
        _sadController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _sadController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Ansiedad
      if (next.emotion == LevEmotion.anxious) {
        _anxiousController.animateTo(1.0, curve: Curves.easeIn);
      } else {
        _anxiousController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Cansancio
      if (next.emotion == LevEmotion.tired) {
        _tiredController.animateTo(1.0, curve: Curves.easeInOut);
      } else {
        _tiredController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Celebración
      if (next.emotion == LevEmotion.celebrating) {
        _celebrateController.animateTo(1.0, curve: Curves.easeOutBack);
      } else {
        _celebrateController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Salto elástico con física de 4 fases
      if (next.emotion == LevEmotion.joyJump) {
        _jumpController.forward(from: 0.0);
      }
    });

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      body: SafeArea(
        child: Column(
          children: [
            // --- CABECERA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Etapa de crecimiento de Lev
                  InkWell(
                    onTap: () => _showGrowthInfo(context, sanctuary),
                    borderRadius: LevTheme.pillRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: LevTheme.pillRadius,
                        border: Border.all(color: LevTheme.levBorder),
                        boxShadow: LevTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            size: 16,
                            color: LevTheme.levMatchaDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sanctuary.growthStageName,
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: LevTheme.levMatchaDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: LevTheme.levTextMuted,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botones de acción derecha
                  Row(
                    children: [
                      // Gotas de cuidado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: LevTheme.pillRadius,
                          border: Border.all(color: LevTheme.levBorder),
                          boxShadow: LevTheme.softShadow,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.water_drop_rounded,
                              size: 15,
                              color: Color(0xFF64B5F6),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${sanctuary.careDrops}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levTextDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Audio ambiental
                      _HeaderIconBtn(
                        icon: Icons.graphic_eq_rounded,
                        tooltip: 'Sonidos del Santuario',
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const SanctuaryAudioDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- ESPACIO CENTRAL: LEV COMO PROTAGONISTA ---
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticsHelper.selection();
                  controller.petLev();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Canvas continuo a 60 FPS con todas las animaciones y sprites
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _ambientController,
                        _wrapController,
                        _sleepController,
                        _happyController,
                        _breathingController,
                        _jumpController,
                        _curiousController,
                        _sadController,
                        _anxiousController,
                        _tiredController,
                        _celebrateController,
                      ]),
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: SanctuaryPondPainter(
                            animationValue: _ambientController.value,
                            timeOfDay: sanctuary.timeOfDay,
                            emotion: sanctuary.emotion,
                            bloomingFlowers: sanctuary.bloomingFlowers,
                            careDrops: sanctuary.careDrops,
                            isPetting: sanctuary.isPetting,
                            growthStage: sanctuary.growthStage,
                            growthFactor: sanctuary.growthFactor,
                            leafWrapProgress: _wrapController.value,
                            sleepProgress: _sleepController.value,
                            happyProgress: _happyController.value,
                            breathingProgress: _breathingController.value,
                            jumpProgress: _jumpController.value,
                            curiousProgress: _curiousController.value,
                            sadProgress: _sadController.value,
                            anxiousProgress: _anxiousController.value,
                            tiredProgress: _tiredController.value,
                            celebrateProgress: _celebrateController.value,
                          ),
                        );
                      },
                    ),

                    // Indicador de modo respiración / calma
                    if (sanctuary.emotion == LevEmotion.breathing ||
                        sanctuary.emotion == LevEmotion.anxious)
                      Positioned(
                        top: 16,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: LevTheme.pillRadius,
                              border: Border.all(
                                color: LevTheme.levMatchaLight,
                                width: 1.5,
                              ),
                              boxShadow: LevTheme.softShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.air_rounded,
                                  size: 17,
                                  color: LevTheme.levMatchaDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  sanctuary.emotion == LevEmotion.anxious
                                      ? 'Respirando contigo para calmarte'
                                      : 'Respiración somática guiada',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: LevTheme.levMatchaDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Bocadillo de diálogo orgánico de Lev
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.12),
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
                            key: ValueKey(sanctuary.dialogue),
                            constraints: const BoxConstraints(maxWidth: 340),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: LevTheme.cardRadius,
                              border: Border.all(
                                color: LevTheme.levBorder,
                                width: 1.0,
                              ),
                              boxShadow: LevTheme.softShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getDialogueIcon(sanctuary.emotion, sanctuary.isPetting),
                                  size: 18,
                                  color: _getDialogueIconColor(sanctuary.emotion, sanctuary.isPetting),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    sanctuary.dialogue,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: LevTheme.levTextDark,
                                      height: 1.35,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BARRA DE ACCIONES CON ICONOS Y MICRO-ANIMACIONES ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPillAction(
                      icon: Icons.air_rounded,
                      label: 'Respirar',
                      isActive: sanctuary.emotion == LevEmotion.breathing,
                      onTap: () {
                        if (sanctuary.emotion == LevEmotion.breathing) {
                          controller.setPeacefulState();
                        } else {
                          controller.startBreathing();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.favorite_rounded,
                      label: 'Acariciar',
                      isActive: sanctuary.isPetting || sanctuary.emotion == LevEmotion.happy,
                      onTap: () => controller.petLev(),
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.spa_rounded,
                      label: 'Abrazo',
                      isActive: sanctuary.emotion == LevEmotion.sheltered,
                      onTap: () {
                        if (sanctuary.emotion == LevEmotion.sheltered) {
                          controller.setPeacefulState();
                        } else {
                          controller.hugLev();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'Curioso',
                      isActive: sanctuary.emotion == LevEmotion.curious,
                      onTap: () {
                        if (sanctuary.emotion == LevEmotion.curious) {
                          controller.setPeacefulState();
                        } else {
                          controller.setCuriousState();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.bedtime_rounded,
                      label: 'Dormir',
                      isActive: sanctuary.emotion == LevEmotion.sleeping,
                      onTap: () {
                        if (sanctuary.emotion == LevEmotion.sleeping) {
                          controller.petLev();
                        } else {
                          controller.putToSleep();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Alegrar',
                      isActive: sanctuary.emotion == LevEmotion.joyJump,
                      onTap: () => controller.triggerJoyJump(),
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.celebration_rounded,
                      label: 'Celebrar',
                      isActive: sanctuary.emotion == LevEmotion.celebrating,
                      onTap: () => controller.setCelebratingState(),
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.bolt_rounded,
                      label: 'Pausa 60s',
                      isActive: false,
                      accentColor: LevTheme.levMatcha,
                      onTap: _triggerRandomHabit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGrowthInfo(BuildContext context, SanctuaryState sanctuary) {
    final nextDrops = sanctuary.dropsToNextStage;
    final controller = ref.read(sanctuaryProvider.notifier);

    final stagesInfo = [
      {'stage': LevGrowthStage.seed, 'name': 'Semilla', 'drops': 0, 'desc': 'Bulbo dorado que descansa.'},
      {'stage': LevGrowthStage.sprout, 'name': 'Brote', 'drops': 5, 'desc': 'Primeras hojitas tiernas.'},
      {'stage': LevGrowthStage.seedling, 'name': 'Plántula', 'drops': 10, 'desc': 'Hojas medianas con cáliz.'},
      {'stage': LevGrowthStage.youngPlant, 'name': 'Planta Joven', 'drops': 20, 'desc': 'Alas canónicas completas.'},
      {'stage': LevGrowthStage.vibrantPlant, 'name': 'Planta Vibrante', 'drops': 35, 'desc': 'Flores en floración.'},
      {'stage': LevGrowthStage.youngTree, 'name': 'Árbol Juvenil', 'drops': 55, 'desc': '4 alas con nervaduras.'},
      {'stage': LevGrowthStage.adultTree, 'name': 'Árbol Adulto', 'drops': 80, 'desc': 'Corona y halo místico.'},
      {'stage': LevGrowthStage.forestSpirit, 'name': 'Espíritu del Bosque', 'drops': 120, 'desc': '6 alas y 3 orbes sagrados.'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentSanctuary = ref.watch(sanctuaryProvider);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Evolución Botánica de Lev',
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: LevTheme.levMatchaLight,
                          borderRadius: LevTheme.pillRadius,
                        ),
                        child: Text(
                          '${currentSanctuary.careDrops} gotas',
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
                    'Toca cualquier etapa para previsualizar su sprite o progresa completando microhábitos.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: LevTheme.levTextMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista scrolleable de las 8 etapas
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: stagesInfo.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final item = stagesInfo[i];
                        final stage = item['stage'] as LevGrowthStage;
                        final isSelected = currentSanctuary.growthStage == stage;
                        final minDrops = item['drops'] as int;

                        return InkWell(
                          onTap: () {
                            HapticsHelper.selection();
                            controller.setCareDrops(minDrops);
                            setModalState(() {});
                          },
                          borderRadius: LevTheme.cardRadius,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 110,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? LevTheme.levMatchaLight
                                  : const Color(0xFFFAF8F5),
                              borderRadius: LevTheme.cardRadius,
                              border: Border.all(
                                color: isSelected
                                    ? LevTheme.levMatchaDark
                                    : LevTheme.levBorder,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.eco_rounded,
                                  size: 22,
                                  color: isSelected
                                      ? LevTheme.levMatchaDark
                                      : LevTheme.levTextMuted,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['name'] as String,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? LevTheme.levMatchaDark
                                        : LevTheme.levTextDark,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['drops']}+ gotas',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: LevTheme.levTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),
                  if (nextDrops != null)
                    Text(
                      'Faltan $nextDrops gotas para desbloquear la siguiente etapa de forma natural.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: LevTheme.levMatchaDark,
                      ),
                    )
                  else
                    Text(
                      'Lev ha alcanzado su forma final suprema. Sigue nutriendo tu bienestar.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: LevTheme.levMatchaDark,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getDialogueIcon(LevEmotion emotion, bool isPetting) {
    if (isPetting) return Icons.favorite_rounded;
    switch (emotion) {
      case LevEmotion.breathing:
      case LevEmotion.anxious:
        return Icons.air_rounded;
      case LevEmotion.sheltered:
      case LevEmotion.sad:
        return Icons.spa_rounded;
      case LevEmotion.curious:
        return Icons.lightbulb_outline_rounded;
      case LevEmotion.sleeping:
      case LevEmotion.tired:
        return Icons.bedtime_rounded;
      case LevEmotion.joyJump:
      case LevEmotion.celebrating:
        return Icons.auto_awesome_rounded;
      case LevEmotion.happy:
        return Icons.favorite_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  Color _getDialogueIconColor(LevEmotion emotion, bool isPetting) {
    if (isPetting) return LevTheme.levPeach;
    switch (emotion) {
      case LevEmotion.sad:
        return const Color(0xFF5C85A0);
      case LevEmotion.anxious:
        return const Color(0xFF8B5E8E);
      case LevEmotion.curious:
        return const Color(0xFFFFA000);
      case LevEmotion.celebrating:
      case LevEmotion.joyJump:
        return const Color(0xFFB7A648);
      default:
        return LevTheme.levMatchaDark;
    }
  }

  Widget _buildPillAction({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? LevTheme.levMatchaDark;

    return InkWell(
      onTap: () {
        HapticsHelper.light();
        onTap();
      },
      borderRadius: LevTheme.pillRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: LevTheme.pillRadius,
          border: Border.all(
            color: isActive ? activeColor : LevTheme.levBorder,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive ? LevTheme.glowShadow : LevTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : LevTheme.levMatchaDark,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : LevTheme.levTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: LevTheme.levBorder),
          boxShadow: LevTheme.softShadow,
        ),
        child: Icon(icon, size: 16, color: LevTheme.levTextDark),
      ),
      onPressed: onTap,
    );
  }
}
