import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:queueup_mobileapp/game_session_files/gameSessionsView.dart';

class GameSessionTab extends StatefulWidget {
  static const String id = "GameSessionTab";

  final String currentUserId;

  GameSessionTab({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new GameSessionTabState(currentUserId: currentUserId);
}

class GameSessionTabState extends State<GameSessionTab> {
  GameSessionTabState({Key key, @required this.currentUserId});
  String currentUserId;
  SharedPreferences prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  List<String> gameNames = new List();
  List<String> gameImageUrls = new List();
  List<String> gameSessionIDs = new List();
  bool isLoading = true;

  Future<void> readLocal() async {
    this.setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("games").getDocuments();
    List<DocumentSnapshot> docs = querySnapshot.documents;

    await Firestore.instance.collection("games").getDocuments().then((data) {
      docs.map((item) {
        gameNames.add(item.data['game']);
        gameImageUrls.add(item.data['imageUrl']);
        gameSessionIDs.add(item.data["sessionID"]);
      }).toList();
      this.setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container();
    } else {
      print(gameImageUrls);
      return Container(
          child: new GridView.builder(
        itemCount: gameNames.length,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new GridTile(
              footer: new Text(gameNames[index]),
              child: Material(
                // Might change this to local storage to decrease load time.
                child: MaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GameSessions(
                                  currentUserId: currentUserId,
                                  gameId: gameSessionIDs[index])));
                    },
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                        width: 90.0,
                        height: 90.0,
                        padding: EdgeInsets.all(20.0),
                      ),
                      imageUrl: gameImageUrls[index],
                      width: 90.0,
                      height: 90.0,
                      fit: BoxFit.cover,
                    )),
                clipBehavior: Clip.hardEdge,
              ), //just for testing, will fill with image later
            ),
          );
        },
      ));
    }
  }
}
