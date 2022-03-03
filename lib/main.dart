import 'package:blossom/backend/flower.dart';
import 'package:blossom/present_flower.dart';
import 'package:blossom/scan_flower.dart';
import 'package:blossom/view_history.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import './backend/authentication.dart';
import 'auth.config.dart';

void main() async {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Declare the object
  late EmailAuth emailAuth;
  @override
  void initState() {
    super.initState();
    // Initialize the package
    emailAuth = new EmailAuth(
      sessionName: "Blossom",
    );

    /// Configuring the remote server
    emailAuth.config(remoteServerConfiguration);
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    // final result =
    //     await Authentication().register("chris@123.com","123123123", "chris");

    final login = await Authentication().login("chris@123.com", "123123123");
    final flower = await Flower().getFlower("colts_foot");
    print(login);
    print(flower);
  }

  void sendOtp() async {
    bool result = await emailAuth.sendOtp(
        recipientMail: "weicheng1997@live.com.sg", otpLength: 5);
    if (result) {
      // using a void function because i am using a
      // stateful widget and seting the state from here.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            RaisedButton(
              child: Text(
                'Navigate to present flower >>',
                style: TextStyle(fontSize: 24.0),
              ),
              onPressed: () {
                _navigateTo(context, 'PresentFlower');
              },
            ),
            RaisedButton(
              child: Text(
                'Navigate to Scan Flower >>',
                style: TextStyle(fontSize: 24.0),
              ),
              onPressed: () {
                _navigateTo(context, 'ScanFlower');
              },
            ),
            RaisedButton(
              child: Text(
                'Navigate to View History >>',
                style: TextStyle(fontSize: 24.0),
              ),
              onPressed: () {
                _navigateTo(context, 'ViewHistory');
              },
            ),
            RaisedButton(
              child: Text(
                'Send OTP',
                style: TextStyle(fontSize: 24.0),
              ),
              onPressed: () {
                sendOtp();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
