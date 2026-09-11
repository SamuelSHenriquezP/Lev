import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';
import 'widgets/lev_task_animation_widget.dart';
import 'habit_timer_screen.dart';

/// Pantalla inmersiva para cada emoción.
/// Lev entra flotando suavemente a 60 FPS con entrada orgánica y adopta su postura
/// sin cortes abruptos, con mensaje sutil tipo chat y tarjetas de microhábitos diferenciadas.
class EmotionDetailScreen extends StatefulWidget {
  final String categoryName;
  final String emoji;

  const EmotionDetailScreen({
    super.key,
    required this.categoryName,
    required this.emoji,
  });

  @override
  State<EmotionDetailScreen> createState() => _EmotionDetailScreenState();
}

class _EmotionDetailScreenState extends State<EmotionDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _entranceController;
  late final Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  LevEmotion _getEmotionForCategory(String category) {
    if (category.contains('Ansiedad')) return LevEmotion.breathing;
    if (category.contains('Tristeza')) return LevEmotion.sheltered;
    if (category.contains('Insomnio')) return LevEmotion.sleeping;
    if (category.contains('Bloqueo')) return LevEmotion.curious;
    if (category.contains('Culpa')) return LevEmotion.happy;
    if (category.contains('Frustración')) return LevEmotion.breathing;
    return LevEmotion.peaceful;
  }

  String _getNonObviousMessage(String category) {
    if (category.contains('Doomscrolling')) {
      return 'El mundo digital está diseñado para que nunca sientas que viste suficiente. No tienes la culpa. Regálate un minuto de silencio real.';
    }
    if (category.contains('Ansiedad')) {
      return 'El pecho apretado solo es tu cuerpo intentando protegerte del futuro. No luches contra él; aflojemos la mandíbula juntos.';
    }
    if (category.contains('Tristeza')) {
      return 'Está bien no tener ganas hoy. La tristeza también necesita un lugar donde descansar sin tener que dar explicaciones a nadie.';
    }
    if (category.contains('Frustración')) {
      return 'La rabia es energía vital atrapada. No te juzgues por sentirla; drenemos la adrenalina con un movimiento somático.';
    }
    if (category.contains('Insomnio')) {
      return 'Tu mente está intentando resolver mañana en plena oscuridad. Suelta la carga. Esta hora es solo para reposar y existir.';
    }
    if (category.contains('Culpa')) {
      return 'Tu voz interna crítica cree que castigándote te hará mejorar. Abrázala y dile con calma: "Gracias por intentar cuidarme, pero ya estoy a salvo".';
    }
    if (category.contains('Bloqueo')) {
      return 'El cerebro se paraliza cuando la tarea parece infinita. No pienses en terminar; solo demos un pasito de diez segundos.';
    }
    return 'Aquí no hay prisa ni metas obligatorias. Elige lo que tu cuerpo pida ahora.';
  }

  void _openHabit(MicroHabit habit) {
    HapticsHelper.light();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitTimerScreen(habit: habit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = HabitsDatabase.getByCategory(widget.categoryName);
    final emotion = _getEmotionForCategory(widget.categoryName);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? LevTheme.levDarkSurface
        : LevTheme.getEmotionBgColor(widget.categoryName);
    final accentColor = LevTheme.getEmotionAccentColor(widget.categoryName);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryName.split('/').first.trim(),
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HERO DE LEV REACCIONANDO A ESTA EMOCIÓN ---
              Center(
                child: Container(
                  width: double.infinity,
                  height: 190,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: accentColor.withValues(alpha: isDark ? 0.35 : 0.20)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lev animado con su estado emocional exacto y entrada suave (sin cortes ni saltos)
                      AnimatedBuilder(
                        animation: Listenable.merge([_animationController, _entranceAnimation]),
                        builder: (context, child) {
                          final enter = _entranceAnimation.value;
                          return FadeTransition(
                            opacity: _entranceAnimation,
                            child: Transform.scale(
                              scale: 0.88 + (0.12 * enter),
                              child: CustomPaint(
                                size: const Size(190, 190),
                                painter: LivingSeedSpiritPainter(
                                  animationValue: _animationController.value,
                                  emotion: emotion,
                                  isPetting: false,
                                  sizeScale: 0.95,
                                  leafWrapProgress: (emotion == LevEmotion.sheltered ? 1.0 : 0.0) * enter,
                                  sleepProgress: (emotion == LevEmotion.sleeping ? 1.0 : 0.0) * enter,
                                  breathingProgress: (emotion == LevEmotion.breathing ? 1.0 : 0.0) * enter,
                                  sadProgress: (emotion == LevEmotion.sad ? 1.0 : 0.0) * enter,
                                  anxiousProgress: (emotion == LevEmotion.anxious ? 1.0 : 0.0) * enter,
                                  tiredProgress: (emotion == LevEmotion.tired ? 1.0 : 0.0) * enter,
                                  curiousProgress: (emotion == LevEmotion.curious ? 1.0 : 0.0) * enter,
                                  happyProgress: (emotion == LevEmotion.happy ? 1.0 : 0.0) * enter,
                                  celebrateProgress: (emotion == LevEmotion.celebrating ? 1.0 : 0.0) * enter,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Insignia del estado de Lev
                      Positioned(
                        top: 14,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: LevTheme.pillRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                'Lev está contigo',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- 2. TARJETA DE MENSAJE SUTIL TIPO CHAT INTEGRADO ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: LevTheme.levBorder),
                  boxShadow: LevTheme.softShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lightbulb_outline_rounded, size: 18, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getNonObviousMessage(widget.categoryName),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. TÍTULO DE AYUDAS SOMÁTICAS EN CUADRADITOS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pausas de 60 segundos',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${habits.length} opciones',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // --- 4. GRID DE CUADRADITOS DE AYUDAS ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habits.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.90,
                ),
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return _buildHabitSquare(habit, bgColor, accentColor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitSquare(MicroHabit habit, Color bgColor, Color accentColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openHabit(habit),
        borderRadius: LevTheme.squareRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? LevTheme.levDarkSurface : Colors.white,
            borderRadius: LevTheme.squareRadius,
            border: Border.all(color: isDark ? LevTheme.levDarkBorder : LevTheme.levBorder),
            boxShadow: isDark ? LevTheme.darkSoftShadow : LevTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Encabezado con ícono circular pastel y duración 60s
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LevTaskBadge(
                    action: habit.taskAction,
                    bgColor: bgColor,
                    accentColor: accentColor,
                    size: 42,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? LevTheme.levDarkSurfaceVariant : LevTheme.levCream,
                      borderRadius: LevTheme.pillRadius,
                      border: Border.all(color: isDark ? LevTheme.levDarkBorder : LevTheme.levBorder),
                    ),
                    child: Text(
                      '60s',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Título claro sin sobrecarga de texto
              Text(
                habit.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  height: 1.25,
                ),
              ),

              // Botón inferior sutil de inicio
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Iniciar pausa',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: accentColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

