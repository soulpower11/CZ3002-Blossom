import 'package:flutter/material.dart';
import 'constants.dart';

import 'components/bottombar.dart';

class ViewHistory extends StatefulWidget {
  const ViewHistory({Key? key}) : super(key: key);

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 15, bottom: 30, left: 15),
              child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Past Captures",
                    style: TextStyle(fontSize: 26),
                  ))),
          Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) => FlowerImage()),
          )
        ],
      )
      // body: SingleChildScrollView(
      //     child: Container(
      //   color: Colors.grey,
      //   margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      //   child: Column(
      //     children: <Widget>[
      //       Padding(
      //           padding: EdgeInsets.only(top: 15, bottom: 15),
      //           child: Container(
      //               alignment: Alignment.topLeft,
      //               child: Text(
      //                 "Past Captures",
      //                 style: TextStyle(fontSize: 26),
      //               ))),
      //       Row(
      //         children: [
      //           Expanded(
      //             child: Container(
      //               child: Text("1"),
      //               color: Colors.red,
      //               height: 100,
      //             ),
      //           ),
      //           Expanded(
      //             child: Container(
      //               child: Text("Ello"),
      //               color: Colors.blue,
      //               height: 100,
      //             ),
      //           ),
      //           Expanded(
      //             child: Container(
      //               child: Text("Ello"),
      //               color: Colors.green,
      //               height: 100,
      //             ),
      //           ),
      //         ],
      //       )
      //     ],
      //   ),
      // )),
      ,
      bottomNavigationBar: BottomBar(),
    );
  }
}

class FlowerImage extends StatelessWidget {
  const FlowerImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.all(kDefaultPadding),
            height: 180,
            width: 160,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(10))),
        Text("Flower Name",
            style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
