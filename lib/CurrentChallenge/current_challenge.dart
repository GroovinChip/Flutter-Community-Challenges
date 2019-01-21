import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_community_challenges/CurrentChallenge/nav_bar.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:flutter_community_challenges/CurrentChallenge/current_challenge_card.dart';
import 'package:groovin_widgets/modal_drawer_handle.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';

/// This widget represents the main screen of the app
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
    if((currentUser.email ?? '').isEmpty)
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
      bottomNavigationBar: NavBar(
        currentUser: currentUser,
        userSubtitle: userSubtitle,
        packageInfo: _packageInfo,
      ),
    );
  }
}