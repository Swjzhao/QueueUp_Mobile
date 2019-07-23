import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'auth.dart';

class Chat extends StatefulWidget {
  static const String id = "CHAT";
  final FirebaseUser user;
  final String other;
  final String chatID;

  const Chat({Key key, this.user, this.other, this.chatID}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  String getChatIDD() {
    _firestore
        .collection('users')
        .document(widget.user.uid)
        .get()
        .then((snapp) {
      Map<dynamic, dynamic> messages = snapp.data['messages'];
      String temp = messages[widget.other];
      return  temp;
    });
  }
  String chatIDD;
  void initState(){
     _firestore
        .collection('users')
        .document(widget.user.uid)
        .get()
        .then((snapp) {
      Map<dynamic, dynamic> messages = snapp.data['messages'];
      chatIDD = messages[widget.other];
    });
  }

  Future<void> callback() async {

    String chatIDD;
    await _firestore
        .collection('users')
        .document(widget.user.uid)
        .get()
        .then((snapp) {
      Map<dynamic, dynamic> messages = snapp.data['messages'];
      chatIDD = messages[widget.other];
    });
    if (messageController.text.length > 0) {
      await _firestore
          .collection("chat")
          .document(chatIDD)
          .collection('messages')
          .add({
        'text': messageController.text,
        'from': widget.user.email,
      });
      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    onLoad();
  }

//  void initState(){
//    super.initState();
//    WidgetsBinding.instance
//        .addPostFrameCallback((_) => onLoad());
//  }
  void onLoad() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'logo',
          child: Container(
            height: 40.0,
            child: Image.asset("assets/images/logo.png"),
          ),
        ),
        title: Text("QueueUp"),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.close),
//            onPressed: () {
//              _auth.signOut();
//              Navigator.of(context).popUntil((route) => route.isFirst);
//            },
//          )
//        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(

                stream: _firestore
                    .collection("chat")
                    .document(chatIDD)
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                            from: doc.data['from'],
                            text: doc.data['text'],
                            me: widget.user.email == doc.data['from'],
                          ))
                      .toList();

                  return ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      child: TextField(
                        decoration: new InputDecoration.collapsed(
                            hintText: "Send a message"),
                        controller: messageController,
                        onTap: () => scrollToBottom(),
                        onSubmitted: (value) => callback(),
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: new IconButton(
                      icon: new Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: callback,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.orange,
      onPressed: callback,
      child: Text(text),
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;

  final bool me;

  const Message({Key key, this.from, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment:
                  me ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: <Widget>[
                Material(
                  color: me ? Colors.teal : Colors.red,
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 6.0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Text(
                      text,
                    ),
                  ),
                ),
//                new Container(
//                  margin: const EdgeInsets.only(left: 5.0),
//                  child: new CircleAvatar(
//                    child: new Text(from[0]),
//                  ),
//                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
