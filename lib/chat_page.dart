import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_setup/firebase_api.dart';
import 'package:firebase_setup/message_model.dart';
import 'package:firebase_setup/utils.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  @override
  Widget build(BuildContext context) {
    arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    debugPrint("argument data is: $arguments");
    debugPrint("chat id is: ${arguments["chat_id"]}");
    chatId = arguments["chat_id"];
    userId = arguments["user_id"];
    toId = arguments["to_id"];
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "Chat"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          children: [
            _buildChatMessage(),
            Row(
              children: [
                Expanded(
                    child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: TextField(
                    controller: sendMessageController,
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
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            chatMessage = snapshot.data!.docs;
            return ListView.builder(
                reverse: true,
                itemCount: chatMessage.length,
                itemBuilder: (context, index) {
                  // if(chatMessage[index]["type"] == "text")
                  return Row(
                    mainAxisAlignment: (chatMessage[index]["from_id"] == userId) ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: (chatMessage[index]["from_id"] == userId)
                            ? const EdgeInsets.only(right: 8.0, left: 48.0, bottom: 8.0)
                            : const EdgeInsets.only(right: 48.0, left: 8.0, bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: (chatMessage[index]["from_id"] == userId) ? Colors.grey.shade300 : Colors.tealAccent),
                          child: Text(chatMessage[index]["message"]),
                        ),
                      )
                    ],
                  );
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

  void sendMessage() {
    Uuid uuid = const Uuid();
    String messageId = uuid.v1();
    MessageModel messageModel = MessageModel(
        type: "text",
        message: sendMessageController.text,
        messageId: messageId,
        fromId: userId,
        toId: toId,
        timestamp: DateTime.now().millisecondsSinceEpoch);
    FirebaseFirestore.instance
        .collection("chats/$chatId/messages")
        .doc(messageId)
        .set(messageModel.toMap());

    updateLastMessage();
    sendMessageController.clear();
  }

  void updateLastMessage() {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .update({
        "last_message": sendMessageController.text
    });
  }
}
