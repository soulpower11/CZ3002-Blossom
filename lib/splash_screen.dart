import 'dart:async';
import 'package:blossom/sign_in/sign_in_screen.dart';
import 'package:blossom/splash/welcome_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => SplashScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(seconds: 2),
        () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              ),
            ));
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
          Text(
            'Blossom',
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),

            // Theme.of(context).textTheme.headline4!.copyWith(
            //           color: Colors.white,

            //         ),
          ),
          SizedBox(height: 50),
          Stack(
            children: <Widget>[
              Center(
                child: Image(
                  image: AssetImage('assets/images/logo.png'),
                  width: 260,
                  height: 260,
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
