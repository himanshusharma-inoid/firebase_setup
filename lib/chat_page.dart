import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_setup/firebase_api.dart';
import 'package:firebase_setup/message_model.dart';
import 'package:firebase_setup/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'main.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var arguments = {};
  TextEditingController sendMessageController = TextEditingController();
  List chatMessage = [];
  String chatId = "";
  String userId = "";
  String toId = "";
  String deviceBrand = "";
  String userName = "";
  String imageUrl = "";
  String otherUserName = "";

  CroppedFile? croppedImageFile;
  XFile? resultFile;

  bool isImageLoading = false;
  @override
  void initState() {
    getDeviceInfo();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    debugPrint("argument data is: $arguments");
    debugPrint("chat id is: ${arguments["chat_id"]}");
    chatId = arguments["chat_id"];
    userId = arguments["user_id"];
    toId = arguments["to_id"];
    userName = arguments["user_name"];
    imageUrl = arguments["image_url"];
    otherUserName = arguments["other_user_name"];
    getOtherUserInfo();
   // updateSeenMessage();
    return Scaffold(
      appBar: AppUtils.customAppbar(text: otherUserName, imageUrl: imageUrl, voidCallback: ()=> Navigator.of(context).pop(), fromChatPage: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildChatMessage(),
            (isImageLoading)
                ? Padding(
                   padding: const EdgeInsets.only(right: 8.0, left: 48.0, bottom: 8.0),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                      child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Image.file(File(resultFile!.path), height: 200, width: 200, fit: BoxFit.cover,))),
                )
                : const SizedBox(),
            Row(
              children: [
                InkWell(
                    onTap: openGallery,
                    child: const Icon(Icons.camera_alt_outlined)),
                const SizedBox(width: 10),
                Expanded(
                    child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: TextField(
                    controller: sendMessageController,
                    onChanged: (value){
                      if(value != "") {
                        updateTypingStatus(true);
                      }else{
                        updateTypingStatus(false);
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 12.0, bottom: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      hintText: "send message.."
                    ),
                  ),
                )),
                const SizedBox(width: 10),
                InkWell(
                    onTap: () {
                      FocusNode currentFocus = FocusScope.of(context);
                      if(!currentFocus.hasPrimaryFocus){
                        currentFocus.unfocus();
                      }
                      if (sendMessageController.text != "") {
                        sendMessage();
                      }
                    },
                    child: const Icon(Icons.send))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage() {
    return Expanded(
        child: StreamBuilder(
      stream: FirebaseApi.getChatMessage(chatId: chatId),
      builder: (BuildContext context, snapshot) {
        updateSeenMessage();
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            chatMessage = snapshot.data!.docs;
            return ListView.builder(
                reverse: true,
                itemCount: chatMessage.length,
                itemBuilder: (context, index) {
                  if (chatMessage[index]["type"] == "text"){
                    return Row(
                      mainAxisAlignment: (chatMessage[index]["from_id"] == userId) ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: (chatMessage[index]["from_id"] == userId) ? const EdgeInsets.only(right: 8.0, left: 48.0, bottom: 8.0) : const EdgeInsets.only(right: 48.0, left: 8.0, bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: (chatMessage[index]["from_id"] == userId)
                                    ? Colors.grey.shade300
                                    : Colors.tealAccent),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0, right: 24.0, top: 8.0, bottom: 12.0),
                                  child: Text(chatMessage[index]["message"]),
                                ),
                                (chatMessage[index]["from_id"] == userId) ? Positioned(
                                    bottom: 2.0,
                                    right: 5.0,
                                    child: Icon(Icons.done_all_outlined, size: 15.0, color: chatMessage[index]["seen"] == false ? Colors.grey.shade600 : Colors.blueAccent)) : const SizedBox()
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  if(chatMessage[index]["type"] == "media") {
                    return Row(
                      mainAxisAlignment: (chatMessage[index]["from_id"] == userId) ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: (chatMessage[index]["from_id"] == userId) ? const EdgeInsets.only(right: 8.0, left: 48.0, bottom: 8.0)
                              : const EdgeInsets.only(right: 48.0,
                              left: 8.0,
                              bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black12.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.boy_outlined),
                                    imageUrl: chatMessage[index]["image_url"],
                                    height: 200.0,
                                    width: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                (chatMessage[index]["from_id"] == userId) ?
                                Positioned(
                                    bottom: 2.0,
                                    right: 5.0,
                                    child: Icon(Icons.done_all_outlined, size: 15.0, color: chatMessage[index]["seen"] == false ? Colors.grey : Colors.blueAccent)) : const SizedBox()
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                });
          } else if (snapshot.hasError) {
            return const Text("something went wrong");
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Text("something went wrong");
      },
    ));
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
        uploadData();
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

  Future<void> uploadData() async {
    setState(() {
      isImageLoading = true;
    });
    ///Create a Reference
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref("chat_images");
    final Ref = storageRef.child(chatId).child(fileName);

    /// upload file
    UploadTask uploadTask = Ref.putFile(File(resultFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask;
    String url = await taskSnapshot.ref.getDownloadURL();

    /// send data into firestore database
    uploadMediaImages(url);

  }

  void uploadMediaImages(String url) {
    Uuid uuid = const Uuid();
    String messageId = uuid.v1();
    MessageModel messageModel = MessageModel(
        type: "media",
        message: "sent media--",
        messageId: messageId,
        fromId: userId,
        toId: toId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        imageUrl: url,
        seen: false);
    FirebaseFirestore.instance
        .collection("chats/$chatId/messages")
        .doc(messageId)
        .set(messageModel.toMap());

    updateLastMessage("sent media--");
    setState(() {
      isImageLoading = false;
    });
    // sendNotification();
  }

  void sendMessage() {
    Uuid uuid = const Uuid();
    String messageId = uuid.v1();
    MessageModel messageModel = MessageModel(
        type: "text",
        message: sendMessageController.text,
        messageId: messageId,
        fromId: userId,
        toId: toId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        seen: false);
    FirebaseFirestore.instance
        .collection("chats/$chatId/messages")
        .doc(messageId)
        .set(messageModel.toMap());

    updateLastMessage(sendMessageController.text);
    sendNotification();
    sendMessageController.clear();
  }

  void updateLastMessage(String lastMessage) {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .update({
        "last_message": lastMessage
    });
  }

  Future<void> getDeviceInfo() async {
    if(Platform.isAndroid){
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceBrand = androidInfo.brand;
    }
    // else{
    //   final iosInfo = await DeviceInfoPlugin().iosInfo;
    //   deviceBrand = iosInfo.utsname.machine;
    // }
    if(kDebugMode){
      debugPrint("device brand is: $deviceBrand");
    }
  }

  Future<void> sendNotification() async {
    String kPushNotificationUrl = "https://fcm.googleapis.com/fcm/send";
    String cloudMessagingServerKey = "AAAAwlEz-SM:APA91bEUVpuRO5ka5_iy6Elh_hkJdewVvqVXOy6DLTww7qOR4ftUfKqT7pXjh1PwB-gm9llevym141StouTw1UgI4oznkipjAIKtL5hlREkvat15kLISTMbK6ZTQAj9MoFLtlhXXMfON";

    /// Vivo 1907 device
    if(deviceBrand == "Redmi"){
      Map<String, dynamic> data = {
        "to": "f9hxBP_sQZmOjoscnyjuYH:APA91bFq7JoaZAj1-dc0VzTf3aafHuVHAG1rMg6qAYosIHLFxuffhiOIwbcTYgwZMuIoevmZ_YqA0QHI6APjljSLUstkXMQ8hneywTwTJZgayAYYq4Jb_SbYSWCozmFjQc9Ybk9ORupy",
        "notification": {
          "title" : userName.toString(),
          "body" : sendMessageController.text,
        },
        "data":{
          "type" : "New_Chat_Message",
          "chat_id": chatId,
          "user_id": userId,
          "to_id": toId,
          "user_name": userName
        }
      };

      Map<String, String> headers = {
        "content-Type": "application/json; charset=UTF-8",
        "Authorization": "key=$cloudMessagingServerKey"
      };

      http.post(Uri.parse(kPushNotificationUrl), body: jsonEncode(data), headers: headers);

    }
    /// Redmi Device number 4
    else if(deviceBrand == "vivo"){
      Map<String, dynamic> data = {
        "to": "emjGwMFtTV-ZYPi0A_E56U:APA91bFv3O6Ue7mepXOAueJyRf8GKSBZmA235fhhkxkkLaDpit6XJNTk8FuQcUjp4tZKZ9B1i8YS20rBehfmGwsIraDO9BMefExx-4ThZoJcj79HBX1IPZtyk3iOelt4zOUyC-XqpXjm",
        "notification": {
          "title" : userName.toString(),
          "body" : sendMessageController.text,
        },
        "data":{
          "type" : "New_Chat_Message",
          "chat_id": chatId,
          "user_id": userId,
          "to_id": toId,
          "user_name": userName
        }
      };

      Map<String, String> headers = {
        "content-Type": "application/json; charset=UTF-8",
        "Authorization": "key=$cloudMessagingServerKey"
      };

      http.post(Uri.parse(kPushNotificationUrl), body: jsonEncode(data), headers: headers);

    }
  }

  Future<void> getOtherUserInfo() async {
    FirebaseFirestore.instance.collection("users").where("user_id", isEqualTo: toId).snapshots().listen((querySnapshot) {
      typingStatus.value = querySnapshot.docs.single["typing"];
      onlineStatus.value = querySnapshot.docs.single["online"];
      debugPrint("user id is: $userId");
      debugPrint("online status is: ${onlineStatus.value}");
   });

  }

  void updateTypingStatus(bool typingStatus) {
    FirebaseFirestore.instance.collection("users").doc(userId).update(
        {
          "typing": typingStatus
        });
  }

  Future<void> updateSeenMessage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("chats/$chatId/messages")
        .where('to_id', isEqualTo: userId)
        .where('seen', isEqualTo: false).get();
    debugPrint('docs is: ${querySnapshot.docs.length}');
    for(var doc in querySnapshot.docs){
      doc.reference.update({"seen": true});
    }
  }
}
