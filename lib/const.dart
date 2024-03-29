import 'dart:ui';
import 'package:flutter/material.dart';

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  const CustomButton({Key key, this.callback, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: Material(
            color: Colors.blueGrey,
            elevation: 6.0,
            borderRadius: BorderRadius.circular(30.0),
            child: MaterialButton(
              onPressed: callback,
              minWidth: 200.0,
              height: 45.0,
              child: Text(text),
            )));
  }
}

class CustomButtonSmall extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  const CustomButtonSmall({Key key, this.callback, this.text})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
            color: Colors.blueGrey,
            elevation: 6.0,
            borderRadius: BorderRadius.circular(30.0),
            child: MaterialButton(
              onPressed: callback,
              minWidth: 100.0,
              height: 25.0,
              child: Text(text),
            )));
  }
}

class CustomLabel extends StatefulWidget {
  final List<String> games;
  CustomLabel({Key key, @required this.games}) : super(key: key);

  @override
  State createState() => new CustomLabelState(games: games);
}

class CustomLabelState extends State<CustomLabel> {
  CustomLabelState({Key key, @required this.games});

  List<String> games;

  _buildChoiceList() {
    List<Widget> widgets = List();
    games.forEach((item) {
      widgets.add(
        Container(
            margin: EdgeInsets.only(bottom: 15, right: 10),
          child:Material(
              color: Colors.blueGrey,
              elevation: 6.0,
              borderRadius: BorderRadius.circular(30.0),
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child:Text(item)
              )
          )
        )
      );
    });
    return widgets;
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
