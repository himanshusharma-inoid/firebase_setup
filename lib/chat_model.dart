class ChatModel{
  String? chatId;
  String? lastMessage;
  String? userId;
  String? toId;
  List<String>? chatUsers;
  int? timestamp;

  ChatModel({this.chatId, this.userId, this.toId, this.lastMessage, this.timestamp, required this.chatUsers});

  ChatModel.fromMap(Map<String, dynamic> map){
     chatId = map["chat_id"];
     userId = map["user_id"];
     toId = map["to_id"];
     lastMessage = map["last_message"];
     timestamp = map["timestamp"];
     chatUsers = map["chat_users"];
  }

  Map<String, dynamic> toMap(){
    return {
      "chat_id": chatId,
      "user_id": userId,
      "to_id": toId,
      "last_message": lastMessage,
      "timestamp": timestamp,
      "chat_users": chatUsers
    };
  }

}