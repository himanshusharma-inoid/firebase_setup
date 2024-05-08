import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_setup/chat_model.dart';
import 'package:firebase_setup/firebase_api.dart';
import 'package:firebase_setup/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{

  String? fcmToken;

  String kPushNotificationUrl = "https://fcm.googleapis.com/fcm/send";
  String cloudMessagingServerKey = "AAAAwlEz-SM:APA91bEUVpuRO5ka5_iy6Elh_hkJdewVvqVXOy6DLTww7qOR4ftUfKqT7pXjh1PwB-gm9llevym141StouTw1UgI4oznkipjAIKtL5hlREkvat15kLISTMbK6ZTQAj9MoFLtlhXXMfON";
  TextEditingController searchTextEditingController = TextEditingController();
  String _textSearch = "";

  List userList = [];
  List chatList = [];
  List searchUserList = [];
  String? userId;
  String? userName;
  String? imageUrl;
  String? toId;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    updateOnlineStatus(true);
    getUserInformations();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    debugPrint("appLifecycle state is: $appLifecycleState");
    if(appLifecycleState == AppLifecycleState.resumed){
      updateOnlineStatus(true);
    }else{
      updateOnlineStatus(false);
    }
    super.didChangeAppLifecycleState(appLifecycleState);
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
      body: (userId != null) ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildUserList(),
          buildSearchBar(),
          const SizedBox(height: 5.0),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 20),
            child: Text("Chats", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.0)),
          ),
          buildChatList(),
        ],
      ) : const Center(child: CircularProgressIndicator()),
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
                searchUserList.clear();
                if (value.isNotEmpty) {
                  for (var userDetail in chatList) {
                    if (userId == userDetail["userInfo"]['user_id']) {
                      if (userDetail["otherUserInfo"]["user_name"].contains(value)) {
                        searchUserList.add(userDetail);
                        debugPrint("search user details is: ${searchUserList.length}");
                      }
                    }else{
                      if (userDetail["userInfo"]["user_name"].contains(value)) {
                        searchUserList.add(userDetail);
                        debugPrint("search user details is: ${searchUserList.length}");
                      }
                    }
                  }
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
        "title" : userName.toString(),
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
    FirebaseApi.signOut();
    // FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login_page", (route) => false);
  }

  Future<void> getUserInformations() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString("USER_ID");
    FirebaseFirestore.instance.collection("users").where("user_id", isEqualTo: userId).snapshots().listen((querySnapshot) {
      userId = querySnapshot.docs.single["user_id"];
      userName = querySnapshot.docs.single["user_name"];
      imageUrl = querySnapshot.docs.single["image_url"];
      debugPrint("user id is: $userId");
      setState(() {});
    });
   // final querySnapshot = await FirebaseFirestore.instance.collection("users").where("user_id", isEqualTo: userId).get();
  }

  buildUserList() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      height: 60.0,
      child: StreamBuilder(
          stream: FirebaseApi.getUsersList(userId!) ,
          builder: (context,  snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }else if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.hasData) {
                userList = snapshot.data!.docs;
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(right: 8.0),
                  itemCount: userList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        FirebaseApi.createChat(context: context, userId: userId!, toId: snapshot.data!.docs[index]["user_id"]).then((querySnapshot) {
                          if(querySnapshot.docs.isNotEmpty){
                            debugPrint("chat is already created");
                            String chatId = querySnapshot.docs.single['chat_id'];
                            String otherUserName = querySnapshot.docs.single['user_name'];
                            Navigator.pushNamed(context, "/chat_page", arguments: {"chat_id": chatId, "user_id": userId, "to_id": snapshot.data!.docs[index]["user_id"], "user_name": userName.toString(), "image_url": userList[index]["image_url"], "other_user_name": otherUserName});
                          }else{
                            debugPrint("new chat created");
                            var uuid = const Uuid();
                            String chatId = uuid.v1();
                            OtherUserInfoModel otherUserInfo = OtherUserInfoModel(
                              userName: userList[index]["user_name"],
                              userId: userList[index]["user_id"],
                              imageUrl: userList[index]["image_url"]
                            );
                            UserInfoModel userInfo = UserInfoModel(
                                userName: userName,
                                userId: userId,
                                imageUrl: imageUrl
                            );
                            ChatModel chatModel = ChatModel(
                                chatId: chatId,
                                lastMessage: "",
                                timestamp: DateTime.now().millisecondsSinceEpoch,
                                chatUsers: [userId!, snapshot.data!.docs[index]["user_id"]],
                                otherUserInfo: otherUserInfo.toMap(),
                                userInfo: userInfo.toMap(),
                                participants: {
                                  userId!: true,
                                  snapshot.data!.docs[index]["user_id"]: true
                                }
                            );

                            FirebaseFirestore.instance.collection("chats").doc(chatId).set(chatModel.toMap());

                            Navigator.pushNamed(context, "/chat_page", arguments: {"chat_id": chatId, "user_id": userId, "to_id": snapshot.data!.docs[index]["user_id"], "user_name": userName.toString(), "image_url": userList[index]["image_url"], "other_user_name": userList[index]["user_name"]});
                          }
                        });

                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.boy_outlined),
                          imageUrl: userList[index]["image_url"],
                          height: 60.0,
                          width: 60.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 1,
                      height: 50,
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
    );
  }

  buildChatList() {
    return Expanded(
        child: (_textSearch == "") ?
        StreamBuilder(
            stream: FirebaseApi.getChatList(userId!) ,
            builder: (context,  snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }else if(snapshot.connectionState == ConnectionState.active){
                if(snapshot.hasData) {
                  chatList = snapshot.data!.docs;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          String chatId = chatList[index]['chat_id'];
                          if(userId == chatList[index]["userInfo"]['user_id']){
                            toId = chatList[index]["otherUserInfo"]['user_id'];
                            imageUrl = chatList[index]["otherUserInfo"]['image_url'];
                          }else{
                            toId = chatList[index]["userInfo"]['user_id'];
                            imageUrl = chatList[index]["userInfo"]['image_url'];
                          }
                          Navigator.pushNamed(context, "/chat_page", arguments: {"chat_id": chatId, "user_id": userId, "to_id": toId, "user_name": userName.toString(), "image_url": imageUrl, "other_user_name": userId == chatList[index]["userInfo"]['user_id'] ? chatList[index]["otherUserInfo"]['user_name'] : chatList[index]["userInfo"]['user_name']});
                          },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.boy_outlined),
                                imageUrl: userId == chatList[index]["userInfo"]['user_id'] ? chatList[index]["otherUserInfo"]["image_url"] : chatList[index]["userInfo"]['image_url'],
                                height: 60.0,
                                width: 60.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(userId == chatList[index]["userInfo"]['user_id'] ? chatList[index]["otherUserInfo"]['user_name'] : chatList[index]["userInfo"]['user_name']),
                            subtitle: chatList[index]["last_message"] != "" ?
                            Text(chatList[index]["last_message"]) : const Text("sent hii to this user..", style: TextStyle(color: Colors.tealAccent)),
                          ),
                        ),
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
        ) : ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          itemCount: searchUserList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){

              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.boy_outlined),
                      imageUrl: userId == searchUserList[index]["userInfo"]['user_id'] ? searchUserList[index]["otherUserInfo"]["image_url"] : searchUserList[index]["userInfo"]['image_url'],
                      height: 60.0,
                      width: 60.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(userId == searchUserList[index]["userInfo"]['user_id'] ? searchUserList[index]["otherUserInfo"]['user_name'] : searchUserList[index]["userInfo"]['user_name']),
                  subtitle: searchUserList[index]["last_message"] != "" ?
                  Text(searchUserList[index]["last_message"]) : const Text("sent hii to this user..", style: TextStyle(color: Colors.tealAccent)),
                ),
              ),
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
        )
    );
  }

  void updateOnlineStatus(bool onlineStatus) {
    FirebaseFirestore.instance.collection("users").doc(userId).update(
        {
          "online": onlineStatus
        });
  }

}