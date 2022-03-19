import 'package:blossom/backend/database.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'dart:async';

class Vouchers {
  Future<void> redeemVoucher(
      String email, String voucher_info, String date, String code) async {
    var db = await Database().connect();
    var userVoucher = db.collection('user_voucher');

    var update = await userVoucher.updateOne(
        where.eq('email', email),
        ModifierBuilder().addToSet('vouchers',
            {"voucher_info": voucher_info, "date": date, "code": code}));

    if (update.isFailure) {
      await userVoucher.insert({
        "email": email,
        "vouchers": [
          {"voucher_info": voucher_info, "date": date, "code": code}
        ]
      });
    }

    db.close();
  }

  Future<List?> getUserVouchers(String email) async {
    var db = await Database().connect();
    var userVoucher = db.collection('user_voucher');

    var vouchers = await userVoucher.findOne(where.eq('email', email));

    db.close();

    if (vouchers != null) {
      return vouchers["vouchers"];
    }

    return [];
  }

  Future<List?> getVouchers() async {
    var db = await Database().connect();
    var vouchers = db.collection('vouchers');

    var vouchersList = await vouchers.find().toList();

    db.close();

    return vouchersList;
  }
}
