import 'package:blossom/constants.dart';
import 'package:blossom/favorites.dart';
import 'package:blossom/home.dart';
import 'package:blossom/scan_flower.dart';
import 'package:blossom/view_history.dart';
import 'package:blossom/view_parks.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static List<Widget> _pages = <Widget>[
    Home(),
    Favorites(),
    ScanFlower(),
    ViewHistory(),
    Parks(),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    GPSPremission();
  }

  void GPSPremission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var items = const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: "Home"
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_border),
      label: "Favorites"
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.photo_camera, color: Colors.transparent),
      label: ""
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_online_outlined),
      label: "History"
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map_outlined),
      label: "Parks"
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Center(
          child: _pages.elementAt(_selectedIndex), //New
      ),
      bottomNavigationBar: Container(
        // add a top right border radius
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
          ),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
              currentIndex: _selectedIndex, //New
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              iconSize: 25,
              selectedIconTheme: IconThemeData(color: Colors.yellow[200], size: 30),
              unselectedIconTheme: IconThemeData(
                color: Colors.white,
              ),
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.yellow[200],
              items: items),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Color(0xffa2a5a4),
            child: Image.asset('assets/images/camera_icon.png'),
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });
              }),
        ),
      ),
    );
  }
}
