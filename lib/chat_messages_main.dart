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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    floatingActionButton: new FloatingActionButton(
      backgroundColor: Theme.of(context).accentColor,
      child: new Icon(
        Icons.message,
        color: Colors.white,
      ),
      onPressed: () => print("open chats"),
    ),
  );
  }

}