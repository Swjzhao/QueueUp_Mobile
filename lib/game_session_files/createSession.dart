import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/game_session_files/gameSessionsView.dart';


class CreateSession extends StatefulWidget {
  static const String id = "CreateSession";

  final String currentUserId;
  final String gameId;
  final String gameName;

  CreateSession({Key key, @required this.currentUserId, @required this.gameId, @required this.gameName})
      : super(key: key);

  @override
  State createState() =>
      new CreateSessionState(currentUserId: currentUserId, gameId: gameId, gameName: gameName);
}

class CreateSessionState extends State<CreateSession> {
  CreateSessionState(
      {Key key, @required this.currentUserId, @required this.gameId, @required this.gameName});

  bool isLoading = false;
  String currentUserId;
  String gameId;
  String gameName;

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Create a new session!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new Container()
    );
  }
}