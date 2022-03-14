import 'package:blossom/backend/authentication.dart';
import 'package:blossom/splash/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? accountName = "";
  var pointNumber = 40; //get user's number of points
  String? emailAddress = ""; //get user's email address

  @override
  void initState() {
    super.initState();
    getAccountInfo().then(((accountInfo) {
      setState(() {
        accountName = accountInfo["username"];
        emailAddress = accountInfo["email"];
      });
    }));
  }

  Future<Map<String, String>> getAccountInfo() async {
    final jwt = await Authentication.verifyJWT();
    Map<String, String> accountInfo = {
      "username": jwt!.payload["username"],
      "email": jwt.payload["email"]
    };
    return accountInfo;
  }

  @override
  Widget build(BuildContext context) {
    Widget profileSection = Container(
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
                  size: 60,
                ), //profile photo
                Text(
                  accountName!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ]),
              Container(
                child: Column(
                  children: [
                    const Text("My Points"),
                    Text(
                      pointNumber.toString() + " pts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              const Text(
                "Email: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                emailAddress!,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          )
        ],
      ),
    );

    Row MyVoucherTile(int index) {
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
          child: Text(voucherCode),
        ),
      ]);
    }

    Widget voucherSection = Container(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Align(
            //to make text in column left-aligned
            alignment: Alignment.centerLeft,
            child: Container(
              child: const Text(
                "My Vouchers",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 100,
                    child: MyVoucherTile(index),
                  );
                }),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context,
                    'RedeemVoucher'); // Respond to button press: go to Redeem Voucher page
              },
              child: const Text('Redeem More >'),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final success = await prefs.remove('jwt');
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  (Route<dynamic> route) => false);
            },
          )
        ],
      ),
      body: Column(children: [
        profileSection,
        Expanded(child: voucherSection),
      ]),
    );
  }
}
