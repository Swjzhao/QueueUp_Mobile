import 'package:flutter/material.dart';

class GameSessions extends StatefulWidget {
  static const String id = "GameSessions";

  final String currentUserId;

  GameSessions({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new GameSessionsState(currentUserId: currentUserId);
}

class GameSessionsState extends State<GameSessions> {
  GameSessionsState({Key key, @required this.currentUserId});
  bool isLoading = false;
  String currentUserId;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container();
    } else {
      return Container();
    }
  }
}
