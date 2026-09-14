import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/lev_theme.dart';

class SomaticReliefCard extends StatelessWidget {
  const SomaticReliefCard({super.key});

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
