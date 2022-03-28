import 'dart:ffi';

import 'package:blossom/screen/dashboard.dart';
import 'package:blossom/screen/present_flower.dart';
import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/flower.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/components/constants.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<Favorites> {
  final GlobalKey<_FavouriteGridViewState> favouriteGridViewKey =
      GlobalKey<_FavouriteGridViewState>();
  TextEditingController controller = TextEditingController();
  Future<List<Map?>?>? favoritesFuture;

  @override
  void initState() {
    favoritesFuture = getUserFavorites();
    super.initState();
  }

  Future<List<Map?>?> getUserFavorites() async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      return await Flower().getUserFavourites(jwt.payload["email"]);
    }
    return null;
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
        backgroundColor: Colors.white,
        // leading: _selectionButton,
        // actions: _buttons,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: EdgeInsets.only(top: 15, bottom: 30, left: 20),
            child: Container(
                alignment: Alignment.topLeft,
                child: AppTextBold(text: "Favourites", size: 26))),
        Expanded(
          child: FutureBuilder(
            future: favoritesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  var items = snapshot.data as List<Map?>;
                  return FavouriteGridView(
                      key: favouriteGridViewKey,
                      isLoading: false,
                      items: items);
                }
              }
              return FavouriteGridView(isLoading: true, items: []);
            },
          ),
        )
      ]),
      bottomNavigationBar: Dashboard(),
    );
  }
}

class FavouriteGridView extends StatefulWidget {
  final bool isLoading;
  List<Map?> items = [];

  FavouriteGridView({Key? key, required this.items, this.isLoading = false})
      : super(key: key);

  @override
  State<FavouriteGridView> createState() => _FavouriteGridViewState();
}

class _FavouriteGridViewState extends State<FavouriteGridView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) =>
                FlowerImage(isLoading: widget.isLoading),
          )
        : GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return GridTile(
                  child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PresentFlower(
                          scannedImage: widget.items[index]!["file"],
                          comingFrom: "favorites",
                          flowerName: widget.items[index]!["flower_name"],
                          location: widget.items[index]!["location"])));
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
                          image: FileImage(widget.items[index]!["file"]),
                        ),
                      ),
                    ),
                    AppTextBold(
                      text: widget.items[index]!["display_name"],
                      size: 12,
                    ),
                  ],
                ),
              ));
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
