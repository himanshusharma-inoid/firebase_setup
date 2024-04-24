import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NotificationServices notificationServices = NotificationServices();
  String? fcmToken;

  String kPushNotificationUrl = "https://fcm.googleapis.com/fcm/send";
  String cloudMessagingServerKey = "AAAAwlEz-SM:APA91bEUVpuRO5ka5_iy6Elh_hkJdewVvqVXOy6DLTww7qOR4ftUfKqT7pXjh1PwB-gm9llevym141StouTw1UgI4oznkipjAIKtL5hlREkvat15kLISTMbK6ZTQAj9MoFLtlhXXMfON";

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: InkWell(
            onTap: () => firebaseLogout(),
            child: const Icon(Icons.logout)),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () => sendNotification(),
              child: Text(
                'send notification',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  sendNotification() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? fcmToken = sharedPreferences.getString("FCM_TOKEN");

    Map<String, dynamic> data = {
      "to": fcmToken,
      "notification": {
        "title" : "test",
        "body" : "successfully sent notification"
      },
      "data":{
        "type" : "received_notifications"
      }
    };

    Map<String, String> headers = {
      "content-Type": "application/json; charset=UTF-8",
      "Authorization": "key=$cloudMessagingServerKey"
    };

    http.post(Uri.parse(kPushNotificationUrl), body: jsonEncode(data), headers: headers);

  }

  firebaseLogout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login_page", (route) => false);
  }
}