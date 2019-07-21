import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Auth.dart';

class Game_Sessions extends StatefulWidget {
  static const String id = "GAME_SESSION";

  final FirebaseUser user;

  const Game_Sessions({Key key, this.user}) : super(key: key);
  @override
  _Game_SessionsState createState() => _Game_SessionsState();
}

class _Game_SessionsState extends State<Game_Sessions> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
