import 'package:flutter/material.dart';
import 'Auth.dart';
import 'Chat.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  static const String id = "HOMESCREEN";
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag:'logo',
                child: Container(
                ),

              ),
              Text(
                "QueueUp",
                style: TextStyle(fontSize: 40.0),
              ),
            ],
          ),
          SizedBox(
            height: 50.0,
          ),
          CustomButton(
            text:"Log In",
            callback:(){},
          ),
          CustomButton(
            text:"Register",
            callback:(){},
          ),
        ],
      )
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  const CustomButton({Key key, this.callback, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child:Material(
          color: Colors.blueGrey,
        elevation:6.0,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: callback,
          minWidth: 200.0,
          height: 45.0,
          child: Text(text),
        )
      )
    );
  }
}