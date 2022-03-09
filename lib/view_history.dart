import 'dart:ffi';

import 'package:blossom/memories.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend/authentication.dart';
import 'backend/flower.dart';
import 'constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'providers/view_history_provider.dart';

class ViewHistory extends StatefulWidget {
  const ViewHistory({Key? key}) : super(key: key);

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  final GlobalKey<_HistoryGridViewState> historyGridViewKey =
      GlobalKey<_HistoryGridViewState>();
  TextEditingController controller = TextEditingController();
  Future<List<Map?>?>? historyFuture;
  Future<List<Map?>?>? memoryFuture;

  @override
  void initState() {
    historyFuture = getUserHistory();
    memoryFuture = getUserMemory();
    context.read<ViewHistoryProvider>().resetSelection();
    checkMemoryExist().then(((value) {
      context.read<ViewHistoryProvider>().setHaveMemory(value);
    }));
    super.initState();
  }

  Future<List<Map?>?> getUserHistory() async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      return await Flower().getUserHistory(jwt.payload["email"]);
    }
    return null;
  }

  Future<List<Map?>?> getUserMemory() async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      return await Flower().getUserMemory(jwt.payload["email"]);
    }
    return null;
  }

  Future<bool> checkMemoryExist() async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      return await Flower().checkMemoryExist(jwt.payload["email"]);
    }
    return false;
  }

  Future<String?> openDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Create Memories"),
            content: TextField(
                autofocus: true,
                controller: controller,
                decoration: InputDecoration(hintText: "Enter name")),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                    controller.clear();
                  },
                  child: Text("SUBMIT"))
            ],
          ));

  @override
  Widget build(BuildContext context) {
    List<Widget> _buttons = [];
    Widget? _selectionButton;

    if (context.watch<ViewHistoryProvider>().selectionMode) {
      _selectionButton = context.read<ViewHistoryProvider>().selectedAll
          ? IconButton(
              icon: Icon(Icons.check_circle),
              onPressed: () {
                context.read<ViewHistoryProvider>().clearAllSelected();
              },
            )
          : IconButton(
              icon: Icon(Icons.circle_outlined),
              onPressed: () {
                context.read<ViewHistoryProvider>().selectAll();
              },
            );
      _buttons = [
        IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              List<Map?> photos = [];
              if (context
                  .read<ViewHistoryProvider>()
                  .selectedIndexList
                  .isNotEmpty) {
                context
                    .read<ViewHistoryProvider>()
                    .selectedIndexList
                    .forEach((index) {
                  photos.add(
                      context.read<ViewHistoryProvider>().historyItems[index]);
                });

                context.read<ViewHistoryProvider>().toggleSelectionMode();

                final jwt = await Authentication.verifyJWT();
                if (jwt != null) {
                  await Flower().saveUserMemory(jwt.payload["email"],
                      context.read<ViewHistoryProvider>().memoryName, photos);
                }

                context.read<ViewHistoryProvider>().setHaveMemory(true);
                context.read<ViewHistoryProvider>().addedMemory();
                context.read<ViewHistoryProvider>().setMemoryName("");
              }
            },
            tooltip: "Done"),
      ];
    } else {
      _selectionButton = null;
      _buttons = [
        IconButton(
          icon: Icon(Icons.create_new_folder_rounded),
          onPressed: () async {
            final name = await openDialog();
            print(name);
            if (name != null) {
              context.read<ViewHistoryProvider>().toggleSelectionMode();
              context.read<ViewHistoryProvider>().setMemoryName(name);
            }
          },
        ),
      ];
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          centerTitle: true,
          leading: _selectionButton,
          actions: _buttons,
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          context.watch<ViewHistoryProvider>().haveMemories
              ? Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 30, left: 15),
                  child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Memories",
                        style: TextStyle(fontSize: 26),
                      )))
              : Row(),
          context.watch<ViewHistoryProvider>().haveMemories
              ? SizedBox(
                  height: 130,
                  child: FutureBuilder(
                    future: memoryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data != null) {
                          print(snapshot.data);
                          List<Map?> memory = snapshot.data as List<Map?>;
                          context
                              .read<ViewHistoryProvider>()
                              .setAllMemory(memory);
                        }
                        return MemoryGridView(
                            isLoading: false,
                            items: context
                                .watch<ViewHistoryProvider>()
                                .memoryItems);
                      }
                      return MemoryGridView(isLoading: true, items: []);
                    },
                  ))
              : Row(),
          context.watch<ViewHistoryProvider>().haveMemories
              ? Divider(height: 20)
              : Row(),
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
              future: historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    context
                        .read<ViewHistoryProvider>()
                        .setAllPhotos(snapshot.data as List<Map?>);
                  }
                  return HistoryGridView(
                      key: historyGridViewKey,
                      isLoading: false,
                      items: context.watch<ViewHistoryProvider>().historyItems);
                }
                return HistoryGridView(isLoading: true, items: []);
              },
            ),
          )
        ]));
  }
}

class MemoryGridView extends StatelessWidget {
  final bool isLoading;
  List<Map?> items = [];

  MemoryGridView({Key? key, required this.items, this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
            itemBuilder: (context, index) => MemoryImage(isLoading: isLoading),
          )
        : GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Memories(
                          name: items[index]!["memory_name"],
                          items: items[index]!["photo_list"])));
                },
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.all(kDefaultPadding),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(
                                  items[index]!["photo_list"]![0]!["file"]),
                            ))),
                    Text(items[index]!["memory_name"],
                        style: TextStyle(
                            color: kTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              );
            });
  }
}

class HistoryGridView extends StatefulWidget {
  final bool isLoading;
  List<Map?> items = [];

  HistoryGridView({Key? key, required this.items, this.isLoading = false})
      : super(key: key);

  @override
  State<HistoryGridView> createState() => _HistoryGridViewState();
}

class _HistoryGridViewState extends State<HistoryGridView> {
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
              if (context.watch<ViewHistoryProvider>().selectionMode) {
                return GridTile(
                    header: GridTileBar(
                      leading: Icon(
                        context.read<ViewHistoryProvider>().contains(index)
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        color:
                            context.read<ViewHistoryProvider>().contains(index)
                                ? Colors.green
                                : Colors.black,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (context
                            .read<ViewHistoryProvider>()
                            .contains(index)) {
                          context
                              .read<ViewHistoryProvider>()
                              .removeSelected(index);
                        } else {
                          context
                              .read<ViewHistoryProvider>()
                              .addSelected(index);
                        }
                      },
                      onLongPress: () {
                        context
                            .read<ViewHistoryProvider>()
                            .changeSelection(enable: false, index: -1);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(kDefaultPadding),
                            height: 180,
                            width: 160,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image:
                                      FileImage(widget.items[index]!["file"]),
                                ),
                              ),
                            ),
                          ),
                          Text(widget.items[index]!["display_name"],
                              style: const TextStyle(
                                  color: kTextColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ));
              } else {
                return GridTile(
                    child: GestureDetector(
                  onTap: () {},
                  onLongPress: () {
                    // context
                    //     .read<ViewHistoryProvider>()
                    //     .changeSelection(enable: true, index: index);
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
                      Text(widget.items[index]!["display_name"],
                          style: const TextStyle(
                              color: kTextColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ));
              }
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

class MemoryImage extends StatelessWidget {
  final bool isLoading;
  const MemoryImage({Key? key, this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
              padding: EdgeInsets.all(kDefaultPadding),
              height: 100,
              width: 100,
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
            width: 70.0,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}
