import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_challenges/upcoming_challenge_card.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class UpcomingChallenges extends StatefulWidget {
  @override
  _UpcomingChallengesState createState() => _UpcomingChallengesState();
}

class _UpcomingChallengesState extends State<UpcomingChallenges> {
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
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
                    "Upcoming Challenges",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("UpcomingChallenges").snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  if(snapshot.data.documents.length > 0) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (builder, index) {
                          DocumentSnapshot challenge = snapshot.data.documents[index];
                          EdgeInsets columnPadding;
                          IconData challengeTypeIcon;
                          if("${challenge['ChallengeDescription']}" != ""){
                            columnPadding = EdgeInsets.only(top: 10.0);
                          } else {
                            columnPadding = EdgeInsets.only(bottom: 10.0);
                          }
                          switch("${challenge['ChallengeCategory']}") {
                            case "Productivity":
                              challengeTypeIcon = OMIcons.checkCircleOutline;
                              break;
                            case "UI/UX":
                              challengeTypeIcon = OMIcons.brush;
                              break;
                            case "State Management":
                              challengeTypeIcon = OMIcons.cached;
                              break;
                            case "Codegolf":
                              challengeTypeIcon = OMIcons.golfCourse;
                              break;
                            case "Other":
                              challengeTypeIcon = OMIcons.moreHoriz;
                              break;
                            default:
                              challengeTypeIcon = Icons.code;
                              break;
                          }
                          return UpcomingChallengeCard(
                            challengeName: "${challenge['ChallengeName']}",
                            challengeDescription: "${challenge['ChallengeDescription']}",
                            challengeCategory: "${challenge['ChallengeCategory']}",
                            submittedBy: "${challenge['SubmittedBy']}",
                            challengeTypeIcon: challengeTypeIcon,
                            columnPadding: columnPadding,
                          );
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Center(
                        child: Text("No upcoming challenges"),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(OMIcons.info),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}
