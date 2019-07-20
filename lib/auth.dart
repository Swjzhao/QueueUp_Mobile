import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_main.dart';
import 'util.dart';

class CreateAccount extends StatefulWidget {
  static const String id = "CREATEACCOUNT";
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerUser() async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Chat()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QueueUp"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'logo',
              child: Container(
              ),
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: "Enter Your Email...",
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextField(
            autocorrect: false,
            obscureText: true,
            onChanged: (value) => password = value,
            decoration: InputDecoration(
              hintText: "Enter Your Password...",
              border: const OutlineInputBorder(),
            ),
          ),
          CustomButton(
            text: "Create An Account",
            callback: () async {
              await registerUser();
            },
          )
        ],
      ),
    );
  }
}

class Login extends StatefulWidget {
  static const String id = "LOGIN";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser() async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tensor Chat"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset(
                  "assets/images/logo.png",
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: "Enter Your Email...",
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextField(
            autocorrect: false,
            obscureText: true,
            onChanged: (value) => password = value,
            decoration: InputDecoration(
              hintText: "Enter Your Password...",
              border: const OutlineInputBorder(),
            ),
          ),
          CustomButton(
            text: "Log In",
            callback: () async {
              await loginUser();
            },
          )
        ],
      ),
    );
  }
}