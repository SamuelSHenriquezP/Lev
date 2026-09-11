import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';

/// Diálogo estético de saludo diario matutino y regalo de rocío.
class DailyGreetingDialog extends StatelessWidget {
  final String title;
  final String message;
  final int rewardDrops;
  final VoidCallback onClaim;

  const DailyGreetingDialog({
    super.key,
    required this.title,
    required this.message,
    required this.rewardDrops,
    required this.onClaim,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required int rewardDrops,
    required VoidCallback onClaim,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DailyGreeting',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, anim1, anim2) {
        return DailyGreetingDialog(
          title: title,
          message: message,
          rewardDrops: rewardDrops,
          onClaim: () {
            Navigator.of(context).pop();
            onClaim();
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.86,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162420) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? const Color(0xFF2E483F) : LevTheme.levBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de gota con resplandor concéntrico
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LevTheme.levMatcha.withValues(alpha: 0.35),
                      LevTheme.levMatcha.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 38,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.45,
                  color: isDark ? Colors.white70 : LevTheme.levTextMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Indicador de recompensa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E332B) : LevTheme.levMatchaLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: LevTheme.levMatcha.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: LevTheme.levMatchaDark),
                    const Icon(Icons.water_drop_rounded, size: 16, color: LevTheme.levMatchaDark),
                    const SizedBox(width: 4),
                    Text(
                      '$rewardDrops Gota de Rocío de bienvenida',
                      style: GoogleFonts.quicksand(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF80E2BF) : LevTheme.levMatchaDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón aceptar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticsHelper.medium();
                    onClaim();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levMatcha,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    'Recibir con Calma',
                    style: GoogleFonts.quicksand(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

