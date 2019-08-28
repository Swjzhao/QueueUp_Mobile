import 'dart:async';

import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CreateProfile2 extends StatefulWidget {
  static const String id = "CREATEPROFILE2";

  final String currentUserId;

  final BuildContext context;

  CreateProfile2({Key key, this.context, @required this.currentUserId})
      : super(key: key);

  @override
  State createState() =>
      new CreateProfile2State(context: context, currentUserId: currentUserId);
}

class CreateProfile2State extends State<CreateProfile2> {
  CreateProfile2State(
      {Key key, @required this.context, @required this.currentUserId});
  BuildContext context;
  final Firestore _firestore = Firestore.instance;

  String currentUserId;
  double sliderVal1 = 2;
  double sliderVal2 = 2;
  bool isLoading = false;
  SharedPreferences prefs;

  List<String> sliderList1 = ["Casual", "", "Ranked", "", "Hardcore"];
  List<String> sliderList2 = [
    "Mic Off, Chat Off",
    "Shy",
    "Indifferent",
    "Chatty",
    "Open Mic"
  ];

  String id = '';

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

    Firestore.instance.collection('users').document(id).updateData({
      'seriousiness': sliderVal1,
      'playerType': sliderVal2
    }).then((data) async {
      await prefs.setDouble('seriousiness', sliderVal1);
      await prefs.setDouble('playerType', sliderVal2);
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
            child: Column(children: <Widget>[
              SizedBox(
                height: 40.0,
              ),
              Text(
                "Player Profile",
                style: TextStyle(fontSize: 40.0),
              ),
              SizedBox(
                height: 40.0,
              ),
              Text('How serious are you?', style: TextStyle(fontSize: 20.0)),
              Slider(
                  value: sliderVal1,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: sliderList1[sliderVal1.round()],
                  onChanged: (double value) {
                    setState(() => sliderVal1 = value);
                  }),
              Divider(),
              Text('What Type of player are you: ',
                  style: TextStyle(fontSize: 20.0)),
              Slider(
                  value: sliderVal2,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: sliderList2[sliderVal2.round()],
                  onChanged: (double value) {
                    setState(() => sliderVal2 = value);
                  }),
              Divider(),
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
            ])));
  }
}
