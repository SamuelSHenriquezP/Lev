import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño visual oficial de "Lev" (Cozy Botanical & Warm Pastels).
class LevTheme {
  // Paleta oficial obligatoria
  static const Color levMatcha = Color(0xFF7A9A60); // Acento principal y acciones saludables
  static const Color levMatchaDark = Color(0xFF587B4C); // Contraste y hover activo
  static const Color levMatchaLight = Color(0xFFEAF2E8); // Fondo secundario y contenedores suaves
  static const Color levCream = Color(0xFFFAF8F5); // Fondo principal de la app
  static const Color levPeach = Color(0xFFF4A28C); // Afecto, calidez y apoyo emocional
  static const Color levPeachDark = Color(0xFFE76F51); // Acento cálido intenso
  static const Color levSky = Color(0xFFD0E8F2); // Módulos cognitivos y calma
  static const Color levLavanda = Color(0xFFE2D9F3); // Diario TCC e introspección
  static const Color levTextDark = Color(0xFF2D3748); // Texto principal (nunca negro puro)
  static const Color levTextMuted = Color(0xFF718096); // Subtítulos y metadatos
  static const Color levCardWhite = Color(0xD9FFFFFF); // Blanco 85% opacidad para glassmorphism
  static const Color levBorder = Color(0x1A2D3748); // Borde sutil y orgánico

  // Paleta oficial nocturna (Circadiana / Dark Mode)
  static const Color levDarkBg = Color(0xFF0E1714); // Verde bosque profundo / obsidiana botánica
  static const Color levDarkSurface = Color(0xFF162420); // Tarjetas y superficies nocturnas
  static const Color levDarkSurfaceVariant = Color(0xFF1E302B); // Tarjetas secundarias nocturnas
  static const Color levDarkBorder = Color(0xFF263D36); // Borde tenue nocturno
  static const Color levDarkText = Color(0xFFF0F4F2); // Texto luminescente suave
  static const Color levDarkTextMuted = Color(0xFFA0B5AC); // Texto secundario menta tenue
  static const Color levMatchaNight = Color(0xFF80E2BF); // Acento matcha luminoso
  static const Color levPeachNight = Color(0xFFFFAB91); // Acento cálido suave
  static const Color levSkyNight = Color(0xFF80CBC4); // Calma nocturna

  // Sombras difuminadas suaves (sin sombras negras duras)
  static List<BoxShadow> get softShadow => [
        const BoxShadow(
          color: Color(0x0D2D3748),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get darkSoftShadow => [
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: levMatcha.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get peachGlowShadow => [
        BoxShadow(
          color: levPeach.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // Geometría estándar
  static final BorderRadius cardRadius = BorderRadius.circular(24);
  static final BorderRadius squareRadius = BorderRadius.circular(24);
  static final BorderRadius sheetRadius = BorderRadius.circular(32);
  static final BorderRadius pillRadius = BorderRadius.circular(999);

  /// Paleta pastel suave y relajante para cada categoría emocional
  static Color getEmotionBgColor(String category) {
    if (category.contains('Doomscrolling')) return const Color(0xFFEDF5F1);
    if (category.contains('Ansiedad')) return const Color(0xFFE8F2F8);
    if (category.contains('Tristeza')) return const Color(0xFFFDF0EA);
    if (category.contains('Frustración')) return const Color(0xFFFDF5E6);
    if (category.contains('Insomnio')) return const Color(0xFFF0ECF8);
    if (category.contains('Culpa')) return const Color(0xFFF6EBF4);
    if (category.contains('Bloqueo')) return const Color(0xFFEFF5E9);
    return const Color(0xFFF4F1EC);
  }

  static Color getEmotionAccentColor(String category) {
    if (category.contains('Doomscrolling')) return const Color(0xFF3F7F68);
    if (category.contains('Ansiedad')) return const Color(0xFF2C6D91);
    if (category.contains('Tristeza')) return const Color(0xFFC8684A);
    if (category.contains('Frustración')) return const Color(0xFFA57328);
    if (category.contains('Insomnio')) return const Color(0xFF5A4579);
    if (category.contains('Culpa')) return const Color(0xFF7E3E6C);
    if (category.contains('Bloqueo')) return const Color(0xFF4C7533);
    return levMatchaDark;
  }

  // Tema global de la aplicación
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.quicksand(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: levTextDark,
      ),
      displayMedium: GoogleFonts.quicksand(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: levTextDark,
      ),
      displaySmall: GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: levTextDark,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: levTextDark,
      ),
      titleLarge: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: levTextDark,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: levTextDark,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: levTextDark,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: levTextDark,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: levTextDark,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: levCream,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: levMatcha,
        onPrimary: Colors.white,
        secondary: levPeach,
        onSecondary: Colors.white,
        tertiary: levSky,
        onTertiary: levTextDark,
        error: levPeachDark,
        onError: Colors.white,
        surface: levCream,
        onSurface: levTextDark,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.90),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: levBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: levTextDark,
        ),
        iconTheme: const IconThemeData(color: levTextDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: levMatcha,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: pillRadius),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: levMatchaDark,
          side: const BorderSide(color: levMatcha, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: pillRadius),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: levBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: levBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: levMatcha, width: 1.8),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: levTextMuted,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Tema oscuro oficial de "Lev" (Zen Botánico Nocturno / Circadiano)
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.quicksand(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: levDarkText,
      ),
      displayMedium: GoogleFonts.quicksand(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: levDarkText,
      ),
      displaySmall: GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: levDarkText,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: levDarkText,
      ),
      titleLarge: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: levDarkText,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: levDarkText,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: levDarkText,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: levDarkTextMuted,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: levDarkText,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: levDarkBg,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: levMatchaNight,
        onPrimary: levDarkBg,
        secondary: levPeachNight,
        onSecondary: levDarkBg,
        tertiary: levSkyNight,
        onTertiary: levDarkBg,
        error: levPeachDark,
        onError: Colors.white,
        surface: levDarkSurface,
        onSurface: levDarkText,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: levDarkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: levDarkBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: levDarkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: levDarkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: levDarkText,
        ),
        iconTheme: const IconThemeData(color: levDarkText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: levMatchaNight,
          foregroundColor: levDarkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: pillRadius),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: levMatchaNight,
          side: const BorderSide(color: levMatchaNight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: pillRadius),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: levDarkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: levDarkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: levDarkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: levMatchaNight, width: 1.8),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: levDarkTextMuted,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Configuración de fuentes defensiva offline para que la app nunca dependa de internet
  static void configureOfflineFonts() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }
}

