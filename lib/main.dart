import 'package:blossom/present_flower.dart';
import 'package:blossom/scan_flower.dart';
import 'package:blossom/view_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

Future main() async {
  // await dotenv.load(fileName: ".env");
  // String mongoUri = dotenv.get('MONGO_URI');
  // var db = await mongo.Db.create(mongoUri);
  // await db.open();
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

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
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
