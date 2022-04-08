import 'dart:io';
import 'dart:typed_data';

import 'package:blossom/backend/database.dart';
import 'package:blossom/components/rounded_button.dart';
import 'package:blossom/screen/forgot_password_change.dart';
import 'package:blossom/screen/home.dart';
import 'package:blossom/screen/view_history.dart';
import 'package:blossom/screen/welcome_screen.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/main.dart' as app;

class MockEmailAuth extends Mock implements EmailAuth {
  // MockEmailAuth() {
  //   EmailAuth(
  //     sessionName: "Blossom",
  //   );
  // }

  // @override
  // bool validateOtp({required String recipientMail, required String userOtp}) {
  //   return true;
  // }

  // @override
  // Future<bool> sendOtp(
  //     {required String recipientMail, int otpLength = 6}) async {
  //   return true;
  // }

  // @override
  // Future<bool> config(Map<String, String> data) async {
  //   return true;
  // }
}

// late EmailAuth emailAuth;
// @GenerateMocks([EmailAuth])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Tests', () {
    setUp(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    tearDown(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    testWidgets(
        'trying to login with wrong email, verify User not found error is shown',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@1233.com");
      await tester.enterText(passwordTextBox, "123123123");
      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.textContaining("User not found"), findsOneWidget);
    });

    testWidgets(
        'trying to login with wrong password, verify Wrong password error is shown',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123123");
      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.textContaining("Wrong password"), findsOneWidget);
    });

    testWidgets(
        'trying to login with password that is too short, verify password too short error is shown',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "1231231");
      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.textContaining("Password is too short"), findsOneWidget);
    });

    testWidgets('logging in, verify if user is succesfully login',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      // await tester.pumpAndSettle(const Duration(seconds: 3));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.byType(LandingPage), findsOneWidget);
    });

    // testWidgets(
    //     'logging in with the wrong detail first then logging in with the correct detail, verify if user is succesfully login',
    //     (WidgetTester tester) async {
    //   app.main();

    //   await tester.pumpAndSettle(const Duration(seconds: 2));

    //   final Finder button = find.widgetWithText(RoundedButton, 'Login');

    //   await tester.tap(button);

    //   await tester.pumpAndSettle();

    //   final emailTextBox = find.bySemanticsLabel("Enter your email");
    //   final passwordTextBox = find.bySemanticsLabel("Enter your password");
    //   final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

    //   await tester.enterText(emailTextBox, "chris@1233.com");
    //   await tester.enterText(passwordTextBox, "1231231");
    //   await tester.tap(loginButton);

    //   for (int i = 0; i < 5; i++) {
    //     // because pumpAndSettle doesn't work
    //     await tester.pump(const Duration(seconds: 1));
    //   }

    //   expect(find.textContaining("Password is too short"), findsOneWidget);

    //   await tester.enterText(passwordTextBox, "123123123123");
    //   await tester.ensureVisible(loginButton);
    //   await tester.tap(loginButton);

    //   for (int i = 0; i < 5; i++) {
    //     // because pumpAndSettle doesn't work
    //     await tester.pump(const Duration(seconds: 1));
    //   }

    //   expect(find.textContaining("User not found"), findsOneWidget);

    //   await tester.enterText(emailTextBox, "chris@123.com");
    //   await tester.ensureVisible(loginButton);
    //   await tester.tap(loginButton);

    //   for (int i = 0; i < 5; i++) {
    //     // because pumpAndSettle doesn't work
    //     await tester.pump(const Duration(seconds: 1));
    //   }

    //   expect(find.textContaining("Wrong password"), findsOneWidget);

    //   await tester.enterText(passwordTextBox, "123123123");
    //   await tester.ensureVisible(loginButton);
    //   await tester.tap(loginButton);

    //   // await tester.pumpAndSettle(const Duration(seconds: 3));
    //   for (int i = 0; i < 5; i++) {
    //     // because pumpAndSettle doesn't work
    //     await tester.pump(const Duration(seconds: 1));
    //   }

    //   expect(find.byType(LandingPage), findsOneWidget);
    // });
  });

  group('Sign Up Tests', () {
    setUp(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    tearDown(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var usersCollection = db.collection('users');
      await usersCollection.deleteOne({"email": "chris@outlook.com"});

      db.close();
    });

    testWidgets(
        'trying to sign up without entering anything and verify the Please enter your username, Please enter your email, Please enter your password error are shown',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Sign Up');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final Finder signUpButton =
          find.widgetWithText(RoundedButton, 'Continue');

      await tester.ensureVisible(signUpButton);

      await tester.tap(signUpButton);

      // await tester.pumpAndSettle(const Duration(seconds: 3));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.textContaining("Please enter your username"), findsOneWidget);
      expect(find.textContaining("Please enter your email"), findsOneWidget);
      expect(find.textContaining("Please enter your password"), findsOneWidget);
    });

    testWidgets(
        'trying to sign up with invalid email, verify Please enter Valid Email error is shown',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Sign Up');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final usernameTextBox = find.bySemanticsLabel("Enter your username");
      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final confirmpasswordTextBox =
          find.bySemanticsLabel("Re-enter your password");

      final Finder signUpButton =
          find.widgetWithText(RoundedButton, 'Continue');

      await tester.enterText(usernameTextBox, "chris");
      await tester.enterText(emailTextBox, "chriss");
      await tester.enterText(passwordTextBox, "123123123");
      await tester.enterText(confirmpasswordTextBox, "123123123");

      await tester.ensureVisible(signUpButton);

      await tester.tap(signUpButton);

      // await tester.pumpAndSettle(const Duration(seconds: 3));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.textContaining("Please enter Valid Email"), findsOneWidget);
    });

    testWidgets(
        'trying to sign up with password that does not match, verify Passwords don\'t match error is shown',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Sign Up');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final usernameTextBox = find.bySemanticsLabel("Enter your username");
      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final confirmpasswordTextBox =
          find.bySemanticsLabel("Re-enter your password");

      final Finder signUpButton =
          find.widgetWithText(RoundedButton, 'Continue');

      await tester.enterText(usernameTextBox, "chris");
      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");
      await tester.enterText(confirmpasswordTextBox, "12312312333");

      await tester.ensureVisible(signUpButton);

      await tester.tap(signUpButton);

      // await tester.pumpAndSettle(const Duration(seconds: 3));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.textContaining("Passwords don't match"), findsOneWidget);
    });

    testWidgets(
        'trying to sign up as a user that already exist, verify User already exist error is shown',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Sign Up');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final usernameTextBox = find.bySemanticsLabel("Enter your username");
      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final confirmpasswordTextBox =
          find.bySemanticsLabel("Re-enter your password");

      final Finder signUpButton =
          find.widgetWithText(RoundedButton, 'Continue');

      await tester.enterText(usernameTextBox, "chris");
      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");
      await tester.enterText(confirmpasswordTextBox, "123123123");

      await tester.ensureVisible(signUpButton);

      await tester.tap(signUpButton);

      // await tester.pumpAndSettle(const Duration(seconds: 3));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.textContaining("User already exist"), findsOneWidget);
    });

    testWidgets('sign up, verify if user is succesfully login',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Sign Up');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final usernameTextBox = find.bySemanticsLabel("Enter your username");
      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final confirmpasswordTextBox =
          find.bySemanticsLabel("Re-enter your password");

      final Finder signUpButton =
          find.widgetWithText(RoundedButton, 'Continue');

      await tester.enterText(usernameTextBox, "chris");
      await tester.enterText(emailTextBox, "chris@outlook.com");
      await tester.enterText(passwordTextBox, "123123123");
      await tester.enterText(confirmpasswordTextBox, "123123123");

      await tester.ensureVisible(signUpButton);

      await tester.tap(signUpButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });
  });

  group('Logout Test', () {
    setUpAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    tearDownAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    testWidgets('logging in for testing', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    testWidgets(
        'logging out of the app, verify user have successfully logouted',
        (WidgetTester tester) async {
      app.main();

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder profileButton = find.byTooltip('Profile');
      await tester.tap(profileButton);

      await tester.pumpAndSettle();

      final Finder logoutButton = find.byTooltip('Logout');
      await tester.tap(logoutButton);

      await tester.pumpAndSettle();

      final Finder confirmLogoutButton = find.text("Confirm to log out");
      await tester.tap(confirmLogoutButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
  });

  group('Change Password Test', () {
    setUpAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    tearDownAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var usersCollection = db.collection('users');

      var salt10 = await FlutterBcrypt.saltWithRounds(rounds: 10);

      var hashedNewPassword =
          await FlutterBcrypt.hashPw(password: "123123123", salt: salt10);

      await usersCollection.updateOne(
        where.eq('email', "chris@123.com"),
        ModifierBuilder().set('password', hashedNewPassword),
      );
      db.close();
    });

    testWidgets('logging in for testing', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    testWidgets('change password, verify user new password still works',
        (WidgetTester tester) async {
      app.main();

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder profileButton = find.byTooltip('Profile');
      await tester.tap(profileButton);

      await tester.pumpAndSettle();

      final Finder changeButton = find.byTooltip('Change Password');
      await tester.tap(changeButton);

      await tester.pumpAndSettle();

      final oldPasswordTextBox =
          find.bySemanticsLabel("Enter your old password");
      final newPasswordTextBox =
          find.bySemanticsLabel("Enter your new password");
      final reNewPasswordTextBox =
          find.bySemanticsLabel("Re-enter your new password");
      final Finder continueButton =
          find.widgetWithText(ElevatedButton, 'Continue');

      await tester.enterText(oldPasswordTextBox, "123123123");
      await tester.enterText(newPasswordTextBox, "123456789");
      await tester.enterText(reNewPasswordTextBox, "123456789");

      await tester.tap(continueButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(WelcomeScreen), findsOneWidget);

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123456789");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    // testWidgets('changing back the password', (WidgetTester tester) async {
    //   app.main();

    //   for (int i = 0; i < 5; i++) {
    //     await tester.pump(const Duration(seconds: 1));
    //   }

    //   final Finder profileButton = find.byTooltip('Profile');
    //   await tester.tap(profileButton);

    //   await tester.pumpAndSettle();

    //   final Finder changeButton = find.byTooltip('Change Password');
    //   await tester.tap(changeButton);

    //   await tester.pumpAndSettle();

    //   final oldPasswordTextBox =
    //       find.bySemanticsLabel("Enter your old password");
    //   final newPasswordTextBox =
    //       find.bySemanticsLabel("Enter your new password");
    //   final reNewPasswordTextBox =
    //       find.bySemanticsLabel("Re-enter your new password");
    //   final Finder continueButton =
    //       find.widgetWithText(ElevatedButton, 'Continue');

    //   await tester.enterText(oldPasswordTextBox, "123456789");
    //   await tester.enterText(newPasswordTextBox, "123123123");
    //   await tester.enterText(reNewPasswordTextBox, "123123123");

    //   await tester.tap(continueButton);

    //   for (int i = 0; i < 5; i++) {
    //     await tester.pump(const Duration(seconds: 1));
    //   }

    //   expect(find.byType(WelcomeScreen), findsOneWidget);
    // });
  });

  group('Forget Password Test', () {
    setUp(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      // emailAuth = MockEmailAuth();
      // when(emailAuth.validateOtp(
      //         recipientMail: "chris@123.com", userOtp: "12345"))
      //     .thenAnswer((_) => true);
    });

    tearDown(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var usersCollection = db.collection('users');

      var salt10 = await FlutterBcrypt.saltWithRounds(rounds: 10);

      var hashedNewPassword =
          await FlutterBcrypt.hashPw(password: "123123123", salt: salt10);

      await usersCollection.updateOne(
        where.eq('email', "chris@123.com"),
        ModifierBuilder().set('password', hashedNewPassword),
      );
      db.close();
    });

    testWidgets('forgetting password, verify if user is succesfully login',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final Finder forgetButton = find.text('Forgot Password');

      await tester.tap(forgetButton);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final otpTextBox = find.bySemanticsLabel("Enter OTP");
      final Finder otpButton = find.text('Request OTP');
      final Finder continueButton =
          find.widgetWithText(RoundedButton, 'Continue');

      await tester.enterText(emailTextBox, "chris@123.com");

      await tester.tap(otpButton);

      await Future.delayed(const Duration(seconds: 5));

      await tester.enterText(otpTextBox, "12345");

      await tester.ensureVisible(continueButton);

      final MockEmailAuth mockEmailAuth = MockEmailAuth();
      // final EmailAuth emailAuth = mockEmailAuth;

      when(mockEmailAuth.validateOtp(
              recipientMail: "chris@123.com", userOtp: "12345"))
          .thenReturn(true);

      await tester.tap(continueButton);

      // await tester.pumpWidget(const MaterialApp(
      //     home: ForgetChangeScreen(
      //   email: 'chris@123.com',
      //   comingForm: "Forget Password",
      // )));

      await tester.pumpAndSettle();

      final newPasswordTextBox =
          find.bySemanticsLabel("Enter your new password");
      final reNewPasswordTextBox =
          find.bySemanticsLabel("Re-enter your new password");
      final Finder continue1Button =
          find.widgetWithText(ElevatedButton, 'Continue');

      await tester.enterText(newPasswordTextBox, "123456789");
      await tester.enterText(reNewPasswordTextBox, "123456789");

      await tester.tap(continue1Button);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });
  });

  group('Flower Identification Test', () {
    setUpAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var scannedHistory = db.collection('user_scanned_history');
      GridFS gridFS = GridFS(db, "scanned_photos");

      await scannedHistory
          .deleteOne({'email': "chris@123.com", 'filename': 'daisy.jpg'});

      var gridOut = await gridFS.findOne(where.eq('filename', 'daisy.jpg'));

      var scannedPhotosChunks = db.collection('scanned_photos.chunks');
      var scannedPhotosFiles = db.collection('scanned_photos.files');

      await scannedPhotosChunks.deleteMany({'_id': gridOut?.id});
      await scannedPhotosFiles.deleteMany({'_id': gridOut?.id});

      db.close();
    });

    tearDownAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var scannedHistory = db.collection('user_scanned_history');
      GridFS gridFS = GridFS(db, "scanned_photos");

      await scannedHistory
          .deleteOne({'email': "chris@123.com", 'filename': 'daisy.jpg'});

      var gridOut = await gridFS.findOne(where.eq('filename', 'daisy.jpg'));

      var scannedPhotosChunks = db.collection('scanned_photos.chunks');
      var scannedPhotosFiles = db.collection('scanned_photos.files');

      await scannedPhotosChunks.deleteMany({'_id': gridOut?.id});
      await scannedPhotosFiles.deleteMany({'_id': gridOut?.id});

      db.close();
    });

    testWidgets('logging in for testing', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    testWidgets('scan a flower, verify if flower is correctly identified',
        (WidgetTester tester) async {
      app.main();

      const MethodChannel channel =
          MethodChannel('plugins.flutter.io/image_picker');

      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        ByteData data = await rootBundle.load('assets/sample/image.jpg');
        Uint8List bytes = data.buffer.asUint8List();
        Directory tempDir = await getTemporaryDirectory();
        File file = await File(
          '${tempDir.path}/daisy.jpg',
        ).writeAsBytes(bytes);
        return file.path;
      });

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder scanFlowerButton = find.byTooltip('Scan Flower');
      await tester.tap(scanFlowerButton);

      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text("Daisy").first, findsOneWidget);
    });
  });

  group('Memories Creation Test', () {
    setUpAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var memoryCollection = db.collection('user_memories');
      await memoryCollection
          .deleteOne({'email': "chris@123.com", 'memory_name': 'Test 1'});

      db.close();
    });

    tearDownAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var memoryCollection = db.collection('user_memories');
      await memoryCollection
          .deleteOne({'email': "chris@123.com", 'memory_name': 'Test 1'});

      db.close();
    });

    testWidgets('logging in for testing', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    testWidgets('create a memory, verify if memory is succesfully created',
        (WidgetTester tester) async {
      app.main();

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder historyButton = find.byTooltip('History');
      await tester.tap(historyButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder memoriesButton = find.byTooltip('Create Memories');
      await tester.tap(memoriesButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final nameTextBox = find.bySemanticsLabel("Enter name");
      final Finder submitButton = find.text('SUBMIT');

      await tester.enterText(nameTextBox, "Test 1");

      await tester.tap(submitButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder checkAllButton = find.byTooltip('Check All');
      final Finder doneButton = find.byTooltip('Done');

      await tester.tap(checkAllButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      await tester.tap(doneButton);

      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      final Finder viewMemoryButton = find.byType(MemoryThumbnail).first;
      await tester.tap(viewMemoryButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text("Test 1"), findsOneWidget);
    });
  });

  group('View Map Test', () {
    setUpAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    tearDownAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    testWidgets('logging in for testing', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    testWidgets(
        'navigate to view maps page, verify if maps is correctly displayed',
        (WidgetTester tester) async {
      app.main();

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder parksButton = find.byTooltip('Parks');
      await tester.tap(parksButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(GoogleMap), findsOneWidget);
    });
  });

  group('Point System Test', () {
    setUpAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var usersCollection = db.collection('users');
      var userVoucher = db.collection('user_voucher');

      await usersCollection.updateOne(where.eq('email', "chris@123.com"),
          ModifierBuilder().set('points', 5000));

      await userVoucher.deleteOne({"email": "chris@123.com"});

      db.close();
    });

    tearDownAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      var db = await Database().connect();

      var usersCollection = db.collection('users');
      var userVoucher = db.collection('user_voucher');

      await usersCollection.updateOne(where.eq('email', "chris@123.com"),
          ModifierBuilder().set('points', 5000));

      await userVoucher.deleteOne({"email": "chris@123.com"});

      db.close();
    });

    testWidgets('logging in for testing', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    testWidgets('Redeem a voucher verify points have been deducted',
        (WidgetTester tester) async {
      app.main();

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder redeemPageButton =
          find.widgetWithText(ElevatedButton, 'Redeem');
      await tester.tap(redeemPageButton);

      await tester.pumpAndSettle();

      final Finder redeemVoucherButton =
          find.widgetWithText(ElevatedButton, 'Redeem').first;
      await tester.tap(redeemVoucherButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      // await tester.pumpAndSettle();

      final Finder confirmRedeemButton = find.text("Confirm to Redeem");
      await tester.tap(confirmRedeemButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      // await tester.pumpAndSettle();

      final Finder useButton = find.widgetWithText(ElevatedButton, 'Use');
      await tester.tap(useButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('4880 pts'), findsOneWidget);
    });
  });

  group('Social Media Sharing Test', () {
    setUpAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    tearDownAll(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    testWidgets('logging in for testing', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder button = find.widgetWithText(RoundedButton, 'Login');

      await tester.tap(button);

      await tester.pumpAndSettle();

      final emailTextBox = find.bySemanticsLabel("Enter your email");
      final passwordTextBox = find.bySemanticsLabel("Enter your password");
      final Finder loginButton = find.widgetWithText(RoundedButton, 'Login');

      await tester.enterText(emailTextBox, "chris@123.com");
      await tester.enterText(passwordTextBox, "123123123");

      await tester.tap(loginButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(LandingPage), findsOneWidget);
    });

    testWidgets('share a flower, verify if flower is succesfully shared',
        (WidgetTester tester) async {
      app.main();

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      const MethodChannel channel =
          MethodChannel('dev.fluttercommunity.plus/share');

      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        print(methodCall);
      });

      final Finder historyButton = find.byTooltip('History');
      await tester.tap(historyButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder viewFlowerButton = find.byType(GridTile).first;
      await tester.tap(viewFlowerButton);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final Finder shareButton = find.byTooltip("Share");

      tester.tap(shareButton);

      await Future.delayed(const Duration(seconds: 5));
      // expect(, returnsNormally);
    });
  });
}
