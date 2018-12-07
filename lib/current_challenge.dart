import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:flutter_community_challenges/current_challenge_card.dart';
import 'package:groovin_widgets/modal_drawer_handle.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_community_challenges/extended_fab_notched_shape.dart';
import 'package:package_info/package_info.dart';

class CurrentChallenge extends StatefulWidget {

  @override
  _CurrentChallengeState createState() => _CurrentChallengeState();
}

class _CurrentChallengeState extends State<CurrentChallenge> {
  FirebaseUser currentUser;
  Widget userSubtitle;

  PackageInfo _packageInfo = new PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _initPackageInfo();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    if(currentUser.email.isEmpty)
      userSubtitle = null;
    else {
      userSubtitle = Text(currentUser.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarIconBrightness:
        Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarColor: Theme.of(context).canvasColor,
      systemNavigationBarColor: Theme.of(context).canvasColor,
      systemNavigationBarIconBrightness:
        Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    ));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Flutter Community Challenges",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            CurrentChallengeCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/SubmitEntryToChallenge");
        },
        child: Icon(Icons.file_upload),
        tooltip: "Submit Entry",
        //label: Text("Submit Entry"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: IconButton(
                    icon: Icon(OMIcons.more),
                    onPressed: () {
                      showRoundedModalBottomSheet(
                        context: context,
                        color: Theme.of(context).canvasColor,
                        dismissOnTap: false,
                        builder: (builder) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ModalDrawerHandle(
                                  handleColor: Colors.indigoAccent,
                                ),
                              ),
                              ListTile(
                                leading: Icon(OMIcons.accountCircle),
                                title: Text(currentUser.displayName),
                                subtitle: userSubtitle,
                                trailing: FlatButton(
                                  child: Text("Log Out"),
                                  onPressed: () {
                                    FirebaseAuth.instance.signOut();
                                    Navigator.of(context).pushNamedAndRemoveUntil('/',(Route<dynamic> route) => false);
                                  },
                                ),
                              ),
                              Divider(
                                height: 0.0,
                                color: Colors.grey,
                              ),
                              Material(
                                child: ListTile(
                                  title: Text("My Submissions"),
                                  leading:
                                      Icon(GroovinMaterialIcons.upload_multiple),
                                  onTap: () {},
                                ),
                              ),
                              Material(
                                child: ListTile(
                                  leading: Icon(OMIcons.settings),
                                  title: Text("App Settings"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/Settings');
                                  },
                                ),
                              ),
                              Divider(
                                height: 0.0,
                                color: Colors.grey,
                              ),
                              ListTile(
                                leading: Icon(OMIcons.info),
                                title: Text("Flutter Community Challenges"),
                                subtitle: Text(_packageInfo.version),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: IconButton(
                    icon: Icon(GroovinMaterialIcons.crown),
                    onPressed: () {
                      Navigator.pushNamed(context, '/HallOfFame');
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: IconButton(
                    icon: Icon(GroovinMaterialIcons.calendar_text),
                    onPressed: () {
                      Navigator.pushNamed(context, '/UpcomingChallenges');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: Icon(GroovinMaterialIcons.ballot_outline),
                    onPressed: () {
                      Navigator.pushNamed(context, '/VoteOnChallengeSuggestions');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}