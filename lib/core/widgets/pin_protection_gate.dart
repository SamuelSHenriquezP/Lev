import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../storage/local_storage_service.dart';
import '../theme/lev_theme.dart';
import '../utils/haptics_helper.dart';

/// Barrera de privacidad que solicita el PIN de 4 dígitos si el usuario
/// activó la protección de privacidad local.
class PinProtectionGate extends StatefulWidget {
  final Widget child;

  const PinProtectionGate({super.key, required this.child});

  @override
  State<PinProtectionGate> createState() => _PinProtectionGateState();
}

class _PinProtectionGateState extends State<PinProtectionGate> {
  bool _isUnlocked = false;
  String _enteredPin = '';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    if (!LocalStorageService.isPinProtectionActive() || _isUnlocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Ícono de escudo botánico
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: LevTheme.levMatchaLight,
                  shape: BoxShape.circle,
                  boxShadow: LevTheme.softShadow,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 36,
                  color: LevTheme.levMatchaDark,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Espacio Protegido',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tu PIN de 4 dígitos para acceder a tus registros íntimos con Lev.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: LevTheme.levTextMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Indicadores de los 4 dígitos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? LevTheme.levMatchaDark : Colors.white,
                      border: Border.all(
                        color: isFilled ? LevTheme.levMatchaDark : LevTheme.levBorder,
                        width: 2,
                      ),
                      boxShadow: isFilled ? LevTheme.softShadow : null,
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else
                const SizedBox(height: 30),

              const Spacer(),

              // Teclado numérico botánico
              _buildKeypad(),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 1; col <= 3; col++)
                  _buildDigitKey('${row * 3 + col}'),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72, height: 72),
            _buildDigitKey('0'),
            _buildBackspaceKey(),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitKey(String digit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      width: 68,
      height: 68,
      child: ElevatedButton(
        onPressed: () => _handleDigitPress(digit),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: LevTheme.levTextDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: LevTheme.levBorder),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          digit,
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: LevTheme.levTextDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      width: 68,
      height: 68,
      child: IconButton(
        onPressed: _handleBackspace,
        icon: const Icon(Icons.backspace_outlined, size: 22, color: LevTheme.levTextMuted),
      ),
    );
  }

  void _handleDigitPress(String digit) {
    if (_enteredPin.length >= 4) return;
    HapticsHelper.light();
    setState(() {
      _errorMessage = null;
      _enteredPin += digit;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isEmpty) return;
    HapticsHelper.selection();
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _verifyPin() {
    final savedPin = LocalStorageService.getPrivacyPin();
    if (_enteredPin == savedPin) {
      HapticsHelper.medium();
      setState(() {
        _isUnlocked = true;
      });
    } else {
      HapticsHelper.medium();
      setState(() {
        _errorMessage = 'PIN incorrecto. Intenta de nuevo.';
        _enteredPin = '';
      });
    }
  }
}
