import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorSchemes.lightZinc,
      radius: 0.5,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorSchemes.darkZinc,
      radius: 0.5,
    );
  }
}
