import 'package:blossom/backend/authentication.dart';
import 'package:blossom/components/app_text.dart';
import 'package:blossom/components/constants.dart';
import 'package:blossom/components/form_error.dart';
import 'package:blossom/components/rounded_button.dart';
import 'package:blossom/providers/userinfo_provider.dart';
import 'package:blossom/screen/welcome_screen.dart';
import 'home.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetChangeScreen extends StatelessWidget {
  final String email;
  final String comingForm;

  const ForgetChangeScreen(
      {Key? key, required this.email, required this.comingForm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double getProportionateScreenHeight(double inputHeight) {
      return (inputHeight / 812.0) * screenHeight;
    }

    double getProportionateScreenWidth(double inputWidth) {
      return (inputWidth / 375.0) * screenWidth;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.lightBlue[50],
      ),
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.03), // 4%
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 60, top: 10),
                    child: AppTextBold(size: 30, text: "Change Password"),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  const Divider(
                    height: 2,
                    indent: 2,
                    endIndent: 0,
                    color: Colors.black,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ForgetChangePassForm(
                    email: email,
                    comingForm: comingForm,
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  SizedBox(height: getProportionateScreenHeight(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgetChangePassForm extends StatefulWidget {
  final String email;
  final String comingForm;

  const ForgetChangePassForm(
      {Key? key, required this.email, required this.comingForm})
      : super(key: key);

  @override
  _ForgetChangePassFormState createState() => _ForgetChangePassFormState();
}

class _ForgetChangePassFormState extends State<ForgetChangePassForm> {
  final _formKey = GlobalKey<FormState>();
  late String password;
  late String conform_password;
  late String oldPassword;
  final List<String> errors = [];

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error!);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double getProportionateScreenHeight(double inputHeight) {
      return (inputHeight / 812.0) * screenHeight;
    }

    double getProportionateScreenWidth(double inputWidth) {
      return (inputWidth / 375.0) * screenWidth;
    }

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            widget.comingForm != "Forget Password"
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 0, bottom: 20, right: 190),
                    //apply padding horizontal or vertical only
                    child: AppTextBold(size: 18, text: "OLD PASSWORD"),
                  )
                : Row(),
            widget.comingForm != "Forget Password"
                ? buildOldPasswordFormField()
                : Row(),
            widget.comingForm != "Forget Password"
                ? SizedBox(height: getProportionateScreenHeight(20))
                : Row(),
            widget.comingForm != "Forget Password"
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 0, bottom: 20, right: 180),
                    //apply padding horizontal or vertical only
                    child: AppTextBold(size: 18, text: "NEW PASSWORD"),
                  )
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 0, bottom: 20, right: 220),
                    //apply padding horizontal or vertical only
                    child: AppTextBold(size: 18, text: "PASSWORD"),
                  ),
            buildPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(20)),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 20, right: 130),
              //apply padding horizontal or vertical only
              child: AppTextBold(size: 18, text: "CONFIRM PASSWORD"),
            ),
            buildConformPassFormField(),
            FormError(errors: errors),
            SizedBox(height: getProportionateScreenHeight(50)),
            Padding(
              padding: const EdgeInsets.only(
                  left: 150, bottom: 10, right: 40, top: 10),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: screenWidth * 0.6,
                height: getProportionateScreenHeight(56),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState?.save();
                        if (widget.comingForm == "Forget Password") {
                          final result = await Authentication().forgetPassword(
                              widget.email, passwordController.text);
                          // Obtain shared preferences.
                          final prefs = await SharedPreferences.getInstance();
                          // Save an String value to 'action' key.
                          await prefs.setString('jwt', result);
                          JWT? jwt = await Authentication.verifyJWT();
                          context
                              .read<UserInfoProvider>()
                              .setUsername(jwt!.payload["username"]);
                          context
                              .read<UserInfoProvider>()
                              .setEmail(jwt.payload["email"]);

                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const LandingPage()),
                              (Route<dynamic> route) => false);
                          // Navigator.of(context).pushAndRemoveUntil(
                          //     PageRouteBuilder(
                          //       pageBuilder: (context, animation1, animation2) =>
                          //           WelcomeScreen(),
                          //       transitionDuration: Duration.zero,
                          //       reverseTransitionDuration: Duration.zero,
                          //     ),
                          //     (Route<dynamic> route) => false);
                        } else {
                          final jwt = await Authentication.verifyJWT();
                          var emailAddress = jwt!.payload["email"];

                          final result = await Authentication().changePassword(
                              emailAddress,
                              oldPasswordController.text,
                              passwordController.text);
                          if (result) {
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
                          } else {
                            addError(error: kWrongOldPassword);
                          }
                        }
                      }
                    },
                    child: Text("Continue",
                        style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontSize: getProportionateScreenWidth(20),
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(143, 32, 48, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildOldPasswordFormField() {
    return TextFormField(
      controller: oldPasswordController,
      autofillHints: const [AutofillHints.password],
      obscureText: true,
      onSaved: (newValue) => oldPassword = newValue!,
      onChanged: (value) {
        removeError(error: kWrongOldPassword);
        if (value.isNotEmpty) {
          removeError(error: kOldPassNullError);
        }
        oldPassword = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kOldPassNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter your old password",
        hintStyle:
            GoogleFonts.montserrat(textStyle: TextStyle(color: Colors.black38)),
        fillColor: Colors.white, filled: true,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.black12,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 143, 32, 49),
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 143, 32, 49),
          ),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF212121),
        ),
      ),
    );
  }

  TextFormField buildConformPassFormField() {
    return TextFormField(
      controller: confirmPasswordController,
      autofillHints: const [AutofillHints.newPassword],
      obscureText: true,
      onSaved: (newValue) => conform_password = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNewPassNullError);
        } else if (value.isNotEmpty &&
            passwordController.text == confirmPasswordController.text) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNewPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: "Re-enter your new password",
        hintStyle:
            GoogleFonts.montserrat(textStyle: TextStyle(color: Colors.black38)),
        fillColor: Colors.white,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.black12,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 143, 32, 49),
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 143, 32, 49),
          ),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF212121),
        ),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      controller: passwordController,
      autofillHints: const [AutofillHints.newPassword],
      obscureText: true,
      onSaved: (newValue) => password = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNewPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNewPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter your new password",
        hintStyle:
            GoogleFonts.montserrat(textStyle: TextStyle(color: Colors.black38)),
        fillColor: Colors.white,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.black12,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 143, 32, 49),
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 143, 32, 49),
          ),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF212121),
        ),
      ),
    );
  }
}
