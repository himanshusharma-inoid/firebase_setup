import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/firebase_api.dart';
import 'package:firebase_setup/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String? fcmToken;

  String kPushNotificationUrl = "https://fcm.googleapis.com/fcm/send";
  String cloudMessagingServerKey = "AAAAwlEz-SM:APA91bEUVpuRO5ka5_iy6Elh_hkJdewVvqVXOy6DLTww7qOR4ftUfKqT7pXjh1PwB-gm9llevym141StouTw1UgI4oznkipjAIKtL5hlREkvat15kLISTMbK6ZTQAj9MoFLtlhXXMfON";
  TextEditingController searchTextEditingController = TextEditingController();
  String _textSearch = "";

  @override
  void initState() {
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
            onTap: () => sendNotification(),
            child: const Icon(Icons.notification_add_outlined)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
                onTap: () => firebaseLogout(),
                child: const Icon(Icons.logout)),
          ),
        ],
      ),
      body: Column(
        children: [
          buildSearchBar(),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseApi().getUserData(),
              builder: (context,  snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator());
                  }else if(snapshot.connectionState == ConnectionState.active){
                    if(snapshot.hasData) {
                      List userList = snapshot.data!.docs;
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.boy_outlined),
                                  imageUrl: userList[index]["image_url"],
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(userList[index]["email"]),
                            );
                          },
                        separatorBuilder: (BuildContext context, int index) {
                           return const Divider(
                             thickness: 1,
                             indent: 10,
                             endIndent: 10,
                             color: Colors.black12,
                           );
                        },
                      );
                    }else if(snapshot.hasError){
                      return const Text("something went wrong");
                    }
                  }return const Text("something went wrong");
              }
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          const Icon(
            Icons.person_search,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                   setState(() {
                    _textSearch = value;
                  });
                } else {
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          // StreamBuilder(
          //     stream: buttonClearController.stream,
          //     builder: (context, snapshot) {
          //       return snapshot.data == true
          //           ? GestureDetector(
          //         onTap: () {
          //           searchTextEditingController.clear();
          //           buttonClearController.add(false);
          //           setState(() {
          //             _textSearch = '';
          //           });
          //         },
          //         child: const Icon(
          //           Icons.clear_rounded,
          //           color: AppColors.greyColor,
          //           size: 20,
          //         ),
          //       )
          //           : const SizedBox.shrink();
          //     })
        ],
      ),
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
    FirebaseApi().signOut();
    // FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login_page", (route) => false);
  }



}