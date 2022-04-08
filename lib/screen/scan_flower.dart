import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/flower.dart';
import 'package:blossom/backend/points.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/image_recognition/classifier.dart';
import 'package:blossom/image_recognition/classifier_float.dart';
import 'package:blossom/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:blossom/screen/present_flower.dart';

class ScanFlower extends StatefulWidget {
  const ScanFlower({Key? key}) : super(key: key);

  @override
  State<ScanFlower> createState() => _ScanFlowerState();
}

class _ScanFlowerState extends State<ScanFlower> {
  bool photoTaken = false;

  @override
  void initState() {
    super.initState();
    getImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: photoTaken
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppTextNormal(size: 18, text: "Recognition in Progress..."),
                  const SizedBox(
                    height: 20,
                  ),
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Color.fromARGB(255, 141, 6, 63)),
                  ),
                ],
              )
            : Row(),
      ),
    );
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
    Classifier _classifier = ClassifierFloat();

    XFile? file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 480,
        imageQuality: 100 //0 - 100
        );

    if (file == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        photoTaken = true;
      });

      File imageFile = File(file.path);
      final jwt = await Authentication.verifyJWT();
      img.Image imageInput = img.decodeImage(imageFile.readAsBytesSync())!;

      var flowerName = _classifier.predict(imageInput);
      int points = await calculatePoints(flowerName.label);

      await Points().addPoints(jwt!.payload["email"], points);

      context.read<DashboardProvider>().setSelectedIndex(2);

      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => PresentFlower(
                scannedImage: imageFile,
                comingFrom: "scan_flower",
                flowerName: flowerName.label),
          ),
          (Route<dynamic> route) => false);

      // Navigator.pushReplacement(
      //   context,
      //   PageRouteBuilder(
      //     pageBuilder: (context, animation1, animation2) => PresentFlower(
      //         scannedImage: imageFile,
      //         comingFrom: "scan_flower",
      //         flowerName: flowerName.label),
      //     transitionDuration: Duration.zero,
      //     reverseTransitionDuration: Duration.zero,
      //   ),
      // );
    }
  }
}
