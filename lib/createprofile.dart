import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queueup_mobileapp/MultiSelectClip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:queueup_mobileapp/main.dart';

class _PageSelector extends StatelessWidget {
  const _PageSelector();

  void _handleArrowButtonPress(BuildContext context, int delta) {
    final TabController controller = DefaultTabController.of(context);
    if (!controller.indexIsChanging)
      controller.animateTo((controller.index + delta).clamp(0, 2));
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final Color color = Theme.of(context).accentColor;
    return Builder(
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  CreateProfile1(context: context, currentUserId: null),
                  CreateProfile2(context: context, currentUserId: null),
                  CreateProfile3(currentUserId: null),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: color,
                    onPressed: () {
                      _handleArrowButtonPress(context, -1);
                    },
                    tooltip: 'Page back',
                  ),
                  TabPageSelector(controller: controller),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: color,
                    onPressed: () {
                      _handleArrowButtonPress(context, 1);
                    },
                    tooltip: 'Page forward',
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateProfile extends StatefulWidget {
  static const String id = "CREATEPROFILE";
  final String currentUserId;

  CreateProfile({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new CreateProfileState(currentUserId: currentUserId);
}

class CreateProfileState extends State<CreateProfile> {
  CreateProfileState({Key key, @required this.currentUserId});
  static const String id = "CREATEPROFILE";
  String currentUserId;

  void _handleArrowButtonPress(BuildContext context, int delta) {
    final TabController controller = DefaultTabController.of(context);
    if (!controller.indexIsChanging)
      controller.animateTo((controller.index + delta).clamp(0, 2));
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final Color color = Theme.of(context).accentColor;
    return Scaffold(
      body: DefaultTabController(
          length: 3,
          child: Builder(
            builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        CreateProfile1(
                            context: context, currentUserId: currentUserId),
                        CreateProfile2(
                            context: context, currentUserId: currentUserId),
                        CreateProfile3(currentUserId: currentUserId),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          color: color,
                          onPressed: () {
                            _handleArrowButtonPress(context, -1);
                          },
                          tooltip: 'Page back',
                        ),
                        TabPageSelector(controller: controller),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          color: color,
                          onPressed: () {
                            _handleArrowButtonPress(context, 1);
                          },
                          tooltip: 'Page forward',
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

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
        controller.animateTo((controller.index + delta).clamp(0, 2));
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
        controller.animateTo((controller.index + delta).clamp(0, 2));
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

class CreateProfile3 extends StatefulWidget {
  static const String id = "CREATEPROFILE3";

  final String currentUserId;
  final BuildContext context;

  CreateProfile3({Key key, this.context, @required this.currentUserId})
      : super(key: key);

  @override
  State createState() =>
      new CreateProfile3State(context: context, currentUserId: currentUserId);
}

class CreateProfile3State extends State<CreateProfile3> {
  CreateProfile3State({Key key, this.context, @required this.currentUserId});
  String currentUserId;
  BuildContext context;

  SharedPreferences prefs;

  String id = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

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
          Firestore.instance
              .collection('users')
              .document(id)
              .updateData({'photoUrl': photoUrl}).then((data) async {
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

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    // Force refresh input
    setState(() {});
  }

  Future<Null> handleSubmitButtonPress() async {
    setState(() {
      isLoading = true;
    });

    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'photoUrl': photoUrl}).then((data) async {
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(currentUserId: currentUserId)));
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
            "Set your picture",
            style: TextStyle(fontSize: 40.0),
          ),
          SizedBox(
            height: 40.0,
          ),
          Stack(children: <Widget>[
            (avatarImageFile == null)
                ? (photoUrl != ''
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
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
                        borderRadius: BorderRadius.all(Radius.circular(45.0)),
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
                    borderRadius: BorderRadius.all(Radius.circular(45.0)),
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
          ]),
          Divider(),
          Expanded(child: Text('')),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
            Expanded(child: Text('')),
            CustomButtonSmall(
              text: 'Let\'s Go',
              callback: () async {
                await handleSubmitButtonPress();
              },
            )
          ])
        ])));
  }
}
