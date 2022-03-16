import 'package:blossom/components/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blossom/constants.dart';

class RedeemVoucher extends StatefulWidget {
  const RedeemVoucher({Key? key}) : super(key: key);

  @override
  State<RedeemVoucher> createState() => _RedeemVoucherState();
}

class _RedeemVoucherState extends State<RedeemVoucher> {
  @override
  Widget build(BuildContext context) {
    void _showSuccesssScreen() {
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
              children: const <Widget>[
                Text(
                  "Here's the code for your voucher ........",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SelectableText(
                  '\nSampleVoucherCode',
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
                  Clipboard.setData(
                          new ClipboardData(text: "SampleVoucherCode"))
                      .then((_) {
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

    Row VoucherTile(int index) {
      int points = 2; //get the number of points needed to redeem this voucher
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          //voucher image
          height: 60,
          width: 70,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage("https://picsum.photos/250?image=9"),
            ),
          ),
        ),
        Center(
          //voucher info
          child: AppTextNormal(
            text: "Voucher " +
                (index + 1).toString() +
                " info\n" +
                points.toString() +
                " points",
            size: 15,
          ),
        ),
        Center(
          //redeem button
          child: ElevatedButton(
            onPressed: () {
              //total points >= points(voucher): can redeem
              bool canRedeem = true;
              if (canRedeem) {
                showDialog(
                  context: context,
                  //barrierDismissible: false,//user must tap button to dismiss
                  builder: (_) => AlertDialog(
                    title: const Text("Confirm"),
                    content: Text(points.toString() +
                        " points will be deducted from your account if you confirm to redeem Voucher xxx"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                      ),
                      TextButton(
                        child: const Text("Confirm to Redeem"),
                        onPressed: () {
                          //redeem voucher code: deduct points; -> my voucher list;
                          Navigator.pop(context, 'Redeem');
                          _showSuccesssScreen();
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
      body: Container(
        padding: const EdgeInsets.all(30),
        child: ListView.builder(
            itemCount: 15,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 90,
                child: VoucherTile(index),
              );
            }),
      ),
    );
  }
}
