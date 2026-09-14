import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';

/// Modal para visualizar y configurar la privacidad local, modo offline y PIN
void showPrivacyOfflineDialog(BuildContext context) {
  HapticsHelper.light();
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final isPinActive = LocalStorageService.isPinProtectionActive();
          final remindersConfig = LocalStorageService.getGentleReminders();
          final remindersEnabled = remindersConfig['enabled'] == true;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            actionsPadding: const EdgeInsets.all(20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, size: 22, color: LevTheme.levMatchaDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tu Espacio Seguro',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrivacyPoint(
                    icon: Icons.wifi_off_rounded,
                    title: '100% Sin Conexión Obligatoria',
                    desc: 'Tus reflexiones, registros de ánimo y hábitos se guardan únicamente en la memoria de este teléfono.',
                  ),
                  const SizedBox(height: 12),
                  _buildPrivacyPoint(
                    icon: Icons.no_accounts_rounded,
                    title: 'Sin Cuentas ni Rastreadores',
                    desc: 'No recopilamos analíticas invasivas ni vendemos tu información. Lev existe para acompañarte en calma.',
                  ),
                  const SizedBox(height: 12),
                  _buildPrivacyPoint(
                    icon: Icons.lock_outline_rounded,
                    title: 'Control Total y Privacidad',
                    desc: 'Tus datos son tuyos. Puedes reiniciar la app cuando desees sin dejar rastro en servidores externos.',
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: LevTheme.levBorder, height: 1),
                  const SizedBox(height: 14),

                  // Tarjeta de Seguridad con PIN
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPinActive ? LevTheme.levMatchaDark : LevTheme.levBorder,
                        width: isPinActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPinActive ? Icons.lock_rounded : Icons.lock_open_rounded,
                              size: 18,
                              color: isPinActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bloqueo con PIN de 4 dígitos',
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: LevTheme.levTextDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPinActive ? LevTheme.levMatchaLight : const Color(0xFFEDF2F7),
                                borderRadius: LevTheme.pillRadius,
                              ),
                              child: Text(
                                isPinActive ? 'Activo' : 'Inactivo',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isPinActive ? LevTheme.levMatchaDark : LevTheme.levTextMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isPinActive
                              ? 'Tu diario íntimo y conversaciones con Lev requieren tu PIN para abrirse.'
                              : 'Añade una clave numérica para proteger tus registros si prestas tu teléfono.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: LevTheme.levTextMuted,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () {
                              showPinConfigDialog(context, () => setDialogState(() {}));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: const BorderSide(color: LevTheme.levMatchaDark),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              isPinActive ? 'Modificar o Quitar PIN' : 'Activar PIN de Seguridad',
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: LevTheme.levMatchaDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tarjeta de Recordatorios Gentilísimas
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LevTheme.levBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, size: 18, color: LevTheme.levMatchaDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pausas amables diarias',
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: LevTheme.levTextDark,
                                ),
                              ),
                              Text(
                                'Recordatorios suaves sin culpa',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: LevTheme.levTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: remindersEnabled,
                          activeThumbColor: LevTheme.levMatcha,
                          activeTrackColor: LevTheme.levMatchaLight,
                          onChanged: (val) async {
                            HapticsHelper.selection();
                            final newConfig = Map<String, dynamic>.from(remindersConfig);
                            newConfig['enabled'] = val;
                            await LocalStorageService.saveGentleReminders(newConfig);
                            setDialogState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levMatcha,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: LevTheme.pillRadius),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Entendido',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

void showPinConfigDialog(BuildContext context, VoidCallback onDone) {
  final pinController = TextEditingController();
  final isCurrentlyActive = LocalStorageService.isPinProtectionActive();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.pin_rounded, color: LevTheme.levMatchaDark),
            const SizedBox(width: 8),
            Text(
              isCurrentlyActive ? 'Modificar PIN' : 'Nuevo PIN de 4 dígitos',
              style: GoogleFonts.quicksand(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: LevTheme.levTextDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa 4 dígitos numéricos para resguardar tu diario y chats íntimos con Lev:',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: LevTheme.levTextMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                filled: true,
                fillColor: LevTheme.levCream,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          if (isCurrentlyActive)
            TextButton(
              onPressed: () async {
                HapticsHelper.light();
                await LocalStorageService.setPrivacyPin(null);
                if (ctx.mounted) Navigator.pop(ctx);
                onDone();
              },
              child: Text('Quitar PIN', style: GoogleFonts.quicksand(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.quicksand(color: LevTheme.levTextMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                HapticsHelper.medium();
                await LocalStorageService.setPrivacyPin(pin);
                if (ctx.mounted) Navigator.pop(ctx);
                onDone();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LevTheme.levMatcha,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: LevTheme.pillRadius),
            ),
            child: Text('Guardar', style: GoogleFonts.quicksand(fontWeight: FontWeight.w700)),
          ),
        ],
      );
    },
  );
}

Widget _buildPrivacyPoint({
  required IconData icon,
  required String title,
  required String desc,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: LevTheme.levMatchaDark),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: LevTheme.levTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: LevTheme.levTextMuted,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
