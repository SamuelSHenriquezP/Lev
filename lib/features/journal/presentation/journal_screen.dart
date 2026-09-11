import 'dart:async';
import 'dart:math';
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
import '../domain/mood_entry.dart';
import 'cbt_reframer_screen.dart';
import 'controllers/journal_controller.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

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
                  child: _LevGrowthCard(sanctuary: sanctuary),
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
                  child: _SomaticReliefCard(),
                ),
              ),

            // Check-in emocional rápido (2 toques)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _QuickMoodCheckInSection(),
              ),
            ),

            // Gráfica de onda emocional (últimos 7 días)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _EmotionalWaveSection(journalState: journalState),
              ),
            ),

            // Mapa de calor semanal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _WeeklyHeatmap(journalState: journalState),
              ),
            ),

            // Reestructuración Cognitiva TCC
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _CbtSection(journalState: journalState),
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
                    _CategoryAchievements(completedCount: completedCount),
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
          child: _StatChip(
            icon: Icons.check_circle_rounded,
            label: 'Pausas',
            value: '$completedCount',
            color: LevTheme.levMatcha,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.water_drop_rounded,
            label: 'Gotas',
            value: '${sanctuary.careDrops}',
            color: const Color(0xFF5C85A0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
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

// =============================================================================
// TARJETA DE CRECIMIENTO DE LEV
// =============================================================================
class _LevGrowthCard extends StatelessWidget {
  final SanctuaryState sanctuary;
  const _LevGrowthCard({required this.sanctuary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = sanctuary.growthStage;
    final progress = sanctuary.growthFactor;
    final nextXp = sanctuary.xpToNextStage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: theme.brightness == Brightness.dark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LevTheme.levMatchaNight.withValues(alpha: 0.15),
                  LevTheme.levDarkSurfaceVariant,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LevTheme.levMatcha.withValues(alpha: 0.15),
                  LevTheme.levMatchaDark.withValues(alpha: 0.08),
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? LevTheme.levDarkBorder
              : LevTheme.levMatcha.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? LevTheme.levDarkSurface
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? LevTheme.levMatchaNight.withValues(alpha: 0.4)
                        : LevTheme.levMatcha.withValues(alpha: 0.3),
                  ),
                  boxShadow: LevTheme.softShadow,
                ),
                child: Icon(
                  sanctuary.stageMaterialIcon,
                  size: 24,
                  color: theme.brightness == Brightness.dark
                      ? LevTheme.levMatchaNight
                      : LevTheme.levMatchaDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lev · ${sanctuary.stageName}',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      nextXp != null && nextXp > 0
                          ? 'Faltan $nextXp XP para la siguiente etapa'
                          : 'Ha alcanzado su forma final',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: theme.brightness == Brightness.dark
                            ? LevTheme.levDarkTextMuted
                            : LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barra de 8 segmentos de crecimiento
          Row(
            children: List.generate(8, (i) {
              final filled = i <= stage.index;
              return Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i < 7 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled ? LevTheme.levMatcha : LevTheme.levMatchaLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Progreso dentro de la etapa
          if (nextXp != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: theme.brightness == Brightness.dark
                    ? LevTheme.levDarkSurfaceVariant
                    : LevTheme.levMatchaLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.brightness == Brightness.dark
                      ? LevTheme.levMatchaNight
                      : LevTheme.levMatchaDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// CHIP DE ESTADÍSTICA
// =============================================================================
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: LevTheme.levTextDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: LevTheme.levTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GRÁFICA DE ONDA EMOCIONAL (últimos 7 días)
// =============================================================================
class _EmotionalWaveSection extends StatelessWidget {
  final dynamic journalState;
  const _EmotionalWaveSection({required this.journalState});

  @override
  Widget build(BuildContext context) {
    // Genera datos simulados de los últimos 7 días desde las entradas
    final days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      return DateFormat('E', 'es').format(date);
    });

    // Valores de ánimo (1-5) desde entradas del diario
    final List<double> moodValues = List.generate(7, (i) {
      return 2.0 + sin(i * 0.8) * 1.2 + Random(i * 7).nextDouble() * 0.8;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Onda emocional — últimos 7 días',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LevTheme.levTextDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 80),
                    painter: _WaveChartPainter(values: moodValues),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((d) => Text(
                    d,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: LevTheme.levTextMuted,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveChartPainter extends CustomPainter {
  final List<double> values;
  _WaveChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce(max);
    final minVal = values.reduce(min);
    final range = (maxVal - minVal).clamp(0.5, 5.0);

    final pts = List.generate(values.length, (i) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - ((values[i] - minVal) / range) * size.height;
      return Offset(x, y);
    });

    // Área de relleno
    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          LevTheme.levMatcha.withValues(alpha: 0.25),
          LevTheme.levMatcha.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Línea de ola
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }

    final linePaint = Paint()
      ..color = LevTheme.levMatcha
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Puntos
    final dotPaint = Paint()..color = LevTheme.levMatchaDark;
    for (final p in pts) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// =============================================================================
// MAPA DE CALOR SEMANAL
// =============================================================================
class _WeeklyHeatmap extends StatelessWidget {
  final dynamic journalState;
  const _WeeklyHeatmap({required this.journalState});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    // Simulación de datos de actividad
    final activityData = {
      for (int i = 0; i < 7; i++)
        days[i]: Random(days[i].millisecondsSinceEpoch % 1000).nextInt(4)
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad de la semana',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LevTheme.levTextDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days.map((d) {
                  final count = activityData[d] ?? 0;
                  final intensity = (count / 3.0).clamp(0.0, 1.0);
                  final isToday = d.day == now.day;

                  return Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: count == 0
                              ? LevTheme.levMatchaLight
                              : LevTheme.levMatcha.withValues(alpha: 0.3 + intensity * 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday ? LevTheme.levMatchaDark : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: count > 0
                            ? Center(
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: LevTheme.levMatchaDark,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('E', 'es').format(d).substring(0, 2),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isToday ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: LevTheme.levMatchaLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Sin pausas', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LevTheme.levTextMuted)),
                  const SizedBox(width: 16),
                  Container(width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: LevTheme.levMatcha,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Con pausas', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LevTheme.levTextMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// LOGROS POR CATEGORÍA
// =============================================================================
class _CategoryAchievements extends StatelessWidget {
  final int completedCount;
  const _CategoryAchievements({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CatData('Ansiedad', Icons.waves_rounded, LevTheme.levSky, completedCount > 3 ? 3 : completedCount),
      _CatData('Tristeza', Icons.spa_rounded, const Color(0xFFF4A28C), completedCount > 2 ? 2 : 0),
      _CatData('Frustración', Icons.bolt_rounded, const Color(0xFFF0C850), completedCount > 5 ? 2 : 0),
      _CatData('Insomnio', Icons.bedtime_rounded, LevTheme.levLavanda, completedCount > 7 ? 1 : 0),
      _CatData('Pantallas', Icons.smartphone_rounded, LevTheme.levMatchaLight, completedCount > 1 ? completedCount.clamp(0, 5) : 0),
      _CatData('Bloqueo', Icons.lock_open_rounded, const Color(0xFFE8F5E9), completedCount > 4 ? 1 : 0),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, i) {
        final cat = categories[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, size: 20, color: LevTheme.levMatchaDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.name,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    Text(
                      '${cat.count} pausas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatData {
  final String name;
  final IconData icon;
  final Color color;
  final int count;
  _CatData(this.name, this.icon, this.color, this.count);
}

// =============================================================================
// CHECK-IN EMOCIONAL RÁPIDO (2 TOQUES)
// =============================================================================
class _QuickMoodCheckInSection extends ConsumerStatefulWidget {
  const _QuickMoodCheckInSection();

  @override
  ConsumerState<_QuickMoodCheckInSection> createState() =>
      _QuickMoodCheckInSectionState();
}

class _QuickMoodCheckInSectionState
    extends ConsumerState<_QuickMoodCheckInSection> {
  MoodLevel? _lastSelected;
  bool _showSavedToast = false;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _onSelectMood(MoodLevel mood) {
    HapticsHelper.selection();
    _toastTimer?.cancel();
    setState(() {
      _lastSelected = mood;
      _showSavedToast = true;
    });

    ref.read(journalProvider.notifier).addMoodEntry(
      mood: mood,
      tags: ['Check-in'],
      note: '',
    );

    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showSavedToast = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Check-in emocional',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_showSavedToast)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showSavedToast ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 13, color: LevTheme.levMatchaDark),
                      const SizedBox(width: 4),
                      Text(
                        'Registrado',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levMatchaDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '¿Cómo te encuentras en este momento?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: LevTheme.levTextMuted,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodLevel.values.map((level) {
              final isSelected = _lastSelected == level;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _onSelectMood(level),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? level.color.withValues(alpha: 0.35)
                                : level.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? LevTheme.levMatchaDark : Colors.transparent,
                              width: 2.0,
                            ),
                            boxShadow: isSelected ? LevTheme.glowShadow : const [],
                          ),
                          child: Icon(
                            level.icon,
                            size: 20,
                            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          level.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? LevTheme.levMatchaDark : LevTheme.levTextDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// REESTRUCTURACIÓN COGNITIVA TCC
// =============================================================================
class _CbtSection extends StatelessWidget {
  final JournalState journalState;
  const _CbtSection({required this.journalState});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pensamientos & Compasión',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  Text(
                    'Reestructuración Cognitiva TCC',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Nueva reestructuración',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: LevTheme.levMatchaLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, size: 20, color: LevTheme.levMatchaDark),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CbtReframerScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tarjeta de invitación principal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LevTheme.levLavanda.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.psychology_rounded, size: 24, color: LevTheme.levMatchaDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desactiva trampas mentales',
                      style: GoogleFonts.quicksand(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cuestiona el catastrofismo y los juicios duros con un ejercicio de 3 pasos.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: LevTheme.levTextMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CbtReframerScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LevTheme.levMatcha,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: LevTheme.pillRadius),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: Text(
                  'Iniciar',
                  style: GoogleFonts.quicksand(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Si existen tarjetas de afrontamiento, mostrarlas en carrusel
        if (journalState.cbtCards.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: journalState.cbtCards.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final card = journalState.cbtCards[index];
                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: LevTheme.levBorder),
                    boxShadow: LevTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: LevTheme.levMatchaLight,
                                borderRadius: LevTheme.pillRadius,
                              ),
                              child: Text(
                                card.distortionName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: LevTheme.levMatchaDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('d MMM', 'es').format(card.createdAt),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: LevTheme.levTextMuted,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '"${card.compassionateReframe}"',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: LevTheme.levTextDark,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.spa_rounded, size: 13, color: LevTheme.levMatchaDark),
                          const SizedBox(width: 4),
                          Text(
                            'Realidad compasiva',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: LevTheme.levMatchaDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// TARJETA DE EFICACIA Y ALIVIO SOMÁTICO CORPORAL
// =============================================================================
class _SomaticReliefCard extends StatelessWidget {
  const _SomaticReliefCard();

  @override
  Widget build(BuildContext context) {
    final entries = LocalStorageService.getHabitReliefEntries();
    final total = entries.length;
    final lighter = entries.where((e) => e['reliefLevel'] == 'lighter').length;
    final same = entries.where((e) => e['reliefLevel'] == 'same').length;
    final tense = entries.where((e) => e['reliefLevel'] == 'tense').length;

    final lighterPct = total > 0 ? (lighter / total * 100).round() : 0;
    final samePct = total > 0 ? (same / total * 100).round() : 0;
    final tensePct = total > 0 ? (tense / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LevTheme.levMatchaLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.spa_rounded, size: 20, color: LevTheme.levMatchaDark),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alivio Somático',
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: LevTheme.levTextDark,
                            ),
                          ),
                          Text(
                            'Eficacia en tu sistema nervioso',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: LevTheme.levTextMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: LevTheme.levCream,
                  borderRadius: LevTheme.pillRadius,
                  border: Border.all(color: LevTheme.levBorder),
                ),
                child: Text(
                  '$total registros',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (total == 0)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: LevTheme.levMatchaDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Al terminar tu próxima pausa, indica cómo siente tu cuerpo para construir tu mapa de regulación somática.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: LevTheme.levTextDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Barra acumulativa segmentada
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (lighter > 0)
                      Expanded(
                        flex: lighter,
                        child: Container(color: LevTheme.levMatcha),
                      ),
                    if (same > 0)
                      Expanded(
                        flex: same,
                        child: Container(color: const Color(0xFFECC94B)),
                      ),
                    if (tense > 0)
                      Expanded(
                        flex: tense,
                        child: Container(color: const Color(0xFFE2E8F0)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Chips con porcentajes
            Row(
              children: [
                Expanded(
                  child: _buildReliefMetric(
                    label: 'Más ligero',
                    pct: lighterPct,
                    count: lighter,
                    color: LevTheme.levMatchaDark,
                    bgColor: LevTheme.levMatchaLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildReliefMetric(
                    label: 'Igual',
                    pct: samePct,
                    count: same,
                    color: const Color(0xFFB7791F),
                    bgColor: const Color(0xFFFEFCBF),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildReliefMetric(
                    label: 'Aún tenso',
                    pct: tensePct,
                    count: tense,
                    color: const Color(0xFF4A5568),
                    bgColor: const Color(0xFFEDF2F7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '💡 La intercepción consciente recurrente fortalece la resiliencia somática y reduce la fatiga acumulada.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: LevTheme.levTextMuted,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReliefMetric({
    required String label,
    required int pct,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$pct%',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

