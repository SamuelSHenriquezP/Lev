import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';

/// Pantalla de bienvenida e introducción interactiva con diseño botánico.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _ambientController;
  late final AnimationController _tapRippleController;
  int _interactiveSeedTaps = 0;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _tapRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ambientController.dispose();
    _tapRippleController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await LocalStorageService.setSeenOnboarding(true);
    HapticsHelper.medium();
    widget.onFinish();
  }

  void _onNext() {
    HapticsHelper.selection();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _onBack() {
    HapticsHelper.selection();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onSeedTapped() {
    HapticsHelper.light();
    setState(() => _interactiveSeedTaps++);
    _tapRippleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior con botón saltar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: LevTheme.levMatcha.withValues(alpha: 0.18),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.spa_rounded,
                            size: 16,
                            color: LevTheme.levMatchaDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lev',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : LevTheme.levTextDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Saltar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: LevTheme.levTextMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Carrusel interactivo
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (idx) {
                  HapticsHelper.selection();
                  setState(() => _currentPage = idx);
                },
                children: [
                  _buildSlide1MeetLev(isDark),
                  _buildSlide2Privacy(isDark),
                  _buildSlide3HowItWorks(isDark),
                ],
              ),
            ),

            // Barra inferior con indicador y botones
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón atrás
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _onBack,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white70 : LevTheme.levTextDark,
                      ),
                    )
                  else
                    const SizedBox(width: 48),

                  // Indicador de pastillas
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? LevTheme.levMatcha
                              : (isDark ? Colors.white24 : LevTheme.levMatchaLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Botón siguiente / comenzar
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LevTheme.levMatcha,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == 2 ? 22 : 18,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == 2 ? 'Comenzar' : 'Siguiente',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _currentPage == 2
                              ? Icons.spa_rounded
                              : Icons.arrow_forward_rounded,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Diapositiva 1: Conoce a Lev (Interactivo con la semilla)
  Widget _buildSlide1MeetLev(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Criatura interactiva
          GestureDetector(
            onTap: _onSeedTapped,
            child: AnimatedBuilder(
              animation: Listenable.merge([_ambientController, _tapRippleController]),
              builder: (context, child) {
                final ripple = _tapRippleController.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Aura concéntrica
                    Container(
                      width: 220 + ripple * 40,
                      height: 220 + ripple * 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LevTheme.levMatcha.withValues(
                          alpha: (0.10 - ripple * 0.08).clamp(0.0, 0.15),
                        ),
                      ),
                    ),
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            LevTheme.levMatcha.withValues(alpha: 0.25),
                            LevTheme.levMatcha.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        size: const Size(160, 160),
                        painter: LivingSeedSpiritPainter(
                          animationValue: _ambientController.value,
                          emotion: _interactiveSeedTaps > 0
                              ? LevEmotion.celebrating
                              : LevEmotion.peaceful,
                          isPetting: false,
                          growthStage: LevGrowthStage.seed,
                          sizeScale: 0.95,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          // Tip interactivo
          AnimatedOpacity(
            opacity: _interactiveSeedTaps == 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_rounded, size: 14, color: LevTheme.levMatchaDark),
                const SizedBox(width: 4),
                Text(
                  'Toca la semilla para sentir su latido',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: LevTheme.levMatchaDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Conoce a Lev',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Un espíritu botánico que habita en tu santuario personal. No te exige rachas ni perfeccionismo; florece al compás de tu propia calma.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Diapositiva 2: Privacidad Sagrada 100% Offline
  Widget _buildSlide2Privacy(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emblema de escudo botánico
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LevTheme.levMatcha.withValues(alpha: 0.12),
              border: Border.all(
                color: LevTheme.levMatcha.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.lock_rounded,
                size: 64,
                color: LevTheme.levMatchaDark,
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Tu Privacidad es Sagrada',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Todo lo que sientes, respiras y escribes permanece estrictamente en tu teléfono. Sin servidores, sin cuentas y sin miradas ajenas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              height: 1.45,
              color: isDark ? Colors.white70 : LevTheme.levTextMuted,
            ),
          ),

          const SizedBox(height: 24),
          // Pastillas de garantía
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('🌿 100% Offline', isDark),
              const SizedBox(width: 8),
              _buildBadge('🔒 Cifrado Local', isDark),
              const SizedBox(width: 8),
              _buildBadge('✨ Sin Anuncios', isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// Diapositiva 3: Cómo Funciona el Santuario
  Widget _buildSlide3HowItWorks(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'El Ritmo de la Calma',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tres pilares sencillos para tu bienestar diario',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: isDark ? Colors.white70 : LevTheme.levTextMuted,
            ),
          ),

          const SizedBox(height: 24),
          _buildFeatureCard(
            emoji: '💧',
            title: 'Pausas y Gotas de Rocío',
            desc: 'Realiza micro-respiraciones y pausas somáticas de 60s para ganar Gotas de Cuidado y regar a Lev.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            emoji: '🌱',
            title: '8 Etapas de Crecimiento',
            desc: 'Lev evoluciona de semilla a espíritu del bosque. Su crecimiento es el reflejo visible de tu autocuidado.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            emoji: '🌸',
            title: 'Santuario a tu Medida',
            desc: 'Coloca libremente 19 decoraciones botánicas, escucha la lluvia zen y acaricia a Lev cuando lo necesites.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2F29) : LevTheme.levMatchaLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LevTheme.levMatcha.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF80E2BF) : LevTheme.levMatchaDark,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String emoji,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162420) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF263D36) : LevTheme.levBorder,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LevTheme.levMatcha.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : LevTheme.levTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    height: 1.35,
                    color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
