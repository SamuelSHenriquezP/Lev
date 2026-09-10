import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/lev_theme.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../habits/data/habits_database.dart';
import '../../habits/presentation/habit_timer_screen.dart';

/// Modal de emergencia/crisis.
/// Colombia aparece PRIMERO. Los teléfonos son táctiles y llaman de verdad.
class CrisisSosModal extends StatefulWidget {
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
  State<CrisisSosModal> createState() => _CrisisSosModalState();
}

class _CrisisSosModalState extends State<CrisisSosModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String number) async {
    HapticsHelper.medium();
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre
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

              // Cabecera
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE76F51).withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.emergency_rounded,
                        color: Color(0xFFE76F51), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ayuda Emocional',
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
                            color: const Color(0xFFE76F51),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mensaje de calma
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

              // Regulación somática urgente
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
                icon: Icons.air_rounded,
                title: 'Suspiro Fisiológico',
                subtitle: 'Calma el ritmo cardíaco en 3 respiraciones exactas.',
                habitId: 'anx_01',
                badgeColor: LevTheme.levSky,
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                context: context,
                icon: Icons.my_location_rounded,
                title: 'Anclaje Sensorial 3-2-1',
                subtitle: 'Frena la despersonalización tocando tu entorno.',
                habitId: 'anx_02',
                badgeColor: LevTheme.levPeach,
              ),
              const SizedBox(height: 28),

              // COLOMBIA PRIMERO — Botón grande de llamada
              _buildColombiaHero(),
              const SizedBox(height: 20),

              // Más líneas de ayuda
              Row(
                children: [
                  const Icon(Icons.phone_rounded,
                      size: 18, color: LevTheme.levTextDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Otras líneas de apoyo (24/7):',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: LevTheme.levTextDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Atendidas por psicólogos, totalmente confidenciales y gratuitas.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: LevTheme.levTextMuted),
              ),
              const SizedBox(height: 14),

              _buildHelplineCard(
                  country: 'España',
                  number: '717003717',
                  label: '024 · Línea de Vida / 717 003 717'),
              const SizedBox(height: 8),
              _buildHelplineCard(
                  country: 'México',
                  number: '8009112000',
                  label: '800 911 2000 · Línea de la Vida'),
              const SizedBox(height: 8),
              _buildHelplineCard(
                  country: 'Argentina',
                  number: '135',
                  label: '135 · Centro de Asistencia al Suicida'),
              const SizedBox(height: 8),
              _buildHelplineCard(
                  country: 'Int. / EE.UU.',
                  number: '988',
                  label: '988 · Crisis & Suicide Lifeline'),

              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cerrar',
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

  Widget _buildColombiaHero() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE76F51).withValues(
                    alpha: 0.20 + _pulseController.value * 0.15),
                blurRadius: 20 + _pulseController.value * 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE76F51), Color(0xFFC4553C)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _callNumber('106'),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Colombia · Línea 106',
                          style: GoogleFonts.quicksand(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Salud mental · 24/7 · Gratuita y confidencial',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LLAMAR',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelplineCard({
    required String country,
    required String number,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LevTheme.levCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LevTheme.levBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _callNumber(number),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_rounded,
                          size: 14, color: LevTheme.levMatchaDark),
                      const SizedBox(width: 5),
                      Text(
                        'Llamar',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levMatchaDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
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
            Navigator.of(context).pop();
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
                  child: Icon(icon,
                      color: badgeColor, size: 22),
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
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: LevTheme.levTextMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
