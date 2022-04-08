import 'dart:io';

import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/flower.dart';
import 'package:blossom/components/constants.dart';
import 'package:blossom/screen/dashboard.dart';
import 'package:blossom/screen/favorites.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blossom/components/app_text.dart';
import 'package:image_watermark/image_watermark.dart';

class PresentFlower extends StatefulWidget {
  final File? scannedImage;
  final String comingFrom, flowerName;
  final String? location;

  const PresentFlower(
      {Key? key,
      required this.scannedImage,
      required this.comingFrom,
      required this.flowerName,
      this.location})
      : super(key: key);

  @override
  State<PresentFlower> createState() => _PresentFlowerState();
}

class _PresentFlowerState extends State<PresentFlower> {
  late String flowerName = "",
      scientificName = "",
      nativeTo = "",
      funFact1 = "",
      funFact2 = "",
      funFact3 = "",
      numScans = "";
  File? scannedImage;
  File? databaseImage;
  late bool favourite = false;
  bool isLoading = true;
  Future<Map?>? future;
  late String email = "";

  @override
  void initState() {
    super.initState();
    if (widget.comingFrom == "scan_flower") {
      future = saveAndGetFlowerInfo(widget.flowerName);
    } else if (widget.comingFrom == "view_history" ||
        widget.comingFrom == "favorites" ||
        widget.comingFrom == "memories") {
      future = getFlowerInfo(widget.flowerName, widget.location);
    }
    scannedImage = widget.scannedImage;
    getEmail().then((value) {
      setState(() => email = value);
      getFavouriteToggle(widget.flowerName)
          .then((value) => {setState(() => favourite = value)});
    });
  }

  Future<Position> locatePosition() async {
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

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<Map?> saveAndGetFlowerInfo(String name) async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      Position position = await locatePosition();
      await Flower().saveFlowerPhoto(scannedImage, name, jwt.payload["email"],
          position.latitude, position.longitude);
      databaseImage = await Flower().getStockFlowerImage(name);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      var flower = await Flower().getFlower(name);
      flower!["location"] = placemarks[0].name;
      return flower;
    }
  }

  Future<Map?> getFlowerInfo(String name, String? location) async {
    databaseImage = await Flower().getStockFlowerImage(name);
    var flower = await Flower().getFlower(name);
    if (location != null) {
      flower!["location"] = location;
    } else {
      flower!["location"] = '';
    }
    return flower;
  }

  Future<bool> getFavouriteToggle(String name) async {
    return await Flower().getOneFavourite(name, email);
  }

  Future<String> getEmail() async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      return jwt.payload["email"];
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Favourite",
            icon: favourite
                ? Icon(Icons.favorite, color: kButtonColor1)
                : Icon(Icons.favorite_border),
            onPressed: isLoading
                ? null
                : () async {
                    setState(() => favourite = !favourite);
                    Flower().toggleFavourite(
                        widget.flowerName, flowerName, email, favourite);
                    if (widget.comingFrom == "favorites") {
                      Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                Favorites(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                          (Route<dynamic> route) => false);
                    }
                  },
          ),
          IconButton(
            tooltip: "Share",
            icon: Icon(Icons.share_rounded),
            onPressed: isLoading
                ? null
                : () async {
                    share(flowerName, scannedImage);
                    print('Ran share');
                  },
          )
        ],
      ),
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var flower = snapshot.data as Map<dynamic, dynamic>;
              flowerName = flower["display_name"];
              SchedulerBinding.instance
                  ?.addPostFrameCallback((_) => setState(() {
                        isLoading = false;
                      }));
              return PresentFlowerScrollView(
                  flower: flower,
                  databaseImage: databaseImage,
                  scannedImage: scannedImage,
                  comeFrom: widget.comingFrom,
                  isLoading: false);
            }
            return PresentFlowerScrollView(
                flower: const {},
                databaseImage: databaseImage,
                scannedImage: scannedImage,
                comeFrom: widget.comingFrom,
                isLoading: true);
          }),
      bottomNavigationBar:
          widget.comingFrom == "scan_flower" ? Dashboard() : null,
    );
  }
}

void share(String flowerName, File? scannedImage) async {
  final bytes = await scannedImage!.readAsBytes();
  final watermarked =
      await image_watermark.addTextWatermarkCentered(bytes, 'Taken by Blossom');
  final appurl = "google.com";

  final temp = await getTemporaryDirectory();
  final path = '${temp.path}/image.jpg';

  File(path).writeAsBytesSync(watermarked);

  // await Share.share(
  //     "I identified " + flowerName + " using the Blossom app!" + appurl);
  await Share.shareFiles([path],
      text: "I identified " +
          flowerName +
          " using the Blossom app!" +
          "Find out more about Blossom at: " +
          appurl);
}

class PresentFlowerScrollView extends StatelessWidget {
  final bool isLoading;
  Map<dynamic, dynamic> flower;
  File? scannedImage;
  File? databaseImage;
  String comeFrom;

  PresentFlowerScrollView(
      {Key? key,
      required this.flower,
      required this.scannedImage,
      required this.databaseImage,
      required this.comeFrom,
      this.isLoading = false})
      : super(key: key);

