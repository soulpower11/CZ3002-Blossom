import 'dart:io';

import 'package:blossom/screen/scan_flower.dart';
import 'package:blossom/screen/view_history.dart';
import 'package:blossom/screen/view_parks.dart';
import 'package:blossom/screen/favorites.dart';
import 'package:blossom/screen/home.dart';
import 'package:blossom/screen/present_flower.dart';
import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/flower.dart';
import 'package:blossom/backend/points.dart';
import 'package:blossom/image_recognition/classifier.dart';
import 'package:blossom/image_recognition/classifier_float.dart';
import 'package:blossom/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  void setPage(Widget? widget) {}

  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();
    }

    Future<int> calculatePoints(String flowerName) async {
      String fod = await Flower().getFlowerOfTheDay();
      if (fod == flowerName) {
        return 3;
      } else {
        return 1;
      }
    }

    void getImage({required ImageSource source}) async {
      File? imageFile;
      Classifier _classifier = ClassifierFloat();

      final navigator = Navigator.of(context);
      final file = await ImagePicker().pickImage(
          source: source,
          maxWidth: 640,
          maxHeight: 480,
          imageQuality: 100 //0 - 100
          );

      if (file?.path != null) {
        setState(() {
          imageFile = File(file!.path);
        });
      }

      if (imageFile != null) {
        final jwt = await Authentication.verifyJWT();
        img.Image imageInput = img.decodeImage(imageFile!.readAsBytesSync())!;
        var flower_name = _classifier.predict(imageInput);
        int points = await calculatePoints(flower_name.label);
        await Points().addPoints(jwt!.payload["email"], points);
        context.read<DashboardProvider>().setSelectedIndex(2);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => PresentFlower(
                scannedImage: imageFile,
                comingFrom: "scan_flower",
                flowerName: flower_name.label),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        // setPage(Dashboard());
      }
    }

    void _onItemTapped(int index) {
      context.read<DashboardProvider>().setSelectedIndex(index);
      switch (index) {
        case 0:
          Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => LandingPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (Route<dynamic> route) => false);
          // Navigator.pushReplacement(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation1, animation2) => LandingPage(),
          //     transitionDuration: Duration.zero,
          //     reverseTransitionDuration: Duration.zero,
          //   ),
          // );

          break;
        case 1:
          Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => Favorites(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (Route<dynamic> route) => false);
          // Navigator.pushReplacement(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation1, animation2) => Favorites(),
          //     transitionDuration: Duration.zero,
          //     reverseTransitionDuration: Duration.zero,
          //   ),
          // );
          break;
        case 3:
          Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => ViewHistory(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (Route<dynamic> route) => false);
          // Navigator.pushReplacement(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation1, animation2) => ViewHistory(),
          //     transitionDuration: Duration.zero,
          //     reverseTransitionDuration: Duration.zero,
          //   ),
          // );
          break;
        case 4:
          Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => Parks(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (Route<dynamic> route) => false);
          // Navigator.pushReplacement(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation1, animation2) => Parks(),
          //     transitionDuration: Duration.zero,
          //     reverseTransitionDuration: Duration.zero,
          //   ),
          // );

          break;
      }
    }

    var items = const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
      BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border), label: "Favorites"),
      BottomNavigationBarItem(
          icon: Icon(Icons.photo_camera, color: Colors.transparent), label: ""),
      BottomNavigationBarItem(
          icon: Icon(Icons.book_online_outlined), label: "History"),
      BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Parks"),
    ];

    final Size size = MediaQuery.of(context).size;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
              ),
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25),
              ),
              child: BottomNavigationBar(
                  currentIndex:
                      context.watch<DashboardProvider>().selectedIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Color.fromRGBO(39, 44, 41, 1),
                  iconSize: 25,
                  selectedIconTheme: const IconThemeData(
                      color: Color.fromRGBO(211, 205, 98, 1), size: 30),
                  unselectedIconTheme: const IconThemeData(
                    color: Colors.white,
                  ),
                  selectedLabelStyle: GoogleFonts.montserrat(),
                  unselectedLabelStyle: GoogleFonts.montserrat(),
                  unselectedItemColor: Colors.white,
                  selectedItemColor: Color.fromRGBO(211, 205, 98, 1),
                  items: items),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          left: size.width / 2.4,
          child: IconButton(
              tooltip: "Scan Flower",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        ScanFlower(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                // getImage(source: ImageSource.camera);
              },
              // splashColor: Colors.transparent,
              // highlightColor: Colors.transparent,
              iconSize: 58,
              color: Color.fromARGB(255, 141, 6, 63),
              icon: Image.asset('assets/images/camera_icon.png')),
        ),
      ],
    );
  }
}
