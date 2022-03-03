import 'dart:io';

import 'package:blossom/social_media.dart';
import 'package:flutter/material.dart';
import 'components/bottombar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PresentFlower extends StatelessWidget {
  const PresentFlower({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final flowerInfo = Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("The flower is..."),
          Text(
            "Sunflower!",
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.left,
          ),
          Text("Details to be here..............................."),
        ],
      ),
    );

    final flowerFacts = Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Flower facts:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
          Text(
              "1: The name Iris comes from the Greek word for rainbow. The name of the Greek goddess of the rainbow is also Iris."),
          SizedBox(height: 10),
          Text(
              "2: The name Iris comes from the Greek word for rainbow. The name of the Greek goddess of the rainbow is also Iris."),
          SizedBox(height: 10),
          Text(
              "2: The name Iris comes from the Greek word for rainbow. The name of the Greek goddess of the rainbow is also Iris."),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return new ShareSocialMedia();
                  });
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () async {
              final urlImage = "https://picsum.photos/200/300";
              final url = Uri.parse(urlImage);
              final response = await http.get(url);
              final bytes = response.bodyBytes;

              final temp = await getTemporaryDirectory();
              final path = '${temp.path}/image.jpg';

              File(path).writeAsBytesSync(bytes);
              await Share.shareFiles([path], text: "This lion is cute!");
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
                  children: <Widget>[
                    Expanded(flex: 6, child: flowerInfo),
                    Expanded(
                        flex: 4,
                        child: Container(
                            color: Colors.blue,
                            child: Image.network(
                                'https://picsum.photos/250?image=9'))),
                  ],
                ),
                Divider(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 4,
                        child: Container(
                            color: Colors.red,
                            child: Image.network(
                                'https://picsum.photos/250?image=9'))),
                    Expanded(
                      flex: 6,
                      child: flowerFacts,
                    ),
                  ],
                ),
              ]),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}

//Image.network('https://picsum.photos/250?image=9'),
  //             Text("Hello"),
