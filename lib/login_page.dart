import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_setup/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  int step = 1;
  CroppedFile? croppedImageFile;
  XFile? resultFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "Login"),
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppUtils.buildEmailTabWidget(context, "email", () {
                  step = 1;
                  setState(() {});
                }, step
                ),
                const SizedBox(width: 10.0,),
                AppUtils.buildPhoneTabWidget(context, "Phone", () {
                  step = 2;
                  setState(() {});
                }, step
                ),
              ],
            ),
            const SizedBox(height: 30.0),

            InkWell(
              onTap: openGallery,
              borderRadius: BorderRadius.circular(50),
              child: (croppedImageFile != null) ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black12
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(File(croppedImageFile!.path), fit: BoxFit.cover, height: 90, width: 90)),
              ) : null,
            ),
            const SizedBox(height: 15.0),

            if(step == 1)
            ...[
            AppUtils.buildTextField(controller: emailController, hint: "enter email"),
            const SizedBox(height: 15.0),
            AppUtils.buildTextField(controller: passwordController, hint: "enter password"),
            ],
            if(step == 2)
            AppUtils.buildTextField(controller: phoneController, hint: "enter phone number"),
            const SizedBox(height: 30.0),
            AppUtils.buildElevatedButton(() {
               firebaseLogin();
            }, "Login"),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppUtils.commonText("Don't have an account?"),
                const SizedBox(width: 10),
                InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, "/signup_page");
                    },
                    child: AppUtils.commonText("SignUp"))
              ],
            ),
            const SizedBox(height: 15.0),
            InkWell(
                onTap: (){
                  Navigator.pushNamed(context, "/forgot_password_page");
                },
                child: AppUtils.commonText("Forgot Password?"))
          ],
        ),
      ),
    );
  }

  Future<void> openGallery() async {

    ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1080).then((pickedFile) {
      debugPrint("file is: ${pickedFile?.path}");
      if (pickedFile != null && pickedFile.path != "") {
        _cropImage(pickedFile.path);
      }
    }).onError((error, stackTrace) {
      debugPrint("error is: $error");
      return null;
    },
    );
  }

  Future<void> _cropImage(String filePath) async {
    debugPrint('crop image');
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080).catchError((error){
      debugPrint("error is: $error");
      return null;
    });
    if (croppedImage != null) {
      croppedImageFile = croppedImage;
      XFile? file = XFile(croppedImageFile?.path ?? "");
      final bytes = await file.readAsBytes();
      double kb = bytes.length / 1024;
      double mb = kb / 1024;
      debugPrint("original image size is: $mb");

      final dir = await getTemporaryDirectory();
      final targetPath = "${dir.absolute.path}/temp.jpg";

      resultFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minWidth: 1080,
        minHeight: 1080,
        quality: 50,
      );
      if(resultFile != null) {
        final newBytes = await resultFile!.readAsBytes();
        kb = newBytes.length / 1024;
        mb = kb / 1024;
        debugPrint("new image size is: $mb");
      }
      setState(() {});
    }
    else{
        Fluttertoast.showToast(msg: "something went wrong");
    }
  }

  void firebaseLogin() {
    try {
      if(step == 1) {
        FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text)
            .then((value) {



               FirebaseFirestore.instance.collection("users").doc(emailController.text).set({
                 "email": emailController.text
               });

               Navigator.pushNamedAndRemoveUntil(
                    context, "/home_page", (route) => false);
               });
            }
      else{
        FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneController.text,
            verificationCompleted: (PhoneAuthCredential credential){
              debugPrint("verification completed");
            },
            verificationFailed: (FirebaseAuthException e){

            },
            codeSent: (verificationId, forceResendingToken){
              Navigator.pushNamed(context, "/otp_page", arguments: {"verification_id": verificationId});
            },
            codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout){

            });
      }
    }on FirebaseAuth catch(e){
      debugPrint("error is : $e");
    }
  }
}
