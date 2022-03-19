import 'package:blossom/backend/points.dart';
import 'package:blossom/backend/vouchers.dart';
import 'package:blossom/components/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blossom/constants.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';

import 'backend/authentication.dart';

class RedeemVoucher extends StatefulWidget {
  const RedeemVoucher({Key? key}) : super(key: key);

  @override
  State<RedeemVoucher> createState() => _RedeemVoucherState();
}

class _RedeemVoucherState extends State<RedeemVoucher> {
  late String email;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    getEmail().then((value) {
      setState(() => email = value);
    });
  }

  Future<String> getEmail() async {
    final jwt = await Authentication.verifyJWT();
    if (jwt != null) {
      return jwt.payload["email"];
    } else {
      return "";
    }
  }

  Future<List?> getVouchers() async {
    return await Vouchers().getVouchers();
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    void _showSuccesssScreen(String code) {
      showDialog(
        context: context,
        //barrierDismissible: false,//user must tap button to dismiss
        builder: (_) => AlertDialog(
          title: const Text(
            "Congratulations",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  "Here's the code for your voucher ........",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SelectableText(
                  "\n$code",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                child: const Text("Use"),
                onPressed: () {
                  Navigator.pop(context, 'use');
                  //copy code to your clipboard
                  Clipboard.setData(new ClipboardData(text: code)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Voucher code copied to your clipboard !')));
                  });
                },
              ),
            )
          ],
          elevation: 24.0,
          //backgroundColor:
        ),
      );
    }

    void _showFailureScreen() {
      showDialog(
        context: context,
        //barrierDismissible: false,//user must tap button to dismiss
        builder: (_) => AlertDialog(
          title: const Text("Sorry"),
          content: const Text(
              "You don't have enough points to redeem this voucher."),
          actions: [
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.pop(context, 'Ok');
              },
            ),
          ],
          elevation: 24.0,
          //backgroundColor:
        ),
      );
    }

    Row VoucherTile(Map? voucher) {
      String voucherInfo = voucher!["voucher_info"];
      int points = voucher[
          "points"]; //get the number of points needed to redeem this voucher
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          //voucher image
          height: 60,
          width: 70,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                  "https://cdn-icons-png.flaticon.com/512/3210/3210036.png"),
            ),
          ),
        ),
        Center(
          //voucher info
          child: AppTextNormal(
            text: voucherInfo + "\n" + points.toString() + " points",
            size: 15,
          ),
        ),
        Center(
          //redeem button
          child: ElevatedButton(
            onPressed: () async {
              //total points >= points(voucher): can redeem
              bool canRedeem = await Points().checkEligible(email, points);
              // bool canRedeem = true;
              if (canRedeem) {
                showDialog(
                  context: context,
                  //barrierDismissible: false,//user must tap button to dismiss
                  builder: (_) => AlertDialog(
                    title: const Text("Confirm"),
                    content: Text(points.toString() +
                        " points will be deducted from your account if you confirm to redeem $voucherInfo"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                      ),
                      TextButton(
                        child: const Text("Confirm to Redeem"),
                        onPressed: () async {
                          //redeem voucher code: deduct points; -> my voucher list;
                          DateTime now = DateTime.now();
                          var format = DateFormat.yMMMMd('en_SG');
                          String dateString = format.format(now);
                          String code = getRandomString(8);
                          await Points().removePoints(email, points);
                          await Vouchers().redeemVoucher(
                              email, voucherInfo, dateString, code);
                          Navigator.pop(context, 'Redeem');
                          _showSuccesssScreen(code);
                        },
                      ),
                    ],
                    elevation: 24.0,
                    //backgroundColor:
                  ),
                );
              } else {
                _showFailureScreen();
              }
            },
            child: const Text('Redeem'),
            style: ElevatedButton.styleFrom(
              primary: kButtonColor1, // Background color
              onPrimary: Colors.white, // Text Color (Foreground color)
            ),
          ),
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: getVouchers(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            List? vouchers = snapshot.data as List?;
            return Container(
              padding: const EdgeInsets.all(30),
              child: ListView.builder(
                  itemCount: vouchers!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 90,
                      child: VoucherTile(vouchers[index]),
                    );
                  }),
            );
          } else {
            return Row();
          }
        },
      ),
    );
  }
}
