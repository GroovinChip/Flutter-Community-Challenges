import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_challenges/properties_file.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseUser currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalStorage storage = LocalStorage("Repositories");

  // attempt to log into github on login button press
  void login(simpleAuth.AuthenticatedApi api) async {
    try {
      currentUser = await FirebaseAuth.instance.currentUser();
      var githubUser = await api.authenticate();
      var token = githubUser.toJson()['token'];
      var response = await http.get("https://api.github.com/user", headers: {HttpHeaders.authorizationHeader : "Bearer " + token});
      var responseJson = json.decode(response.body.toString());
      var reposURL = responseJson['repos_url'];
      var firebaseUser = await FirebaseAuth.instance.signInWithGithub(token: token);
      //print(responseJson);
      var repoResponse = await http.get(reposURL, headers: {HttpHeaders.authorizationHeader : "Bearer " + token});
      var repoJson = json.decode(repoResponse.body);
      storage.setItem("user_repositories", repoJson);
      UserUpdateInfo newInfo = UserUpdateInfo();
      newInfo.displayName = responseJson['login'];
      firebaseUser.updateProfile(newInfo);
      DocumentReference usersDB = Firestore.instance.collection("Users").document(firebaseUser.uid);
      usersDB.setData({
        "ReposUrl":reposURL,
        //"Login":responseJson['login'],
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).canvasColor,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Logging in...", style: TextStyle(color: Colors.black),),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        )
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pushNamedAndRemoveUntil('/CurrentChallenge',(Route<dynamic> route) => false);
    } catch (e) {
      showError(e);
    }
  }

  // log out of github (not firebase)
  void logout(simpleAuth.AuthenticatedApi api) async {
    await api.logOut();
    showMessage("Logged out");
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "Flutter Community Challenges",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
              ),
              /*Image.asset(
                "images/flutt.png",
                height: 150.0,
                width: 150.0,
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton.extended(
                    icon: Icon(
                      GroovinMaterialIcons.github_circle,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      final properties = await PropertiesFile().load();

                      final simpleAuth.GithubApi githubApi = simpleAuth.GithubApi(
                        "github",
                        properties.github.clientID,
                        properties.github.clientSecret,
                        properties.github.redirectURL,
                        scopes: [
                          "user",
                          "read:user",
                          "repo",
                          "public_repo",
                        ],
                      );
                      /*Navigator.pushNamed(context, '/CurrentChallenge');*/
                      login(githubApi);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
