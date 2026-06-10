import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color _primarySeed  = Color(0xFF1A1A2E);
  static const Color _accentBlue   = Color(0xFF0F3460);
  static const Color _neonTeal     = Color(0xFF00D4AA);
  static const Color _surfaceCard  = Color(0xFF16213E);
  static const Color _errorRed     = Color(0xFFE53E3E);
  static const Color _warningAmber = Color(0xFFF6AD55);
  static const Color _successGreen = Color(0xFF48BB78);

  static ColorScheme get _darkColorScheme => ColorScheme(
        brightness: Brightness.dark,
        primary: _neonTeal,
        onPrimary: _primarySeed,
        primaryContainer: _accentBlue,
        onPrimaryContainer: _neonTeal,
        secondary: const Color(0xFF7B8CDE),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF2D3561),
        onSecondaryContainer: const Color(0xFFBBC4FF),
        tertiary: _warningAmber,
        onTertiary: _primarySeed,
        tertiaryContainer: const Color(0xFF4A3219),
        onTertiaryContainer: _warningAmber,
        error: _errorRed,
        onError: Colors.white,
        errorContainer: const Color(0xFF4A1515),
        onErrorContainer: const Color(0xFFFFB3B3),
        background: _primarySeed,
        onBackground: Colors.white,
        surface: _surfaceCard,
        onSurface: Colors.white,
        surfaceVariant: const Color(0xFF1E2D4A),
        onSurfaceVariant: const Color(0xFFBBC4D0),
        outline: const Color(0xFF3A4A5C),
        outlineVariant: const Color(0xFF2A3A4C),
        shadow: Colors.black,
        scrim: Colors.black54,
        inverseSurface: Colors.white,
        onInverseSurface: _primarySeed,
        inversePrimary: _accentBlue,
      );

  static TextTheme get _textTheme => GoogleFonts.dmSansTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -1.5),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: -0.25),
          headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          headlineSmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
          titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium:  TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall:   TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
          labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.0),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ),
      ).apply(bodyColor: Colors.white, displayColor: Colors.white);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _darkColorScheme,
        textTheme: _textTheme,
        scaffoldBackgroundColor: _primarySeed,

        appBarTheme: AppBarTheme(
          backgroundColor: _primarySeed,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),

        // ── FIXED: CardThemeData instead of CardTheme ──────────────────────
        cardTheme: CardThemeData(
          color: _surfaceCard,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2A3A4C), width: 1),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E2D4A),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A4A5C)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A4A5C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _neonTeal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _errorRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _errorRed, width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF7B8FA6)),
          hintStyle: const TextStyle(color: Color(0xFF4A5A6C)),
          floatingLabelStyle: const TextStyle(color: _neonTeal),
          prefixIconColor: const Color(0xFF7B8FA6),
          suffixIconColor: const Color(0xFF7B8FA6),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _neonTeal,
            foregroundColor: _primarySeed,
            disabledBackgroundColor: const Color(0xFF2A3A4C),
            disabledForegroundColor: const Color(0xFF4A5A6C),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _neonTeal,
            textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _neonTeal,
            side: const BorderSide(color: _neonTeal),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _neonTeal,
          foregroundColor: _primarySeed,
          elevation: 4,
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: _surfaceCard,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1E2D4A),
          selectedColor: _neonTeal.withOpacity(0.2),
          side: const BorderSide(color: Color(0xFF3A4A5C)),
          labelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xFF2A3A4C), thickness: 1, space: 1,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surfaceCard,
          indicatorColor: _neonTeal.withOpacity(0.2),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: _neonTeal, size: 24);
            }
            return const IconThemeData(color: Color(0xFF7B8FA6), size: 24);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: _neonTeal);
            }
            return GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF7B8FA6));
          }),
        ),

        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),

        iconTheme: const IconThemeData(color: Color(0xFF7B8FA6), size: 24),
      );

  static const Color neonTeal    = _neonTeal;
  static const Color primaryDark = _primarySeed;
  static const Color accentBlue  = _accentBlue;
  static const Color cardSurface = _surfaceCard;
  static const Color success     = _successGreen;
  static const Color warning     = _warningAmber;
  static const Color error       = _errorRed;

  static const LinearGradient tealGradient = LinearGradient(
    colors: [_neonTeal, Color(0xFF00A884)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
