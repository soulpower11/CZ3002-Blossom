import 'package:blossom/backend/database.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Flower {
  Future<Map?> getFlower(String flower_name) async {
    var db = await Database().connect();
    var flowersCollection = db.collection('flower_database');
    var flower = await flowersCollection.findOne(where.eq('flower_name', flower_name));

    if (flower != null) {
      return flower;
    } else {
      return null;
    }
  }
}
