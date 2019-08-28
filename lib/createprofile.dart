import 'package:flutter/material.dart';
import 'package:queueup_mobileapp/createprofile_tabs/createProfile1.dart';
import 'package:queueup_mobileapp/createprofile_tabs/createProfile2.dart';
import 'package:queueup_mobileapp/createprofile_tabs/createProfile3.dart';
import 'package:queueup_mobileapp/createprofile_tabs/createProfile4.dart';

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
                  CreateProfile2(context: context, currentUserId: null),
                  CreateProfile3(bcontext: context, currentUserId: null),
                  CreateProfile4(currentUserId: null),
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

class CreateProfile extends StatefulWidget {
  static const String id = "CREATEPROFILE";
  final String currentUserId;

  CreateProfile({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new CreateProfileState(currentUserId: currentUserId);
}

class CreateProfileState extends State<CreateProfile> {
  CreateProfileState({Key key, @required this.currentUserId});
  static const String id = "CREATEPROFILE";
  String currentUserId;

  void _handleArrowButtonPress(BuildContext context, int delta) {
    final TabController controller = DefaultTabController.of(context);
    if (!controller.indexIsChanging)
      controller.animateTo((controller.index + delta).clamp(0, 2));
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final Color color = Theme.of(context).accentColor;
    return Scaffold(
      body: DefaultTabController(
          length: 4,
          child: Builder(
            builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        CreateProfile1(
                            context: context, currentUserId: currentUserId),
                        CreateProfile2(
                            context: context, currentUserId: currentUserId),
                        CreateProfile3(
                            bcontext: context, currentUserId: currentUserId),
                        CreateProfile4(currentUserId: currentUserId),
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
          )),
    );
  }
}
