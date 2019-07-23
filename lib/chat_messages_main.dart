import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:queueup_mobileapp/chat_conversation_main.dart';

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
        isScrollControlled: true,
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
                                  user: widget.user,
                                  userid: doc.data['userid'],
                                  email: doc.data['email'],
                                  messages: doc.data['messages'],
                                ))
                            .toList();

                        return ListView.separated(
                          controller: scrollController,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return users[index];
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
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

class User extends StatefulWidget {
  final String userid;
  final String email;
  final FirebaseUser user;
  final Map<dynamic, dynamic> messages;

  const User({Key key, this.user, this.userid, this.email, this.messages})
      : super(key: key);

  @override
  _UserState createState() => _UserState();

}


class _UserState extends State<User> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  String getChatID(){
    String chatID;
    if(widget.messages.containsKey(widget.userid)){
      chatID = widget.messages[widget.userid];
    }else{
      callback();
      chatID = widget.messages[widget.userid];
    }

    return chatID;
  }

  Future<void> callback() async{
    String docID;

    await _firestore.collection('chat').add({
      'to':widget.email,
      'from': widget.user.email,
    }).then((snap) {
      docID = snap.documentID;
    });
    _firestore.collection('users').document(widget.user.uid).get().then((snapp){
      Map<dynamic, dynamic> messages = snapp.data['messages'];
      messages[widget.userid] = docID;
      _firestore.collection('users').document(widget.user.uid).updateData({"messages":messages});
    });
    //docs = snapshot.data
    _firestore.collection('users').document(widget.userid).get().then((snapp){

      Map<dynamic, dynamic> otherMessages = snapp.data['messages'];
      otherMessages[widget.user.uid] = docID;
      _firestore.collection('users').document(widget.userid).updateData({"messages":otherMessages});
    });

  }
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
                  widget.email,
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
                widget.email,
                style: new TextStyle(color: Colors.grey, fontSize: 15.0),
              ),
            ),
            onTap: () {
              String chatID = getChatID();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                        chatID: chatID,
                        user: widget.user,
                        other: widget.userid,
                      )));
            },
          )
        ],
      ),
    );
  }

}
