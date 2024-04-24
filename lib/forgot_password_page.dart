import 'package:firebase_auth/firebase_auth.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30),
        child: Column(
          children: [
            AppUtils.buildTextField(controller: emailController, hint: "enter email"),
            const SizedBox(height: 30.0),
            AppUtils.buildElevatedButton(() {
              firebaseForgotPassword();
            }, "Submit"),

          ],
        ),
      ),
    );
  }

  void firebaseForgotPassword() {
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text).then((value) =>
      AppUtils.customAlertBox(context, text: "password reset send to email")
      );
    }on FirebaseAuth catch(e){
      debugPrint("error is : $e");
    }
  }
}
