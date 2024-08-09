import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  // get brightness from system
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  Future<void> setThemeMode(ThemeMode value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', value.toString());
    _themeMode = value;
    notifyListeners();
  }

  Future<void> setDarkScheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', ThemeMode.dark.toString());
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  Future<void> setLightScheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', ThemeMode.light.toString());
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? theme = prefs.getString('theme');
    print("Retrieved user theme");
    print(theme);
    if (theme == "ThemeMode.dark") {
      setDarkScheme();
    } else if (theme == "ThemeMode.light") {
      print("User selected light");
      setLightScheme();
    } else {
      // return system brightness
      print("User has not selected");
      _themeMode = ThemeMode.system;
      if (ThemeMode.system == ThemeMode.dark) {
        setDarkScheme();
      } else {
        setLightScheme();
      }
    }
  }
}
