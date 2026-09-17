import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/profile/domain/user_profile.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';

/// Modal para que el usuario ingrese o edite su nombre y edad.
/// Lev adapta su tono, energía y pedagogía según la etapa de vida resultante.
class UserProfileSheet extends ConsumerStatefulWidget {
  const UserProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UserProfileSheet(),
    );
  }

  @override
  ConsumerState<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends ConsumerState<UserProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;

  late UserProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = LocalStorageService.getUserProfile();
    _nameController = TextEditingController(text: _currentProfile.name == 'Humano' ? '' : _currentProfile.name);
    _ageController = TextEditingController(text: _currentProfile.age.toString());

    _ageController.addListener(_onAgeChanged);
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onAgeChanged() {
    final parsed = int.tryParse(_ageController.text.trim());
    if (parsed != null && parsed != _currentProfile.age) {
      setState(() {
        _currentProfile = _currentProfile.copyWith(age: parsed.clamp(1, 120));
      });
    }
  }

  void _onNameChanged() {
    final text = _nameController.text.trim();
    final name = text.isEmpty ? 'Humano' : text;
    if (name != _currentProfile.name) {
      setState(() {
        _currentProfile = _currentProfile.copyWith(name: name);
      });
    }
  }

  Future<void> _saveProfile() async {
    final text = _nameController.text.trim();
    final name = text.isEmpty ? 'Humano' : text;
    final age = int.tryParse(_ageController.text.trim()) ?? 25;

    final profile = UserProfile(name: name, age: age.clamp(1, 120));
    await LocalStorageService.saveUserProfile(profile);

    // Notificar al Santuario para actualizar diálogos en tiempo real
    ref.read(sanctuaryProvider.notifier).updateUserProfile(profile);
    await HapticsHelper.medium();

    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Perfil actualizado! Lev ahora cuidará de ti como ${profile.stage.shortLabel.toLowerCase()}.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: LevTheme.levMatchaDark,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = _currentProfile.stage;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? LevTheme.levDarkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(top: LevTheme.sheetRadius.topLeft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre superior
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
              const SizedBox(height: 18),

              // Título y bienvenida
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: LevTheme.levMatchaLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      stage.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu Perfil en Lev',
                          style: GoogleFonts.quicksand(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lev adapta su tono y pedagogía según tu edad.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: LevTheme.levTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Campo 1: Nombre o apodo
              Text(
                '¿Cómo te gustaría que Lev te llame?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Tu nombre o apodo (ej. Samuel, Sofía)',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: LevTheme.levTextMuted,
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? LevTheme.levDarkSurfaceVariant : LevTheme.levCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: LevTheme.levBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? LevTheme.levDarkBorder : LevTheme.levBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: LevTheme.levMatcha, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 18),

              // Campo 2: Edad
              Text(
                '¿Cuántos años tienes?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  hintText: 'Tu edad en años (ej. 16, 28, 65)',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: LevTheme.levTextMuted,
                  ),
                  prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                  filled: true,
                  fillColor: isDark ? LevTheme.levDarkSurfaceVariant : LevTheme.levCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: LevTheme.levBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? LevTheme.levDarkBorder : LevTheme.levBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: LevTheme.levMatcha, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Tarjeta dinámica de cómo Lev se adaptará
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LevTheme.levMatchaLight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: LevTheme.levMatcha.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${stage.emoji}  Modo activo: ${stage.label}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: LevTheme.levMatchaDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stage.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    'Guardar y adaptar a Lev',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levMatcha,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
