import 'package:blossom/backend/database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'dart:async';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:flutter/services.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  String generateJWT(String username, String email) {
    final jwt = JWT({
      "alg": "HS256",
      "typ": "JWT",
      "username": username,
      "email": email,
      "iat": DateTime.now().millisecondsSinceEpoch,
      "exp": DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch
    });

    final token = jwt.sign(SecretKey('awesomeblossom'));
    return token;
  }

  static Future<JWT?> verifyJWT() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt');

    try {

      final jwt = JWT.verify(token!, SecretKey('awesomeblossom'));
      return jwt;
    } on JWTExpiredError {

      await prefs.remove('jwt');
      return null;
    } on JWTError catch (ex) {

      await prefs.remove('jwt');
      return null;
    }
  }

  static Future<bool> checkUserExist(String email) async {
    var db = await Database().connect();
    var collection = db.collection('users');

    var user = await collection.findOne(where.eq('email', email));

    db.close();

    if (user != null) {
      return true;
    }

    return false;
  }

  Future<String> register(
      String email, String password, String username) async {
    var db = await Database().connect();
    var collection = db.collection('users');

    var salt10 = await FlutterBcrypt.saltWithRounds(rounds: 10);
    var hashedPassword =
        await FlutterBcrypt.hashPw(password: password, salt: salt10);

    await collection.insert(
        {"email": email, "username": username, "password": hashedPassword});

    db.close();
    return generateJWT(username, email);
  }

  Future<String> login(String email, String password) async {
    var db = await Database().connect();
    var usersCollection = db.collection('users');

    String output = "";

    var user = await usersCollection.findOne(where.eq('email', email));

    if (user != null) {
      bool result = await FlutterBcrypt.verify(
          password: password, hash: user['password']);
      if (result) {
        output = generateJWT(user["username"], email);
      } else {
        // Password is wrong
        output = "WrongPassword";
      }
    } else {
      // User not found
      output = "UserNotFound";
    }

    db.close();

    return output;
  }
}
