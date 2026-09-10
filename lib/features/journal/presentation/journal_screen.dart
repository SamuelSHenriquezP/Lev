import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/lev_theme.dart';
import '../../../core/utils/haptics_helper.dart';
import '../domain/cbt_thought_card.dart';
import '../domain/mood_entry.dart';
import 'cbt_reframer_screen.dart';
import 'controllers/journal_controller.dart';
import 'widgets/emotional_wave_chart.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  MoodLevel _selectedMood = MoodLevel.calm;
  final Set<String> _selectedTags = {'Pantallas'};
  final TextEditingController _noteController = TextEditingController();

  static const List<String> _availableTags = [
    'Pantallas',
    'Trabajo',
    'Familia',
    'Pareja',
    'Dormir',
    'Escuela',
    'Amigos',
    'Salud',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    HapticsHelper.light();
    await ref.read(journalProvider.notifier).addMoodEntry(
      mood: _selectedMood,
      tags: _selectedTags.toList(),
      note: _noteController.text.trim(),
    );

    _noteController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🍃 Estado registrado. Lev respira contigo.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: LevTheme.levMatchaDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  void _openCbtReframer() {
    HapticsHelper.light();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CbtReframerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalProvider);

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      appBar: AppBar(
        title: Text(
          'Diario Inteligente & TCC',
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: LevTheme.levTextDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Estado Rápido (Mood Slider / Chips estilo Imagen 1 y 4)
              _buildMoodLoggerCard(),
              const SizedBox(height: 24),

              // Gráfica de ondas suaves
              EmotionalWaveChart(entries: journalState.moodEntries),
              const SizedBox(height: 24),

              // Banner para Reestructuración TCC
              _buildCbtBanner(),
              const SizedBox(height: 24),

              // Tarjetas de Afrontamiento Guardadas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tarjetas de Afrontamiento',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  Text(
                    '${journalState.cbtCards.length} guardadas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (journalState.cbtCards.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: LevTheme.cardRadius,
                    border: Border.all(color: LevTheme.levBorder),
                  ),
                  child: Center(
                    child: Text(
                      'No tienes tarjetas aún. Transforma tu primer pensamiento intrusivo con el botón de arriba.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: journalState.cbtCards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final card = journalState.cbtCards[index];
                    return _buildCopingCardItem(card);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodLoggerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: LevTheme.cardRadius,
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '¿Cómo late tu corazón en este minuto?',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selector horizontal de estados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: MoodLevel.values.map((mood) {
              final isSelected = mood == _selectedMood;
              return GestureDetector(
                onTap: () {
                  HapticsHelper.selection();
                  setState(() {
                    _selectedMood = mood;
                  });
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? LevTheme.levMatchaLight
                            : LevTheme.levCream,
                        border: Border.all(
                          color: isSelected
                              ? LevTheme.levMatcha
                              : LevTheme.levBorder,
                          width: isSelected ? 2.2 : 1.0,
                        ),
                        boxShadow: isSelected ? LevTheme.glowShadow : const [],
                      ),
                      child: Center(
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mood.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? LevTheme.levMatchaDark
                            : LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),
          const Divider(color: LevTheme.levBorder, height: 1),
          const SizedBox(height: 14),

          // Contexto / Chips de situación
          Text(
            'Contexto actual:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: LevTheme.levTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                backgroundColor: LevTheme.levCream,
                selectedColor: LevTheme.levMatchaLight,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: LevTheme.pillRadius,
                  side: BorderSide(
                    color: isSelected ? LevTheme.levMatcha : LevTheme.levBorder,
                  ),
                ),
                onSelected: (val) {
                  HapticsHelper.selection();
                  setState(() {
                    if (val) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 14),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Nota opcional sobre este momento...',
              fillColor: LevTheme.levCream,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: LevTheme.levMatcha,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Registrar en mi Santuario'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCbtBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2D9F3), Color(0xFFFAF0E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: LevTheme.cardRadius,
        boxShadow: LevTheme.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Text(
                    '🧠 Reestructuración TCC',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B4E71),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transforma un pensamiento intrusivo',
                  style: GoogleFonts.quicksand(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aprende a diferenciar un hecho de una distorsión con la ayuda de Lev.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: LevTheme.levTextMuted,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _openCbtReframer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4E71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: const Text('Iniciar Reencuadre'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('🪷', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  Widget _buildCopingCardItem(CbtThoughtCard card) {
    final dateStr = DateFormat('d MMM, yyyy', 'es').format(card.createdAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: LevTheme.cardRadius,
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LevTheme.levPeach.withValues(alpha: 0.2),
                  borderRadius: LevTheme.pillRadius,
                ),
                child: Text(
                  card.distortionName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: LevTheme.levPeachDark,
                  ),
                ),
              ),
              Text(
                dateStr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: LevTheme.levTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pensamiento automático
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LevTheme.levCream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚡ ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    '"${card.automaticThought}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Realidad compasiva
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LevTheme.levMatchaLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌱 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    card.compassionateReframe,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
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
    );
  }
}

