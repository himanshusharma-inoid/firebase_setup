import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/utils.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "SignUp"),
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30),
        child: Column(
          children: [
            AppUtils.buildTextField(controller: emailController, hint: "enter email"),
            const SizedBox(height: 15.0),
            AppUtils.buildTextField(controller: passwordController, hint: "enter password"),
            const SizedBox(height: 30.0),
            AppUtils.buildElevatedButton(() {
              firebaseSignUp();
            }, "SignUp"),
          ],
        ),
      ),
    );
  }

  Future<void> firebaseSignUp() async {
    try {
      UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      Navigator.pushNamedAndRemoveUntil(context, "/home_page", (route) => false);
    }on FirebaseAuth catch(e){
      debugPrint("error is : $e");
    }
  }
}
