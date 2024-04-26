import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_string/random_string.dart';

class FirebaseApi{

Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
  return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
}

Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
  return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
}

Future<UserCredential> signInWithCredential({required PhoneAuthCredential credential}) async {
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future sendPasswordResetEmail({required String email}) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
Future signOut() async {
  await FirebaseAuth.instance.signOut();
}


Future addUserData({required String email, required String url}) async {
  String id = randomAlphaNumeric(10);
  await FirebaseFirestore.instance.collection("users").doc(email).set({
    "email": email,
    "image_url": url,
    "id": id
  });
}

Stream<QuerySnapshot> getUserData() {
  return FirebaseFirestore.instance.collection("users").snapshots();
}
}