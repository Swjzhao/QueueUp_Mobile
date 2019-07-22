import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

class Chat_Messages extends StatefulWidget {
  static const String id = "CHATMESSAGE";
  final FirebaseUser user;

  const Chat_Messages({Key key, this.user}) : super(key: key);
  @override
  _ChatMessageState createState() => _ChatMessageState();
}

//child: StreamBuilder<DocumentSnapshot>(
//stream: _firestore.collection('messages').document(widget.user.uid).snapshots(),
//builder: (context, snapshot){
//snapshot.data.
//ret
//}
//)

class _ChatMessageState extends State<Chat_Messages> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled:true,
        builder: (builder) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("New Chat"),
              elevation: 0.7,
            ),

            body: SafeArea(
                child: Column(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('users').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return Center(
                              child: CircularProgressIndicator(),
                            );

                          List<DocumentSnapshot> docs = snapshot.data.documents;

                          List<Widget> users = docs
                              .map((doc) => User(
                            userid: doc.data['userid'],
                            email: doc.data['email'],
                          ))
                              .toList();

                          return ListView(
                            controller: scrollController,
                            children: <Widget>[
                              ...users,
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    floatingActionButton: new FloatingActionButton(
      backgroundColor: Theme.of(context).accentColor,
      child: new Icon(
        Icons.message,
        color: Colors.white,
      ),
      onPressed: _showModalSheet,
    ),
  );
  }

}

class User extends StatelessWidget {
  final String userid;
  final String email;

  const User({Key key, this.userid, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

            new ListTile(
              leading: new CircleAvatar(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey,
                //backgroundImage: new NetworkImage(dummyData[i].avatarUrl),
              ),
              title: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    email,
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
//                  new Text(
//                    dummyData[i].time,
//                    style: new TextStyle(color: Colors.grey, fontSize: 14.0),
//                  ),
                ],
              ),
              subtitle: new Container(
                padding: const EdgeInsets.only(top: 5.0),
                child: new Text(
                  email,
                  style: new TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
              ),
            )
        ],
      ),
    );
  }
}