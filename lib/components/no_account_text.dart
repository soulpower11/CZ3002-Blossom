import 'package:blossom/components/constants.dart';
import 'package:blossom/components/size_config.dart';
import 'package:blossom/screen/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:bowls/screens/sign_up/sign_up_screen.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don’t have an account? ",
          style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                  fontSize: getProportionateScreenWidth(16),
                  color: Color(0xDD303030))),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpScreen()),
          ),
          child: Text(
            "Sign Up",
            style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                    fontSize: getProportionateScreenWidth(16),
                    color: kPrimaryColor)),
          ),
        ),
      ],
    );
  }
}
