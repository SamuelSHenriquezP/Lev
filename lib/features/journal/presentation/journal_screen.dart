import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/lev_theme.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../../core/widgets/pin_protection_gate.dart';
import '../../sanctuary/domain/sanctuary_state.dart';
import '../../sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'controllers/journal_controller.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import 'widgets/journal_somatic_relief_card.dart';
import 'widgets/journal_cbt_section.dart';
import 'widgets/journal_quick_mood_checkin.dart';
import 'widgets/journal_weekly_heatmap.dart';
import 'widgets/journal_emotional_wave_section.dart';
import 'widgets/journal_growth_card.dart';

/// Pantalla de Progreso — solo estadísticas con sentido.
/// Gráfica emocional, crecimiento de Lev, logros por categoría, mapa de calor.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalProvider);
    final sanctuary = ref.watch(sanctuaryProvider);
    final completedCount = LocalStorageService.getCompletedHabitsCount();

    return PinProtectionGate(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App bar con título y botón de reporte clínico
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progreso',
                              style: GoogleFonts.quicksand(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : LevTheme.levTextDark,
                              ),
                            ),
                            Text(
                              'Tu camino con Lev',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : LevTheme.levTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.help_outline_rounded, size: 20),
                            color: LevTheme.levMatchaDark,
                            tooltip: 'Guía de inicio',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            onPressed: () {
                              HapticsHelper.light();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OnboardingScreen(
                                    onFinish: () => Navigator.pop(context),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.backup_outlined, size: 20),
                            color: LevTheme.levMatchaDark,
                            tooltip: 'Copia de seguridad',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            onPressed: () => _showBackupModal(context, ref),
                          ),
                          IconButton(
                            icon: const Icon(Icons.description_outlined, size: 20),
                            color: LevTheme.levMatchaDark,
                            tooltip: 'Reporte clínico',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            onPressed: () => _showTherapyReportModal(context, journalState, sanctuary, completedCount),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Estadísticas de crecimiento de Lev
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: LevGrowthCard(sanctuary: sanctuary),
                ),
              ),

              // Resumen de estadísticas (3 tarjetas)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildStatsRow(completedCount, sanctuary),
                ),
              ),

              // Eficacia somática y alivio corporal
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SomaticReliefCard(),
                ),
              ),

            // Check-in emocional rápido (2 toques)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: QuickMoodCheckInSection(),
              ),
            ),

            // Gráfica de onda emocional (últimos 7 días)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: EmotionalWaveSection(journalState: journalState),
              ),
            ),

            // Mapa de calor semanal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: WeeklyHeatmap(journalState: journalState),
              ),
            ),

            // Reestructuración Cognitiva TCC
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: JournalCbtSection(journalState: journalState),
              ),
            ),

            // Logros por categoría
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pausas por emoción',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CategoryAchievements(completedCount: completedCount),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    ));
  }

  void _showTherapyReportModal(
    BuildContext context,
    JournalState journalState,
    SanctuaryState sanctuary,
    int completedCount,
  ) {
    HapticsHelper.light();
    final reportText = _generateTherapyReportText(journalState, sanctuary, completedCount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: LevTheme.levMatchaLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.summarize_rounded, size: 20, color: LevTheme.levMatchaDark),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reporte Clínico',
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: LevTheme.levTextDark,
                                ),
                              ),
                              Text(
                                'Para tus sesiones de terapia o auto-observación',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: LevTheme.levTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20, color: LevTheme.levTextMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Área de texto del reporte
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: LevTheme.levBorder),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: SelectableText(
                          reportText,
                          style: GoogleFonts.firaCode(
                            fontSize: 11.5,
                            color: LevTheme.levTextDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Botón Copiar al Portapapeles
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticsHelper.medium();
                        await Clipboard.setData(ClipboardData(text: reportText));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '📋 Reporte copiado al portapapeles con éxito',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: LevTheme.levMatchaDark,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: LevTheme.cardRadius),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white),
                      label: Text(
                        'Copiar Reporte Completo',
                        style: GoogleFonts.quicksand(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LevTheme.levMatcha,
                        shape: RoundedRectangleBorder(borderRadius: LevTheme.pillRadius),
                        elevation: 0,
                      ),
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

  void _showBackupModal(BuildContext context, WidgetRef ref) {
    HapticsHelper.light();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF162420) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF263D36) : LevTheme.levBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: LevTheme.levMatchaLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.backup_rounded, size: 20, color: LevTheme.levMatchaDark),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Copia de Seguridad',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : LevTheme.levTextDark,
                        ),
                      ),
                      Text(
                        'Exporta o restaura tus datos 100% offline',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Opción 1: Exportar
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.file_download_outlined, color: LevTheme.levMatchaDark),
                ),
                title: Text(
                  'Exportar Respaldo (Copiar JSON)',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : LevTheme.levTextDark,
                  ),
                ),
                subtitle: Text(
                  'Copia todos tus hábitos, diario y progreso al portapapeles',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                  ),
                ),
                onTap: () {
                  final json = LocalStorageService.exportFullBackupJson();
                  Clipboard.setData(ClipboardData(text: json));
                  Navigator.pop(context);
                  HapticsHelper.medium();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Respaldo JSON copiado al portapapeles. ¡Guárdalo en tus notas o mensajes!'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
              ),
              const Divider(height: 20),
              // Opción 2: Importar
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.file_upload_outlined, color: Color(0xFF1976D2)),
                ),
                title: Text(
                  'Restaurar Respaldo (Pegar JSON)',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : LevTheme.levTextDark,
                  ),
                ),
                subtitle: Text(
                  'Pega un respaldo exportado previamente para rehidratar tus datos',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showImportDialog(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF162420) : Colors.white,
          title: Text(
            'Restaurar Datos',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LevTheme.levTextDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pega aquí el texto JSON de tu respaldo:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 5,
                style: GoogleFonts.firaCode(
                  fontSize: 11,
                  color: isDark ? Colors.white : LevTheme.levTextDark,
                ),
                decoration: InputDecoration(
                  hintText: '{\n  "version": "1.0", ...\n}',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                final success = await LocalStorageService.importFullBackupJson(text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  if (success) {
                    HapticsHelper.medium();
                    ref.invalidate(sanctuaryProvider);
                    ref.invalidate(journalProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✨ Respaldo restaurado con éxito.')),
                    );
                  } else {
                    HapticsHelper.heavy();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ Formato de respaldo no válido.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LevTheme.levMatcha,
                foregroundColor: Colors.white,
              ),
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );
  }

  String _generateTherapyReportText(
    JournalState journalState,
    SanctuaryState sanctuary,
    int completedCount,
  ) {
    final entries = LocalStorageService.getHabitReliefEntries();
    final totalRelief = entries.length;
    final lighter = entries.where((e) => e['reliefLevel'] == 'lighter').length;
    final same = entries.where((e) => e['reliefLevel'] == 'same').length;
    final tense = entries.where((e) => e['reliefLevel'] == 'tense').length;
    final lighterPct = totalRelief > 0 ? (lighter / totalRelief * 100).round() : 0;
    final samePct = totalRelief > 0 ? (same / totalRelief * 100).round() : 0;
    final tensePct = totalRelief > 0 ? (tense / totalRelief * 100).round() : 0;

    final cbtCards = journalState.cbtCards;
    final moodEntries = journalState.moodEntries;

    final buffer = StringBuffer();
    buffer.writeln('==============================================');
    buffer.writeln('📋 REPORTE CLÍNICO DE BIENESTAR SOMÁTICO Y EMOCIONAL');
    buffer.writeln('Lev Health Companion — Privacidad 100% Local');
    buffer.writeln('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln('Usuario: ${LocalStorageService.getUserName()}');
    buffer.writeln('==============================================\n');

    buffer.writeln('1. INTERVENCIONES SOMÁTICAS Y CONDUCTUALES');
    buffer.writeln('• Micro-pausas conscientes completadas: $completedCount');
    buffer.writeln('• Gotas de autorregulación acumuladas: ${sanctuary.careDrops}');
    buffer.writeln('• Etapa de maduración somática: ${sanctuary.stageName} (${sanctuary.experiencePoints} XP)');
    buffer.writeln('• Evaluaciones corporales post-hábito registradas: $totalRelief');
    if (totalRelief > 0) {
      buffer.writeln('  - Sensación de mayor ligereza (alivio somático): $lighter ($lighterPct%)');
      buffer.writeln('  - Estado neutro / en proceso: $same ($samePct%)');
      buffer.writeln('  - Tensión persistente (alerta de sobrecarga): $tense ($tensePct%)');
    }
    buffer.writeln('');

    buffer.writeln('2. HISTORIAL DE ÁNIMO Y AFECTO');
    buffer.writeln('• Total de check-ins registrados: ${moodEntries.length}');
    if (moodEntries.isNotEmpty) {
      final recent = moodEntries.take(10).toList();
      for (final e in recent) {
        buffer.writeln('  - ${DateFormat('dd/MM HH:mm').format(e.timestamp)}: ${e.mood.emoji} ${e.mood.label} (Nivel: ${e.mood.score}/5)');
        if (e.note.isNotEmpty) {
          buffer.writeln('    Nota: "${e.note}"');
        }
      }
    }
    buffer.writeln('');

    buffer.writeln('3. REGISTROS DE REESTRUCTURACIÓN COGNITIVA (TCC)');
    buffer.writeln('• Pensamientos automáticos reencuadrados: ${cbtCards.length}');
    if (cbtCards.isNotEmpty) {
      for (final card in cbtCards.take(5)) {
        buffer.writeln('  - Pensamiento automático: "${card.automaticThought}"');
        buffer.writeln('    Distorsión cognitiva: ${card.distortionName}');
        buffer.writeln('    Reencuadre compasivo: "${card.compassionateReframe}"');
      }
    }
    buffer.writeln('');
    buffer.writeln('==============================================');
    buffer.writeln('Nota clínica: Este informe resume las micro-intervenciones conductuales, somáticas y cognitivas realizadas de forma autónoma entre sesiones de acompañamiento profesional.');
    return buffer.toString();
  }

  Widget _buildStatsRow(int completedCount, SanctuaryState sanctuary) {
    return Row(
      children: [
        Expanded(
          child: StatChip(
            icon: Icons.check_circle_rounded,
            label: 'Pausas',
            value: '$completedCount',
            color: LevTheme.levMatcha,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatChip(
            icon: Icons.water_drop_rounded,
            label: 'Gotas',
            value: '${sanctuary.careDrops}',
            color: const Color(0xFF5C85A0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatChip(
            icon: Icons.energy_savings_leaf_rounded,
            label: 'Etapa',
            value: '${sanctuary.growthStage.index + 1}/8',
            color: LevTheme.levMatchaDark,
          ),
        ),
      ],
    );
  }
}
