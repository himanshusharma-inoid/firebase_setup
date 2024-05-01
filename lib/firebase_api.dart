import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/chat_model.dart';
import 'package:firebase_setup/message_model.dart';
import 'package:firebase_setup/user_model.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

class FirebaseApi{

static Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
  return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
}

static Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
  return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
}

static Future<UserCredential> signInWithCredential({required PhoneAuthCredential credential}) async {
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

static Future sendPasswordResetEmail({required String email}) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
static Future signOut() async {
  await FirebaseAuth.instance.signOut();
}


static Future addUserData({required String uid, required String email, required String url, required String userName}) async {
  UserModel userModel = UserModel(
    email: email,
    userName: userName,
    uid: uid,
    imageUrl: url
  );

  await FirebaseFirestore.instance.collection("users").doc(uid).set(userModel.toMap());
}

static Stream<QuerySnapshot> getUsersList(String userId) {
  return FirebaseFirestore.instance.collection("users").where("user_id", isNotEqualTo: userId).snapshots();
}

static Future<QuerySnapshot> createChat({required BuildContext context,required String userId, required String toId})  async {
     return await FirebaseFirestore.instance.collection("chats").where("chat_users", arrayContains: userId).get();
}

static Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessage({required String chatId}){
  return FirebaseFirestore.instance.collection("chats/$chatId/messages").orderBy("timestamp", descending: true).snapshots();
}

}
