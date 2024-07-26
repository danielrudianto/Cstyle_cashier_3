import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  useMaterial3: true,
  primaryColor: const Color.fromARGB(150, 220, 216, 215),
  primaryColorDark: const Color.fromARGB(255, 68, 68, 68),
  secondaryHeaderColor: const Color.fromARGB(255, 109, 78, 137),
  fontFamily: "Montserrat",
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 130, 131, 130),
  ),
  scaffoldBackgroundColor: Colors.white,
  dividerColor: Colors.grey.shade500,
  textTheme: TextTheme(
    bodySmall: TextStyle(
      color: Colors.grey.shade500,
      fontFamily: "Montserrat",
      fontSize: 12,
    ),
    bodyMedium: const TextStyle(
      color: Colors.black,
      fontFamily: "Montserrat",
      fontSize: 16,
    ),
    bodyLarge: const TextStyle(
      color: Colors.black,
      fontFamily: "Montserrat",
      fontSize: 18,
    ),
    labelSmall: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      fontFamily: "Montserrat",
    ),
    labelMedium: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontFamily: "Montserrat",
      fontSize: 20,
    ),
    labelLarge: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontFamily: "Montserrat",
      fontSize: 15,
    ),
    headlineSmall: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 15,
      fontFamily: "Montserrat",
    ),
    headlineMedium: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 16,
      fontFamily: "Montserrat",
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.black,
  ),
  disabledColor: Colors.grey.shade300,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black,
    elevation: 2.0,
    behavior: SnackBarBehavior.floating,
    contentTextStyle: TextStyle(
      color: Colors.white,
    ),
    actionTextColor: Color.fromARGB(255, 109, 78, 137),
  ),
  cardColor: Color.fromARGB(255, 255, 255, 255),
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

ThemeData darkThemeData = ThemeData(
  useMaterial3: true,
  primaryColor: const Color.fromARGB(150, 220, 216, 215),
  primaryColorDark: const Color.fromARGB(255, 68, 68, 68),
  fontFamily: "Montserrat",
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 130, 131, 130),
  ),
  scaffoldBackgroundColor: Color.fromARGB(255, 41, 41, 41),
  dividerColor: Colors.grey.shade500,
  textTheme: TextTheme(
    bodySmall: TextStyle(
      color: Colors.grey.shade500,
      fontFamily: "Montserrat",
      fontSize: 12,
    ),
    bodyMedium: const TextStyle(
      color: Colors.white,
      fontFamily: "Montserrat",
      fontSize: 16,
    ),
    bodyLarge: const TextStyle(
      color: Colors.white,
      fontFamily: "Montserrat",
      fontSize: 18,
    ),
    labelSmall: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      fontFamily: "Montserrat",
    ),
    labelMedium: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: "Montserrat",
      fontSize: 20,
    ),
    titleMedium: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: "Montserrat",
      fontSize: 20,
    ),
    headlineSmall: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 15,
      fontFamily: "Montserrat",
    ),
    headlineMedium: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 16,
      fontFamily: "Montserrat",
    ),
  ),
  // icon button, icon color
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  // icon theme on disabled
  disabledColor: Colors.grey.shade500,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.white,
    elevation: 2.0,
    behavior: SnackBarBehavior.fixed,
    contentTextStyle: TextStyle(
      color: Colors.black,
    ),
    actionTextColor: Color.fromARGB(255, 109, 78, 137),
  ),
  secondaryHeaderColor: const Color.fromARGB(255, 109, 78, 137),
  cardColor: const Color.fromARGB(255, 36, 36, 36),
  colorScheme: const ColorScheme(
    primary: Color.fromARGB(255, 220, 216, 215),
    secondary: Color.fromARGB(255, 180, 181, 181),
    surface: Colors.black,
    background: Color.fromARGB(255, 245, 245, 245),
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.dark,
  ).copyWith(background: Colors.black),
);
