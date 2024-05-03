import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/firebase_api.dart';
import 'package:firebase_setup/login_page.dart';
import 'package:firebase_setup/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  CroppedFile? croppedImageFile;
  XFile? resultFile;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "SignUp", voidCallback: ()=> Navigator.of(context).pop()),
      body: SingleChildScrollView(
        child: ClipPath(
          clipper: MyCubicClipper(),
          child: Container(
            color: Colors.tealAccent,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30, bottom: 80),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InkWell(
                      onTap: openGallery,
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        height: 120, width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            color: Colors.black12
                        ),
                        child:  (croppedImageFile != null) ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.file(File(croppedImageFile!.path), fit: BoxFit.cover)) : const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    AppUtils.buildTextField(controller: usernameController, hint: "enter name", validate: (values){
                      debugPrint("validate");
                        if(values == ""){
                          return "please fill required field";
                        }else{
                          return null;
                        }
                    }),
                    const SizedBox(height: 15.0),
                    AppUtils.buildTextField(controller: emailController, hint: "enter email", validate: (values){
                      if(values == ""){
                        return "please fill required field";
                      }else{
                        return null;
                      }
                    }),
                    const SizedBox(height: 15.0),
                    AppUtils.buildTextField(controller: passwordController, hint: "enter password", validate: (values){
                      if(values == ""){
                        return "please fill required field";
                      }else{
                        return null;
                      }
                    }),
                    const SizedBox(height: 30.0),
                    AppUtils.buildElevatedButton(() {
                      if(_formKey.currentState!.validate()) {
                        firebaseSignUp();
                      }
                    }, "SignUp"),
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

  Future<void> uploadData(UserCredential credential) async {
    ///Create a Reference
    final storageRef = FirebaseStorage.instance.ref("images");
    final Ref = storageRef.child(emailController.text);

    /// upload file
    UploadTask uploadTask = Ref.putFile(File(croppedImageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask;
    String url = await taskSnapshot.ref.getDownloadURL();

    /// send data into firestore database
    String? uid = credential.user?.uid;
    // String? userName = credential.user?.displayName;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("USER_ID", uid.toString());
    // preferences.setString("USER_NAME", userName.toString());
    await FirebaseApi.addUserData(uid: uid.toString(), email: emailController.text, url: url, userName: usernameController.text);
    // FirebaseFirestore.instance.collection("users").doc(emailController.text).set({
    //   "email": emailController.text,
    //   "image_url": url
    // });
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, "/home_page", (route) => false);

  }

  Future<void> firebaseSignUp() async {
    if (croppedImageFile != null) {
      try {
        AppUtils.loadingDialog(context);
        FirebaseApi.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
            .then((credentials) => uploadData(credentials));
        // UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
        // if(userCredential != null){
        //   uploadData();
        // }
      } on FirebaseAuth catch (e) {
        Navigator.pop(context);
        debugPrint("error is : $e");
      }
    }
    else {
    Fluttertoast.showToast(msg: "Please add photo");
    }
  }
}

class MyCubicClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    Path path = Path()
                 ..lineTo(0, size.height - 60)
                 ..cubicTo(size.width/3, size.height, 3/4 * size.width, size.height - 90, size.width, size.height - 60)
                 ..lineTo(size.width, 0)
                 ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }

}