  Widget build(BuildContext context) {
    return isLoading
        ? SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            flex: 4,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Container(
                                          padding: EdgeInsets.only(top: 25),
                                          height: 185.0,
                                          width: 160.0,
                                          color: Colors.grey[300])
                                    ]))),
                        Expanded(
                            flex: 6,
                            child: FlowerInfo(
                              flowerName: '',
                              nativeTo: '',
                              numScans: '',
                              scientificName: '',
                              location: '',
                              comeFrom: comeFrom,
                              isLoading: isLoading,
                            )),
                      ],
                    ),
                    Divider(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: FlowerFacts(
                              funFact1: '',
                              funFact2: '',
                              funFact3: '',
                              isLoading: isLoading),
                        ),
                        Expanded(
                            flex: 4,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Container(
                                          padding: EdgeInsets.only(top: 25),
                                          height: 185.0,
                                          width: 160.0,
                                          color: Colors.grey[300])
                                    ]))),
                      ],
                    ),
                  ]),
            ),
          )
        : SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            flex: 4,
                            child: Container(
                                padding: EdgeInsets.only(top: 25),
                                child: Image(
                                  image: FileImage(scannedImage!),
                                ))),
                        Expanded(
                            flex: 6,
                            child: FlowerInfo(
                              flowerName: flower["display_name"],
                              nativeTo: flower["native_to"],
                              numScans: flower["num_scans"].toString(),
                              scientificName: flower["scientific_name_origin"],
                              location: flower["location"],
                              comeFrom: comeFrom,
                              isLoading: isLoading,
                            )),
                      ],
                    ),
                    Divider(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: FlowerFacts(
                              funFact1: flower["fun_facts_1"],
                              funFact2: flower["fun_facts_2"],
                              funFact3: flower["fun_facts_3"],
                              isLoading: isLoading),
                        ),
                        Expanded(
                            flex: 4,
                            child: Container(
                                padding: EdgeInsets.only(top: 25),
                                child:
                                    Image(image: FileImage(databaseImage!)))),
                      ],
                    ),
                  ]),
            ),
          );
  }
}

class FlowerInfo extends StatelessWidget {
  final bool isLoading;
  String flowerName, scientificName, nativeTo, numScans, location, comeFrom;

  FlowerInfo(
      {Key? key,
      required this.flowerName,
      required this.scientificName,
      required this.nativeTo,
      required this.numScans,
      required this.location,
      required this.comeFrom,
      this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    height: 18.0,
                    width: 58.0,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    height: 32.0,
                    width: 152.0,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    height: 32.0,
                    width: 180.0,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    height: 16.0,
                    width: 98.0,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    height: 18.0,
                    width: 130.0,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    height: 16.0,
                    width: 52.0,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    height: 68.0,
                    width: 162.0,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 8),
                comeFrom != 'favorites'
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          padding: EdgeInsets.all(kDefaultPadding),
                          height: 50.0,
                          width: 162.0,
                          color: Colors.grey[300],
                        ),
                      )
                    : Row(),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextBold(size: 17, text: "I am a"),
                AppTextBold(size: 28, text: flowerName, color: kAppBrownColor),
                AppTextNormal(
                    size: 14,
                    text: "I have been scanned " + numScans + " times!\n"),
                AppTextNormal(
                    size: 12, text: "Scientific Name", color: kAppBrownColor),
                AppTextBold(size: 14, text: scientificName + '\n'),
                AppTextNormal(
                    size: 12, text: "Native to", color: kAppBrownColor),
                AppTextBold(size: 14, text: nativeTo + '\n'),
                comeFrom != 'favorites'
                    ? SizedBox(
                        height: 50,
                        child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: kAppPinkColor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 5, right: 10),
                                    child: Icon(Icons.pin_drop_outlined)),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppTextNormal(
                                          size: 12, text: "I was taken at"),
                                      AppTextBold(size: 14, text: location)
                                    ])
                              ],
                            )))
                    : Row()
              ],
            ),
          );
  }
}

class FlowerFacts extends StatelessWidget {
  final bool isLoading;
  String funFact1, funFact2, funFact3;

  FlowerFacts(
      {Key? key,
      required this.funFact1,
      required this.funFact2,
      required this.funFact3,
      this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      padding: EdgeInsets.all(kDefaultPadding),
                      height: 24.0,
                      width: 124.0,
                      color: Colors.grey[300],
                    )),
                SizedBox(height: 10),
                Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      padding: EdgeInsets.all(kDefaultPadding),
                      height: 98.0,
                      width: 168.0,
                      color: Colors.grey[300],
                    )),
                SizedBox(height: 10),
                Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      padding: EdgeInsets.all(kDefaultPadding),
                      height: 98.0,
                      width: 168.0,
                      color: Colors.grey[300],
                    )),
                SizedBox(height: 10),
                Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      padding: EdgeInsets.all(kDefaultPadding),
                      height: 98.0,
                      width: 168.0,
                      color: Colors.grey[300],
                    )),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextBold(size: 20, text: "Flower facts"),
                SizedBox(height: 10),
                AppTextNormal(size: 12, text: "1. " + funFact1),
                SizedBox(height: 10),
                AppTextNormal(size: 12, text: "2. " + funFact2),
                SizedBox(height: 10),
                AppTextNormal(size: 12, text: "3. " + funFact3)
              ],
            ),
          );
  }
}
