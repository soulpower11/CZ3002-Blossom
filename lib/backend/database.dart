import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
class Database {
    Future<Db> connect() async {
      await dotenv.load(fileName: ".env");
      String mongoUri = dotenv.get('MONGO_URI');
      var db = await Db.create(mongoUri);
      await db.open();
      return db;
    }
}
