import 'dart:async';
import 'package:queueup_mobileapp/explore_files/dummyCard.dart';
import 'package:queueup_mobileapp/explore_files/activeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:animation_exp/PageReveal/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class ProfileCard extends StatefulWidget {
  @override
  ProfileCardState createState() => new ProfileCardState();
}

class ProfileCardState extends State<ProfileCard>
    with TickerProviderStateMixin {
  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  Animation<double> bottom;
  Animation<double> width;
  int flag = 0;

  final Firestore _firestore = Firestore.instance;

  List data;
  List selectedData = [];
  String id = '';
  bool isLoading = true;
  SharedPreferences prefs;
  int dataLengthRef = 0;
  List<DocumentSnapshot> docs;
  Future<void> readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    this.setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot =
    await Firestore.instance
        .collection("users")
        .getDocuments();
    docs = querySnapshot.documents;
    dataLengthRef = docs.length;
    await Firestore.instance
        .collection("users")
        .getDocuments()
        .then((data) {
      this.setState(() {
        isLoading = false;
      });
    });
  }

  void initState() {
    super.initState();
    readLocal();
    _buttonController = new AnimationController(
        duration: new Duration(milliseconds: 1000), vsync: this);

    rotate = new Tween<double>(
      begin: -0.0,
      end: -40.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    rotate.addListener(() {
      setState(() {
        if (rotate.isCompleted) {
          //var i = data.removeLast();
          //data.insert(0, i);
          _buttonController.reset();
        }
      });
    });

    right = new Tween<double>(
      begin: 0.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    bottom = new Tween<double>(
      begin: 15.0,
      end: 100.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    width = new Tween<double>(
      begin: 20.0,
      end: 25.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<Null> _swipeAnimation() async {
    try {
      await _buttonController.forward();
    } on TickerCanceled {}
  }

//  dismissImg(DecorationImage img) {
////    setState(() {
////      data.remove(img);
////    });
//  }
//
//  addImg(DecorationImage img) {
////    setState(() {
////      data.remove(img);
////      selectedData.add(img);
////    });
//  }
  addImg() {
    setState(() {
      docs.removeLast();
    });
  }
  dismissImg() {
   setState(() {
     docs.removeLast();
   });
  }

  swipeRight() {
    if (flag == 0)
      setState(() {
        flag = 1;
      });
    _swipeAnimation();

  }

  swipeLeft() {
    if (flag == 1)
      setState(() {
        flag = 0;
      });
    _swipeAnimation();
  }

  @override
  Widget build(BuildContext context) {

    if(isLoading) {
      return new Container();
    }else {
      timeDilation = 0.4;
      var dataLength = dataLengthRef;
      double initialBottom = 15.0;
      double backCardPosition = initialBottom + (dataLengthRef - 1) * 10 + 10;
      double backCardWidth = -10.0;
      return (new Scaffold(
        appBar: new AppBar(
          elevation: 0.0,
          backgroundColor: ThemeData
              .dark()
              .scaffoldBackgroundColor,
          leading: new Container(),
          actions: <Widget>[
            new GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     new MaterialPageRoute(
                //         builder: (context) => new PageMain()));
              },
              child: new Container(
                margin:
                const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 15.0),
                child: new Icon(
                  Icons.equalizer,
                  color: Colors.cyan,
                  size: 30.0,
                ),
              ),
            ),
            new Container(
              width: 15.0,
              height: 15.0,
              margin: new EdgeInsets.only(bottom: 20.0),
              alignment: Alignment.center,
              child: new Text(
                dataLength.toString(),
                style: new TextStyle(fontSize: 10.0),
              ),
              decoration:
              new BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            )
          ],
        ),
        body: new Container(
          alignment: Alignment.center,
          child: docs != null
              ? Stack(
              alignment: AlignmentDirectional.center,
              children: docs.map((item) {
                if (docs.indexOf(item) == dataLength - 1) {
                  return profileCard(
                      item.data['photoUrl'],
                      bottom.value,
                      right.value,
                      0.0,
                      backCardWidth + 10,
                      rotate.value,
                      rotate.value < -10 ? 0.1 : 0.0,
                      context,
                      dismissImg,
                      flag,
                      addImg,
                      swipeRight,
                      swipeLeft);
                } else {
                  backCardPosition = backCardPosition - 10;
                  backCardWidth = backCardWidth + 10;

                  return profileCardDummy(
                      item.data['photoUrl'],
                      backCardPosition,
                      0.0,
                      0.0,
                      backCardWidth,
                      0.0,
                      0.0,
                      context);
                }
              }).toList())
              : new Text("No Profiles Left",
              style:
              new TextStyle(color: Colors.white, fontSize: 50.0)),
        ),
      ));
    }
  }
}

/*
  StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('games').snapshots(),
                builder: (context, snapshot) {
                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  List<String> reportList = [];
                  docs.map((doc) => reportList.add(doc.data['game'])).toList();
                  reportList.add("Other");
                  return MultiSelectChip(reportList);
                }),
 */

/*
dataLength > 0
              ? new Stack(
                  alignment: AlignmentDirectional.center,
                  children: data.map((item) {
                    if (data.indexOf(item) == dataLength - 1) {
                      return cardDemo(
                          item,
                          bottom.value,
                          right.value,
                          0.0,
                          backCardWidth + 10,
                          rotate.value,
                          rotate.value < -10 ? 0.1 : 0.0,
                          context,
                          dismissImg,
                          flag,
                          addImg,
                          swipeRight,
                          swipeLeft);
                    } else {
                      backCardPosition = backCardPosition - 10;
                      backCardWidth = backCardWidth + 10;

                      return cardDemoDummy(item, backCardPosition, 0.0, 0.0,
                          backCardWidth, 0.0, 0.0, context);
                    }
                  }).toList())
              : new Text("No Event Left",
                  style: new TextStyle(color: Colors.white, fontSize: 50.0))
 */
