import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {

  @override
  void initState() {
    checkUserState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void checkUserState() {
    Future.delayed(const Duration(seconds: 2), (){
      User? user = FirebaseAuth.instance.currentUser;
      if(user == null){
        Navigator.pushNamed(context, "/login_page");
      }else{
        Navigator.pushNamed(context, "/home_page");
      }
    });
  }
}
