import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/firebase_api.dart';
import 'package:firebase_setup/utils.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "Forgot Password"),
      body: ClipPath(
        clipper: MyArcClipper(),
        child: Container(
          color: Colors.tealAccent,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30, bottom: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppUtils.buildTextField(controller: emailController, hint: "enter email"),
                const SizedBox(height: 30.0),
                AppUtils.buildElevatedButton(() {
                  firebaseForgotPassword();
                }, "Submit"),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void firebaseForgotPassword() {
    try {
      FirebaseApi().sendPasswordResetEmail(email: emailController.text).then((value) =>
          AppUtils.customAlertBox(context, text: "password reset send to email")
      );
      // FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text).then((value) =>
      // AppUtils.customAlertBox(context, text: "password reset send to email")
      // );
    }on FirebaseAuth catch(e){
      debugPrint("error is : $e");
    }
  }
}

class MyArcClipper extends CustomClipper<Path>{
  double radius = 30;
  @override
  Path getClip(Size size) {
    Path path = Path()
               ..lineTo(0, size.height - radius)
               ..arcToPoint(Offset(radius, size.height),radius: Radius.circular(radius), clockwise: true)
               ..lineTo(size.width - radius, size.height)
               ..arcToPoint(Offset(size.width, size.height - radius), radius: Radius.circular(radius), clockwise: false)
               ..lineTo(size.width, 0)
               ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
