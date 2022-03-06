import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blossom/backend/database.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path_provider/path_provider.dart';

class Flower {
  Future<Map?> getFlower(String flower_name) async {
    var db = await Database().connect();
    var flowersCollection = db.collection('flower_database');
    var flower = await flowersCollection.findOne(where.eq('flower_name', flower_name));

    db.close();
    if (flower != null) {
      return flower;
    } else {
      return null;
    }
  }

  Future<Map?> saveFlowerPhoto(final file, String flower_name, String email) async {
    var db = await Database().connect();
    var scannedHistory = db.collection('user_scanned_history');
    var flowersCollection = db.collection('flower_database');

    var inputStream = File(file!.path).openRead();
    var filename = file.path.split("/").last;

    GridFS gridFS = GridFS(db,"scanned_photos");
    GridIn input = gridFS.createFile(inputStream, filename);

    await input.save();

    await flowersCollection.updateOne(where.eq('flower_name', flower_name), ModifierBuilder().inc('num_scans', 1));

    var flower = await flowersCollection.findOne(where.eq('flower_name', flower_name));

    var res = await scannedHistory.insert({"email": email, "display_name": flower!["display_name"], "filename": filename});

    db.close();

    return res;
  }
  
  Future<List<Map?>> getUserHistory(String email) async {
    var db = await Database().connect();
    var scannedHistory = db.collection('user_scanned_history');
    GridFS gridFS = GridFS(db,"scanned_photos");
    final Directory directory = await getTemporaryDirectory();

    List<Map?> userHistory = [];
    var histories = await scannedHistory.find(where.eq('email', email)).toList();

    for(var history in histories){
          var gridOut = await gridFS.findOne(where.eq('filename', history["filename"]));
          File image = File(directory.path + "/" + history["filename"]);
          await gridOut?.writeToFile(image);
          userHistory.add({
            "flower_name": history["display_name"],
            "file": image,
          });
     }

    db.close();

    return userHistory;
  }
  
}
