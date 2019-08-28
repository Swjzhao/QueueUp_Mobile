import 'dart:async';

import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:day_selector/day_selector.dart';

class CreateProfile3 extends StatefulWidget {
  static const String id = "CREATEPROFILE3";

  final String currentUserId;

  final BuildContext bcontext;

  CreateProfile3({Key key, this.bcontext, @required this.currentUserId})
      : super(key: key);

  @override
  State createState() =>
      new CreateProfile3State(bcontext: bcontext, currentUserId: currentUserId);
}

class CreateProfile3State extends State<CreateProfile3> {
  CreateProfile3State(
      {Key key, @required this.bcontext, @required this.currentUserId});
  BuildContext bcontext;
  final Firestore _firestore = Firestore.instance;
  // 3 7 15 31 63 127 255
  String currentUserId;
  bool isLoading = false;
  SharedPreferences prefs;
  List<String> selectedChoices = List();
  String id = '';

  TimeOfDay _time = new TimeOfDay.now();
  TimeOfDay _time2 = new TimeOfDay.now();
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
    String timeStart = _time.hour.toString() +
        ":" +
        _time.minute.toString() +
        ":" +
        _time.hourOfPeriod.toString();
    String timeEnd = _time2.hour.toString() +
        ":" +
        _time2.minute.toString() +
        ":" +
        _time2.hourOfPeriod.toString();
    Firestore.instance.collection('users').document(id).updateData({
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'daysAvailable': selectedChoices,
      'timeZone': DateTime.now().timeZoneName
    }).then((data) async {
      await prefs.setString('timeStart', timeStart);
      await prefs.setString('timeEnd', timeEnd);
      await prefs.setStringList('daysAvailable', selectedChoices);
      await prefs.setString('timeZone', DateTime.now().timeZoneName);

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

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<Null> _selectTime2(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _time2);
    if (picked != null) {
      setState(() {
        _time2 = picked;
      });
    }
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
            "Time Preferences",
            style: TextStyle(fontSize: 40.0),
          ),
          SizedBox(
            height: 40.0,
          ),
          Text(
            "Choose all available: ",
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 20.0,
          ),
          DaySelector(
              value: null,
              onChange: (value) {
                selectedChoices.contains(value.toString())
                    ? selectedChoices.remove(value.toString())
                    : selectedChoices.add(value.toString());
              },
              mode: DaySelector.modeFull),
          SizedBox(
            height: 80.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(
              "From ",
              style: TextStyle(fontSize: 20.0),
            ),
            FlatButton(
                child: Text(_time.format(context),
                    style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  _selectTime(context);
                }),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(
              "To ",
              style: TextStyle(fontSize: 20.0),
            ),
            FlatButton(
                child: Text(_time2.format(context),
                    style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  _selectTime2(context);
                }),
          ]),
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
