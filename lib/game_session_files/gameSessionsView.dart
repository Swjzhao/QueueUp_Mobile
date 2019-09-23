import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:queueup_mobileapp/game_session_files/createSession.dart';

class GameSessions extends StatefulWidget {
  static const String id = "GameSessions";

  final String currentUserId;
  final String gameId;
  final String gameName;

  GameSessions(
      {Key key,
      @required this.currentUserId,
      @required this.gameId,
      @required this.gameName})
      : super(key: key);

  @override
  State createState() => new GameSessionsState(
      currentUserId: currentUserId, gameId: gameId, gameName: gameName);
}

class GameSessionsState extends State<GameSessions> {
  GameSessionsState(
      {Key key,
      @required this.currentUserId,
      @required this.gameId,
      @required this.gameName});
  bool isLoading = false;
  String currentUserId;
  String gameId;
  String gameName;



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            gameName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Container()
            : Scaffold(
                body: Stack(
                  children: <Widget>[
                    Container(
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('gameSessions')
                            .document(gameId)
                            .collection("sessions")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              padding: EdgeInsets.all(10.0),
                              itemBuilder: (context, index) => buildItem(
                                  context, snapshot.data.documents[index]),
                              itemCount: snapshot.data.documents.length,
                            );
                          }
                        },
                      ),
                    ),

                    // Loading
                  ],
                ),
                floatingActionButton: new FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).buttonColor,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Create a session",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateSession(
                                  currentUserId: currentUserId,
                                  gameId: gameId,
                                  gameName: gameName,
                                )));
                  },
                ),
              ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
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

/*
return Scaffold(
      body:
      Stack(
        children: <Widget>[
          // List
          Container(
            child: StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(context, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            ),
          ),
          // Loading
        ],
      ),
      };
 */
