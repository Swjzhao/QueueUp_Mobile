import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

class Chat_Messages extends StatefulWidget {
  static const String id = "CHATMESSAGE";
  final FirebaseUser user;

  const Chat_Messages({Key key, this.user}) : super(key: key);
  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<Chat_Messages> {
  @override
  Widget build(BuildContext context) {
  return Container();
  }

}