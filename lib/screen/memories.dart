import 'dart:io';

import 'package:blossom/components/app_text.dart';
import 'package:blossom/components/constants.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:blossom/screen/present_flower.dart';

class Memories extends StatefulWidget {
  List<Map?> items = [];
  String name;
  Memories({Key? key, required this.items, required this.name})
      : super(key: key);

  @override
  State<Memories> createState() => _MemoriesState();
}

class _MemoriesState extends State<Memories> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              tooltip: "Share",
              icon: Icon(Icons.share_rounded),
              onPressed: () async {
                share(widget.name, widget.items);
                print('Ran share');
              },
            )
          ],
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 30, left: 20),
                  child: Container(
                      alignment: Alignment.topLeft,
                      child: AppTextBold(text: widget.name, size: 26))),
              Expanded(child: PhotoGridView(items: widget.items))
            ]));
  }
}

class PhotoGridView extends StatelessWidget {
  final bool isLoading;
  List<Map?> items = [];

  PhotoGridView({Key? key, required this.items, this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) => FlowerImage(isLoading: isLoading),
          )
        : GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PresentFlower(
                          scannedImage: items[index]!["file"],
                          comingFrom: "memories",
                          flowerName: items[index]!["flower_name"],
                          location: items[index]!["location"])));
                },
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(kDefaultPadding),
                      height: 180,
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(items[index]!["file"]),
                        ),
                      ),
                    ),
                    AppTextBold(
                      text: items[index]!["display_name"],
                      size: 12,
                    ),
                  ],
                ),
              );
            });
  }
}

class FlowerImage extends StatelessWidget {
  final bool isLoading;
  const FlowerImage({Key? key, this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
              padding: EdgeInsets.all(kDefaultPadding),
              height: 180,
              width: 160,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
        ),
        SizedBox(height: 2),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            padding: EdgeInsets.all(kDefaultPadding),
            height: 12.0,
            width: 130.0,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}

void share(String memoryName, List<Map?> items) async {
  List<String> files = [];
  const String appurl = "google.com";

  for (int index = 0; index < items.length; index++) {
    final bytes = await items[index]!["file"].readAsBytes();
    final watermarked = await image_watermark.addTextWatermarkCentered(
        bytes, 'Taken by Blossom');

    final name = items[index]!["file"].path.split("/").last;

    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image$index.jpg';

    File(path).writeAsBytesSync(watermarked);

    files.add(path);
  }
  // await Share.share(
  //     "I identified " + flowerName + " using the Blossom app!" + appurl);
  await Share.shareFiles(files, text: "$memoryName $appurl");
}
