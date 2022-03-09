import 'package:blossom/components/constants.dart';
import 'package:blossom/components/form_error.dart';
import 'package:blossom/components/rounded_button.dart';
import 'package:blossom/components/size_config.dart';
import 'package:blossom/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/authentication.dart';
import '../present_flower.dart';

class SignUpScreen extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => SignUpScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.lightBlue[50],
      ),
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: SizedBox(
          //width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: SizeConfig.screenHeight! * 0.03), // 4%
                  Padding(
                    padding: EdgeInsets.only(left: 0, right: 80, top: 10),
                    child: Text("Register Account", style: headingStyle),
                  ),
                  SizedBox(height: SizeConfig.screenHeight! * 0.03),
                  const Divider(
                    height: 2,
                    indent: 2,
                    endIndent: 0,
                    color: Colors.black,
                  ),

                  SizedBox(height: SizeConfig.screenHeight! * 0.03),
                  SignUpForm(),
                  SizedBox(height: SizeConfig.screenHeight! * 0.08),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SocalCard(
                  //       icon: "assets/icons/google-icon.svg",
                  //       press: () {},
                  //     ),
                  //     SocalCard(
                  //       icon: "assets/icons/facebook-2.svg",
                  //       press: () {},
                  //     ),
                  //     SocalCard(
                  //       icon: "assets/icons/twitter.svg",
                  //       press: () {},
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: getProportionateScreenHeight(20)),

                  // Text(
                  //   'By continuing your confirm that you agree \nwith our Term and Condition',
                  //   textAlign: TextAlign.center,
                  //   style: Theme.of(context).textTheme.caption,
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  late String conform_password;
  bool remember = false;
  final List<String> errors = [];

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0, bottom: 20, right: 280),
              //apply padding horizontal or vertical only
              child: Text(
                "EMAIL",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildEmailFormField(),
            SizedBox(height: getProportionateScreenHeight(20)),
            Padding(
              padding: EdgeInsets.only(left: 0, bottom: 20, right: 240),
              //apply padding horizontal or vertical only
              child: Text(
                "PASSWORD",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(20)),
            Padding(
              padding: EdgeInsets.only(left: 0, bottom: 20, right: 140),
              //apply padding horizontal or vertical only
              child: Text(
                "CONFIRM PASSWORD",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildConformPassFormField(),
            FormError(errors: errors),
            SizedBox(height: getProportionateScreenHeight(50)),
            Padding(
              padding:
                  EdgeInsets.only(left: 150, bottom: 10, right: 40, top: 10),
              child: RoundedButton(
                text: "Continue",
                press: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState?.save();
                    bool exist = await Authentication.checkUserExist(
                        emailController.text);
                    if (!exist) {
                      final result = await Authentication().register(
                          emailController.text, passwordController.text, "");
                                                // Obtain shared preferences.
                      final prefs = await SharedPreferences.getInstance();
                      // Save an String value to 'action' key.
                      await prefs.setString('jwt', result);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const Dashboard()),
                          (Route<dynamic> route) => false);
                    } else {
                      addError(error: kUserExistError);
                    }
                    // if all are valid then go to success screen
                    // Navigator.pushNamed(context, CompleteProfileScreen.routeName);
                  }
                },
              ),
            ),
          ],
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
          removeError(error: kPassNullError);
        } else if (value.isNotEmpty &&
            passwordController.text == confirmPasswordController.text) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        //labelText: "Confirm Password",
        hintText: "Re-enter your password",
        fillColor: Colors.white, filled: true,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        // suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Colors.black12,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(
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
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        //labelText: "Password",
        hintText: "Enter your password",
        fillColor: Colors.white, filled: true,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,

        suffixIcon: Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Colors.black12,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(
          color: Color(0xFF212121),
        ),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      controller: emailController,
      autofillHints: const [AutofillHints.newUsername],
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue!,
      onChanged: (value) {
        removeError(error: kUserExistError);
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
        // labelText: "Email",
        hintText: "Enter your email",
        fillColor: Colors.white, filled: true,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Icon(
            Icons.mail,
            color: Colors.grey,
          ),
        ),
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Colors.black12,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(
          color: Color(0xFF212121),
        ),
      ),
    );
  }
}
