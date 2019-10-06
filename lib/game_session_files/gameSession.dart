import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:intl/intl.dart';
import 'package:queueup_mobileapp/explore_files/detail.dart';

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
  final String timeStr1;
  final String timeStr2;
  final String gameType;

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
      @required this.maxCapacity,
      @required this.timeStr1,
      @required this.timeStr2,
      @required this.gameType})
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
      maxCapacity: maxCapacity,
      timeStr1: timeStr1,
      timeStr2: timeStr2,
      gameType: gameType);
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
      @required this.maxCapacity,
      @required this.timeStr1,
      @required this.timeStr2,
      @required this.gameType});

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
  String timeStr1;
  String timeStr2;
  String gameType;

  String username;
  TimeOfDay _time;
  TimeOfDay _time2;

  SharedPreferences prefs;
  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
  }

  String timeStart;
  String timeEnd;
  final f = new DateFormat('hh:mm');
  void initState() {
    super.initState();
    List<String> time1s = timeStr1.split(':');
    List<String> time2s = timeStr2.split(':');
    _time =
        new TimeOfDay(hour: int.parse(time1s[0]), minute: int.parse(time1s[1]));
    _time2 =
        new TimeOfDay(hour: int.parse(time2s[0]), minute: int.parse(time2s[1]));
    timeStart = f
            .format(
                new DateTime(2019, 01, 01, _time.hourOfPeriod, _time.minute))
            .toString() +
        " " +
        (_time.hour.toString() != _time.hourOfPeriod.toString() ? 'PM' : 'AM');

    timeEnd = f
            .format(
                new DateTime(2019, 01, 01, _time2.hourOfPeriod, _time2.minute))
            .toString() +
        " " +
        (_time2.hour.toString() != _time2.hourOfPeriod.toString()
            ? 'PM'
            : 'AM');

    readLocal();
  }

  void clickUser(String playerID) {
    Firestore.instance
        .collection('users')
        .document(playerID)
        .get()
        .then((DocumentSnapshot ds) {
      Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => new DetailPage(snapshot: ds),
      ));
    });
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
        .document(currentUserId)
        .get()
        .then((data) async {
      if (!data.exists) {
        Firestore.instance
            .collection('gameSessions')
            .document(gameId)
            .collection('sessions')
            .document(hostID)
            .updateData({'currentCapacity': ++currentCapacity})
            .then((data) async {})
            .catchError((err) {
          Fluttertoast.showToast(msg: err.toString());
        });
      }

      Firestore.instance
          .collection('gameSessions')
          .document(gameId)
          .collection('sessions')
          .document(hostID)
          .collection('players')
          .document(currentUserId)
          .setData({
        'playerID': currentUserId,
        'playerName': username,
        'joinedAt': DateTime.now().millisecondsSinceEpoch
      });

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
        .collection('users')
        .document(currentUserId)
        .collection('sessions')
        .document(gameSessionID)
        .setData({'gameSessionID': gameSessionID}).then((data) async {
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

    Color tabColor =
        currentUserId == hostID ? ThemeData.light().cardColor : greyColor2;
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
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              bottom: 5.0, left: 15.0, right: 5.0),
                          child: Text('Lobby'),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              bottom: 5.0, left: 15.0, right: 5.0),
                          child: Text(gameType),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              bottom: 5.0, left: 15.0, right: 5.0),
                          child: Text(timeStart + " to " + timeEnd),
                        )
                      ],
                    ),
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
                            onPressed: () {
                              Firestore.instance
                                  .collection('users')
                                  .document(hostID)
                                  .get()
                                  .then((DocumentSnapshot ds) {
                                Navigator.of(context).push(new PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      new DetailPage(snapshot: ds),
                                ));
                              });
                            },
                            color: tabColor,
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
                                  .orderBy('joinedAt')
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
                                    padding:
                                        EdgeInsets.only(bottom: 10, top: 10),
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
    Color tabColor = currentUserId == '${document['playerID']}'
        ? ThemeData.light().cardColor
        : greyColor2;
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
        onPressed: () {
          Firestore.instance
              .collection('users')
              .document('${document['playerID']}')
              .get()
              .then((DocumentSnapshot ds) {
            Navigator.of(context).push(new PageRouteBuilder(
              pageBuilder: (_, __, ___) => new DetailPage(snapshot: ds),
            ));
          });
        },
        color: tabColor,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }
}
