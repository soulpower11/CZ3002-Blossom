import 'dart:ffi';

import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/flower.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/components/constants.dart';
import 'package:blossom/providers/view_history_provider.dart';
import 'package:blossom/screen/dashboard.dart';
import 'package:blossom/screen/memories.dart';
import 'package:blossom/screen/present_flower.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

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
            title: AppTextBold(
              size: 18,
              text: "Create Memories",
            ),
            content: TextField(
                autofocus: true,
                controller: controller,
                decoration: InputDecoration(
                    hintText: "Enter name",
                    hintStyle: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                      color: kTextColor,
                    )))),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                  controller.clear();
                },
                child: AppTextNormal(
                  size: 14,
                  text: "SUBMIT",
                  color: Colors.blue,
                ),
              )
            ],
          ));

  @override
  Widget build(BuildContext context) {
    List<Widget> _buttons = [];
    Widget? _selectionButton;

    if (context.watch<ViewHistoryProvider>().selectionMode) {
      _selectionButton = context.read<ViewHistoryProvider>().selectedAll
          ? IconButton(
              tooltip: "Uncheck All",
              icon: Icon(Icons.check_circle_rounded),
              onPressed: () {
                context.read<ViewHistoryProvider>().clearAllSelected();
              },
            )
          : IconButton(
              tooltip: "Check All",
              icon: Icon(Icons.radio_button_unchecked_rounded),
              onPressed: () {
                context.read<ViewHistoryProvider>().selectAll();
              },
            );
      _buttons = [
        context.read<ViewHistoryProvider>().selectedIndexList.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.done_rounded),
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
                      photos.add(context
                          .read<ViewHistoryProvider>()
                          .historyItems[index]);
                    });

                    context.read<ViewHistoryProvider>().toggleSelectionMode();

                    final jwt = await Authentication.verifyJWT();
                    if (jwt != null) {
                      await Flower().saveUserMemory(
                          jwt.payload["email"],
                          context.read<ViewHistoryProvider>().memoryName,
                          photos);
                    }

                    context.read<ViewHistoryProvider>().setHaveMemory(true);
                    context.read<ViewHistoryProvider>().addedMemory();
                    context.read<ViewHistoryProvider>().setMemoryName("");
                    memoryFuture = getUserMemory();
                  }
                },
                tooltip: "Done")
            : Visibility(
                child: IconButton(icon: Icon(Icons.check), onPressed: () {}),
                visible: false,
              ),
        IconButton(
            icon: Icon(Icons.close_rounded),
            onPressed: () {
              context
                  .read<ViewHistoryProvider>()
                  .changeSelection(enable: false, index: -1);
            },
            tooltip: "Cancel")
      ];
    } else {
      _selectionButton = null;
      _buttons = [
        IconButton(
          tooltip: "Create Memories",
          icon: Icon(Icons.create_new_folder_rounded),
          onPressed: () async {
            final name = await openDialog();
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
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: _selectionButton,
        actions: _buttons,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        context.watch<ViewHistoryProvider>().haveMemories
            ? Padding(
                padding: EdgeInsets.only(top: 15, bottom: 30, left: 20),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: AppTextBold(text: "Memories", size: 26)))
            : Row(),
        context.watch<ViewHistoryProvider>().haveMemories
            ? SizedBox(
                height: 130,
                child: FutureBuilder(
                  future: memoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data != null) {
                        List<Map?> memory = snapshot.data as List<Map?>;
                        context
                            .read<ViewHistoryProvider>()
                            .setAllMemory(memory);
                      }
                      return MemoryGridView(
                          isLoading: false,
                          items:
                              context.watch<ViewHistoryProvider>().memoryItems);
                    }
                    return MemoryGridView(isLoading: true, items: []);
                  },
                ))
            : Row(),
        context.watch<ViewHistoryProvider>().haveMemories
            ? Divider(height: 20)
            : Row(),
        Padding(
            padding: EdgeInsets.only(top: 15, bottom: 30, left: 20),
            child: Container(
                alignment: Alignment.topLeft,
                child: AppTextBold(text: "Past Captures", size: 26))),
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
      ]),
      bottomNavigationBar: Dashboard(),
    );
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
                    MemoryThumbnail(
                      items: items[index]!["photo_list"],
                    ),
                    AppTextBold(
                      text: items[index]!["memory_name"],
                      size: 12,
                    ),
                  ],
                ),
              );
            });
  }
}

class MemoryThumbnail extends StatelessWidget {
  final bool isLoading;
  List<Map?> items = [];

  MemoryThumbnail({Key? key, required this.items, this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _widget = Column();
    if (items.length >= 4) {
      _widget = Container(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: const Border(
                            right: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                            bottom: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(items[0]!["file"]),
                          ))),
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: const Border(
                            bottom: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(items[1]!["file"]),
                          ))),
                ],
              ),
              Row(
                children: [
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: const Border(
                            right: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(items[2]!["file"]),
                          ))),
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(items[3]!["file"]),
                      ))),
                ],
              )
            ],
          ),
        ),
      );
    } else if (items.length == 3) {
      _widget = SizedBox(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: const Border(
                            right: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                            bottom: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(items[0]!["file"]),
                          ))),
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: const Border(
                            bottom: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(items[1]!["file"]),
                          ))),
                ],
              ),
              Row(
                children: [
                  Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(items[2]!["file"]),
                      ))),
                ],
              )
            ],
          ),
        ),
      );
    } else if (items.length == 2) {
      _widget = SizedBox(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width: 50,
                      height: 100,
                      decoration: BoxDecoration(
                          border: const Border(
                            right: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(items[0]!["file"]),
                          ))),
                  Container(
                      width: 50,
                      height: 100,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(items[1]!["file"]),
                      ))),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (items.length == 1) {
      _widget = SizedBox(
        height: 100,
        width: 100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(items[0]!["file"]),
            ),
          ),
        ),
      );
    }

    return _widget;
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
                        leading: IconButton(
                      alignment: Alignment.topLeft,
                      icon: Icon(
                        context.read<ViewHistoryProvider>().contains(index)
                            ? Icons.check_circle_outline_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color:
                            context.read<ViewHistoryProvider>().contains(index)
                                ? Colors.green
                                : Colors.black,
                      ),
                      onPressed: () {
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
                    )),
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
                          AppTextBold(
                            text: widget.items[index]!["display_name"],
                            size: 12,
                          ),
                        ],
                      ),
                    ));
              } else {
                return GridTile(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PresentFlower(
                            scannedImage: widget.items[index]!["file"],
                            comingFrom: "view_history",
                            flowerName: widget.items[index]!["flower_name"],
                            location: widget.items[index]!["location"])));
                  },
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
                      AppTextBold(
                        text: widget.items[index]!["display_name"],
                        size: 12,
                      ),
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
