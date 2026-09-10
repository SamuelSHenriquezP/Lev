import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/lev_theme.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../habits/data/habits_database.dart';
import '../../habits/presentation/habit_timer_screen.dart';

class CrisisSosModal extends StatelessWidget {
  const CrisisSosModal({super.key});

  static void show(BuildContext context) {
    HapticsHelper.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
      ),
      builder: (context) => const CrisisSosModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior de arrastre
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: LevTheme.levBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Cabecera compasiva
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LevTheme.levPeach.withValues(alpha: 0.25),
                    ),
                    child: const Center(
                      child: Text('🛟', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salvavidas Emocional',
                          style: GoogleFonts.quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: LevTheme.levTextDark,
                          ),
                        ),
                        Text(
                          'Estás a salvo aquí y ahora',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: LevTheme.levPeachDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LevTheme.levCream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LevTheme.levBorder),
                ),
                child: Text(
                  'Si sientes que el aire no te alcanza, tu corazón late desbocado o el mundo te pesa demasiado, recuerda: esto es una ola y va a bajar. No estás en peligro real.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: LevTheme.levTextDark,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Herramientas de rescate somático inmediato
              Text(
                'Regulación somática urgente:',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 12),

              _buildActionTile(
                context: context,
                emoji: '🫁',
                title: 'Suspiro Fisiológico de Emergencia',
                subtitle: 'Calma el ritmo cardíaco en 3 respiraciones exactas.',
                habitId: 'anx_01',
                badgeColor: LevTheme.levSky,
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                context: context,
                emoji: '🎯',
                title: 'Anclaje Sensorial 3-2-1',
                subtitle: 'Frena la despersonalización y el pánico tocando tu entorno.',
                habitId: 'anx_02',
                badgeColor: LevTheme.levPeach,
              ),
              const SizedBox(height: 28),

              // Directorio de Líneas de Ayuda en Crisis
              Row(
                children: [
                  const Text('📞', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Líneas de apoyo gratuitas (24/7):',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Atendidas por psicólogos, totalmente confidenciales y gratuitas.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: LevTheme.levTextMuted,
                ),
              ),
              const SizedBox(height: 14),

              _buildHelplineCard('🇪🇸 España', '024 (Línea de Vida) / 717 003 717 (Teléfono de la Esperanza)'),
              const SizedBox(height: 8),
              _buildHelplineCard('🇲🇽 México', '800 911 2000 (Línea de la Vida, 24 horas)'),
              const SizedBox(height: 8),
              _buildHelplineCard('🇨🇴 Colombia', 'Línea 106 (Salud Mental y Escucha Telefónica)'),
              const SizedBox(height: 8),
              _buildHelplineCard('🇦🇷 Argentina', '135 o (011) 5275-1135 (Centro de Asistencia al Suicida)'),
              const SizedBox(height: 8),
              _buildHelplineCard('🌎 Internacional / EE.UU.', '988 (Crisis & Suicide Lifeline / SMS o Llamada)'),

              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cerrar salvavidas',
                    style: GoogleFonts.plusJakartaSans(
                      color: LevTheme.levTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required String habitId,
    required Color badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).pop(); // Cierra modal
            final habit = HabitsDatabase.getById(habitId);
            if (habit != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HabitTimerScreen(habit: habit),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: LevTheme.levTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: LevTheme.levTextMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelplineCard(String country, String phone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: LevTheme.levCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LevTheme.levBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: LevTheme.levMatchaDark,
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

