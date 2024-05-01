import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_setup/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  int step = 1;
  CroppedFile? croppedImageFile;
  XFile? resultFile;
  String countryCode = "+33";
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "Login"),
      body: SingleChildScrollView(
        child: ClipPath(
          clipper: MyClipper(),
          child: Container(
            //height: size.height * 0.8,
            color: Colors.tealAccent,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30, bottom: 60),
              child: Form(
                key: _formKey,
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

                    if(step == 2)
                    ...[
                    InkWell(
                      onTap: openGallery,
                      borderRadius: BorderRadius.circular(50),
                      child:  Container(
                        height: 90, width: 90,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12
                        ),
                        child: (croppedImageFile != null) ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(File(croppedImageFile!.path), fit: BoxFit.cover)) : const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    ],

                    if(step == 1)
                    ...[
                    AppUtils.buildTextField(controller: emailController, hint: "enter email", validate: (values){
                      debugPrint("validate");
                      if(values == ""){
                        return "please fill required field";
                      }else{
                        return null;
                      }
                    }),
                    const SizedBox(height: 15.0),
                    AppUtils.buildTextField(controller: passwordController, hint: "enter password", validate: (values){
                      debugPrint("validate");
                      if(values == ""){
                        return "please fill required field";
                      }else{
                        return null;
                      }
                    }),
                    ],
                    if(step == 2)
                    ...[AppUtils.buildTextField(controller: usernameController, hint: "enter name", validate: (values){
                      debugPrint("validate");
                      if(values == ""){
                        return "please fill required field";
                      }else{
                        return null;
                      }
                    }),
                    const SizedBox(height: 15.0),
                    AppUtils.buildPhoneNumberTextFormField(controller: phoneController, hint: "enter phone number", callback: (String? value){
                      if(value != null) countryCode = value;
                  },validate: (values){
                    debugPrint("validate");
                    if(values == ""){
                        return "please fill required field";
                    }else{
                       return null;
                       }
                     }
                    ),
                    ],
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
                        onTap: () {
                          Navigator.pushNamed(context, "/forgot_password_page");
                        },
                        child: AppUtils.commonText("Forgot Password?"))
                  ],
                ),
              ),
            ),
          ),
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

  Future<void> firebaseLogin() async {
      if (step == 1) {
        if(_formKey.currentState!.validate()){
          AppUtils.loadingDialog(context);
          try {
            FirebaseApi.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).then((credential) async {
              Navigator.pop(context);
              String? uid = credential.user?.uid;
              // String? userName = credential.user?.displayName;
              SharedPreferences preferences = await SharedPreferences.getInstance();
              preferences.setString("USER_ID", uid.toString());
              // preferences.setString("USER_NAME", userName.toString());
              Navigator.pushNamedAndRemoveUntil(context, "/home_page", (route) => false);
            });
            // FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text)
            //     .then((value) {
            //   Navigator.pushNamedAndRemoveUntil(context, "/home_page", (route) => false);
            // });
          } on FirebaseAuthException catch (e) {
            Navigator.pop(context);
            debugPrint("error is: $e");
          }
        }

      }
      else {
        if(_formKey.currentState!.validate()) {
          if (croppedImageFile != null) {
            AppUtils.loadingDialog(context);
            try {
              FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: countryCode + phoneController.text,
                  verificationCompleted: (PhoneAuthCredential credential) {
                    Navigator.pop(context);
                    debugPrint("verification completed");
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    Navigator.pop(context);
                  },
                  codeSent: (verificationId, forceResendingToken) {
                    debugPrint("code sent");
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/otp_page",
                        arguments: {
                          "verification_id": verificationId,
                          "image_file": croppedImageFile?.path,
                          "phone_number": countryCode + phoneController.text,
                          "user_name": usernameController.text
                        });
                  },
                  codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout) {

                  });
            } on FirebaseAuthException catch (e) {
              Navigator.pop(context);
              debugPrint("error is : $e");
            }
          } else {
            Fluttertoast.showToast(msg: "Please add photo");
          }
        }
    }
  }

}

class MyClipper extends CustomClipper<Path>{
  @override
  getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width/2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
   return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}
