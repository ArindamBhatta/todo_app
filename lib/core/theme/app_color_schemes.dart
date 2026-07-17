import 'package:flutter/material.dart';

class AppColorSchemes {
  static const ColorScheme light = ColorScheme.light(
    primary: Color.fromARGB(255, 45, 32, 13),
    onPrimary: Colors.white,
    secondary: Color.fromARGB(255, 120, 101, 49),
    onSecondary: Colors.white,
    surfaceBright: Color.fromARGB(255, 62, 65, 68),
    surface: Colors.white,
    onSurface: Colors.black,
  );

  static const ColorScheme dark = ColorScheme.dark(
    secondary: Colors.deepPurple,
    onSecondary: Colors.white,
    surface: Color(0xFF2C2C2E),
    onSurface: Colors.white,
  );
}
