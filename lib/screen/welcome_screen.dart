import 'package:blossom/components/app_text.dart';
import 'package:blossom/components/constants.dart';
import 'package:blossom/components/rounded_button.dart';
import 'package:blossom/components/size_config.dart';
import 'package:blossom/screen/sign_in_screen.dart';
import 'package:blossom/screen/sign_up_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  static String routeName = '/welcome';
  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (context) => WelcomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // You have to call it on your starting screen
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Center(
            child: Image(
              image: AssetImage('assets/images/blossom.png'),
              width: 250,
              height: 250,
            ),
          ),
          AppTextBold(size: 40, text: 'Blossom'),
          // Theme.of(context).textTheme.headline4!.copyWith(
          //           color: Colors.white,

          //         ),

          const SizedBox(height: 20),
          RoundedButton(
            text: "Login",
            color: kPrimaryColor,
            //textColor: Colors.white,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
              //Navigator.pushNamed(context, SignInScreen.routeName);
            },
          ),
          RoundedButton(
            text: "Sign Up",
            color: kPrimaryLightColor,
            textColor: Colors.white,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
              //Navigator.pushNamed(context, SignUpScreen.routeName);
            },
          ),
          // SizedBox(height: 50),

          const Image(
            image: AssetImage('assets/images/logo.png'),
            width: 250,
            height: 250,
            alignment: Alignment.bottomCenter,
          ),

          // Stack(
          //   children: <Widget>[
          //     Center(
          //       child: Image(
          //         image: AssetImage('assets/images/logo.png'),
          //         width: 300,
          //         height: 300,
          //         alignment: Alignment.bottomLeft,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
