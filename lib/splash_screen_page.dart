import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {

  NotificationServices notificationServices = NotificationServices();
  String? fcmToken;

  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    // notificationServices.isRefreshToken();
    notificationServices.getDeviceToken().then((generatedToken) async {
      debugPrint("fcm token is: $generatedToken");
      fcmToken = generatedToken ?? "";
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("FCM_TOKEN", fcmToken ?? "");
    }
    );

    ///initialize local notification for showing notifications in foreground
    notificationServices.initLocalNotifications(context);

    ///handle foreground notifications
    notificationServices.firebaseInit(context);
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
        Navigator.pushReplacementNamed(context, "/login_page");
      }else{
        Navigator.pushReplacementNamed(context, "/home_page");
      }
    });
  }
}
