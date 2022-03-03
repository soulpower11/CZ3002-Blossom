import 'package:flutter/material.dart';
import 'package:blossom/constants.dart';

class AppTextLarge extends StatelessWidget {
  double size;
  final String text;
  final Color color;

  AppTextLarge(
      {Key? key, this.size = 16, required this.text, this.color = kTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: color, fontSize: size));
  }
}
