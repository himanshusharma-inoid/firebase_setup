import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'chat_page.dart';
import 'message_screen.dart';

class NotificationServices{
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );

    ///for check permission in android
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
       debugPrint("user granted permission");
    }
    ///for check permission in ios
    else if(settings.authorizationStatus == AuthorizationStatus.provisional){
       debugPrint("user granted provisional permission");
    }else{
       debugPrint("user denied permission");
       AppSettings.openNotificationSettings();
      // AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  Future<String?> getDeviceToken() async {
   String? token = await firebaseMessaging.getToken();
   return token;
  }

  void isRefreshToken(){
    firebaseMessaging.onTokenRefresh.listen((event) {
      debugPrint("refresh token: ${event.toString()}");
    });
  }

void initLocalNotifications(BuildContext context){
    AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings darwinInitializationSettings = const DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse){
        debugPrint("foreground notification tapped event");
        debugPrint("encode foreground payload is: ${notificationResponse.payload}");
        if(notificationResponse.payload != null){
          var usrMap = jsonDecode(notificationResponse.payload!);
          debugPrint("decode foreground payload is: $usrMap");
          handleMessage(context, usrMap);
        }
      }
      // onDidReceiveNotificationResponse: (notificationResponse){
      //   debugPrint("foreground payload is: ${notificationResponse.payload}");
      //   notificationTapForeground(context, message);
      // }

    //  onDidReceiveBackgroundNotificationResponse: notificationTapBackground
    );

    // ///handle foreground notifications
    // firebaseInit();
}


// static void notificationTapForeground(BuildContext context, RemoteMessage? message){
//     debugPrint("foreground notification tapped event");
//     if(message ==  null) return;
//     debugPrint("foreground payload is: ${message.data}");
//     if(message.data['type'] == "received_notifications"){
//       // navigate to particular screen
//       Navigator.push(context, MaterialPageRoute(builder: (context) => const MessageScreen()));
//
//     }
// }

 // static void notificationTapBackground(payload){
 //     debugPrint("background notification tapped event");
 //  }

  void firebaseInit(BuildContext context){

    ///showing notifications when app is terminated
      firebaseMessaging.getInitialMessage().then((message) {
      debugPrint("received terminated notification message");
      debugPrint("FirebaseMessaging.getInitialMessage");
      if(message == null) return;
      debugPrint("terminated payload is: ${message.data}");
      var usrMap = message.data;
      handleMessage(context, usrMap);
    });

    /// showing notifications in foreground
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("received foreground message");
      debugPrint("foreground payload is: ${message.data}");
      debugPrint("title is: ${message.notification?.title}");
      debugPrint("body is: ${message.notification?.body}");

      // initLocalNotifications(context, message);
      showNotifications(message);

    });

    /// showing notifications on background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("received background message and navigate to user preference screens");
      debugPrint("background payload is: ${message.data}");
      debugPrint("body is: ${message.notification?.body}");

      var usrMap = message.data;
      handleMessage(context, usrMap);

    });


  }

  void showNotifications(RemoteMessage message){
    RemoteNotification? notification = message.notification;

    AndroidNotificationChannel androidNotificationChannel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        androidNotificationChannel.id,
        androidNotificationChannel.name,
      channelDescription: androidNotificationChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker"
     );

    DarwinNotificationDetails  darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        notificationDetails,
        payload: jsonEncode(message.data));
  }

  void handleMessage(BuildContext context, Map<String, dynamic> usrMap) {
    String chatId = usrMap['chat_id'];
    String userId = usrMap['user_id'];
    String toId = usrMap['to_id'];
    String userName = usrMap['user_name'];
    if(usrMap['type'] == "received_notifications"){
      // navigate to particular screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MessageScreen()));

    }else if(usrMap['type'] == "New_Chat_Message"){
      debugPrint("message received");
      Navigator.pushNamed(context, "/chat_page", arguments: {"chat_id": chatId, "user_id": userId, "to_id": toId, "user_name": userName});
    }
  }

}
