import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:queueup_mobileapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:queueup_mobileapp/auth.dart';
import 'package:queueup_mobileapp/createprofile.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData.dark(),
      home: LoginScreen(title: 'CHAT DEMO'),
      debugShowCheckedModeBanner: false,
      routes: {
        CreateAccount.id: (context) => CreateAccount(),
        CreateProfile.id: (context) => CreateProfile()
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  bool usingGoogle = false;
  String email;
  String password;

  TextEditingController controllerEmail;
  TextEditingController controllerPassword;
  final FocusNode focusNodeEmail = new FocusNode();
  final FocusNode focusNodePassword = new FocusNode();

  @override
  void initState() {
    super.initState();
    isSignedIn();
    readGames();
  }

  Future<void> readGames() async {
    final QuerySnapshot result3 =
        await Firestore.instance.collection("games").getDocuments();
    final List<DocumentSnapshot> gameCollections = result3.documents;

    prefs = await SharedPreferences.getInstance();
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("games").getDocuments();
    List<DocumentSnapshot> docs = querySnapshot.documents;
    List<String> gameNames = new List();
    List<String> gameImageUrls = new List();
    docs.map((item) {
      gameNames.add(item.data['game']);
      gameImageUrls.add(item.data['imageUrl']);
    }).toList();

    await prefs.setStringList('gameNames', gameNames);
    await prefs.setStringList('gameImageUrls', gameImageUrls);
    print(gameNames);
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainScreen(currentUserId: prefs.getString('id'))),
      );
    }

    this.setState(() {
      isLoading = false;
    });
  }

  Future<void> loginUser() async {
    FirebaseUser firebaseUser = null;
    try {
      firebaseUser = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      List<String> errors = error.toString().split(',');
      String errorMsg = "Error: " + errors[1];
      Fluttertoast.showToast(msg: errorMsg);
    }

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      final QuerySnapshot result2 = await Firestore.instance
          .collection('swipes')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents2 = result2.documents;

      // Write data to local
      await prefs.setString('id', documents[0]['id']);
      await prefs.setString('username', documents[0]['username']);
      await prefs.setString('photoUrl', documents[0]['photoUrl']);

      await prefs.setString('aboutMe', documents[0]['aboutMe']);
      await prefs.setString('gender', documents[0]['gender']);
      await prefs.setString('photoUrl', documents[0]['status']);
      await prefs.setDouble('playerType', documents[0]['playerType']);
      await prefs.setDouble('seriousiness', documents[0]['seriousiness']);
      await prefs.setString('countryCode', documents[0]['countryCode']);
      await prefs.setString('timeStart', documents[0]['timeStart']);
      await prefs.setString('timeEnd', documents[0]['timeEnd']);
      await prefs.setString('timeZone', documents[0]['timeZone']);

      List<dynamic> games = documents[0]['games'];
      await prefs.setStringList('games', games.cast<String>().toList());
      List<dynamic> daysAvailable = documents[0]['daysAvailable'];
      await prefs.setStringList(
          'daysAvailable', daysAvailable.cast<String>().toList());

      if (documents2.length == 0) {
        List<String> swipedIds = new List();
        swipedIds.add(firebaseUser.uid);
        Firestore.instance
            .collection('swipes')
            .document(firebaseUser.uid)
            .setData({'id': firebaseUser.uid, 'swipedIds': swipedIds});
        await prefs.setStringList('swipedIds', swipedIds);
      } else {
        List<dynamic> swipedIds = documents2[0]['swipedIds'];
        await prefs.setStringList(
            'swipedIds', swipedIds.cast<String>().toList());
      }

      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });
      if (documents[0]['playerType'] == null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreateProfile(currentUserId: firebaseUser.uid)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen(currentUserId: firebaseUser.uid)));
      }
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser firebaseUser =
        await firebaseAuth.signInWithCredential(credential);

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      final QuerySnapshot result2 = await Firestore.instance
          .collection('swipes')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents2 = result2.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'username': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('username', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
        await prefs.setString('gender', documents[0]['gender']);
        await prefs.setString('photoUrl', documents[0]['status']);
        await prefs.setDouble('playerType', documents[0]['playerType']);
        await prefs.setDouble('seriousiness', documents[0]['seriousiness']);
        await prefs.setString('countryCode', documents[0]['countryCode']);
        await prefs.setString('timeStart', documents[0]['timeStart']);
        await prefs.setString('timeEnd', documents[0]['timeEnd']);
        await prefs.setString('timeZone', documents[0]['timeZone']);

        List<dynamic> games = documents[0]['games'];
        await prefs.setStringList('games', games.cast<String>().toList());
        List<dynamic> daysAvailable = documents[0]['daysAvailable'];
        await prefs.setStringList(
            'daysAvailable', daysAvailable.cast<String>().toList());

        List<String> swipedIds = new List();
        swipedIds.add(firebaseUser.uid);
        Firestore.instance
            .collection('swipes')
            .document(firebaseUser.uid)
            .setData({'id': firebaseUser.uid, 'swipedIds': swipedIds});
        await prefs.setStringList('swipedIds', swipedIds);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('username', documents[0]['username']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
        if (documents2.length == 0) {
          List<String> swipedIds = new List();
          swipedIds.add(firebaseUser.uid);
          Firestore.instance
              .collection('swipes')
              .document(firebaseUser.uid)
              .setData({'id': firebaseUser.uid, 'swipedIds': swipedIds});
          await prefs.setStringList('swipedIds', swipedIds);
        } else {
          await prefs.setStringList('swipedIds', documents2[0]['swipedIds']);
        }
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });

      if (documents[0]['playerType'] == null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreateProfile(currentUserId: firebaseUser.uid)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen(currentUserId: firebaseUser.uid)));
      }
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "QueueUp",
              style: TextStyle(fontSize: 40.0),
            ),
            SizedBox(
              height: 40.0,
            ),
            TextField(
              controller: controllerEmail,
              focusNode: focusNodeEmail,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                hintText: "Enter Your Email...",
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            TextField(
              controller: controllerPassword,
              focusNode: focusNodePassword,
              autocorrect: false,
              obscureText: true,
              onChanged: (value) => password = value,
              decoration: InputDecoration(
                hintText: "Enter Your Password...",
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            CustomButton(
              text: "Log In",
              callback: () async {
                await loginUser();
              },
            ),
            CustomButton(
              text: "Create an Account",
              callback: () {
                Navigator.of(context).pushNamed(CreateAccount.id);
              },
            ),
            SizedBox(
              height: 40.0,
            ),
            FlatButton(
                onPressed: handleSignIn,
                child: Text(
                  'SIGN IN WITH GOOGLE',
                  style: TextStyle(fontSize: 16.0),
                ),
                color: Color(0xffdd4b39),
                highlightColor: Color(0xffff7f7f),
                splashColor: Colors.transparent,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
          ],
        ),
      ),
    );
  }
}
