import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queueup_mobileapp/const.dart';

class GameSession extends StatefulWidget {
  static const String id = "GameSessions";

  final String currentUserId;
  final String gameId;
  final String gameName;
  final String gameSessionName;
  final String gameSessionID;
  final String hostID;
  final String hostName;

  GameSession(
      {Key key,
      @required this.currentUserId,
      @required this.gameId,
      @required this.gameName,
      @required this.gameSessionName,
      @required this.gameSessionID,
      @required this.hostID,
      @required this.hostName})
      : super(key: key);

  @override
  State createState() => new GameSessionState(
      currentUserId: currentUserId,
      gameId: gameId,
      gameName: gameName,
      gameSessionName: gameSessionName,
      gameSessionID: gameSessionID,
      hostID: hostID,
      hostName: hostName);
}

class GameSessionState extends State<GameSession> {
  GameSessionState(
      {Key key,
      @required this.currentUserId,
      @required this.gameId,
      @required this.gameName,
      @required this.gameSessionName,
      @required this.gameSessionID,
      @required this.hostID,
      @required this.hostName});

  bool isLoading = false;
  String currentUserId;
  String gameId;
  String gameName;
  String gameSessionName;
  String gameSessionID;
  String hostID;
  String hostName;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            gameSessionName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Container()
            : Scaffold(
                body: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          child: FlatButton(

                            child: Row(
                              children: <Widget>[
                                Text(
                                  '1 ',
                                  style: TextStyle(color: primaryColor),
                                ),
                                Flexible(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            'Host ',
                                            style:
                                                TextStyle(color: primaryColor),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.fromLTRB(
                                              10.0, 0.0, 0.0, 5.0),
                                        ),
                                        Container(
                                          child: Text(
                                            hostName,
                                            style:
                                                TextStyle(color: primaryColor),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.fromLTRB(
                                              10.0, 0.0, 0.0, 0.0),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {},
                            color: greyColor2,
                            padding:
                                EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          margin: EdgeInsets.only(
                              bottom: 10.0, left: 5.0, right: 5.0),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            child: StreamBuilder(
                              stream: Firestore.instance
                                  .collection('gameSessions')
                                  .document(gameId)
                                  .collection("sessions")
                                  .document(gameSessionID)
                                  .collection("players")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    padding: EdgeInsets.all(10.0),
                                    itemBuilder: (context, index) => buildItem(
                                        context,
                                        snapshot.data.documents[index],
                                    index+1),
                                    itemCount: snapshot.data.documents.length,
                                  );
                                }
                              },
                            ),
                          ),

                          // Loading
                        ],
                      ),
                    )
                  ],
                ),
                floatingActionButton: new FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).buttonColor,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Join",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document, int index) {
    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
            Text(
              index.toString(),
              style: TextStyle(color: primaryColor),
            ),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${document['sessionName']}',
                        style: TextStyle(color: primaryColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                    Container(
                      child: Text(
                        'Hosted by: ${document['hostName']}',
                        style: TextStyle(color: primaryColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    )
                  ],
                ),
              ),
            ),
            Text(
              '${document['currentCapacity']} / ${document['maxCapacity']} ',
              style: TextStyle(color: primaryColor),
            ),
          ],
        ),
        onPressed: () {},
        color: greyColor2,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }
}
