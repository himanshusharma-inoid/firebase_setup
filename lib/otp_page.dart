import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/firebase_api.dart';
import 'package:firebase_setup/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: borderColor),
    ),
  );
  static const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
  static const fillColor = Color.fromRGBO(243, 246, 249, 0);
  static const borderColor = Color.fromRGBO(23, 171, 144, 0.4);
  var arguments = {};


  @override
  Widget build(BuildContext context) {
    arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    debugPrint("argument data is: $arguments");
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "Otp"),
      body: ClipPath(
        clipper: MyPolygonClipper(),
        child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            color: Colors.tealAccent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Pinput(
                  length: 6,
                  keyboardType: TextInputType.number,
                  controller: pinController,
                  defaultPinTheme: defaultPinTheme,
                  onCompleted: (pin) {
                    debugPrint('onCompleted: $pin');
                  },
                  onChanged: (value) {
                    debugPrint('onChanged: $value');
                  },
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  textInputAction: TextInputAction.next,
                  showCursor: true,
                  validator: (s) {
                    debugPrint('validating code: $s');
                  },
                ),
                const SizedBox(height: 15.0),
                AppUtils.buildElevatedButton(() {
                  validateOtp();
                }, "Submit"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> validateOtp() async {
    focusNode.unfocus();
    formKey.currentState!.validate();
    AppUtils.loadingDialog(context);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: arguments["verification_id"], smsCode: pinController.text);

      // Sign the user in (or link) with the credential
      FirebaseApi.signInWithCredential(credential: credential).then((credential) => uploadData(credential));
      // FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      //   uploadData();
      // });

    }on FirebaseAuth catch(e){
      Navigator.pop(context);
      debugPrint("error: ${e.toString()}");
    }


  }

  Future<void> uploadData(UserCredential credential) async {
    ///Create a Reference
    final storageRef = FirebaseStorage.instance.ref("images");
    final ref = storageRef.child(arguments["phone_number"]);

    /// upload file
    UploadTask uploadTask = ref.putFile(File(arguments["image_file"]));
    TaskSnapshot taskSnapshot = await uploadTask;
    String url = await taskSnapshot.ref.getDownloadURL();

    /// send data into firestore database
    String? uid = credential.user?.uid;
    // String? userName = credential.user?.displayName;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("USER_ID", uid.toString());
    // preferences.setString("USER_Name", userName.toString());
    FirebaseApi.addUserData(uid: uid.toString(), email: arguments["phone_number"], url: url, userName: arguments["user_name"]);
    // FirebaseFirestore.instance.collection("users").doc(arguments["phone_number"]).set({
    //   "email": arguments["phone_number"],
    //   "image_url": url
    // });
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, "/home_page", (route) => false);
  }

}

class MyPolygonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var points = [
      Offset(size.width / 2, 0), // point p1
      Offset(0, size.height / 2), // point p2
      Offset(size.width / 2, size.height), // point p3
      Offset(size.width, size.height / 2) // point p4
    ];

    Path path = Path()
      ..addPolygon(points, false)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
