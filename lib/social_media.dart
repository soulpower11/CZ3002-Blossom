import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';

enum ShareTo {
  facebook,
  twitter,
  whatsapp,
  whatsapp_personal,
  whatsapp_business,
  share_system,
  share_instagram,
  share_telegram
}

class ShareSocialMedia extends StatelessWidget {
  //const ShareSocialMedia({Key? key}) : super(key: key);
  File? file;
  ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Share to social media'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            onButtonTap(ShareTo.facebook);
          },
          child: const Text('Share with Facebook'),
        ),
        SimpleDialogOption(
          onPressed: () {},
          child: const Text('Share with Twitter'),
        ),
      ],
    );
  }

  Future<void> onButtonTap(ShareTo share) async {
    File? file;
    ImagePicker picker = ImagePicker();
    String msg =
        'Flutter share is great!!\n Check out full example at https://pub.dev/packages/flutter_share_me';
    String url = 'https://pub.dev/packages/flutter_share_me';

    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case ShareTo.facebook:
        response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
        break;
      case ShareTo.twitter:
        response = await flutterShareMe.shareToTwitter(url: url, msg: msg);
        break;
      case ShareTo.share_instagram:
        response = await flutterShareMe.shareToInstagram(imagePath: file!.path);
        break;
      case ShareTo.share_telegram:
        response = await flutterShareMe.shareToTelegram(msg: msg);
        break;
    }
    debugPrint(response);
  }
}
