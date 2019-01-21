import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_challenges/ChallengeSuggestions/challenge_suggestion_card.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class VoteOnChallengeSuggestions extends StatefulWidget {
  @override
  _VoteOnChallengeSuggestionsState createState() => _VoteOnChallengeSuggestionsState();
}

class _VoteOnChallengeSuggestionsState extends State<VoteOnChallengeSuggestions> {
  String votes;
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
            // Mimics an AppBar for this page
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
            // Represents the body of the whole page
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
                    final challengeSuggestionSnap = snapshot;
                    // This list will contain all Challenge Suggestions
                    return ListView.builder(
                      itemCount: challengeSuggestionSnap.data.documents.length,
                      itemBuilder: (builder, index) {
                        return ChallengeSuggestionCard(
                          currentUser: currentUser,
                          index: index,
                          snapshot: challengeSuggestionSnap,
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
