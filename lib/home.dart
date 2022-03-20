import 'dart:io';

import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/flower.dart';
import 'package:blossom/backend/points.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/dashboard.dart';
import 'package:blossom/image_recognition/classifier.dart';
import 'package:blossom/image_recognition/classifier_float.dart';
import 'package:blossom/present_flower.dart';
import 'package:blossom/profile.dart';
import 'package:blossom/providers/userinfo_provider.dart';
import 'package:blossom/redeem_voucher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import 'dashboard.dart';
import 'providers/dashboard_provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var name = context.watch<UserInfoProvider>().username;
    var points = 40;

    Future<Map?> getAccountInfo() async {
      final jwt = await Authentication.verifyJWT();
      int points = await Points().getPoints(jwt!.payload["email"]);
      return {"username": jwt.payload["username"], "points": points};
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

      imageFile = File(file!.path);

      if (imageFile != null) {
        final jwt = await Authentication.verifyJWT();
        img.Image imageInput = img.decodeImage(imageFile.readAsBytesSync())!;
        var flower_name = _classifier.predict(imageInput);
        int points = await calculatePoints(flower_name.label);
        await Points().addPoints(jwt!.payload["email"], points);
        // Navigator.push(
        //   context,
        //   PageRouteBuilder(
        //     pageBuilder: (context, animation1, animation2) => PresentFlower(
        //         scannedImage: imageFile,
        //         comingFrom: "scan_flower",
        //         flowerName: flower_name.label),
        //     transitionDuration: Duration.zero,
        //     reverseTransitionDuration: Duration.zero,
        //   ),
        // );

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

    return Scaffold(
      appBar: AppBar(
        title: AppTextBold(
          text: "Welcome $name!",
          size: 24,
        ),
        actions: [
          Container(
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Profile(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              iconSize: 40,
              icon: Icon(Icons.account_circle_outlined),
              color: Colors.black,
            ),
            alignment: Alignment.topRight,
          )
        ],
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Container(
            child: CarouselSlider(
              items: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F37%2F2021%2F10%2F22%2Fpink-camellias.jpg'),
                        fit: BoxFit.cover,
                      )),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://scx2.b-cdn.net/gfx/news/hires/2018/flower.jpg'),
                        fit: BoxFit.cover,
                      )),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://hgtvhome.sndimg.com/content/dam/images/grdn/fullset/2014/4/22/0/CI_sun-a-00503.jpg.rend.hgtvcom.966.644.suffix/1452656431819.jpeg'),
                        fit: BoxFit.cover,
                      )),
                ),
              ],
              options: CarouselOptions(
                  height: 300.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.easeInOut,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 3000),
                  viewportFraction: 1),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              Flexible(
                  child: Container(
                      height: 174,
                      //alignment: Alignment.centerLeft,
                      /*
                        constraints: BoxConstraints(
                            minHeight: 10,
                            maxHeight: 90,
                            minWidth: 0,
                            maxWidth: 400),
                        */
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AppTextBold(
                              text: "Scan\nFlower",
                              size: 20,
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  onPressed: () {
                                    getImage(source: ImageSource.camera);
                                  },
                                  iconSize: 60,
                                  color: Color.fromARGB(255, 141, 6, 63),
                                  icon: Image.asset(
                                      'assets/images/camera_icon.png'))),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white,
                          //border: Border.all(color: Colors.black, width: 2),
                          //borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 7,
                                offset: Offset(0, 3))
                          ]))),
              SizedBox(
                width: 30,
              ),
              Flexible(
                  child: Container(
                height: 174,
                width: 200,
                //alignment: Alignment.centerLeft,

                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppTextNormal(
                        text: "My Points",
                        size: 18,
                      ),
                    ),
                    const Divider(
                      height: 20,
                      indent: 0,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: FutureBuilder(
                            future: getAccountInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.data != null) {
                                  Map? userInfo = snapshot.data as Map?;
                                  points = userInfo!["points"];
                                  return AppTextBold(
                                    text: '$points pts',
                                    size: 26,
                                  );
                                } else {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 32.0,
                                      width: 130.0,
                                      color: Colors.grey[300],
                                    ),
                                  );
                                }
                              } else {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 32.0,
                                    width: 130.0,
                                    color: Colors.grey[300],
                                  ),
                                );
                              }
                            })),
                    const SizedBox(
                      height: 6,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                RedeemVoucher(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: AppTextBold(
                          text: 'Redeem', size: 14, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 141, 6, 63),
                          fixedSize: const Size(100, 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
                decoration: BoxDecoration(color: Colors.white,
                    //border: Border.all(color: Colors.black, width: 2),
                    //borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3))
                    ]),
                padding: EdgeInsets.all(20),
              )),
              SizedBox(width: 20)
            ],
          ),
        ],
      ),
      bottomNavigationBar: Dashboard(),
    );

    // return Scaffold(
    // appBar: AppBar(
    //   title: Text(
    //     "Welcome $name!",
    //     style: TextStyle(
    //         color: Colors.black, fontSize: 25, fontWeight: FontWeight.w600),
    //     textAlign: TextAlign.center,
    //   ),
    //   actions: [
    //     Container(
    //       child: IconButton(
    //         onPressed: () {
    //           Navigator.of(context).push(
    //               MaterialPageRoute(builder: (context) => const Profile()));
    //         },
    //         iconSize: 40,
    //         icon: Icon(Icons.account_circle_rounded),
    //         color: Colors.black,
    //       ),
    //       alignment: Alignment.topRight,
    //     )
    //   ],
    //   backgroundColor: Colors.white,
    // ),
    // body: ListView(
    //   children: [
    //     Container(
    //       child: CarouselSlider(
    //         items: [
    //           Container(
    //             margin: EdgeInsets.all(10.0),
    //             decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(10.0),
    //                 image: DecorationImage(
    //                   image: NetworkImage(
    //                       'https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F37%2F2021%2F10%2F22%2Fpink-camellias.jpg'),
    //                   fit: BoxFit.cover,
    //                 )),
    //           ),
    //           Container(
    //             margin: EdgeInsets.all(10.0),
    //             decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(10.0),
    //                 image: DecorationImage(
    //                   image: NetworkImage(
    //                       'https://scx2.b-cdn.net/gfx/news/hires/2018/flower.jpg'),
    //                   fit: BoxFit.cover,
    //                 )),
    //           ),
    //           Container(
    //             margin: EdgeInsets.all(10.0),
    //             decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(10.0),
    //                 image: DecorationImage(
    //                   image: NetworkImage(
    //                       'https://hgtvhome.sndimg.com/content/dam/images/grdn/fullset/2014/4/22/0/CI_sun-a-00503.jpg.rend.hgtvcom.966.644.suffix/1452656431819.jpeg'),
    //                   fit: BoxFit.cover,
    //                 )),
    //           ),
    //         ],
    //         options: CarouselOptions(
    //             height: 300.0,
    //             enlargeCenterPage: false,
    //             autoPlay: true,
    //             aspectRatio: 16 / 9,
    //             autoPlayCurve: Curves.easeInOut,
    //             enableInfiniteScroll: true,
    //             autoPlayAnimationDuration: Duration(milliseconds: 3000),
    //             viewportFraction: 1),
    //       ),
    //     ),
    //     SizedBox(
    //       height: 50,
    //     ),
    //     Row(
    //       children: [
    //         SizedBox(
    //           width: 20,
    //         ),
    //         Flexible(
    //             child: Container(
    //                 height: 150,
    //                 //alignment: Alignment.centerLeft,
    //                 /*
    //                 constraints: BoxConstraints(
    //                     minHeight: 10,
    //                     maxHeight: 90,
    //                     minWidth: 0,
    //                     maxWidth: 400),
    //                 */
    //                 child: Column(
    //                   children: [
    //                     Text(
    //                       "Scan Flower",
    //                       style: TextStyle(
    //                         color: Colors.black,
    //                         fontSize: 20,
    //                         fontWeight: FontWeight.w500,
    //                       ),
    //                     ),
    //                     IconButton(
    //                         onPressed: () {
    //                           getImage(source: ImageSource.camera);
    //                         },
    //                         iconSize: 70,
    //                         color: Color.fromARGB(255, 141, 6, 63),
    //                         icon: Icon(Icons.add_a_photo_rounded))
    //                   ],
    //                 ),
    //                 padding: EdgeInsets.all(20),
    //                 decoration: BoxDecoration(color: Colors.white,
    //                     //border: Border.all(color: Colors.black, width: 2),
    //                     //borderRadius: BorderRadius.circular(10),
    //                     boxShadow: [
    //                       BoxShadow(
    //                           color: Colors.grey.withOpacity(0.5),
    //                           spreadRadius: 3,
    //                           blurRadius: 7,
    //                           offset: Offset(0, 3))
    //                     ]))),
    //         SizedBox(
    //           width: 30,
    //         ),
    //         Flexible(
    //             child: Container(
    //           height: 150,
    //           width: 200,
    //           //alignment: Alignment.centerLeft,

    //           child: Column(
    //             children: [
    //               Text(
    //                 "My Points",
    //                 style: TextStyle(
    //                   color: Colors.black,
    //                   fontSize: 20,
    //                   fontWeight: FontWeight.w500,
    //                 ),
    //               ),
    //               Text('$points',
    //                   style: TextStyle(
    //                     color: Colors.black,
    //                     fontSize: 30,
    //                     fontWeight: FontWeight.w900,
    //                   )),
    //               ElevatedButton(
    //                 onPressed: () {
    //                   Navigator.of(context).push(MaterialPageRoute(
    //                       builder: (context) => const RedeemVoucher()));
    //                 },
    //                 child: const Text(
    //                   'Redeem',
    //                   style: TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 15,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 style: ElevatedButton.styleFrom(
    //                     primary: Color.fromARGB(255, 141, 6, 63),
    //                     fixedSize: const Size(100, 2),
    //                     shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(10))),
    //               ),
    //             ],
    //           ),
    //           decoration: BoxDecoration(color: Colors.white,
    //               //border: Border.all(color: Colors.black, width: 2),
    //               //borderRadius: BorderRadius.circular(10),
    //               boxShadow: [
    //                 BoxShadow(
    //                     color: Colors.grey.withOpacity(0.5),
    //                     spreadRadius: 3,
    //                     blurRadius: 7,
    //                     offset: Offset(0, 3))
    //               ]),
    //           padding: EdgeInsets.all(20),
    //         )),
    //         SizedBox(width: 20)
    //       ],
    //     ),
    //   ],
    // ));
  }
}
