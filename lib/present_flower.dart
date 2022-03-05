import 'dart:io';

import 'package:blossom/scan_flower.dart';
import 'package:blossom/social_media.dart';
import 'package:flutter/material.dart';
import 'backend/flower.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/constants.dart';
import 'package:image_watermark/image_watermark.dart';

class PresentFlower extends StatefulWidget {
  const PresentFlower({Key? key}) : super(key: key);

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
  var scannedImage = 'https://picsum.photos/id/237/480/640';
  var databaseImage = 'https://picsum.photos/id/237/480/640';
  bool favourite = false;

  @override
  void initState() {
    super.initState();
    getFlowerInfo("colts_foot").then((flower) {
      setState(() {
        flowerName = flower!["display_name"];
        scientificName = flower["scientific_name_origin"];
        nativeTo = flower["native_to"];
        funFact1 = flower["fun_facts_1"];
        funFact2 = flower["fun_facts_2"];
        funFact3 = flower["fun_facts_3"];
        numScans = flower["num_scans"].toString();
        favourite = false;
      });
    });
  }

  Future<Map?> getFlowerInfo(String name) async {
    final flower = await Flower().getFlower(name);
    return flower;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final flowerInfo = Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextBold(size: 17, text: "I am a"),
          AppTextBold(size: 30, text: flowerName, color: kAppBrownColor),
          AppTextNormal(
              size: 14, text: "I have been scanned " + numScans + " times!\n"),
          AppTextNormal(
              size: 12, text: "Scientific Name", color: kAppBrownColor),
          AppTextBold(size: 14, text: scientificName + '\n'),
          AppTextNormal(size: 12, text: "Native to", color: kAppBrownColor),
          AppTextBold(size: 14, text: nativeTo + '\n'),
        ],
      ),
    );

    final flowerFacts = Container(
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
          AppTextNormal(size: 12, text: "3. " + funFact1)
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ScanFlower()));
          },
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: favourite
                ? Icon(Icons.favorite, color: kButtonColor1)
                : Icon(Icons.favorite_border),
            onPressed: () async {
              setState(() => favourite = !favourite);
              // showDialog(
              //     context: context,
              //     builder: (context) {
              //       return new ShareSocialMedia();
              //     });
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              share(flowerName, scannedImage);
              print('Ran share');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
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
                            child: Image.network(scannedImage))),
                    Expanded(flex: 6, child: flowerInfo),
                  ],
                ),
                Divider(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: flowerFacts,
                    ),
                    Expanded(
                        flex: 4,
                        child: Container(
                            padding: EdgeInsets.only(top: 25),
                            child: Image.network(databaseImage))),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}

void share(String flowerName, scannedImage) async {
  final urlImage = scannedImage;
  final url = Uri.parse(urlImage);
  final response = await http.get(url);
  final bytes = response.bodyBytes;
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

//Image.network('https://picsum.photos/250?image=9'),
  //             Text("Hello"),
