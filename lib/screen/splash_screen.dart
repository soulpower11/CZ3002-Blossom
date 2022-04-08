import 'dart:async';
import 'package:blossom/backend/authentication.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/providers/userinfo_provider.dart';
import 'package:blossom/screen/home.dart';
import 'package:blossom/screen/sign_in_screen.dart';
import 'package:blossom/screen/welcome_screen.dart';
import 'package:dart_jsonwebtoken/src/jwt.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blossom/components/size_config.dart';

class SplashScreen extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => SplashScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Timer(const Duration(seconds: 2), () async {
      final JWT? jwt = await Authentication.verifyJWT();
      if (jwt != null) {
        context.read<UserInfoProvider>().setUsername(jwt.payload["username"]);
        context.read<UserInfoProvider>().setEmail(jwt.payload["email"]);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LandingPage()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => WelcomeScreen()));
      }
    });

    // push(
    //       context,
    //       MaterialPageRoute(builder: (context) => SignInScreen()),
    //     ));
    //Timer(Duration(seconds: 2), () => Navigator.pushNamed(context, '/'));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Center(
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
          SizedBox(height: 50),
          Stack(
            children: <Widget>[
              Center(
                child: Image(
                  image: AssetImage('assets/images/logo.png'),
                  width: 250,
                  height: 250,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
