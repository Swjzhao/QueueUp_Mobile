import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  MultiSelectChip(this.reportList);
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}
class _MultiSelectChipState extends State<MultiSelectChip> {

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

  List<String> selectedChoices = List();
  _buildChoiceList() {
    List<Widget> choices = List();
    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(10.0),
        child: ChoiceChip(
          label: Text(item,  style: TextStyle(fontSize: 20.0)),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
            });
            Firestore.instance
                .collection('users')
                .document(id)
                .updateData({'games': selectedChoices}).then((data) async {
              await prefs.setStringList('games', selectedChoices);
              setState(() {
                isLoading = false;
              });
            }).catchError((err) {
              setState(() {
                isLoading = false;
              });

              Fluttertoast.showToast(msg: err.toString());
            });
          },
        ),
      ));
    });
    return choices;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
      child:  Wrap(
        children: _buildChoiceList(),
      )
    );
  }
}

