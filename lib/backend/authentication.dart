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
      if (token != null) {
        final jwt = JWT.verify(token, SecretKey('awesomeblossom'));
        return jwt;
      } else {
        return null;
      }
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

  Future<String> forgetPassword(String email, String password) async {
    var db = await Database().connect();
    var usersCollection = db.collection('users');

    var salt10 = await FlutterBcrypt.saltWithRounds(rounds: 10);
    var hashedPassword =
        await FlutterBcrypt.hashPw(password: password, salt: salt10);

    var result = await usersCollection.modernFindAndModify(
        query: where.eq('email', email),
        update: ModifierBuilder().set('password', hashedPassword),
        returnNew: true);

    var user = result.value;

    db.close();
    return generateJWT(user!["username"].toString(), email);
  }

  Future<bool> changePassword(
      String email, String oldPassword, String newPassword) async {
    var db = await Database().connect();
    var usersCollection = db.collection('users');

    var salt10 = await FlutterBcrypt.saltWithRounds(rounds: 10);

    var hashedNewPassword =
        await FlutterBcrypt.hashPw(password: newPassword, salt: salt10);

    var user = await usersCollection.findOne(where.eq('email', email));

    if (user != null) {
      bool verify = await FlutterBcrypt.verify(
          password: oldPassword, hash: user['password']);
      if (verify) {
        var result = await usersCollection.updateOne(
          where.eq('email', email),
          ModifierBuilder().set('password', hashedNewPassword),
        );
        db.close();
        return true;
      }
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

    await collection.insert({
      "email": email,
      "username": username,
      "password": hashedPassword,
      "points": 0
    });

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
