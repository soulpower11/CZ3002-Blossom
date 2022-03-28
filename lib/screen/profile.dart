import 'package:blossom/backend/authentication.dart';
import 'package:blossom/backend/points.dart';
import 'package:blossom/backend/vouchers.dart';
import 'package:blossom/components/constants.dart';
import 'package:blossom/providers/userinfo_provider.dart';
import 'package:blossom/screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blossom/components/app_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:blossom/screen/dashboard.dart';
import 'package:blossom/screen/forgot_password_change.dart';
import 'package:blossom/screen/redeem_voucher.dart';

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

  // Future<Map?> getAccountInfo() async {
  //   final jwt = await Authentication.verifyJWT();
  //   int points = await Points().getPoints(jwt!.payload["email"]);
  //   List? vouchers = await Vouchers().getUserVouchers(jwt.payload["email"]);
  //   Map? accountInfo = {
  //     "username": jwt.payload["username"],
  //     "email": jwt.payload["email"],
  //     "points": points
  //     "vouchers": vouchers
  //   };
  //   return accountInfo;
  // }

  Future<List?> getVouchers() async {
    final jwt = await Authentication.verifyJWT();
    List? vouchers = await Vouchers().getUserVouchers(jwt!.payload["email"]);

    return vouchers;
  }

  Future<int> getPoints() async {
    final jwt = await Authentication.verifyJWT();
    int points = await Points().getPoints(jwt!.payload["email"]);

    return points;
  }

  @override
  Widget build(BuildContext context) {
    Widget profileSection() {
      var accountName = context.watch<UserInfoProvider>().username;
      var emailAddress = context.watch<UserInfoProvider>().email;

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
                    size: 60,
                    color: kTextColor,
                  ), //profile photo
                  AppTextBold(
                    text: accountName,
                    size: 28,
                  ),
                ]),
                Container(
                  child: Column(
                    children: [
                      AppTextNormal(text: "My Points", size: 14),
                      FutureBuilder(
                        future: getPoints(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            int? pointNumber = snapshot.data as int?;
                            return AppTextBold(
                              text: pointNumber.toString() + " pts",
                              size: 22,
                            );
                          } else {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 29,
                                width: 100.0,
                                color: Colors.grey[300],
                              ),
                            );
                          }
                        },
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
                  size: 18,
                ),
                AppTextNormal(
                  text: emailAddress,
                  size: 18,
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
              image: NetworkImage(
                  "https://cdn-icons-png.flaticon.com/512/3210/3210036.png"),
            ),
          ),
        ),
        const SizedBox(width: 10), //add spacing
        Center(
          //voucher info
          child: AppTextNormal(
            text: voucher!["voucher_info"] + "\n" + voucher["date"],
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

    Widget voucherSection() {
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
              child: FutureBuilder(
                future: getVouchers(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    List? vouchers = snapshot.data as List?;
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: vouchers!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 100,
                            child: MyVoucherTile(vouchers[index]),
                          );
                        });
                  } else {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 100.0,
                        color: Colors.grey[300],
                      ),
                    );
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          RedeemVoucher(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const RedeemVoucher()),
                  // ); // Respond to button press: go to Redeem Voucher page
                },
                child: AppTextBold(
                    text: 'Redeem More >', size: 14, color: Colors.white),
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
            tooltip: "Change Password",
            icon: Icon(
              Icons.manage_accounts_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const ForgetChangeScreen(
                    comingForm: 'Change Password',
                    email: '',
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded),
            tooltip: "Logout",
            onPressed: () {
              showDialog(
                context: context,
                //barrierDismissible: false,//user must tap button to dismiss
                builder: (_) => AlertDialog(
                  title: AppTextBold(
                    text: "Confirm",
                    size: 18,
                  ),
                  content: AppTextNormal(
                    text: 'Confirm to log out?',
                    size: 16,
                  ),
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
                        text: "Confirm to log out",
                        size: 14,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        //log out
                        final prefs = await SharedPreferences.getInstance();
                        final success = await prefs.remove('jwt');
                        context.read<UserInfoProvider>().setUsername("");
                        context.read<UserInfoProvider>().setEmail("");
                        // Navigator.of(context).pushAndRemoveUntil(
                        //     PageRouteBuilder(
                        //       pageBuilder: (context, animation1, animation2) =>
                        //           WelcomeScreen(),
                        //       transitionDuration: Duration.zero,
                        //       reverseTransitionDuration: Duration.zero,
                        //     ),
                        //     (Route<dynamic> route) => false);
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
          ),
        ],
      ),
      body: Column(children: [
        profileSection(),
        Expanded(child: voucherSection()),
      ]),
      bottomNavigationBar: Dashboard(),
    );
  }
}
