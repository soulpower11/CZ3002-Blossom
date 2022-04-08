import 'package:blossom/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextBold extends StatelessWidget {
  double size;
  final String text;
  final Color color;

  AppTextBold(
      {Key? key,
      required this.size,
      required this.text,
      this.color = kTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
                fontSize: size, color: color, fontWeight: FontWeight.bold)));
  }
}

class AppTextNormal extends StatelessWidget {
  double size;
  final String text;
  final Color color;

  AppTextNormal(
      {Key? key,
      required this.size,
      required this.text,
      this.color = kTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
                fontSize: size, color: color, fontWeight: FontWeight.w400)));
  }
}
