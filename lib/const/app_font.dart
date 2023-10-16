import 'package:flutter/material.dart';

class AppFont {
  static TextStyle orbitronRegular(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
      fontFamily: 'Orbitron',
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      decoration: decoration,
    );
  }

  static TextStyle montRegular(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
      fontFamily: 'Montserrat',
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      decoration: decoration,
    );
  }

  static TextStyle montMedium(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
      fontFamily: 'Montserrat',
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      decoration: decoration,
    );
  }

  static TextStyle montSemibold(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
        fontFamily: 'Montserrat',
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        decoration: decoration);
  }

  static TextStyle montBold(double size,
      {Color? color, TextDecoration? decoration, List<Shadow>? shadows}) {
    return TextStyle(
        fontFamily: 'Montserrat',
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        decoration: decoration,
        shadows: shadows);
  }

  static TextStyle montExtrabold(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
        fontFamily: 'Montserrat',
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        decoration: decoration);
  }

  static TextStyle montBlack(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
        fontFamily: 'Montserrat',
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        decoration: decoration);
  }

  static TextStyle poppinsThin(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: FontWeight.w100,
        color: color,
        decoration: decoration);
  }

  static TextStyle poppinsLight(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: color,
        decoration: decoration);
  }

  static TextStyle poppinsRegular(double size,
      {Color? color, TextDecoration? decoration, double? height}) {
    return TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: FontWeight.w400,
        height: height,
        color: color,
        decoration: decoration);
  }

  static TextStyle poppinsMedium(double size,
      {Color? color, TextDecoration? decoration, TextOverflow? overflow}) {
    return TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        decoration: decoration,
        overflow: overflow);
  }

  static TextStyle poppinsSemibold(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        decoration: decoration);
  }

  static TextStyle poppinsBold(double size,
      {Color? color, TextDecoration? decoration}) {
    return TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        decoration: decoration);
  }
}
