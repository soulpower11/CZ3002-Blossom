import 'package:blossom/constants.dart';
import 'package:blossom/favorites.dart';
import 'package:blossom/home.dart';
import 'package:blossom/scan_flower.dart';
import 'package:blossom/view_history.dart';
import 'package:blossom/view_parks.dart';
import 'package:flutter/material.dart';

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
