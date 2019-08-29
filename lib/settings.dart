import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:queueup_mobileapp/MultiSelectClip.dart';
import 'package:day_selector/day_selector.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'SETTINGS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController controllerUsername;
  TextEditingController controllerAboutMe;

  SharedPreferences prefs;

  List<String> sliderList1 = ["Casual", "", "Ranked", "", "Hardcore"];
  List<String> sliderList2 = [
    "Mic Off, Chat Off",
    "Shy",
    "Indifferent",
    "Chatty",
    "Open Mic"
  ];
  // Need to fix update games

  String id = '';
  String username = '';
  String aboutMe = '';
  String photoUrl = '';
  double sliderVal1 = 2;
  double sliderVal2 = 2;
  String dropdownValue = 'Male';
  List<String> selectedChoices = List();
  TimeOfDay _time = new TimeOfDay.now();
  TimeOfDay _time2 = new TimeOfDay.now();

  final Firestore _firestore = Firestore.instance;
  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeUsername = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    username = prefs.getString('username') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    sliderVal1 = prefs.getDouble('seriousiness');
    sliderVal2 = prefs.getDouble('playerType');
    dropdownValue = prefs.getString('gender');


    String strTime1 = prefs.getString('timeStart');
    String strTime2 = prefs.getString('timeEnd');
    List<String> time1s = strTime1.split(':');
    List<String> time2s = strTime2.split(':');
    _time =
        new TimeOfDay(hour: int.parse(time1s[0]), minute: int.parse(time1s[1]));
    _time2 =
        new TimeOfDay(hour: int.parse(time2s[0]), minute: int.parse(time2s[1]));

    await prefs.setStringList('daysAvailable', selectedChoices);

    controllerUsername = new TextEditingController(text: username);
    controllerAboutMe = new TextEditingController(text: aboutMe);

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance.collection('users').document(id).updateData({
            'username': username,
            'aboutMe': aboutMe,
            'photoUrl': photoUrl
          }).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {
    focusNodeUsername.unfocus();
    focusNodeAboutMe.unfocus();

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
      'username': username,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl,
      'seriousiness': sliderVal1,
      'playerType': sliderVal2,
      'gender': dropdownValue,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'daysAvailable': selectedChoices
    }).then((data) async {
      await prefs.setString('username', username);
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('photoUrl', photoUrl);
      await prefs.setDouble('seriousiness', sliderVal1);
      await prefs.setDouble('playerType', sliderVal2);
      await prefs.setString('gender', dropdownValue);
      await prefs.setString('timeStart', timeStart);
      await prefs.setString('timeEnd', timeEnd);
      await prefs.setStringList('daysAvailable', selectedChoices);
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
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
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                themeColor),
                                      ),
                                      width: 90.0,
                                      height: 90.0,
                                      padding: EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 90.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                  color: greyColor,
                                ))
                          : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(45.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: primaryColor.withOpacity(0.5),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: greyColor,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      'Username',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerUsername,
                        onChanged: (value) {
                          username = value;
                        },
                        focusNode: focusNodeUsername,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                    docs
                        .map((doc) => reportList.add(doc.data['game']))
                        .toList();
                    reportList.add("Other");
                    return MultiSelectChip(reportList);
                  }),

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
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
              // Button
              Container(
                child: FlatButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: primaryColor,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Loading
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : Container(),
        ),
      ],
    );
  }
}
