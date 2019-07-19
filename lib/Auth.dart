import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Chat.dart';

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
        email: email,
        password: password);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Chat()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tensor Chat"),
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag:'logo',
              child: Container(
              ),
            ),
          )
        ],
      )
    );
  }
}

class Login extends StatefulWidget {
  static const String id = "LOGIN";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

