import 'package:blossom/components/constants.dart';
import 'package:blossom/components/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color color, textColor;
  const RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
    Align? child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.6,
      height: getProportionateScreenHeight(56),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // child: FlatButton(
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        //   color: color,
        //   onPressed: press,
        //   child: Text(
        //     text,
        //     style: TextStyle(
        //       color: textColor,
        //       fontSize: getProportionateScreenWidth(20),
        //     ),
        //   ),
        // ),
        child: ElevatedButton(
          onPressed: press,
          child: Text(text,
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      fontSize: getProportionateScreenWidth(20),
                      color: textColor,
                      fontWeight: FontWeight.bold))),
          style: ElevatedButton.styleFrom(
              primary: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
        ),
      ),
    );
  }
}
