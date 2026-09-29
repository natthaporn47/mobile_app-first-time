import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color primaryColor = const Color.fromARGB(255, 0, 0, 0);
Color secondaryColor = const Color.fromARGB(255, 255, 255, 255);

Color lightBackgroundColor = const Color.fromARGB(255, 206, 231, 253);
Color darkBackgroundColor = Color.fromARGB(255, 213, 240, 243);

TextStyle headingTextStyle = TextStyle(
  fontFamily: GoogleFonts.karla().fontFamily,
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: primaryColor,
);

TextStyle bodyTextStyle = TextStyle(
  fontFamily: GoogleFonts.karla().fontFamily,
  fontSize: 16,
  color: primaryColor,
);