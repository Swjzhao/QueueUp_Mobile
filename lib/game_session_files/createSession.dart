import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateSession extends StatefulWidget {
  static const String id = "CreateSession";

  final String currentUserId;
  final String gameId;
  final String gameName;

  CreateSession(
      {Key key,
      @required this.currentUserId,
      @required this.gameId,
      @required this.gameName})
      : super(key: key);

  @override
  State createState() => new CreateSessionState(
      currentUserId: currentUserId, gameId: gameId, gameName: gameName);
}

class CreateSessionState extends State<CreateSession> {
  CreateSessionState(
      {Key key,
      @required this.currentUserId,
      @required this.gameId,
      @required this.gameName});

  bool isLoading = false;
  String currentUserId;
  String gameId;
  String gameName;

  TextEditingController controllerName;
  final FocusNode focusNodeName = new FocusNode();

  String sessionName;
  String casual = 'Casual Session';
  int maxPlayers = 5;
  String username = '';

  SharedPreferences prefs;
  final Firestore _firestore = Firestore.instance;


  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
  }

  void handleCreateSession() {
    focusNodeName.unfocus();
    if(sessionName.isEmpty){
      Fluttertoast.showToast(msg: "Please name this session!");
      return;
    }
    setState(() {
      isLoading = true;
    });

    Firestore.instance.collection('gameSessions').document(gameId).collection('sessions').add({
      'currentCapacity': 1,
      'hostID': currentUserId,
      'maxCapacity': maxPlayers,
      'sessionName': sessionName,
      'gameType':casual,
      'hostName': username,

    }).then((data) async {

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Session Created");
      Navigator.pop(context);
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

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
        body: Stack(children: <Widget>[
          SingleChildScrollView(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Column(children: <Widget>[
                SizedBox(
                  height: 80.0,
                ),
                TextField(
                  controller: controllerName,
                  focusNode: focusNodeName,
                  onChanged: (value) => sessionName = value,
                  decoration: InputDecoration(
                    hintText: "Session Name...",
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Game Type:  ",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      DropdownButton<String>(
                        value: casual,
                        onChanged: (String newValue) {
                          setState(() {
                            casual = newValue;
                          });
                        },
                        items: <String>[
                          'Casual Session',
                          'Ranked',
                          'Fun Game, do whatever'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child:
                                Text(value, style: TextStyle(fontSize: 20.0)),
                          );
                        }).toList(),
                      ),
                    ]),
                SizedBox(
                  height: 40.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Number of Players:  ",
                      style: TextStyle(fontSize: 20.0),
                    ),
                    DropdownButton<int>(
                      value: maxPlayers,
                      onChanged: (int newValue) {
                        setState(() {
                          maxPlayers = newValue;
                        });
                      },
                      items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString(),
                              style: TextStyle(fontSize: 20.0)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Container(
                  child: FlatButton(
                    onPressed: handleCreateSession,
                    child: Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Theme.of(context).buttonColor,
                    highlightColor: new Color(0xff8d93a0),
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                  ),
                  margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
                ),
              ]))
        ]));
  }
}
