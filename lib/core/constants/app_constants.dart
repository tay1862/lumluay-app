class AppConstants {
  AppConstants._();

  static const String appName = 'Lumluay POS';
  static const String appVersion = '0.1.0';

  // Database
  static const String dbName = 'lumluay_pos.db';
  static const int dbVersion = 1;

  // Supported locales
  static const String localeLao = 'lo';
  static const String localeThai = 'th';
  static const String localeEnglish = 'en';

  // Default currency
  static const String defaultCurrencyCode = 'LAK';
  static const String defaultCurrencySymbol = '₭';

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // PIN
  static const int pinLength = 4;
}
