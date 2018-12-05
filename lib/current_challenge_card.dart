import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CurrentChallengeCard extends StatefulWidget {
  @override
  _CurrentChallengeCardState createState() => _CurrentChallengeCardState();
}

class _CurrentChallengeCardState extends State<CurrentChallengeCard> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final backgroundColor = isLightTheme ? Colors.white : Colors.grey.shade800;

    final textColor = isLightTheme ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 2.0,
          color: backgroundColor,
          child: StreamBuilder<QuerySnapshot>(
            stream:
                Firestore.instance.collection("CurrentChallenge").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("ERROR"),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.data.documents.length > 0) {
                  DocumentSnapshot currentChallenge = snapshot.data.documents[0];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "${currentChallenge['ChallengeName']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: textColor,
                          ),
                        ),
                        "${currentChallenge['ChallengeName']}" != null
                          ? Text(
                              "${currentChallenge['ChallengeName']}",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 20.0,
                                color: textColor,
                              ),
                            )
                          : Container(),
                        Text(
                          "Time Remaining: 00d, 00:00",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16.0,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "Submissions so far: X",
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No challenge found",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
