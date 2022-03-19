import 'package:blossom/backend/database.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'dart:async';

class Points {
  Future<void> addPoints(String email, int points) async {
    var db = await Database().connect();
    var users = db.collection('users');

    await users.updateOne(
        where.eq('email', email), ModifierBuilder().inc('points', points));

    db.close();
  }

  Future<bool> removePoints(String email, int points) async {
    var db = await Database().connect();
    var users = db.collection('users');

    var user = await users.findOne(where.eq('email', email));
    if (user != null) {
      if (user["points"] >= points) {
        await users.updateOne(
            where.eq('email', email), ModifierBuilder().inc('points', -points));
        db.close();

        return true;
      }
    }
    return false;
  }

  Future<bool> checkEligible(String email, int points) async {
    var db = await Database().connect();
    var users = db.collection('users');

    var user = await users.findOne(where.eq('email', email));
    if (user != null) {
      if (user["points"] >= points) {
        return true;
      }
    }
    return false;
  }


  Future<int> getPoints(String email) async {
    var db = await Database().connect();
    var users = db.collection('users');

    var user = await users.findOne(where.eq('email', email));

    db.close();

    if (user != null) {
      return user["points"];
    }

    return -1;
  }
}
