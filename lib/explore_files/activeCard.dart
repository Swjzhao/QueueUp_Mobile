import 'dart:math';
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:flutter/material.dart';

Positioned profileCard(
    String photoUrl,
    String username,
    List<String> games,
    double bottom,
    double right,
    double left,
    double cardWidth,
    double rotation,
    double skew,
    BuildContext context,
    Function dismissImg,
    int flag,
    Function addImg,
    Function swipeRight,
    Function swipeLeft) {
  Size screenSize = MediaQuery.of(context).size;
  // print("Card");
  return new Positioned(
    bottom: 50.0 + bottom,
    right: flag == 0 ? right != 0.0 ? right : null : null,
    left: flag == 1 ? right != 0.0 ? right : null : null,
    child: new Dismissible(
      key: new Key(new Random().toString()),
      crossAxisEndOffset: -0.3,
      onResize: () {
        //print("here");
        // setState(() {
        //   var i = data.removeLast();

        //   data.insert(0, i);
        // });
      },
      onDismissed: (DismissDirection direction) {
        //   _swipeAnimation();
        if (direction == DismissDirection.endToStart)
          dismissImg();
        else
          addImg();
      },
      child: new Transform(
        alignment: flag == 0 ? Alignment.bottomRight : Alignment.bottomLeft,
        //transform: null,
        transform: new Matrix4.skewX(skew),
        //..rotateX(-math.pi / rotation),
        child: new RotationTransition(
          turns: new AlwaysStoppedAnimation(
              flag == 0 ? rotation / 360 : -rotation / 360),
          child: new Hero(
            tag: "img",
            child: new GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     new MaterialPageRoute(
                //         builder: (context) => new DetailPage(type: img)));
//                Navigator.of(context).push(new PageRouteBuilder(
//                      pageBuilder: (_, __, ___) => new DetailPage(type: img),
//                    ));
              },
              child: new Card(
                color: Colors.transparent,
                elevation: 4.0,
                child: new Container(
                  alignment: Alignment.center,
                  width: screenSize.width / 1.2 + cardWidth,
                  height: screenSize.height / 1.7,
                  decoration: new BoxDecoration(
                    color: ThemeData.light().backgroundColor,
                    borderRadius: new BorderRadius.circular(8.0),
                  ),
                  child: new Column(

                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Material(
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
                      ),

                      new Container(
                          width: screenSize.width / 1.2 + cardWidth,
                          height:
                              screenSize.height / 1.7 - screenSize.height / 2.2,
                          alignment: Alignment.center,
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new FlatButton(
                                  padding: new EdgeInsets.all(0.0),
                                  onPressed: () {
                                    swipeLeft();
                                  },
                                  child: new Container(
                                    height: 60.0,
                                    width: 120.0,
                                    alignment: Alignment.center,
                                    decoration: new BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          new BorderRadius.circular(60.0),
                                    ),
                                    child: new Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 30.0,
                                    ),
                                  )),
                              new FlatButton(
                                  padding: new EdgeInsets.all(0.0),
                                  onPressed: () {
                                    swipeRight();
                                  },
                                  child: new Container(
                                    height: 60.0,
                                    width: 120.0,
                                    alignment: Alignment.center,
                                    decoration: new BoxDecoration(
                                      color: Colors.cyan,
                                      borderRadius:
                                          new BorderRadius.circular(60.0),
                                    ),
                                    child: new Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 30.0,
                                    ),
                                  ))
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
