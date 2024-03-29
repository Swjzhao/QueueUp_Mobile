import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/main.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:queueup_mobileapp/createprofile.dart';

class CreateAccount extends StatefulWidget {
  static const String id = "CREATEACCOUNT";
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String email;
  String password;
  String confirmpassword;
  String username;
  SharedPreferences prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  TextEditingController controllerEmail;
  TextEditingController controllerPassword;
  TextEditingController controllerConfirmPassword;
  TextEditingController controllerUsername;
  final FocusNode focusNodeEmail = new FocusNode();
  final FocusNode focusNodePassword = new FocusNode();
  final FocusNode focusNodeConfirmPassword = new FocusNode();
  final FocusNode focusNodeUsername = new FocusNode();

  @override
  void initState() {
    super.initState();
    signInSetUp();
  }

  void signInSetUp() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> registerUser() async {
    if (password != confirmpassword) {
      Fluttertoast.showToast(msg: "Password does not match!");
    } else if (username == "") {
      Fluttertoast.showToast(msg: "Username cannot be empty!");
    } else {
      FirebaseUser firebaseUser = null;
      try {
        firebaseUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } catch (error) {
        List<String> errors = error.toString().split(',');
        String errorMsg = "Error: " + errors[1];
        Fluttertoast.showToast(msg: errorMsg);
      }

      if (firebaseUser != null) {
        // Check is already sign up

        final QuerySnapshot result2 = await Firestore.instance
            .collection('swipes')
            .where('id', isEqualTo: firebaseUser.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents2 = result2.documents;
        Locale myLocale = Localizations.localeOf(context);

        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          //Need to add custom stuff
          'username': username,
          'photoUrl':
              "https://firebasestorage.googleapis.com/v0/b/queueup-51825.appspot.com/o/no-img.png?alt=media",
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
          'countryCode': myLocale.countryCode
        });
        List<String> swipedIds = new List();
        swipedIds.add(firebaseUser.uid);
        Firestore.instance
            .collection('swipes')
            .document(firebaseUser.uid)
            .setData({'id': firebaseUser.uid, 'swipedIds': swipedIds});
        await prefs.setStringList('swipedIds', swipedIds);
        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('username', "TempName");
        await prefs.setString('photoUrl',
            "https://firebasestorage.googleapis.com/v0/b/queueup-51825.appspot.com/o/no-img.png?alt=media");
        await prefs.setString('countryCode', myLocale.countryCode);
        Fluttertoast.showToast(msg: "Sign in success");

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreateProfile(currentUserId: firebaseUser.uid)));
      } else {
        Fluttertoast.showToast(msg: "Sign in fail");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("QueueUp"),
        ),
        body: Stack(children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 80.0,
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
                TextField(
                  controller: controllerConfirmPassword,
                  focusNode: focusNodeConfirmPassword,
                  autocorrect: false,
                  obscureText: true,
                  onChanged: (value) => confirmpassword = value,
                  decoration: InputDecoration(
                    hintText: "Confirm Your Password...",
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                TextField(
                  controller: controllerUsername,
                  focusNode: focusNodeUsername,
                  onChanged: (value) => username = value,
                  decoration: InputDecoration(
                    hintText: "Enter Your Username...",
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                CustomButton(
                  text: "Create An Account",
                  callback: () async {
                    await registerUser();
                  },
                )
              ],
            ),
          )
        ]));
  }
}
