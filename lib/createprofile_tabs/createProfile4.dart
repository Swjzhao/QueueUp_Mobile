import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:queueup_mobileapp/main.dart';


class CreateProfile4 extends StatefulWidget {
  static const String id = "CREATEPROFILE4";

  final String currentUserId;

  CreateProfile4({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new CreateProfile4State(currentUserId: currentUserId);
}

class CreateProfile4State extends State<CreateProfile4> {
  CreateProfile4State({Key key, @required this.currentUserId});
  String currentUserId;

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
              builder: (context) => MainScreen(currentUserId: id)));
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
