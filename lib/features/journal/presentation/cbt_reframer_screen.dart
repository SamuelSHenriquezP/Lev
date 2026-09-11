import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/journal/domain/cbt_thought_card.dart';
import 'package:lev/features/journal/presentation/controllers/journal_controller.dart';

class CbtReframerScreen extends ConsumerStatefulWidget {
  const CbtReframerScreen({super.key});

  @override
  ConsumerState<CbtReframerScreen> createState() => _CbtReframerScreenState();
}

class _CbtReframerScreenState extends ConsumerState<CbtReframerScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _reframeController = TextEditingController();
  CognitiveDistortion? _selectedDistortion;

  @override
  void dispose() {
    _pageController.dispose();
    _thoughtController.dispose();
    _reframeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticsHelper.light();
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _saveCard();
    }
  }

  void _previousStep() {
    HapticsHelper.light();
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveCard() async {
    final thought = _thoughtController.text.trim();
    final reframe = _reframeController.text.trim();
    final distortion = _selectedDistortion?.name ?? 'Pensamiento Automático';

    if (thought.isEmpty || reframe.isEmpty) return;

    await ref.read(journalProvider.notifier).addCbtCard(
      automaticThought: thought,
      distortionName: distortion,
      compassionateReframe: reframe,
    );

    await HapticsHelper.medium();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tarjeta de afrontamiento guardada en tu santuario.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: LevTheme.levMatchaDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  bool get _canProceed {
    if (_currentStep == 0) return _thoughtController.text.trim().isNotEmpty;
    if (_currentStep == 1) return _selectedDistortion != null;
    if (_currentStep == 2) return _reframeController.text.trim().isNotEmpty;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _previousStep,
        ),
        title: Text(
          'Reestructuración TCC',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de pasos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildStepIndicator(0, '1. Pensamiento'),
                  const SizedBox(width: 8),
                  _buildStepIndicator(1, '2. Trampa'),
                  const SizedBox(width: 8),
                  _buildStepIndicator(2, '3. Compasión'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Contenido de cada paso
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),

            // Botón inferior de avance
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentStep == 2 ? 'Guardar Tarjeta Compasiva' : 'Continuar',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Expanded(
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? LevTheme.levMatcha
              : (isDone ? LevTheme.levMatchaLight : Colors.white),
          borderRadius: LevTheme.pillRadius,
          border: Border.all(
            color: isActive ? LevTheme.levMatcha : LevTheme.levBorder,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? Colors.white
                  : (isDone ? LevTheme.levMatchaDark : LevTheme.levTextMuted),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LevTheme.levLavanda.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology_rounded, size: 22, color: LevTheme.levMatchaDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Paso 1: Ponle nombre a la voz crítica o catastrofista de tu mente.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Qué pensamiento automático apareció?',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escríbelo tal cual lo sientes, sin censurarte. Los pensamientos no son hechos.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: LevTheme.levTextMuted,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _thoughtController,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Ej: "No he sido productivo hoy y estoy arruinando todo mi futuro..."',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué trampa de la mente es?',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reconocer el sesgo cognitivo le quita poder al pensamiento automático.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: LevTheme.levTextMuted,
            ),
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CognitiveDistortion.standardDistortions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = CognitiveDistortion.standardDistortions[index];
              final isSelected = _selectedDistortion?.id == item.id;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticsHelper.selection();
                  setState(() {
                    _selectedDistortion = item;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? LevTheme.levMatcha : LevTheme.levBorder,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected ? LevTheme.glowShadow : const [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, size: 22, color: LevTheme.levTextDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levTextDark,
                              ),
                            ),
                            Text(
                              item.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: LevTheme.levTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LevTheme.levMatchaLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: LevTheme.levMatcha,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.spa_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lev te recuerda:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levMatchaDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Si un ser querido te dijera exactamente lo que tú te estás diciendo, ¿le hablarías con la misma dureza o con compasión?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu Realidad Compasiva:',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe una perspectiva más amable, realista y basada en hechos:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: LevTheme.levTextMuted,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _reframeController,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Ej: "Hoy mi energía estuvo baja y eso es humano. No tengo que arreglar toda mi vida en una sola tarde."',
            ),
          ),
        ],
      ),
    );
  }
}

