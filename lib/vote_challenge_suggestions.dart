import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class VoteOnChallengeSuggestions extends StatefulWidget {
  @override
  _VoteOnChallengeSuggestionsState createState() => _VoteOnChallengeSuggestionsState();
}

class _VoteOnChallengeSuggestionsState extends State<VoteOnChallengeSuggestions> {
  String votes;
  FirebaseUser currentUser;
  final LocalStorage storage = LocalStorage("Repositories");

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
                    "Vote on Challenge Suggestions",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("ChallengeSuggestions").orderBy("VoteCount", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if(snapshot.data.documents.length == 0) {
                      return Center(
                        child: Text("No suggestions"),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (builder, index) {
                        int voteCount;
                        Color upvoteColor = Colors.black;
                        Color downvoteColor = Colors.black;
                        IconData challengeTypeIcon;
                        DocumentSnapshot csSnap = snapshot.data.documents[index];
                        if("${csSnap['VoteCount']}" == null || "${csSnap['VoteCount']}" == ""){
                          voteCount = 0;
                        } else {
                          voteCount = int.parse("${csSnap['VoteCount']}");
                        }
                        EdgeInsets columnPadding;
                        if("${csSnap['ChallengeDescription']}" != ""){
                          columnPadding = EdgeInsets.only(top: 10.0);
                        } else {
                          columnPadding = EdgeInsets.only(bottom: 10.0);
                        }
                        switch("${csSnap['ChallengeCategory']}") {
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
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Card(
                              elevation: 0.0,
                              color: Theme.of(context).canvasColor,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 12.0),
                                          child: Padding(
                                            padding: columnPadding,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Wrap(
                                                  children: <Widget>[
                                                    Text(
                                                      "${csSnap['ChallengeName']} - Submitted by " + "${csSnap['SubmittedBy']}",
                                                      style: TextStyle(
                                                        fontSize: 16.0
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                "${csSnap['ChallengeDescription']}" != "" ? Wrap(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Text(
                                                        "${csSnap['ChallengeDescription']}",
                                                        style: TextStyle(
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ) : Container(),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(challengeTypeIcon),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 8.0),
                                                        child: Text("${csSnap['ChallengeCategory']}"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 0.0),
                                        child: StreamBuilder<DocumentSnapshot>(
                                          stream: Firestore.instance.collection("ChallengeSuggestions").document(csSnap.documentID).collection("Voters").document(currentUser.displayName).snapshots(),
                                          builder: (context, snapshot) {
                                            if(!snapshot.hasData){
                                              return CircularProgressIndicator();
                                            } else {
                                              final voteType = snapshot.data.exists ? snapshot.data['VoteType'] : "";

                                              upvoteColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
                                              downvoteColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
                                              if(voteType == "Upvote") {
                                                upvoteColor = Colors.orange;
                                                downvoteColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
                                              } else if(voteType == "Downvote"){
                                                downvoteColor = Colors.indigo;
                                                upvoteColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
                                              }
                                              return Column(
                                                children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(Icons.arrow_upward, color: upvoteColor),
                                                    onPressed: (){
                                                      if(voteType != "Upvote") {
                                                        voteCount += 1;
                                                        Firestore.instance.collection("ChallengeSuggestions").document(csSnap.documentID).updateData({
                                                          "VoteCount":voteCount,
                                                        });
                                                        Firestore.instance.collection("ChallengeSuggestions").document(csSnap.documentID).collection("Voters").document(currentUser.displayName).setData({
                                                          "VoteType":"Upvote",
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  Text(voteCount.toString()),
                                                  IconButton(
                                                    icon: Icon(Icons.arrow_downward, color: downvoteColor),
                                                    onPressed: (){
                                                      if(voteType != "Downvote") {
                                                        voteCount-= 1;
                                                        Firestore.instance.collection("ChallengeSuggestions").document(csSnap.documentID).updateData({
                                                          "VoteCount":voteCount,
                                                        });
                                                        Firestore.instance.collection("ChallengeSuggestions").document(csSnap.documentID).collection("Voters").document(currentUser.displayName).setData({
                                                          "VoteType":"Downvote",
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 0.0,
                              color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.lightbulb_outline),
        label: Text("Suggest Challenge"),
        onPressed: () {
          Navigator.pushNamed(context, '/SuggestChallenge');
        },
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
