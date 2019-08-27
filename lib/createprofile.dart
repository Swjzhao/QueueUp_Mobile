import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queueup_mobileapp/MultiSelectClip.dart';

class _PageSelector extends StatelessWidget {
  const _PageSelector();

  void _handleArrowButtonPress(BuildContext context, int delta) {
    final TabController controller = DefaultTabController.of(context);
    if (!controller.indexIsChanging)
      controller.animateTo((controller.index + delta).clamp(0, 2));
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final Color color = Theme.of(context).accentColor;
    return Builder(
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  CreateProfile1(context: context, currentUserId: null),
                  CreateProfile2(currentUserId: null),
                  CreateProfile3(currentUserId: null),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: color,
                    onPressed: () {
                      _handleArrowButtonPress(context, -1);
                    },
                    tooltip: 'Page back',
                  ),
                  TabPageSelector(controller: controller),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: color,
                    onPressed: () {
                      _handleArrowButtonPress(context, 1);
                    },
                    tooltip: 'Page forward',
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateProfile extends StatelessWidget {
  static const String id = "CREATEPROFILE";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: _PageSelector(),
      ),
    );
  }
}

class CreateProfile1 extends StatefulWidget {
  static const String id = "CREATEPROFILE1";

  final String currentUserId;
  final BuildContext context;

  CreateProfile1({Key key, this.context, @required this.currentUserId})
      : super(key: key);

  @override
  State createState() =>
      new CreateProfile1State(context: context, currentUserId: currentUserId);
}

class CreateProfile1State extends State<CreateProfile1> {
  CreateProfile1State({Key key, this.context, @required this.currentUserId});
  String currentUserId;
  String dropdownValue = 'Male';
  BuildContext context;

  Future<Null> handleNextButtonPress(int delta) async {
    final TabController controller = DefaultTabController.of(context);
    if (!controller.indexIsChanging)
      controller.animateTo((controller.index + delta).clamp(0, 2));
    Fluttertoast.showToast(msg: "Button Pressed");
  }

  List<String> reportList = [
    "Not relevant",
    "Illegal",
    "Spam",
    "Offensive",
    "Uncivil"
  ];
   
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Welcome!",
              style: TextStyle(fontSize: 40.0),
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(
                "Gender:  ",
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(
                height: 40.0,
              ),
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: <String>['Male', 'Female', 'Unspecified']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 20.0)),
                  );
                }).toList(),
              )
            ]),
            MultiSelectChip(reportList),
            Expanded(child: Text('')),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
              Expanded(child: Text('')),
              CustomButtonSmall(
                text: 'Next',
                callback: () async {
                  await handleNextButtonPress(1);
                },
              )
            ])
          ],
        )));
  }
}

class CreateProfile2 extends StatefulWidget {
  static const String id = "CREATEPROFILE2";

  final String currentUserId;

  CreateProfile2({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new CreateProfile2State(currentUserId: currentUserId);
}

class CreateProfile2State extends State<CreateProfile2> {
  CreateProfile2State({Key key, @required this.currentUserId});
  String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CreateProfile3 extends StatefulWidget {
  static const String id = "CREATEPROFILE3";

  final String currentUserId;

  CreateProfile3({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new CreateProfile3State(currentUserId: currentUserId);
}

class CreateProfile3State extends State<CreateProfile3> {
  CreateProfile3State({Key key, @required this.currentUserId});
  String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
