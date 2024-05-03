class ChatModel{
  String? chatId;
  String? lastMessage;
  int? timestamp;
  List<String>? chatUsers;
  Map<String, dynamic>? otherUserInfo;

  Map<String, dynamic>? userInfo;

  Map<String, dynamic>? participants;

  ChatModel({this.chatId, this.lastMessage, this.timestamp, required this.chatUsers, this.otherUserInfo, this.userInfo, this.participants});

  ChatModel.fromMap(Map<String, dynamic> map){
     chatId = map["chat_id"];
     lastMessage = map["last_message"];
     timestamp = map["timestamp"];
     chatUsers = map["chat_users"];
     otherUserInfo = map["otherUserInfo"];
     userInfo = map["userInfo"];
     participants = map["participants"];
  }

  Map<String, dynamic> toMap(){
    return {
      "chat_id": chatId,
      "last_message": lastMessage,
      "timestamp": timestamp,
      "chat_users": chatUsers,
      "otherUserInfo": otherUserInfo,
      "userInfo": userInfo,
      "participants": participants
    };
  }

}

class OtherUserInfoModel {
  String? userName;
  String? userId;
  String? imageUrl;

  OtherUserInfoModel({this.userName, this.userId, this.imageUrl});

  OtherUserInfoModel.fromMap(Map<String, dynamic> map){
     userName = map["user_name"];
     userId = map["user_id"];
     imageUrl = map["image_url"];
  }

  Map<String, dynamic> toMap(){
    return {
    "user_name": userName,
    "user_id": userId,
    "image_url": imageUrl
    };
  }

}

class UserInfoModel {
  String? userName;
  String? userId;
  String? imageUrl;

  UserInfoModel({this.userName, this.userId, this.imageUrl});

  UserInfoModel.fromMap(Map<String, dynamic> map){
    userName = map["user_name"];
    userId = map["user_id"];
    imageUrl = map["image_url"];
  }

  Map<String, dynamic> toMap(){
    return {
    "user_name": userName,
    "user_id": userId,
    "image_url": imageUrl
    };
  }

}