import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';
import 'package:lev/features/home/presentation/widgets/sanctuary_audio_dialog.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_pond_painter.dart';
import 'package:lev/features/crisis/presentation/crisis_sos_modal.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Etapa de crecimiento de Lev
                  Flexible(
                    child: InkWell(
                      onTap: () => _showGrowthInfo(context, sanctuary),
                      borderRadius: LevTheme.pillRadius,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: LevTheme.pillRadius,
                          border: Border.all(color: LevTheme.levBorder),
                          boxShadow: LevTheme.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              size: 15,
                              color: LevTheme.levMatchaDark,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                sanctuary.growthStageName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: LevTheme.levMatchaDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 15,
                              color: LevTheme.levTextMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botones de acción derecha
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gotas de cuidado
                      InkWell(
                        onTap: () => _showGrowthInfo(context, sanctuary, initialTab: 1),
                        borderRadius: LevTheme.pillRadius,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: LevTheme.pillRadius,
                            border: Border.all(color: LevTheme.levBorder),
                            boxShadow: LevTheme.softShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.water_drop_rounded,
                                size: 14,
                                color: Color(0xFF64B5F6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${sanctuary.careDrops}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: LevTheme.levTextDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Audio ambiental
                      _HeaderIconBtn(
                        icon: Icons.graphic_eq_rounded,
                        tooltip: 'Sonidos del Santuario',
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const SanctuaryAudioDialog(),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Botón Privacidad y Datos Offline
                      _HeaderIconBtn(
                        icon: Icons.shield_outlined,
                        iconColor: LevTheme.levMatchaDark,
                        tooltip: 'Privacidad y datos',
                        onTap: () => _showPrivacyDialog(context),
                      ),
                      const SizedBox(width: 6),

                      // Botón SOS / Crisis
                      _HeaderIconBtn(
                        icon: Icons.health_and_safety_rounded,
                        iconColor: const Color(0xFFE57373),
                        tooltip: 'Líneas de ayuda y SOS',
                        onTap: () => CrisisSosModal.show(context),
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
                            timeOfDay: sanctuary.effectiveTimeOfDay,
                            emotion: sanctuary.emotion,
                            bloomingFlowers: sanctuary.bloomingFlowers,
                            careDrops: sanctuary.careDrops,
                            isPetting: sanctuary.isPetting,
                            growthStage: sanctuary.growthStage,
                            growthFactor: sanctuary.growthFactor,
                            activeDecors: sanctuary.activeDecors,
                            activeAccessory: sanctuary.activeAccessory,
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

  void _showGrowthInfo(BuildContext context, SanctuaryState sanctuary, {int initialTab = 0}) {
    final controller = ref.read(sanctuaryProvider.notifier);
    int activeTab = initialTab; // 0 = Evolución (XP), 1 = Casa (Gotas)
    DecorCategory selectedCategory = DecorCategory.all;

    final stagesInfo = [
      {'stage': LevGrowthStage.seed, 'name': 'Semilla', 'xp': 0, 'desc': 'Bulbo dorado que descansa.'},
      {'stage': LevGrowthStage.sprout, 'name': 'Brote', 'xp': 50, 'desc': 'Primeras hojitas tiernas.'},
      {'stage': LevGrowthStage.seedling, 'name': 'Plántula', 'xp': 100, 'desc': 'Hojas medianas con cáliz.'},
      {'stage': LevGrowthStage.youngPlant, 'name': 'Planta Joven', 'xp': 200, 'desc': 'Alas canónicas completas.'},
      {'stage': LevGrowthStage.vibrantPlant, 'name': 'Planta Vibrante', 'xp': 350, 'desc': 'Flores en floración.'},
      {'stage': LevGrowthStage.youngTree, 'name': 'Árbol Juvenil', 'xp': 550, 'desc': '4 alas con nervaduras.'},
      {'stage': LevGrowthStage.adultTree, 'name': 'Árbol Adulto', 'xp': 800, 'desc': 'Corona y halo místico.'},
      {'stage': LevGrowthStage.forestSpirit, 'name': 'Espíritu del Bosque', 'xp': 1200, 'desc': '6 alas y 3 orbes sagrados.'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentSanctuary = ref.watch(sanctuaryProvider);
            final nextXp = currentSanctuary.xpToNextStage;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: LevTheme.levBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Santuario Botánico',
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: LevTheme.levMatchaLight,
                              borderRadius: LevTheme.pillRadius,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco_rounded, size: 14, color: LevTheme.levMatchaDark),
                                const SizedBox(width: 4),
                                Text(
                                  '${currentSanctuary.experiencePoints} XP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levMatchaDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: LevTheme.pillRadius,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.water_drop_rounded, size: 14, color: Color(0xFF1976D2)),
                                const SizedBox(width: 4),
                                Text(
                                  '${currentSanctuary.careDrops} 💧',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Selector de 4 pestañas
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: LevTheme.levCream,
                      borderRadius: LevTheme.pillRadius,
                      border: Border.all(color: LevTheme.levBorder),
                    ),
                    child: Row(
                      children: [
                        _buildGrowthTabPill('🌱 Etapas', 0, activeTab, () => setModalState(() => activeTab = 0)),
                        _buildGrowthTabPill('🏡 Casa', 1, activeTab, () => setModalState(() => activeTab = 1)),
                        _buildGrowthTabPill('🎀 Armario', 2, activeTab, () => setModalState(() => activeTab = 2)),
                        _buildGrowthTabPill('☀️ Cielo', 3, activeTab, () => setModalState(() => activeTab = 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (activeTab == 0) ...[
                    Text(
                      'Toca cualquier etapa para previsualizar su sprite o progresa ganando +25 XP por hábito.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: LevTheme.levTextMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 125,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: stagesInfo.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final item = stagesInfo[i];
                          final stage = item['stage'] as LevGrowthStage;
                          final isSelected = currentSanctuary.growthStage == stage;
                          final minXp = item['xp'] as int;

                          return InkWell(
                            onTap: () {
                              HapticsHelper.selection();
                              final dropsForXp = (minXp / 10).round();
                              controller.setCareDrops(dropsForXp);
                              setModalState(() {});
                            },
                            borderRadius: LevTheme.cardRadius,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 108,
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
                                    size: 20,
                                    color: isSelected
                                        ? LevTheme.levMatchaDark
                                        : LevTheme.levTextMuted,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item['name'] as String,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12,
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
                                    '${item['xp']}+ XP',
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
                    const SizedBox(height: 12),
                    if (nextXp != null)
                      Text(
                        'Faltan $nextXp XP para la siguiente evolución botánica.',
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
                  ] else if (activeTab == 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Objetos para la casa de Lev:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: LevTheme.levTextDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: LevTheme.levMatchaLight,
                            borderRadius: LevTheme.pillRadius,
                          ),
                          child: Text(
                            '${currentSanctuary.activeDecors.length}/${SanctuaryDecorItem.values.length} en casa',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: LevTheme.levMatchaDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Selector de categorías de objetos
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: DecorCategory.values.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, catIndex) {
                          final cat = DecorCategory.values[catIndex];
                          final isCatSelected = selectedCategory == cat;

                          return InkWell(
                            onTap: () => setModalState(() => selectedCategory = cat),
                            borderRadius: LevTheme.pillRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isCatSelected ? LevTheme.levMatcha : Colors.white,
                                borderRadius: LevTheme.pillRadius,
                                border: Border.all(
                                  color: isCatSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 13,
                                    color: isCatSelected ? Colors.white : LevTheme.levMatchaDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    cat.label,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 11.5,
                                      fontWeight: isCatSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isCatSelected ? Colors.white : LevTheme.levTextDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lista horizontal de objetos filtrados
                    Builder(
                      builder: (context) {
                        final filteredItems = selectedCategory == DecorCategory.all
                            ? SanctuaryDecorItem.values
                            : SanctuaryDecorItem.values.where((d) => d.category == selectedCategory).toList();

                        return SizedBox(
                          height: 165,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredItems.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final item = filteredItems[i];
                              final isUnlocked = currentSanctuary.unlockedDecors.contains(item);
                              final isActive = currentSanctuary.activeDecors.contains(item);
                              final canAfford = currentSanctuary.careDrops >= item.dropCost;

                              return Container(
                                width: 144,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? LevTheme.levMatchaLight.withValues(alpha: 0.75)
                                      : const Color(0xFFFAF8F5),
                                  borderRadius: LevTheme.cardRadius,
                                  border: Border.all(
                                    color: isActive
                                        ? LevTheme.levMatchaDark
                                        : LevTheme.levBorder,
                                    width: isActive ? 1.8 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(item.icon, size: 18, color: LevTheme.levMatchaDark),
                                        ),
                                        if (isUnlocked)
                                          Icon(
                                            isActive ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                            size: 16,
                                            color: isActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                                          )
                                        else
                                          Text(
                                            '${item.dropCost} 💧',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: canAfford ? const Color(0xFF1976D2) : LevTheme.levTextMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.quicksand(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: LevTheme.levTextDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: LevTheme.levTextMuted,
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 28,
                                      child: isUnlocked
                                          ? OutlinedButton(
                                              onPressed: () {
                                                HapticsHelper.light();
                                                controller.toggleDecor(item);
                                                setModalState(() {});
                                              },
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor: isActive ? Colors.white : Colors.transparent,
                                                side: BorderSide(
                                                  color: isActive ? LevTheme.levMatchaDark : LevTheme.levBorder,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                isActive ? 'Colocado 🌿' : 'Poner',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: isActive ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                                                ),
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed: canAfford
                                                  ? () async {
                                                      HapticsHelper.medium();
                                                      final success = await controller.unlockDecor(item);
                                                      if (success) setModalState(() {});
                                                    }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor: LevTheme.levMatcha,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                'Desbloquear',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ] else if (activeTab == 2) ...[
                    // Pestaña Armario: Accesorios botánicos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Accesorios botánicos para Lev:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: LevTheme.levTextDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: LevTheme.levMatchaLight,
                            borderRadius: LevTheme.pillRadius,
                          ),
                          child: Text(
                            '${currentSanctuary.unlockedAccessories.length}/${LevAccessory.values.length} en armario',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: LevTheme.levMatchaDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 165,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: LevAccessory.values.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final acc = LevAccessory.values[i];
                          final isEquipped = currentSanctuary.activeAccessory == acc;
                          final isUnlocked = acc == LevAccessory.none || currentSanctuary.unlockedAccessories.contains(acc);
                          final canAfford = currentSanctuary.careDrops >= acc.dropCost;

                          return Container(
                            width: 144,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isEquipped
                                  ? LevTheme.levMatchaLight.withValues(alpha: 0.75)
                                  : const Color(0xFFFAF8F5),
                              borderRadius: LevTheme.cardRadius,
                              border: Border.all(
                                color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levBorder,
                                width: isEquipped ? 1.8 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(acc.icon, size: 18, color: LevTheme.levMatchaDark),
                                    ),
                                    if (isUnlocked)
                                      Icon(
                                        isEquipped ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                        size: 16,
                                        color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                                      )
                                    else
                                      Text(
                                        '${acc.dropCost} 💧',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: canAfford ? const Color(0xFF1976D2) : LevTheme.levTextMuted,
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: LevTheme.levTextDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      acc.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: LevTheme.levTextMuted,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: isUnlocked
                                      ? OutlinedButton(
                                          onPressed: () {
                                            HapticsHelper.light();
                                            if (isEquipped) {
                                              controller.equipAccessory(LevAccessory.none);
                                            } else {
                                              controller.equipAccessory(acc);
                                            }
                                            setModalState(() {});
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor: isEquipped ? Colors.white : Colors.transparent,
                                            side: BorderSide(
                                              color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levBorder,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            isEquipped ? 'Puesto 🌿' : (acc == LevAccessory.none ? 'Sin nada' : 'Poner'),
                                            style: GoogleFonts.quicksand(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isEquipped ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: canAfford
                                              ? () async {
                                                  HapticsHelper.medium();
                                                  final success = await controller.unlockAccessory(acc);
                                                  if (success) setModalState(() {});
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor: LevTheme.levMatcha,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            'Desbloquear',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // Pestaña Cielo: Ciclo circadiano
                    Text(
                      'Atmósfera circadiana del Santuario:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Por defecto, Lev sincroniza la luz con tu reloj local para cuidar tu descanso nocturno sin luz azul.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: LevTheme.levTextMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCircadianChip(
                          label: 'Automático (Reloj)',
                          icon: Icons.access_time_rounded,
                          isSelected: currentSanctuary.circadianOverride == null,
                          onTap: () {
                            HapticsHelper.selection();
                            controller.setCircadianOverride(null);
                            setModalState(() {});
                          },
                        ),
                        _buildCircadianChip(
                          label: 'Amanecer 🌅',
                          icon: Icons.wb_twilight_rounded,
                          isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.morning,
                          onTap: () {
                            HapticsHelper.selection();
                            controller.setCircadianOverride(SanctuaryTimeOfDay.morning);
                            setModalState(() {});
                          },
                        ),
                        _buildCircadianChip(
                          label: 'Día ☀️',
                          icon: Icons.wb_sunny_rounded,
                          isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.afternoon,
                          onTap: () {
                            HapticsHelper.selection();
                            controller.setCircadianOverride(SanctuaryTimeOfDay.afternoon);
                            setModalState(() {});
                          },
                        ),
                        _buildCircadianChip(
                          label: 'Ocaso 🌇',
                          icon: Icons.wb_cloudy_rounded,
                          isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.dusk,
                          onTap: () {
                            HapticsHelper.selection();
                            controller.setCircadianOverride(SanctuaryTimeOfDay.dusk);
                            setModalState(() {});
                          },
                        ),
                        _buildCircadianChip(
                          label: 'Noche Serena 🌙',
                          icon: Icons.bedtime_rounded,
                          isSelected: currentSanctuary.circadianOverride == SanctuaryTimeOfDay.night,
                          onTap: () {
                            HapticsHelper.selection();
                            controller.setCircadianOverride(SanctuaryTimeOfDay.night);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                            ? const Color(0xFF192530)
                            : const Color(0xFFF6F4ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: LevTheme.levBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                                ? Icons.nights_stay_rounded
                                : Icons.light_mode_rounded,
                            size: 18,
                            color: currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                                ? const Color(0xFFFFF9E0)
                                : LevTheme.levMatchaDark,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                                  ? 'Cielo nocturno activo: estrellas titilantes y luna serena sin luz azul.'
                                  : 'Iluminación cálida diurna activa en el santuario.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: currentSanctuary.effectiveTimeOfDay == SanctuaryTimeOfDay.night
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : LevTheme.levTextDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    HapticsHelper.light();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isPinActive = LocalStorageService.isPinProtectionActive();
            final remindersConfig = LocalStorageService.getGentleReminders();
            final remindersEnabled = remindersConfig['enabled'] == true;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              actionsPadding: const EdgeInsets.all(20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: LevTheme.levMatchaLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, size: 22, color: LevTheme.levMatchaDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu Espacio Seguro',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrivacyPoint(
                      icon: Icons.wifi_off_rounded,
                      title: '100% Sin Conexión Obligatoria',
                      desc: 'Tus reflexiones, registros de ánimo y hábitos se guardan únicamente en la memoria de este teléfono.',
                    ),
                    const SizedBox(height: 12),
                    _buildPrivacyPoint(
                      icon: Icons.no_accounts_rounded,
                      title: 'Sin Cuentas ni Rastreadores',
                      desc: 'No recopilamos analíticas invasivas ni vendemos tu información. Lev existe para acompañarte en calma.',
                    ),
                    const SizedBox(height: 12),
                    _buildPrivacyPoint(
                      icon: Icons.lock_outline_rounded,
                      title: 'Control Total y Privacidad',
                      desc: 'Tus datos son tuyos. Puedes reiniciar la app cuando desees sin dejar rastro en servidores externos.',
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: LevTheme.levBorder, height: 1),
                    const SizedBox(height: 14),

                    // Tarjeta de Seguridad con PIN
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPinActive ? LevTheme.levMatchaDark : LevTheme.levBorder,
                          width: isPinActive ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPinActive ? Icons.lock_rounded : Icons.lock_open_rounded,
                                size: 18,
                                color: isPinActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bloqueo con PIN de 4 dígitos',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levTextDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPinActive ? LevTheme.levMatchaLight : const Color(0xFFEDF2F7),
                                  borderRadius: LevTheme.pillRadius,
                                ),
                                child: Text(
                                  isPinActive ? 'Activo' : 'Inactivo',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isPinActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isPinActive
                                ? 'Tu diario íntimo y conversaciones con Lev requieren tu PIN para abrirse.'
                                : 'Añade una clave numérica para proteger tus registros si prestas tu teléfono.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: LevTheme.levTextMuted,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: OutlinedButton(
                              onPressed: () {
                                _showPinConfigDialog(context, () => setDialogState(() {}));
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                side: const BorderSide(color: LevTheme.levMatchaDark),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                isPinActive ? 'Modificar o Quitar PIN' : 'Activar PIN de Seguridad',
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
                    const SizedBox(height: 12),

                    // Tarjeta de Recordatorios Gentilísimas
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: LevTheme.levBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, size: 18, color: LevTheme.levMatchaDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pausas amables diarias',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levTextDark,
                                  ),
                                ),
                                Text(
                                  'Recordatorios suaves sin culpa',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: LevTheme.levTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: remindersEnabled,
                            activeThumbColor: LevTheme.levMatcha,
                            activeTrackColor: LevTheme.levMatchaLight,
                            onChanged: (val) async {
                              HapticsHelper.selection();
                              final newConfig = Map<String, dynamic>.from(remindersConfig);
                              newConfig['enabled'] = val;
                              await LocalStorageService.saveGentleReminders(newConfig);
                              setDialogState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LevTheme.levMatcha,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: LevTheme.pillRadius),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Entendido',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPinConfigDialog(BuildContext context, VoidCallback onDone) {
    final pinController = TextEditingController();
    final isCurrentlyActive = LocalStorageService.isPinProtectionActive();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.pin_rounded, color: LevTheme.levMatchaDark),
              const SizedBox(width: 8),
              Text(
                isCurrentlyActive ? 'Modificar PIN' : 'Nuevo PIN de 4 dígitos',
                style: GoogleFonts.quicksand(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingresa 4 dígitos numéricos para resguardar tu diario y chats íntimos con Lev:',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: LevTheme.levTextMuted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  filled: true,
                  fillColor: LevTheme.levCream,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            if (isCurrentlyActive)
              TextButton(
                onPressed: () async {
                  HapticsHelper.light();
                  await LocalStorageService.setPrivacyPin(null);
                  if (ctx.mounted) Navigator.pop(ctx);
                  onDone();
                },
                child: Text('Quitar PIN', style: GoogleFonts.quicksand(color: Colors.redAccent, fontWeight: FontWeight.w700)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.quicksand(color: LevTheme.levTextMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text.trim();
                if (pin.length == 4) {
                  HapticsHelper.medium();
                  await LocalStorageService.setPrivacyPin(pin);
                  if (ctx.mounted) Navigator.pop(ctx);
                  onDone();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LevTheme.levMatcha,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: LevTheme.pillRadius),
              ),
              child: Text('Guardar', style: GoogleFonts.quicksand(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrowthTabPill(String label, int index, int current, VoidCallback onTap) {
    final isSelected = index == current;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: LevTheme.pillRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: LevTheme.pillRadius,
            boxShadow: isSelected ? LevTheme.softShadow : null,
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircadianChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: LevTheme.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? LevTheme.levMatcha : Colors.white,
          borderRadius: LevTheme.pillRadius,
          border: Border.all(
            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? LevTheme.glowShadow : null,
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
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : LevTheme.levTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: LevTheme.levMatchaDark),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: LevTheme.levTextMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
  final Color? iconColor;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    this.iconColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      splashRadius: 18,
      icon: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: LevTheme.levBorder),
          boxShadow: LevTheme.softShadow,
        ),
        child: Icon(icon, size: 15, color: iconColor ?? LevTheme.levTextDark),
      ),
      onPressed: onTap,
    );
  }
}
