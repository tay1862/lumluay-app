import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Colors ──
  static const Color _blue50 = Color(0xFFEFF6FF);
  static const Color _blue100 = Color(0xFFDBEAFE);
  static const Color _blue200 = Color(0xFFBFDBFE);
  static const Color _blue400 = Color(0xFF60A5FA);
  static const Color _blue500 = Color(0xFF3B82F6);
  static const Color _blue600 = Color(0xFF2563EB);
  static const Color _blue700 = Color(0xFF1D4ED8);
  static const Color _blue900 = Color(0xFF1E3A5F);
  static const Color _sky50 = Color(0xFFF0F9FF);
  static const Color _sky100 = Color(0xFFE0F2FE);

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        background: _sky50,
        foreground: const Color(0xFF1E293B),
        card: Colors.white,
        cardForeground: const Color(0xFF1E293B),
        popover: Colors.white,
        popoverForeground: const Color(0xFF1E293B),
        primary: _blue600,
        primaryForeground: Colors.white,
        secondary: _blue50,
        secondaryForeground: _blue900,
        muted: _blue100,
        mutedForeground: const Color(0xFF64748B),
        accent: _sky100,
        accentForeground: _blue700,
        destructive: const Color(0xFFEF4444),
        destructiveForeground: Colors.white,
        border: _blue200,
        input: _blue200,
        ring: _blue500,
        chart1: _blue500,
        chart2: const Color(0xFF06B6D4),
        chart3: const Color(0xFF8B5CF6),
        chart4: const Color(0xFFF59E0B),
        chart5: const Color(0xFF10B981),
      ),
      radius: 0.75,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        background: const Color(0xFF0F172A),
        foreground: const Color(0xFFF1F5F9),
        card: const Color(0xFF1E293B),
        cardForeground: const Color(0xFFF1F5F9),
        popover: const Color(0xFF1E293B),
        popoverForeground: const Color(0xFFF1F5F9),
        primary: _blue400,
        primaryForeground: const Color(0xFF0F172A),
        secondary: const Color(0xFF1E3A5F),
        secondaryForeground: const Color(0xFFE2E8F0),
        muted: const Color(0xFF1E293B),
        mutedForeground: const Color(0xFF94A3B8),
        accent: const Color(0xFF1E3A5F),
        accentForeground: _blue200,
        destructive: const Color(0xFFDC2626),
        destructiveForeground: Colors.white,
        border: const Color(0xFF334155),
        input: const Color(0xFF334155),
        ring: _blue400,
        chart1: _blue400,
        chart2: const Color(0xFF22D3EE),
        chart3: const Color(0xFFA78BFA),
        chart4: const Color(0xFFFBBF24),
        chart5: const Color(0xFF34D399),
      ),
      radius: 0.75,
    );
  }

  // ── Gradient helpers for shared use ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_blue500, Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [_sky50, _blue50],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF1D4ED8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
