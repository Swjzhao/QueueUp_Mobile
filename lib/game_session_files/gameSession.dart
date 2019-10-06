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
  final int currentCapacity;
  final int maxCapacity;

  GameSession(
      {Key key,
      @required this.currentUserId,
      @required this.gameId,
      @required this.gameName,
      @required this.gameSessionName,
      @required this.gameSessionID,
      @required this.hostID,
      @required this.hostName,
      @required this.currentCapacity,
      @required this.maxCapacity})
      : super(key: key);

  @override
  State createState() => new GameSessionState(
      currentUserId: currentUserId,
      gameId: gameId,
      gameName: gameName,
      gameSessionName: gameSessionName,
      gameSessionID: gameSessionID,
      hostID: hostID,
      hostName: hostName,
      currentCapacity: currentCapacity,
      maxCapacity: maxCapacity);
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
      @required this.hostName,
      @required this.currentCapacity,
      @required this.maxCapacity});

  bool isLoading = false;
  String currentUserId;
  String gameId;
  String gameName;
  String gameSessionName;
  String gameSessionID;
  String hostID;
  String hostName;
  int currentCapacity;
  int maxCapacity;

  String username;

  SharedPreferences prefs;
  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
  }
  void initState() {
    super.initState();
    readLocal();
  }

  void handleJoinSession() {
    print(currentCapacity.toString() + ' ' + maxCapacity.toString());
    if (currentCapacity == maxCapacity) {
      Fluttertoast.showToast(msg: "Full");
      return;
    }
    setState(() {
      isLoading = true;
    });

    Firestore.instance
        .collection('gameSessions')
        .document(gameId)
        .collection('sessions')
        .document(hostID)
        .collection('players')
        .document(DateTime.now().millisecondsSinceEpoch.toString())
        .setData({'playerID': currentUserId,
    'playerName':username}).then((data) async {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Session Joined");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });

    Firestore.instance
        .collection('gameSessions')
        .document(gameId)
        .collection('sessions')
        .document(hostID)
        .updateData({'currentCapacity': ++currentCapacity}).then((data) async {
      Navigator.pop(context);
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingWindow;
    if (currentUserId != hostID) {
      floatingWindow = FloatingActionButton.extended(
        backgroundColor: Theme.of(context).buttonColor,
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          "Join",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: handleJoinSession,
      );
    } else {
      floatingWindow = Container();
    }

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
                                    padding: EdgeInsets.only(bottom: 10, top: 10),
                                    itemBuilder: (context, index) => buildItem(
                                        context,
                                        snapshot.data.documents[index],
                                        index + 2),
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
                floatingActionButton: floatingWindow));
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
                        '${document['playerName']}',
                        style: TextStyle(color: primaryColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                    Container(
                      child: Text(
                        'Other Info',
                        style: TextStyle(color: primaryColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    )
                  ],
                ),
              ),
            ),

          ],
        ),
        onPressed: handleJoinSession,
        color: greyColor2,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }
}
