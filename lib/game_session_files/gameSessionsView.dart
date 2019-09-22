import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queueup_mobileapp/const.dart';

class GameSessions extends StatefulWidget {
  static const String id = "GameSessions";

  final String currentUserId;
  final String gameId;

  GameSessions({Key key, @required this.currentUserId, @required this.gameId})
      : super(key: key);

  @override
  State createState() =>
      new GameSessionsState(currentUserId: currentUserId, gameId: gameId);
}

class GameSessionsState extends State<GameSessions> {
  GameSessionsState(
      {Key key, @required this.currentUserId, @required this.gameId});
  bool isLoading = false;
  String currentUserId;
  String gameId;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container();
    } else {
      return Scaffold(
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
                  print(gameId);

                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );

                },
              ),
            ),

            // Loading
          ],
        ),
        floatingActionButton: new FloatingActionButton.extended(
          backgroundColor: Theme.of(context).accentColor,
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: Text(
            "Create a new Session",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {},
        ),
      );
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    print('${document['sessionName']}');
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
