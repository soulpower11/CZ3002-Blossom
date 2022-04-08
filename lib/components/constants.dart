import 'package:blossom/components/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color.fromRGBO(143, 32, 48, 1);
const kAccentColor = Colors.yellow;
const kPrimaryLightColor = Color.fromRGBO(87, 66, 54, 1);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
// const kTextColor = Color(0xFF757575);

const kTextColor = Color(0xDD303030);
const kTextLightColor = Color(0XFFBDBDBD);
const kDefaultPadding = 20.0;
const kBarColor = Color.fromARGB(255, 39, 44, 41);
const kButtonColor1 = Color.fromARGB(255, 143, 32, 49);
const kAppBrownColor = Color.fromARGB(255, 87, 66, 54);
const kAppPinkColor = Color.fromARGB(255, 255, 234, 234);

const kAnimationDuration = Duration(milliseconds: 200);

// final headingStyle = TextStyle(
//   fontSize: getProportionateScreenWidth(28),
//   fontWeight: FontWeight.bold,
//   color: Colors.black,
//   height: 1.5,
// );

final headingStyle = GoogleFonts.montserrat(
    textStyle: TextStyle(
        fontSize: getProportionateScreenWidth(28),
        fontWeight: FontWeight.bold,
        height: 1.5,
        color: Color(0xDD303030)));

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kUsernameNullError = "Please enter your username";
const String kEmailNullError = "Please enter your email";
const String kInvalidEmailError = "Please enter Valid Email";
const String kPassNullError = "Please enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please enter your name";
const String kPhoneNumberNullError = "Please enter your phone number";
const String kAddressNullError = "Please enter your address";
const String kWrongPassError = "Wrong password";
const String kUserNotFoundError = "User not found";
const String kUserExistError = "User already exist";
const String kShortOTPError = "OTP is too short";
const String kWrongOTPError = "OTP is wrong";
const String kOTPNullError = "Please enter OTP";
const String kOTPNotRequested = "Please request an OTP";
const String kWrongOldPassword = "Your old password is wrong";
const String kOldPassNullError = "Please enter your old password";
const String kNewPassNullError = "Please enter your new password";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}
