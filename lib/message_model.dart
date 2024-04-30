class MessageModel{
  String? type;
  String? message;
  String? messageId;

  String? fromId;

  String? toId;
  int? timestamp;
  MessageModel({this.type, this.message, this.messageId, this.fromId, this.toId, this.timestamp});

  MessageModel.fromMap(Map<String, dynamic> map){
    type = map["type"];
    message = map["message"];
    messageId = map["message_id"];
    fromId = map["from_id"];
    toId = map["to_id"];
    timestamp = map["timestamp"];
  }

   Map<String, dynamic> toMap(){
    return{
      "type": type,
      "message": message,
      "message_id": messageId,
      "from_id": fromId,
      "to_id": toId,
      "timestamp": timestamp,
    };
  }

}