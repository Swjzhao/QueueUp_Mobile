import 'dart:async';

import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queueup_mobileapp/MultiSelectClip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CreateProfile1 extends StatefulWidget {
  static const String id = "CREATEPROFILE1";

  final String currentUserId;
  final BuildContext context;

  CreateProfile1({Key key, this.context, @required this.currentUserId})
      : super(key: key);

  @override
  State createState() =>
      new CreateProfile1State(context: context, currentUserId: currentUserId);
}

class CreateProfile1State extends State<CreateProfile1> {
  CreateProfile1State({Key key, this.context, @required this.currentUserId});
  String currentUserId;
  String dropdownValue = 'Male';
  BuildContext context;
  final Firestore _firestore = Firestore.instance;
  String id = '';
  bool isLoading = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    // Force refresh input
    setState(() {});
  }

  Future<Null> handleNextButtonPress(int delta) async {
    setState(() {
      isLoading = true;
    });
    List<String> selectedChoices = prefs.getStringList('games');

    if (selectedChoices.isEmpty) {
      selectedChoices.add("Other");
    }

    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'gender': dropdownValue}).then((data) async {
      await prefs.setString('gender', dropdownValue);
      setState(() {
        isLoading = false;
      });
      final TabController controller = DefaultTabController.of(context);
      if (!controller.indexIsChanging)
        controller.animateTo((controller.index + delta).clamp(0, 3));
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  "Welcome!",
                  style: TextStyle(fontSize: 40.0),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text(
                    "Gender:  ",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>['Male', 'Female', 'Unspecified']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 20.0)),
                      );
                    }).toList(),
                  )
                ]),
                SizedBox(
                  height: 40.0,
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Which games do you play? :  ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      )
                    ]),
                StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('games').snapshots(),
                    builder: (context, snapshot) {
                      List<DocumentSnapshot> docs = snapshot.data.documents;
                      List<String> reportList = [];
                      docs.map((doc) => reportList.add(doc.data['game'])).toList();
                      reportList.add("Other");
                      return MultiSelectChip(reportList);
                    }),
                Expanded(child: Text('')),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                  Expanded(child: Text('')),
                  CustomButtonSmall(
                    text: 'Next',
                    callback: () async {
                      await handleNextButtonPress(1);
                    },
                  )
                ])
              ],
            )));
  }
}
