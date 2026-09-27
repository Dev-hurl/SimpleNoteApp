import 'package:flutter/material.dart';
import 'package:note_app/core/constants/app_colors.dart';
import 'package:note_app/core/constants/app_fonts.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.family,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: AppFonts.headline,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: AppFonts.title,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: AppFonts.bodyLarge,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        fontSize: AppFonts.body,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        fontSize: AppFonts.caption,
        fontWeight: FontWeight.w400,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.teal,
      onPrimary: AppColors.chalk,
      secondary: AppColors.deepSea,
      onSecondary: AppColors.chalk,
      surface: AppColors.chalk,
      onSurface: AppColors.deepSea,
    ),
    scaffoldBackgroundColor: AppColors.chalk,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.chalk,
      foregroundColor: AppColors.deepSea,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.family,
        fontSize: AppFonts.title,
        fontWeight: FontWeight.w600,
        color: AppColors.deepSea,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.chalk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.chalk,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppFonts.family,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: AppFonts.headline,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: AppFonts.title,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: AppFonts.bodyLarge,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        fontSize: AppFonts.body,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        fontSize: AppFonts.caption,
        fontWeight: FontWeight.w400,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.teal,
      onPrimary: AppColors.chalk,
      secondary: AppColors.chalk,
      onSecondary: AppColors.deepSea,
      surface: AppColors.deepSea,
      onSurface: AppColors.chalk,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
    ),
    scaffoldBackgroundColor: AppColors.deepSea,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.deepSea,
      foregroundColor: AppColors.chalk,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.family,
        fontSize: AppFonts.title,
        fontWeight: FontWeight.w600,
        color: AppColors.chalk,
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.darkSurface),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.chalk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.chalk,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.chalk),
    ),
  );
}
