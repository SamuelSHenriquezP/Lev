import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/lev_theme.dart';
import '../cbt_reframer_screen.dart';
import '../controllers/journal_controller.dart';

class JournalCbtSection extends StatelessWidget {
  final JournalState journalState;
  const JournalCbtSection({super.key, required this.journalState});

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
