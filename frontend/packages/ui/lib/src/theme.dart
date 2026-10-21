import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Tema terang MeDrive. Nunito dipilih karena bentuknya membulat seperti tipografi Figma dan
/// tetap jelas dibaca dalam kondisi panik.
ThemeData buildMedTheme() {
  const fontFamily = 'Nunito';
  final scheme = ColorScheme.fromSeed(
    seedColor: MedColors.brand,
    primary: MedColors.brand,
    onPrimary: Colors.white,
    secondary: MedColors.brandDeep,
    surface: MedColors.surface,
    onSurface: MedColors.ink,
    error: MedColors.brandDeep,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: fontFamily, package: 'medrive_ui');

  OutlineInputBorder border(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(MedRadius.lg),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    scaffoldBackgroundColor: MedColors.surface,
    textTheme: base.textTheme
        .copyWith(
          headlineLarge: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.15),
          headlineMedium: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.2),
          titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
          bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
          bodySmall: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.35),
          labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        )
        .apply(bodyColor: MedColors.ink, displayColor: MedColors.ink, fontFamily: fontFamily, package: 'medrive_ui'),
    appBarTheme: const AppBarTheme(
      backgroundColor: MedColors.surface,
      foregroundColor: MedColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        package: 'medrive_ui',
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: MedColors.ink,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: MedColors.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: MedColors.inkFaint, fontWeight: FontWeight.w600),
      labelStyle: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700),
      floatingLabelStyle: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w800),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(MedColors.brand, width: 2),
      errorBorder: border(MedColors.brandDeep),
      focusedErrorBorder: border(MedColors.brandDeep, width: 2),
      errorStyle: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w700),
      errorMaxLines: 3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MedColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: MedColors.line,
        disabledForegroundColor: MedColors.inkFaint,
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontFamily: fontFamily, package: 'medrive_ui', fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MedColors.brand,
        side: const BorderSide(color: MedColors.brand, width: 2),
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontFamily: fontFamily, package: 'medrive_ui', fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MedColors.brandDeep,
        minimumSize: const Size(48, 44),
        textStyle: const TextStyle(fontFamily: fontFamily, package: 'medrive_ui', fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: MedColors.field,
      selectedColor: MedColors.brand,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MedRadius.md)),
      labelStyle: const TextStyle(fontFamily: fontFamily, package: 'medrive_ui', fontWeight: FontWeight.w700, color: MedColors.ink),
      secondaryLabelStyle: const TextStyle(fontFamily: fontFamily, package: 'medrive_ui', fontWeight: FontWeight.w800, color: Colors.white),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MedColors.surface,
      indicatorColor: MedColors.brandSoft,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: fontFamily,
          package: 'medrive_ui',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: states.contains(WidgetState.selected) ? MedColors.brandDeep : MedColors.inkMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(color: states.contains(WidgetState.selected) ? MedColors.brand : MedColors.inkMuted),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: MedColors.ink,
      contentTextStyle: const TextStyle(fontFamily: fontFamily, package: 'medrive_ui', color: Colors.white, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MedRadius.md)),
    ),
    dividerTheme: const DividerThemeData(color: MedColors.line, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MedColors.surface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(MedRadius.lg + 8))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: MedColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MedRadius.lg + 8)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: MedColors.brand),
  );
}
