import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/crisis/presentation/crisis_sos_modal.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/sanctuary_pond_painter.dart';
import 'widgets/sanctuary_audio_dialog.dart';

/// Pantalla Principal: El Espacio Exclusivo de Lev con Transiciones Orgánicas Continuas.
/// Los cambios de postura fluyen mediante interpolación suave (lerp/tween),
/// asegurando que Lev NUNCA se congele ni se corte de golpe entre animaciones.
class HomeScreen extends ConsumerStatefulWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  // 1. Controlador ambiental infinito (Lev siempre respira y flota)
  late final AnimationController _ambientController;

  // 2. Controladores de transición suave entre posturas (0.0 a 1.0)
  late final AnimationController _wrapController;
  late final AnimationController _sleepController;
  late final AnimationController _happyController;
  late final AnimationController _breathingController;

  // 3. Controlador de física dedicada para el salto elástico
  late final AnimationController _jumpController;

  @override
  void initState() {
    super.initState();

    // Ciclo base continuo a 60 FPS (Lev nunca se queda quieto)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    // Transición suave de abrazo de hojas (500ms curva cúbica)
    _wrapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Transición suave de adormecimiento/despertar (600ms)
    _sleepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Transición suave de caricias/cosquillas (400ms)
    _happyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Transición suave de respiración somática (550ms)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Salto elástico con física de anticipación y rebote (1300ms)
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
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
    super.dispose();
  }

  void _triggerRandomHabit() {
    HapticsHelper.light();
    final randHabit = HabitsDatabase.getRandomHabit();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitTimerScreen(habit: randHabit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sanctuary = ref.watch(sanctuaryProvider);
    final controller = ref.read(sanctuaryProvider.notifier);

    // Escucha reactiva para interpolar suavemente los valores de transición
    ref.listen<SanctuaryState>(sanctuaryProvider, (previous, next) {
      // 1. Transición de Abrazo protector
      if (next.emotion == LevEmotion.sheltered) {
        _wrapController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _wrapController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // 2. Transición de Sueño / Siesta
      if (next.emotion == LevEmotion.sleeping) {
        _sleepController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _sleepController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // 3. Transición de Respiración Somática
      if (next.emotion == LevEmotion.breathing) {
        _breathingController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        _breathingController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // 4. Transición de Caricias / Cosquillas
      if (next.isPetting || next.emotion == LevEmotion.happy) {
        _happyController.animateTo(1.0, curve: Curves.easeOutBack);
      } else {
        _happyController.animateTo(0.0, curve: Curves.easeInOutCubic);
      }

      // 5. Salto de alegría
      if (next.emotion == LevEmotion.joyJump) {
        _jumpController.forward(from: 0.0);
      }
    });

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. CABECERA MINIMALISTA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: LevTheme.pillRadius,
                      border: Border.all(color: LevTheme.levBorder),
                      boxShadow: LevTheme.softShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(sanctuary.sanctuaryLevelEmoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'Lev • ${sanctuary.sanctuaryLevelName}',
                          style: GoogleFonts.quicksand(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: LevTheme.levTextDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: LevTheme.pillRadius,
                          border: Border.all(color: LevTheme.levBorder),
                          boxShadow: LevTheme.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💧', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              '${sanctuary.careDrops}',
                              style: GoogleFonts.quicksand(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levMatchaDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      IconButton(
                        tooltip: 'Sonidos Relajantes',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: LevTheme.levBorder),
                            boxShadow: LevTheme.softShadow,
                          ),
                          child: const Text('🎧', style: TextStyle(fontSize: 15)),
                        ),
                        onPressed: () => SanctuaryAudioDialog.show(context),
                      ),

                      IconButton(
                        tooltip: 'Salvavidas Emocional / SOS',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: LevTheme.levPeach.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🛟', style: TextStyle(fontSize: 15)),
                        ),
                        onPressed: () => CrisisSosModal.show(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- 2. EL ESPACIO HEROICO DE LEV CON TRANSICIONES CONTINUAS ---
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.petLev(),
                onDoubleTap: () => controller.triggerJoyJump(),
                onLongPress: () => controller.hugLev(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fusión de todas las animaciones en un solo ciclo suave a 60 FPS
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _ambientController,
                        _wrapController,
                        _sleepController,
                        _happyController,
                        _breathingController,
                        _jumpController,
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
                            leafWrapProgress: _wrapController.value,
                            sleepProgress: _sleepController.value,
                            happyProgress: _happyController.value,
                            breathingProgress: _breathingController.value,
                            jumpProgress: _jumpController.value,
                          ),
                        );
                      },
                    ),

                    // Indicador flotante en modo respiración
                    if (sanctuary.emotion == LevEmotion.breathing)
                      Positioned(
                        top: 20,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: sanctuary.emotion == LevEmotion.breathing ? 1.0 : 0.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: LevTheme.levMatchaDark,
                              borderRadius: LevTheme.pillRadius,
                              boxShadow: LevTheme.glowShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🫁', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'Inhala al expandirse... exhala al contraerse',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Burbuja de Diálogo e Inteligencia de Lev
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: GestureDetector(
                        onTap: () => controller.petLev(),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey(sanctuary.dialogue),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.96),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: sanctuary.isPetting
                                    ? LevTheme.levPeach
                                    : LevTheme.levBorder,
                                width: sanctuary.isPetting ? 1.6 : 1.0,
                              ),
                              boxShadow: LevTheme.softShadow,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _getDialogueIcon(sanctuary.emotion, sanctuary.isPetting),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    sanctuary.dialogue,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: LevTheme.levTextDark,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.touch_app_rounded,
                                  size: 16,
                                  color: LevTheme.levTextMuted,
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

            // --- 3. BARRA DE PASTILLAS INTERACTIVAS (CON TRANSICIONES SUAVES) ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPillAction(
                      emoji: '🫁',
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
                      emoji: '💛',
                      label: 'Acariciar',
                      isActive: sanctuary.isPetting || sanctuary.emotion == LevEmotion.happy,
                      onTap: () => controller.petLev(),
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      emoji: '🌿',
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
                      emoji: '🌙',
                      label: 'Dormir',
                      isActive: sanctuary.emotion == LevEmotion.sleeping,
                      onTap: () {
                        if (sanctuary.emotion == LevEmotion.sleeping) {
                          controller.petLev(); // Despertar
                        } else {
                          controller.putToSleep();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      emoji: '✨',
                      label: 'Alegrar',
                      isActive: sanctuary.emotion == LevEmotion.joyJump,
                      onTap: () => controller.triggerJoyJump(),
                    ),
                    const SizedBox(width: 8),
                    _buildPillAction(
                      emoji: '🎲',
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

  String _getDialogueIcon(LevEmotion emotion, bool isPetting) {
    if (isPetting) return '💛';
    switch (emotion) {
      case LevEmotion.breathing:
        return '🫁';
      case LevEmotion.sheltered:
        return '🌿';
      case LevEmotion.sleeping:
        return '💤';
      case LevEmotion.joyJump:
        return '✨';
      case LevEmotion.happy:
        return '💛';
      default:
        return '💬';
    }
  }

  Widget _buildPillAction({
    required String emoji,
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
            Text(emoji, style: const TextStyle(fontSize: 15)),
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
