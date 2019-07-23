import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:queueup_mobileapp/auth.dart';
import 'package:queueup_mobileapp/chat_messages_main.dart';
import 'package:queueup_mobileapp/game_sessions.dart';
import 'package:queueup_mobileapp/explore.dart';


class Dashboard extends StatefulWidget {
  static const String id = "DASHBOARD";
  final FirebaseUser user;

  const Dashboard({Key key, this.user}) : super(key: key);
  @override
  _DashboardState createState() => new _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  FirebaseUser user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 1, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("QueueUp"),
        elevation: 0.7,
        bottom: new TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            new Tab(text: "Sessions"),
            new Tab(
              text: "Chats",
            ),
            new Tab(
              text: "Swipe",
            ),
          ],
        ),
        actions: <Widget>[
          new Icon(Icons.search),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
          new Icon(Icons.more_vert)
        ],
      ),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          Game_Sessions(user: widget.user,),
          Chat_Messages(user: widget.user,),
          Explore(user:widget.user,),
        ],
      ),

    );
  }
}