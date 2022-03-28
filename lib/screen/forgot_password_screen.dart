import 'dart:async';

import 'package:blossom/screen/forgot_password_change.dart';
import 'package:blossom/backend/authentication.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/components/constants.dart';
import 'package:blossom/components/form_error.dart';
import 'package:blossom/components/no_account_text.dart';
import 'package:blossom/components/rounded_button.dart';
import 'package:blossom/components/size_config.dart';
import 'package:blossom/config/auth.config.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => ForgotPasswordScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        // title: Text("Forgot Password", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.lightBlue[50],
      ),
      backgroundColor: Colors.lightBlue[50],
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight! * 0.04),
                Padding(
                  padding: EdgeInsets.only(left: 0, right: 70, top: 10),
                  child: AppTextBold(
                    text: "Forgot Password",
                    size: getProportionateScreenWidth(28),
                  ),
                ),
                SizedBox(height: SizeConfig.screenHeight! * 0.03),
                const Divider(
                  height: 2,
                  indent: 2,
                  endIndent: 0,
                  color: Colors.black,
                ),

                //SizedBox(height: SizeConfig.screenHeight * 0.01),
                // Text(
                //   "Please enter your email and we will send \nyou a link to return to your account",
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: 50),
                ForgotPassForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPassForm extends StatefulWidget {
  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> errors = [];
  late String email;
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  late EmailAuth emailAuth;
  bool OTPsent = false;
  bool timerStart = false;

  late Timer _timer;
  int _start = 100;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            timerStart = false;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error!);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the package
    emailAuth = new EmailAuth(
      sessionName: "Blossom",
    );

    /// Configuring the remote server
    emailAuth.config(remoteServerConfiguration);
  }

  void sendOtp(String email) async {
    bool result = await emailAuth.sendOtp(recipientMail: email, otpLength: 5);
    if (result) {
      // using a void function because i am using a
      // stateful widget and seting the state from here.
      setState(() {
        OTPsent = true;
        timerStart = true;
      });
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue!,
            onChanged: (value) {
              removeError(error: kUserNotFoundError);
              if (value.isNotEmpty) {
                removeError(error: kEmailNullError);
              } else if (emailValidatorRegExp.hasMatch(value)) {
                removeError(error: kInvalidEmailError);
              }
              return null;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kEmailNullError);
                return "";
              } else if (!emailValidatorRegExp.hasMatch(value)) {
                addError(error: kInvalidEmailError);
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              //labelText: "Email",
              hintText: "Enter your email",
              hintStyle: GoogleFonts.montserrat(
                  textStyle: TextStyle(color: Colors.black38)),
              fillColor: Colors.white, filled: true,
              //fillColor: Color(0xFFFFC61F), filled: none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Colors.black12,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 143, 32, 49),
                  width: 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 143, 32, 49),
                ),
              ),
              labelStyle: TextStyle(
                color: Color(0xFF212121),
              ),

              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(30)),
          TextFormField(
            controller: otpController,
            onChanged: (value) {
              if (OTPsent) {
                if (value.isNotEmpty && errors.contains(kOTPNullError)) {
                  removeError(error: kOTPNullError);
                } else if (value.length == 5) {
                  removeError(error: kShortOTPError);
                }
                removeError(error: kWrongOTPError);
              }
            },
            validator: (value) {
              if (OTPsent) {
                if (value!.isEmpty) {
                  addError(error: kOTPNullError);
                  return "";
                } else if (value.length < 5) {
                  addError(error: kShortOTPError);
                  return "";
                }
              }
              return null;
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(5),
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter OTP",
              hintStyle: GoogleFonts.montserrat(
                  textStyle: TextStyle(color: Colors.black38)),
              fillColor: Colors.white,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Colors.black12,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 143, 32, 49),
                  width: 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 143, 32, 49),
                ),
              ),
              labelStyle: TextStyle(
                color: Color(0xFF212121),
              ),
              suffixIcon: TextButton(
                child: Text(
                  timerStart ? "Resend in ($_start)" : "Request OTP",
                ),
                onPressed: timerStart
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          // Do what you want to do
                          if (!timerStart) {
                            bool exist = await Authentication.checkUserExist(
                                emailController.text);
                            if (exist) {
                              sendOtp(emailController.text);
                            } else {
                              addError(error: kUserNotFoundError);
                            }
                          }
                        }
                      },
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          // SizedBox(height: getProportionateScreenHeight(50)),
          FormError(errors: errors),
          SizedBox(height: SizeConfig.screenHeight! * 0.25),
          Padding(
            padding: EdgeInsets.only(left: 150, bottom: 10, right: 40, top: 10),
            child: RoundedButton(
              text: "Continue",
              press: () async {
                if (_formKey.currentState!.validate()) {
                  // Do what you want to do
                  // bool exist =
                  //     await Authentication.checkUserExist(emailController.text);
                  // if (exist) {
                  //   sendOtp(emailController.text);
                  // } else {}
                  if (OTPsent) {
                    if (emailAuth.validateOtp(
                        recipientMail: emailController.value.text,
                        userOtp: otpController.value.text)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetChangeScreen(
                                  email: emailController.value.text,
                                  comingForm: "Forget Password",
                                )),
                      );
                    } else {
                      addError(error: kWrongOTPError);
                    }
                  } else {
                    addError(error: kOTPNotRequested);
                  }
                }
              },
            ),
          ),
          SizedBox(height: 60),
          Padding(
            padding: EdgeInsets.only(left: 0, right: 50, top: 10),
            child: NoAccountText(),
          ),
        ],
      ),
    );
  }
}
