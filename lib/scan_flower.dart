import 'package:blossom/dashboard.dart';
import 'package:blossom/present_flower.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'home.dart';

class ScanFlower extends StatefulWidget {
  const ScanFlower({Key? key}) : super(key: key);

  @override
  State<ScanFlower> createState() => _ScanFlowerState();
}

class _ScanFlowerState extends State<ScanFlower> {
  @override
  File? imageFile;
  @override
  void initState() {
    super.initState();
    getImage(source: ImageSource.camera);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        // body: Padding(
        //   padding: const EdgeInsets.all(12.0),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       if (imageFile != null)
        //         Container(
        //           width: 640,
        //           height: 480,
        //           alignment: Alignment.center,
        //           decoration: BoxDecoration(
        //             color: Colors.grey,
        //             image: DecorationImage(
        //                 image: FileImage(imageFile!), fit: BoxFit.cover),
        //             border: Border.all(width: 8, color: Colors.black),
        //             borderRadius: BorderRadius.circular(12.0),
        //           ),
        //         )
        //       else
        //         Container(
        //           width: 640,
        //           height: 480,
        //           alignment: Alignment.center,
        //           decoration: BoxDecoration(
        //             color: Colors.grey,
        //             border: Border.all(width: 8, color: Colors.black12),
        //             borderRadius: BorderRadius.circular(12.0),
        //           ),
        //           child: const Text(
        //             'Image is nothing',
        //             style: TextStyle(fontSize: 26),
        //           ),
        //         ),
        //       const SizedBox(
        //         height: 20,
        //       ),
        //       Row(
        //         children: [
        //           Expanded(
        //             child: ElevatedButton(
        //                 onPressed: () => getImage(source: ImageSource.camera),
        //                 child: const Text('Capture Image',
        //                     style: TextStyle(fontSize: 18))),
        //           ),
        //           const SizedBox(
        //             width: 20,
        //           ),
        //           Expanded(
        //             child: ElevatedButton(
        //                 onPressed: () {
        //                   Navigator.of(context).push(MaterialPageRoute(
        //                       builder: (context) => PresentFlower()));
        //                 },
        //                 child:
        //                     const Text('Next', style: TextStyle(fontSize: 18))),
        //           )
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        );
  }

  void getImage({required ImageSource source}) async {
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
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PresentFlower(scannedImage: imageFile)));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Dashboard()));
    }
  }
}
