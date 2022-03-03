import 'package:blossom/components/constants.dart';
import 'package:blossom/components/form_error.dart';
import 'package:blossom/components/no_account_text.dart';
import 'package:blossom/components/rounded_button.dart';
import 'package:blossom/components/size_config.dart';
import 'package:blossom/forgot_password/forgot_password_screen.dart';
import 'package:blossom/splash_screen.dart';
import 'package:flutter/material.dart';

import '../backend/authentication.dart';

class SignInScreen extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => SignInScreen(),
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
          // width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: SizeConfig.screenHeight! * 0.04),
                  Padding(
                    padding: EdgeInsets.only(left: 0, right: 100, top: 10),
                    child: Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight! * 0.03),
                  const Divider(
                    height: 2,
                    indent: 2,
                    endIndent: 0,
                    color: Colors.black,
                  ),
                  SizedBox(height: SizeConfig.screenHeight! * 0.04),
                  SignInForm(),
                  SizedBox(height: SizeConfig.screenHeight! * 0.04),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  Padding(
                    padding: EdgeInsets.only(left: 0, right: 80, top: 10),
                    child: NoAccountText(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  bool remember = false;
  final List<String> errors = [];
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 0, bottom: 20, right: 280, top: 10),
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
            padding: EdgeInsets.only(left: 0, bottom: 10, right: 240, top: 10),
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
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              // Checkbox(
              //   value: remember,
              //   activeColor: kPrimaryColor,
              //   onChanged: (value) {
              //     setState(() {
              //       remember = value;
              //     });
              //   },
              // ),
              //Text("Remember me", style: TextStyle(color: Colors.black)),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen()),
                ),
                // Named(
                //     context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          SizedBox(height: SizeConfig.screenHeight! * 0.04),
          SizedBox(height: SizeConfig.screenHeight! * 0.03),
          Padding(
            padding: EdgeInsets.only(left: 150, bottom: 10, right: 40, top: 10),
            child: RoundedButton(
              text: "Login",

              // backgroundColor: Color(0xFFFFC61F),
              press: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState?.save();
                  // if all are valid then go to success screen
                  // KeyboardUtil.hideKeyboard(context);
                  final login = await Authentication()
                      .login(emailController.text, passwordController.text);
                  print(login);
                  if (login == "UserNotFound") {
                    addError(error: kUserNotFoundError);
                  } else if (login == "WrongPassword") {
                    addError(error: kWrongPassError);
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      onSaved: (newValue) => password = newValue!,
      onChanged: (value) {
        removeError(error: kWrongPassError);
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
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
        hintStyle: TextStyle(color: Colors.black38),
        fillColor: Colors.white, filled: true,
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
        labelStyle: TextStyle(
          color: Color(0xFF212121),
        ),
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
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
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
        hintStyle: TextStyle(color: Colors.black38),
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
        labelStyle: TextStyle(
          color: Color(0xFF212121),
        ),
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
      ),
    );
  }
}
