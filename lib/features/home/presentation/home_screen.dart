import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/detox/presentation/phone_down_screen.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';
import 'package:lev/features/home/presentation/widgets/sanctuary_audio_dialog.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_pond_painter.dart';
import 'package:lev/features/sanctuary/presentation/widgets/daily_greeting_dialog.dart';
import 'package:lev/features/sanctuary/presentation/widgets/evolution_celebration_dialog.dart';
import 'package:lev/features/crisis/presentation/crisis_sos_modal.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_weather_sheet.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_growth_dialog.dart';
import 'package:lev/features/settings/presentation/widgets/privacy_offline_dialog.dart';

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
  Offset? _touchPosition;
  bool _isFingerActive = false;
  bool _hasCheckedGreeting = false;
  DateTime _lastPetTime = DateTime.fromMillisecondsSinceEpoch(0);

  // Física continua de seguimiento suave con inercia acuática y muelle de retorno orgánico
  Offset _currentSmoothedOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  Offset _touchVelocity = Offset.zero;
  double _currentInfluence = 0.0;
  double _targetInfluence = 0.0;
  final DateTime _animStartTime = DateTime.now();
  double get _continuousTime =>
      DateTime.now().difference(_animStartTime).inMicroseconds / 3600000.0;

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
  late final AnimationController _prayController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..addListener(_onAmbientTick)..repeat();

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

    _prayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  void _onAmbientTick() {
    if (!mounted) return;

    Offset nextOffset;
    if (_isFingerActive) {
      // Seguimiento suave del dedo mientras está activo en pantalla
      nextOffset = Offset.lerp(_currentSmoothedOffset, _targetOffset, 0.20)!;
      _touchVelocity = nextOffset - _currentSmoothedOffset;
    } else {
      // Retorno físico elástico con muelle amortiguado (damped spring return)
      // Lev acelera, desacelera suavemente y reposa de forma orgánica en el centro
      const double springStiffness = 0.12;
      const double fluidDamping = 0.82;
      _touchVelocity = (_touchVelocity + (_targetOffset - _currentSmoothedOffset) * springStiffness) * fluidDamping;
      if (_touchVelocity.distance > 0.12) {
        _touchVelocity = (_touchVelocity / _touchVelocity.distance) * 0.12;
      }
      nextOffset = _currentSmoothedOffset + _touchVelocity;

      if (nextOffset.distanceSquared < 0.00002 && _touchVelocity.distanceSquared < 0.00002) {
        nextOffset = Offset.zero;
        _touchVelocity = Offset.zero;
      }
    }

    final nextInfluence = (lerpDouble(_currentInfluence, _targetInfluence, 0.14) ?? 0.0);

    if ((nextOffset - _currentSmoothedOffset).distanceSquared > 0.000001 ||
        (nextInfluence - _currentInfluence).abs() > 0.001) {
      setState(() {
        _currentSmoothedOffset = nextOffset;
        _currentInfluence = nextInfluence;
      });
    }
  }

  @override
  void dispose() {
    _ambientController.removeListener(_onAmbientTick);
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
    _prayController.dispose();
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

  void _checkDailyGreetingAndEvolution(SanctuaryState sanctuary, SanctuaryController controller) {
    if (sanctuary.pendingEvolutionStage != null) {
      final stage = sanctuary.pendingEvolutionStage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        controller.clearPendingEvolution();
        EvolutionCelebrationDialog.show(
          context,
          stage: stage,
          onDismiss: () {},
        );
      });
      return;
    }

    if (!_hasCheckedGreeting) {
      _hasCheckedGreeting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final greeting = await controller.checkDailyGreeting();
        if (greeting != null && mounted) {
          DailyGreetingDialog.show(
            context,
            title: greeting['title'] as String,
            message: greeting['body'] as String,
            rewardDrops: greeting['rewardDrops'] as int,
            onClaim: () {},
          );
        }
      });
    }
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

      // Oración y devoción
      if (next.emotion == LevEmotion.praying) {
        _prayController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _prayController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // Salto elástico con física de 4 fases
      if (next.emotion == LevEmotion.joyJump) {
        _jumpController.forward(from: 0.0).then((_) {
          if (mounted) _jumpController.reset();
        });
      }
    });

    _checkDailyGreetingAndEvolution(sanctuary, controller);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      onTap: () => showSanctuaryGrowthDialog(context, ref, sanctuary, onNavigateToTab: widget.onNavigateToTab),
                      borderRadius: LevTheme.pillRadius,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? LevTheme.levDarkSurface
                              : Colors.white,
                          borderRadius: LevTheme.pillRadius,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? LevTheme.levDarkBorder
                                : LevTheme.levBorder,
                          ),
                          boxShadow: LevTheme.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              sanctuary.stageMaterialIcon,
                              size: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? LevTheme.levMatchaNight
                                  : LevTheme.levMatchaDark,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                sanctuary.stageName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
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
                      // Gotas de cuidado -> Navegar a la Tienda
                      InkWell(
                        onTap: () {
                          HapticsHelper.selection();
                          if (widget.onNavigateToTab != null) {
                            widget.onNavigateToTab!(2);
                          } else {
                            showSanctuaryGrowthDialog(context, ref, sanctuary, initialTab: 1, onNavigateToTab: widget.onNavigateToTab);
                          }
                        },
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

                      // Clima dinámico del Santuario
                      _HeaderIconBtn(
                        icon: sanctuary.weather.icon,
                        tooltip: 'Clima: ${sanctuary.weather.label}',
                        onTap: () => showSanctuaryWeatherSheet(context, controller, sanctuary.weather),
                      ),
                      const SizedBox(width: 6),

                      // Botón Privacidad y Datos Offline
                      _HeaderIconBtn(
                        icon: Icons.shield_outlined,
                        iconColor: LevTheme.levMatchaDark,
                        tooltip: 'Privacidad y datos',
                        onTap: () => showPrivacyOfflineDialog(context),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final areaWidth = constraints.maxWidth;
                  final areaHeight = constraints.maxHeight;
                  final centerX = areaWidth * 0.5;
                  final centerY = areaHeight * 0.48;

                  double touchDist = 999.0;
                  if (_touchPosition != null) {
                    final dx = _touchPosition!.dx - centerX;
                    final dy = _touchPosition!.dy - centerY;
                    touchDist = sqrt(dx * dx + dy * dy);
                  }

                  void handleTouch(Offset localPos) {
                    _touchPosition = localPos;
                    _isFingerActive = true;
                    _targetInfluence = 1.0;

                    final dx = localPos.dx - centerX;
                    final dy = localPos.dy - centerY;
                    _targetOffset = Offset(
                      (dx / (areaWidth * 0.5)).clamp(-1.0, 1.0),
                      (dy / (areaHeight * 0.48)).clamp(-1.0, 1.0),
                    );

                    final dist = sqrt(dx * dx + dy * dy);
                    if (dist < 92.0) {
                      final now = DateTime.now();
                      if (now.difference(_lastPetTime).inMilliseconds > 400) {
                        _lastPetTime = now;
                        controller.petLev();
                      }
                    }
                  }

                  void handleTouchEnd() {
                    _isFingerActive = false;
                    _targetInfluence = 0.0;
                    _targetOffset = Offset.zero;
                    _touchPosition = null;
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (details) => handleTouch(details.localPosition),
                    onPanUpdate: (details) => handleTouch(details.localPosition),
                    onPanEnd: (_) => handleTouchEnd(),
                    onPanCancel: () => handleTouchEnd(),
                    onTapDown: (details) => handleTouch(details.localPosition),
                    onTapUp: (_) => handleTouchEnd(),
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
                            _prayController,
                          ]),
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size.infinite,
                              painter: SanctuaryPondPainter(
                                animationValue: _continuousTime,
                                timeOfDay: sanctuary.effectiveTimeOfDay,
                                emotion: sanctuary.emotion,
                                bloomingFlowers: sanctuary.bloomingFlowers,
                                careDrops: sanctuary.careDrops,
                                isPetting: sanctuary.isPetting,
                                growthStage: sanctuary.growthStage,
                                growthFactor: sanctuary.growthFactor,
                                activeDecors: sanctuary.activeDecors,
                                activeAccessory: sanctuary.activeAccessory,
                                touchNormalizedOffset: _currentSmoothedOffset,
                                touchLocalPosition: _touchPosition,
                                isFingerActive: _isFingerActive,
                                touchDistance: _touchPosition != null ? touchDist : (_currentSmoothedOffset.distance * 100.0),
                                weather: sanctuary.weather,
                                isWatering: sanctuary.isWatering,
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
                                prayProgress: _prayController.value,
                              ),
                            );
                          },
                        ),

                    // Indicador de modo oración y confianza bíblica
                    if (sanctuary.emotion == LevEmotion.praying)
                      Positioned(
                        top: 16,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: LevTheme.pillRadius,
                              border: Border.all(
                                color: const Color(0xFFFFD54F),
                                width: 1.5,
                              ),
                              boxShadow: LevTheme.softShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 17,
                                  color: Color(0xFFD4AF37),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Momento de Oración y Confianza',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8D6E00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                  );
                },
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
                      icon: Icons.phone_android_rounded,
                      label: 'Soltar Móvil',
                      accentColor: LevTheme.levMatchaDark,
                      isActive: false,
                      onTap: () {
                        HapticsHelper.selection();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PhoneDownScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      icon: Icons.water_drop_rounded,
                      label: 'Regar',
                      accentColor: const Color(0xFF64B5F6),
                      isActive: sanctuary.isWatering,
                      onTap: () => controller.waterLev(),
                    ),
                    const SizedBox(width: 8),
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
                      icon: Icons.auto_awesome_rounded,
                      label: 'Orar',
                      accentColor: const Color(0xFFD4AF37),
                      isActive: sanctuary.emotion == LevEmotion.praying,
                      onTap: () {
                        if (sanctuary.emotion == LevEmotion.praying) {
                          controller.setPeacefulState();
                        } else {
                          controller.prayWithLev();
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
      case LevEmotion.praying:
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
      case LevEmotion.praying:
        return const Color(0xFFD4AF37);
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
