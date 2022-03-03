import 'package:blossom/backend/flower.dart';
import 'package:blossom/present_flower.dart';
import 'package:blossom/scan_flower.dart';
import 'package:blossom/view_history.dart';
import 'package:blossom/splash_screen.dart';
import 'package:blossom/splash/welcome_screen.dart';
import './backend/authentication.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/material.dart';
import 'auth.config.dart';

void main() {
  runApp(const MyApp());
}

void _navigateTo(BuildContext context, page) {
  switch (page) {
    case "PresentFlower":
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PresentFlower()));
      break;
    case "ScanFlower":
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ScanFlower()));
      break;

    case "ViewHistory":
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ViewHistory()));
      break;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blossom',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.

          ),
      home: SplashScreen(),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}