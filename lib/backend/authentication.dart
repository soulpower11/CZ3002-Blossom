import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'dart:async';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:flutter/services.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Authentication {
  Future<Db> connect() async {
    await dotenv.load(fileName: ".env");
    String mongoUri = dotenv.get('MONGO_URI');
    var db = await Db.create(mongoUri);
    await db.open();
    return db;
  }

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

  Future<String> register(
      String email, String password, String username) async {
    var db = await connect();
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
    var db = await connect();
    var usersCollection = db.collection('users');

    String output = "";

    usersCollection.findOne(where.eq('email', email)).then((user) async {
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
    });

    db.close();
    return output;
  }
}
