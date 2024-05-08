class MessageModel{
  String? type;
  String? message;
  String? messageId;
  String? fromId;
  String? toId;
  int? timestamp;
  String? imageUrl;
  bool? seen;
  MessageModel({this.type, this.message, this.messageId, this.fromId, this.toId, this.timestamp, this.imageUrl, this.seen});

  MessageModel.fromMap(Map<String, dynamic> map){
    type = map["type"];
    message = map["message"];
    messageId = map["message_id"];
    fromId = map["from_id"];
    toId = map["to_id"];
    timestamp = map["timestamp"];
    imageUrl = map["image_url"];
    seen = map["seen"];
  }

   Map<String, dynamic> toMap(){
    return{
      "type": type,
      "message": message,
      "message_id": messageId,
      "from_id": fromId,
      "to_id": toId,
      "timestamp": timestamp,
      "image_url": imageUrl,
      "seen": seen,
    };
  }

}