import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend/authentication.dart';
import 'backend/flower.dart';
import 'constants.dart';
import 'package:shimmer/shimmer.dart';

class ViewHistory extends StatefulWidget {
  const ViewHistory({Key? key}) : super(key: key);

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<Map?>?> getUserHistory() async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      return await Flower().getUserHistory(jwt.payload["email"]);
    }
    return null;
  }

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
                  child: FutureBuilder(
                future: getUserHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Map?> _items = [];
                    _items.addAll(snapshot.data as List<Map?>);
                  return  HistoryGridView(isLoading: false, items: _items);
                  } 
                  return  HistoryGridView(isLoading: true, items: []);
                },
              ))
            ]));
  }
}

class HistoryGridView extends StatelessWidget {
  final bool isLoading;
  List<Map?> items = [];

  HistoryGridView({Key? key, required this.items, this.isLoading = false})
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
              return new GestureDetector(
                onTap: () {},
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
                    Text(items[index]!["flower_name"],
                        style: TextStyle(
                            color: kTextColor, fontWeight: FontWeight.bold)),
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
