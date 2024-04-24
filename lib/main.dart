import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_setup/dashboard_page.dart';
import 'package:firebase_setup/forgot_password_page.dart';
import 'package:firebase_setup/login_page.dart';
import 'package:firebase_setup/otp_page.dart';
import 'package:firebase_setup/sign_up_page.dart';
import 'package:firebase_setup/splash_screen_page.dart';
import 'package:flutter/material.dart';
Future<void> main() async{
  await mainCommon();
}

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
     // options: DefaultFirebaseOptions.currentPlatform,
      options: const FirebaseOptions(
        apiKey: "AIzaSyC4ldrPwT8tXa_VAdA0Vtkn_uovng9Fpco",
        appId: "1:834586016035:android:e047aa08089c23c6387496",
        messagingSenderId: "834586016035",
        projectId: "flutterpushnotifications-c3d4d",
      ),
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('firebase error $e');
  }

  // await Firebase.initializeApp();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
   await Firebase.initializeApp();
   debugPrint("received background notifications");
   debugPrint("title is: ${message.notification?.title}");
   debugPrint("body is: ${message.notification?.body}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenPage(),
        '/login_page': (context) => const LoginPage(),
        "/signup_page":(context) => const SignUpPage(),
        "/home_page":(context) => const MyHomePage(title: 'dashboard'),
        "/forgot_password_page":(context) => const ForgotPasswordPage(),
        "/otp_page":(context) => const OtpScreen(),
      },
    );
  }
}
