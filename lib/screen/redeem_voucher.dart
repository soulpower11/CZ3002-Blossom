import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/points.dart';
import 'package:blossom/backend/vouchers.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import 'package:blossom/screen/dashboard.dart';
import 'package:blossom/screen/home.dart';

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
          title: Text(
            "Congratulations",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                    fontSize: 18,
                    color: kTextColor,
                    fontWeight: FontWeight.bold)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  "Here's the code for your voucher ........",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: kTextColor,
                          fontWeight: FontWeight.w400)),
                ),
                SelectableText(
                  "\n$code",
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          fontSize: 18,
                          color: kTextColor,
                          fontWeight: FontWeight.w400)),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                child: AppTextBold(text: "Use", size: 14, color: Colors.white),
                style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 141, 6, 63),
                    fixedSize: const Size(100, 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context, 'use');
                  //copy code to your clipboard
                  Clipboard.setData(new ClipboardData(text: code)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(milliseconds: 1000),
                        content: AppTextNormal(
                            text: 'Voucher code copied to your clipboard !',
                            color: Colors.white,
                            size: 14),
                        margin: const EdgeInsets.only(
                          bottom: 30,
                          left: 14,
                          right: 14,
                        )));
                    Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              LandingPage(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                        (Route<dynamic> route) => false);
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
          title: AppTextBold(text: "Sorry", size: 18),
          content: AppTextNormal(
            text: "You don't have enough points to redeem this voucher.",
            size: 16,
          ),
          actions: [
            TextButton(
              child: AppTextNormal(
                text: "Ok",
                size: 14,
                color: Colors.blue,
              ),
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
                    title: AppTextBold(
                      text: "Confirm",
                      size: 18,
                    ),
                    content: AppTextNormal(
                        size: 14,
                        text: points.toString() +
                            " points will be deducted from your account if you confirm to redeem $voucherInfo"),
                    actions: [
                      TextButton(
                        child: AppTextNormal(
                          text: 'Cancel',
                          size: 14,
                          color: Colors.blue,
                        ),
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                      ),
                      TextButton(
                        child: AppTextNormal(
                          text: "Confirm to Redeem",
                          size: 14,
                          color: Colors.blue,
                        ),
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
            child: AppTextBold(text: 'Redeem', size: 14, color: Colors.white),
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
            return Container(
              padding: const EdgeInsets.all(30),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.grey[300],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Dashboard(),
    );
  }
}
