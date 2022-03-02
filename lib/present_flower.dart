import 'package:flutter/material.dart';

class PresentFlower extends StatelessWidget {
  const PresentFlower({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: Text("Hello"),
        leading: BackButton(
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {},
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
      bottomNavigationBar: Container(
        height: 40.0,
        color: Colors.red,
      ),
    );
  }
}

//Image.network('https://picsum.photos/250?image=9'),
  //             Text("Hello"),
