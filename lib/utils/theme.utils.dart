import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  useMaterial3: true,
  primaryColor: const Color.fromARGB(150, 220, 216, 215),
  primaryColorDark: const Color.fromARGB(255, 68, 68, 68),
  fontFamily: "Lato",
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromARGB(255, 130, 131, 130),
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.grey.shade500,
      fontFamily: "Lato",
      fontSize: 16,
    ),
    labelSmall: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      fontFamily: "Lato",
    ),
    labelMedium: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontFamily: "Lato",
      fontSize: 20,
    ),
    labelLarge: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontFamily: "Lato",
      fontSize: 15,
    ),
    headlineSmall: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 15,
      fontFamily: "Lato",
    ),
    headlineMedium: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 16,
      fontFamily: "Lato",
    ),
  ),
  colorScheme: const ColorScheme(
    primary: Color.fromARGB(255, 220, 216, 215),
    secondary: Color.fromARGB(255, 180, 181, 181),
    surface: Colors.white,
    background: Color.fromARGB(255, 245, 245, 245),
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ).copyWith(background: Colors.white),
);
