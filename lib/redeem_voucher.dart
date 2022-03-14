import 'package:flutter/material.dart';

class RedeemVoucher extends StatefulWidget {
  const RedeemVoucher({Key? key}) : super(key: key);

  @override
  State<RedeemVoucher> createState() => _RedeemVoucherState();
}

class _RedeemVoucherState extends State<RedeemVoucher> {
  @override
  Widget build(BuildContext context) {
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
          child: Text("Voucher " +
              (index + 1).toString() +
              " info\n" +
              points.toString() +
              " points"),
        ),
        Center(
          //redeem button
          child: ElevatedButton(
            onPressed: () {
              // Respond to button press
            },
            child: const Text('Redeem'),
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
              return Container(
                height: 90,
                child: VoucherTile(index),
              );
            }),
      ),
    );
  }
}
