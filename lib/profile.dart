import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/points.dart';
import 'package:blossom/backend/vouchers.dart';
import 'package:blossom/redeem_voucher.dart';
import 'package:blossom/splash/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
  }

  Future<Map?> getAccountInfo() async {
    final jwt = await Authentication.verifyJWT();
    int points = await Points().getPoints(jwt!.payload["email"]);
    List? vouchers = await Vouchers().getUserVouchers(jwt.payload["email"]);
    Map? accountInfo = {
      "username": jwt.payload["username"],
      "email": jwt.payload["email"],
      "points": points
      "vouchers": vouchers
    };
    return accountInfo;
  }

  @override
  Widget build(BuildContext context) {
    
    Widget profileSection(String accountName, int pointNumber, String emailAddress) {
      
      return Container(
      padding: const EdgeInsets.all(30.0),
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 70,
                  color: kTextColor,
                ), //profile photo
                AppTextBold(
                  text: accountName,
                  size: 35,
                ),
              ]),
              Container(
                child: Column(
                  children: [
                    AppTextNormal(text: "My Points", size: 17),
                    AppTextBold(
                      text: pointNumber.toString() + " pts",
                      size: 30,
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              AppTextBold(
                text: "Email: ",
                size: 20,
              ),
              AppTextNormal(
                text: emailAddress,
                size: 20,
              ),
            ],
          )
        ],
      ),
    );
    }

    Row MyVoucherTile(Map? voucher) {
      int points = 2; //get the number of points needed to redeem this voucher
      String voucherCode = "SampleVoucherCode"; //get the code of this voucher
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          //voucher image
          height: 60,
          width: 70,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage("https://cdn-icons-png.flaticon.com/512/3210/3210036.png"),
            ),
          ),
        ),
        const SizedBox(width: 10), //add spacing
        Center(
          //voucher info
          child: AppTextNormal(
            text:
                voucher!["voucher_info"] +
                "\n" +
                voucher["date"],
            size: 15,
          ),
        ),
        const SizedBox(width: 10),
        //vouchercode
        ////Center(
        //child:
        Expanded(
          child: SelectableText(
            voucher["code"],
            style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                    fontSize: 15,
                    color: kTextColor,
                    fontWeight: FontWeight.w400)),
          ), //selectable so that user can copy the code ,)
        ),
        //),
      ]);
    }

    Widget voucherSection(List? vouchers) {

    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Align(
            //to make text in column left-aligned
            alignment: Alignment.centerLeft,
            child: AppTextBold(
              text: "My Vouchers",
              size: 20,
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: vouchers!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 100,
                    child: MyVoucherTile(vouchers[index]),
                  );
                }),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RedeemVoucher()),
                ); // Respond to button press: go to Redeem Voucher page
              },
              child: const Text('Redeem More >'),
              style: ElevatedButton.styleFrom(
                primary: kButtonColor1, // Background color
                onPrimary: Colors.white, // Text Color (Foreground color)
              ),
            ),
          ),
        ],
      ),
    );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: () {
              showDialog(
                context: context,
                //barrierDismissible: false,//user must tap button to dismiss
                builder: (_) => AlertDialog(
                  title: const Text("Confirm"),
                  content: const Text('Confirm to log out?'),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                    ),
                    TextButton(
                      child: const Text("Confirm to log out"),
                      onPressed: () async {
                        //log out
                        final prefs = await SharedPreferences.getInstance();
                        final success = await prefs.remove('jwt');
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => WelcomeScreen()),
                            (Route<dynamic> route) => false);
                      },
                    ),
                  ],
                  elevation: 24.0,
                  //backgroundColor:
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: getAccountInfo(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            Map? accountInfo = snapshot.data as Map?;
            String accountName = accountInfo!["username"];
            String emailAddress = accountInfo["email"];
            int pointNumber = accountInfo["points"];
            List? vouchers = accountInfo["vouchers"];
            return Column(children: [
              profileSection(accountName, pointNumber, emailAddress),
              Expanded(child: voucherSection(vouchers)),
            ]);
          } else {
            return Row();
          }
        },
      ),
    );
  }
}
