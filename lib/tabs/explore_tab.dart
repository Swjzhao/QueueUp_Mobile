import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExploreTab extends StatefulWidget {
  static const String id = "EXPLORE";

  final String currentUserId;

  ExploreTab({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new ExploreTabState(currentUserId:currentUserId);
}

class ExploreTabState extends State<ExploreTab> {
  ExploreTabState({Key key, @required this.currentUserId});
  String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}