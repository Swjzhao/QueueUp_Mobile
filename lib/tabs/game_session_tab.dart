import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class GameSessionTab extends StatefulWidget {
  static const String id = "GameSessionTab";

  final String currentUserId;

  GameSessionTab({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new GameSessionTabState(currentUserId:currentUserId);
}

class GameSessionTabState extends State<GameSessionTab> {
   GameSessionTabState({Key key, @required this.currentUserId});
  String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}