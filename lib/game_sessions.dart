import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

class Game_Sessions extends StatefulWidget {
  static const String id = "GAME_SESSION";

  final FirebaseUser user;

  const Game_Sessions({Key key, this.user}) : super(key: key);
  @override
  _Game_SessionsState createState() => _Game_SessionsState();
}

class _Game_SessionsState extends State<Game_Sessions> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    final title = 'Grid List';

    return Scaffold(
        body: GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 2,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(100, (index) {
        return Center(
          child: Text(
            'Item $index',
            style: Theme.of(context).textTheme.headline,
          ),
        );
      }),
    )); 
    // Generate 100 widgets that display their index in the List.
//          children: <Widget>[
//            Expanded(
//                child: StreamBuilder<QuerySnapshot>(
//                    stream: _firestore.collection("games").snapshots(),
//                    builder: (context, snapshot) {
//                      List<DocumentSnapshot> docs = snapshot.data.documents;
//
//                      List<Widget> gameicons = docs
//                          .map((doc) => GameIcon(
//                                game: doc.data['game'],
//                              ))
//                          .toList();
//
//                      return Center(
//                        child: Text(
//                          'Item 1 ',
//                          style: Theme.of(context).textTheme.headline,
//                        ),
//                      );
//                    }))
//          ]
  }
}

//          List.generate(100, (index) {
//            return Center(
//
//            );
//          }),

class GameIcon extends StatelessWidget {
  final String game;

  const GameIcon({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.only(left: 5.0),
      child: new CircleAvatar(
        child: new Text(game[0]),
      ),
    );
  }
}
