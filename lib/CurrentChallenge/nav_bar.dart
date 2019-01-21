import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:rounded_modal/rounded_modal.dart';

class NavBar extends StatefulWidget {
  final FirebaseUser currentUser;
  final Widget userSubtitle;
  final PackageInfo packageInfo;

  const NavBar({
    Key key,
    @required this.currentUser,
    @required this.userSubtitle,
    @required this.packageInfo,
  }) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
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
                              title: Text(widget.currentUser.displayName),
                              subtitle: widget.userSubtitle,
                              trailing: FlatButton(
                                child: Text("Log Out"),
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/', (Route<dynamic> route) => false);
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
                              subtitle: Text(widget.packageInfo.version),
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
    );
  }
}
