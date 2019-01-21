import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

typedef CurrentUserBuilderFunction = Function(BuildContext, FirebaseUser);

class CurrentUserBuilder extends StatelessWidget {
  final CurrentUserBuilderFunction builder;

  const CurrentUserBuilder({Key key, @required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return builder(context, snapshot.data);
      }
    );
  }
}