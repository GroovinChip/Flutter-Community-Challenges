import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class SuggestChallenge extends StatefulWidget {
  @override
  _SuggestChallengeState createState() => _SuggestChallengeState();
}

class _SuggestChallengeState extends State<SuggestChallenge> {
  String _challengeType;
  TextEditingController _challengeNameController = TextEditingController();
  TextEditingController _challengeDescriptionController = TextEditingController();
  FirebaseUser currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  final formKey = GlobalKey<FormState>();

  void submitSuggestion() async {
    /*if(formKey.currentState.validate()) {
      // submit suggestion
    }*/

    if(_challengeNameController.text != null || _challengeNameController.text != ""){
      if(_challengeType != null) {
        CollectionReference challengeSuggestionsDB = Firestore.instance.collection("ChallengeSuggestions");
        challengeSuggestionsDB.document().setData({
          "ChallengeName":_challengeNameController.text,
          "ChallengeCategory":_challengeType,
          "ChallengeDescription":_challengeDescriptionController.text,
          "SubmittedBy":currentUser.displayName,
          "VoteCount":"",
        });
        Navigator.pop(context);
      } else if(_challengeType == null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).canvasColor,
            content: Row(
              children: <Widget>[
                Icon(Icons.error, color: Colors.red),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("Please enter required fields", style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: "Dismiss",
              onPressed: () {},
            ),
          ),
        );
      }
    } else if(_challengeType == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).canvasColor,
          content: Row(
            children: <Widget>[
              Icon(Icons.error, color: Colors.red),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Please enter required fields", style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: "Dismiss",
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Suggest a Challenge",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    validator: (input) => input == null || input == "" ? 'This field is required' : null,
                    onSaved: (input) => _challengeNameController.text = input,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Challenge Name *",
                      prefixIcon: Icon(OMIcons.assignment)
                    ),
                    controller: _challengeNameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlineDropdownButton(
                    items: [
                      DropdownMenuItem(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(OMIcons.checkCircleOutline),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text("Productivity"),
                            ),
                          ],
                        ),
                        value: "Productivity",
                      ),
                      DropdownMenuItem(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(OMIcons.brush),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text("UI/UX"),
                            ),
                          ],
                        ),
                        value: "UI/UX",
                      ),
                      DropdownMenuItem(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(OMIcons.cached),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text("State Management"),
                            ),
                          ],
                        ),
                        value: "State Management",
                      ),
                      DropdownMenuItem(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(OMIcons.golfCourse),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text("Codegolf"),
                            ),
                          ],
                        ),
                        value: "Codegolf",
                      ),
                      DropdownMenuItem(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(OMIcons.moreHoriz),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text("Other"),
                            ),
                          ],
                        ),
                        value: "Other",
                      ),
                    ],
                    hint: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(OMIcons.category, color: Colors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("Challenge Category *"),
                        ),
                      ],
                    ),
                    value: _challengeType,
                    onChanged: (value) {
                      setState(() {
                        _challengeType = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    validator: (input) => input == null || input == "" ? 'This field is required' : null,
                    onSaved: (input) => _challengeDescriptionController.text = input,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Description*",
                      prefixIcon: Icon(OMIcons.textsms)
                    ),
                    maxLines: 2,
                    controller: _challengeDescriptionController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.cloud_upload),
        label: Text("Submit"),
        onPressed: () {
          submitSuggestion();
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
