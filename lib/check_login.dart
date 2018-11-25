import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckLogin extends StatefulWidget {
  @override
  _CheckLoginState createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    checkCachedUser();
  }

  void checkCachedUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    if(currentUser != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/CurrentChallenge',(Route<dynamic> route) => false);
    } else {
      Navigator.pushNamed(context, '/LoginScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CircularProgressIndicator(),
    );
  }
}
