import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blossom/backend/database.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geocoding/geocoding.dart';

class Flower {
  Future<Map?> getFlower(String flower_name) async {
    var db = await Database().connect();
    var flowersCollection = db.collection('flower_database');
    var flower =
        await flowersCollection.findOne(where.eq('flower_name', flower_name));

    db.close();
    if (flower != null) {
      return flower;
    } else {
      return null;
    }
  }

  Future<File> getStockFlowerImage(String flower_name) async {
    var db = await Database().connect();
    GridFS gridFS = GridFS(db, "stock_flower_image");

    final Directory directory = await getTemporaryDirectory();

    String filename = flower_name + ".jpg";

    var gridOut = await gridFS.findOne(where.eq('filename', filename));
    File image = File(directory.path + "/" + filename);
    // await gridOut?.writeToFile(image);
    if (!await image.exists()) {
      await gridOut?.writeToFile(image);
    }
    db.close();

    return image;
  }

  Future<Map?> saveFlowerPhoto(final file, String flower_name, String email,
      double lat, double long) async {
    var db = await Database().connect();
    var scannedHistory = db.collection('user_scanned_history');
    var flowersCollection = db.collection('flower_database');

    var inputStream = File(file!.path).openRead();
    var filename = file.path.split("/").last;

    GridFS gridFS = GridFS(db, "scanned_photos");
    GridIn input = gridFS.createFile(inputStream, filename);

    await input.save();

    await flowersCollection.updateOne(where.eq('flower_name', flower_name),
        ModifierBuilder().inc('num_scans', 1));

    var flower =
        await flowersCollection.findOne(where.eq('flower_name', flower_name));
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

    var res = await scannedHistory.insert({
      "email": email,
      "display_name": flower!["display_name"],
      "flower_name": flower["flower_name"],
      "filename": filename,
      "location": placemarks[0].name,
    });

    db.close();

    return res;
  }

  Future<void> toggleFavourite(String flower_name, String display_name,
      String email, bool favourite) async {
    var db = await Database().connect();
    var favouritedFlowers = db.collection('user_favourited_flower');

    var flower = await favouritedFlowers.updateOne(
        where.eq('flower_name', flower_name).eq('email', email),
        ModifierBuilder().set('favourited', favourite));

    if (flower.nMatched == 0) {
      await favouritedFlowers.insert({
        "flower_name": flower_name,
        "display_name": display_name,
        "email": email,
        "favourited": favourite
      });
    }
    db.close();
  }

  Future<bool> getOneFavourite(String flower_name, String email) async {
    var db = await Database().connect();
    var favouritedFlowers = db.collection('user_favourited_flower');

    var flower = await favouritedFlowers
        .findOne(where.eq('flower_name', flower_name).eq('email', email));

    db.close();
    if (flower != null) {
      return flower["favourited"];
    } else {
      return false;
    }
  }

  Future<List<Map?>> getUserFavourites(String email) async {
    var db = await Database().connect();
    var favouritedFlowers = db.collection('user_favourited_flower');

    GridFS gridFS = GridFS(db, "stock_flower_image");
    final Directory directory = await getTemporaryDirectory();

    List<Map?> userFavourites = [];
    var favourites = await favouritedFlowers
        .find(where.eq('email', email).eq('favourited', true))
        .toList();

    for (var favourite in favourites) {
      var gridOut = await gridFS
          .findOne(where.eq('filename', favourite["flower_name"] + ".jpg"));
      File image = File(directory.path + "/" + favourite["flower_name"]);
      await gridOut?.writeToFile(image);
      userFavourites.add({
        "display_name": favourite["display_name"],
        "flower_name": favourite["flower_name"],
        "file": image,
      });
    }

    db.close();

    return userFavourites;
  }

  Future<List<Map?>> getUserHistory(String email) async {
    var db = await Database().connect();
    var scannedHistory = db.collection('user_scanned_history');
    GridFS gridFS = GridFS(db, "scanned_photos");
    final Directory directory = await getTemporaryDirectory();

    List<Map?> userHistory = [];
    var histories =
        await scannedHistory.find(where.eq('email', email)).toList();

    for (var history in histories) {
      var gridOut =
          await gridFS.findOne(where.eq('filename', history["filename"]));
      File image = File(directory.path + "/" + history["filename"]);
      if (!await image.exists()) {
        await gridOut?.writeToFile(image);
      }
      userHistory.add({
        "display_name": history["display_name"],
        "flower_name": history["flower_name"],
        "location": history["location"],
        "file": image,
      });
    }

    db.close();

    return userHistory;
  }

  Future<Map?> saveUserMemory(
      String email, String memoryName, List<Map?> photos) async {
    var db = await Database().connect();
    var collection = db.collection('user_memories');

    List<Map?> photo_list = [];

    for (int index = 0; index < photos.length; index++) {
      photo_list.add({
        "display_name": photos[index]!["display_name"],
        "flower_name": photos[index]!["flower_name"],
        "location": photos[index]!["location"],
        "filename": photos[index]!["file"].path.split("/").last,
      });
    }

    var res = await collection.insert({
      "email": email,
      "memory_name": memoryName,
      "photo_list": photo_list,
    });

    db.close();

    return res;
  }

  Future<List<Map?>> getUserMemory(String email) async {
    var db = await Database().connect();
    var collection = db.collection('user_memories');

    GridFS gridFS = GridFS(db, "scanned_photos");
    final Directory directory = await getTemporaryDirectory();

    List<Map?> userMemory = [];

    var memories = await collection.find(where.eq('email', email)).toList();

    for (var memory in memories) {
      List<Map?> memoryPhotos = [];
      for (int index = 0; index < memory["photo_list"].length; index++) {
        var gridOut = await gridFS.findOne(
            where.eq('filename', memory["photo_list"][index]["filename"]));

        File image = File(
            directory.path + "/" + memory["photo_list"][index]["filename"]);
        if (!await image.exists()) {
          await gridOut?.writeToFile(image);
        }
        // await gridOut?.writeToFile(image);

        memoryPhotos.add({
          "display_name": memory["photo_list"][index]["display_name"],
          "flower_name": memory["photo_list"][index]["flower_name"],
          "location": memory["photo_list"][index]["location"],
          "file": image,
        });
      }
      userMemory.add({
        "memory_name": memory["memory_name"],
        "photo_list": memoryPhotos,
      });
    }

    db.close();
    return userMemory;
  }

  Future<bool> checkMemoryExist(String email) async {
    var db = await Database().connect();
    var collection = db.collection('user_memories');

    var user = await collection.findOne(where.eq('email', email));

    db.close();

    if (user != null) {
      return true;
    }

    return false;
  }

  Future<String> getFlowerOfTheDay() async {
    var db = await Database().connect();
    var fod = db.collection('flower_of_the_day');

    var flower = await fod.find().toList();

    String flowerName = flower[0]["flower_name"];

    db.close();

    return flowerName;
  }
}
