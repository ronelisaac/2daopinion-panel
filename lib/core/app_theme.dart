import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF03A68B);
  static const ink = Color(0xFF2D2938);
  static const dark = Color(0xFF333333);
  static const greyLight = Color(0xFFD9D9D9);
  static const pageBackground = Color(0xFFF2F6F5);
  static const primaryLight = Color(0xFFE5F6F2);
  static const facebook = Color(0xFF4267B2);
}

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Montserrat',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.ink,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    toolbarHeight: 45,
    titleTextStyle: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    elevation: 2,
    shadowColor: Colors.black26,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleSpacing: 0,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 57),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      elevation: 3,
      shadowColor: Colors.black38,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    floatingLabelStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF787580),
    ),
    labelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF787580),
    ),
    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF787580)),
    contentPadding: EdgeInsets.symmetric(vertical: 12),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.greyLight),
    ),
  ),
);
