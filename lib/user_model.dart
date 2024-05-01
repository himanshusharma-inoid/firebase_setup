class UserModel{
  String? email;
  String? userName;
  String? uid;
  String? imageUrl;

  UserModel({this.email, this.userName, this.uid, this.imageUrl});

  UserModel.fromJson(Map<String, dynamic> map){
    email = map["email"];
    userName = map["user_name"];
    uid = map["user_id"];
    imageUrl = map["image_url"];
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "user_name": userName,
      "user_id": uid,
      "image_url": imageUrl,
    };
  }

}