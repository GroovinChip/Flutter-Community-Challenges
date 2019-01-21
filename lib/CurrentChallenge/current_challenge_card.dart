import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CurrentChallengeCard extends StatefulWidget {
  @override
  _CurrentChallengeCardState createState() => _CurrentChallengeCardState();
}

class _CurrentChallengeCardState extends State<CurrentChallengeCard> {
  String formatDuration(Duration duration) {
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    return "${duration.inDays}d, $hours:$minutes";
  }

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
              }

              if (snapshot.data.documents.isEmpty) {
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

              final currentChallenge = snapshot.data.documents[0];
              final String challengeName = currentChallenge['ChallengeName'] ?? "";
              
              final DateTime submissionEndTime = currentChallenge['EndTime'];
              final timeLeft = submissionEndTime.difference(DateTime.now().toUtc());
              final String timeRemaining = "Time Remaining: ${formatDuration(timeLeft)}";
              
              final int submissionCount = currentChallenge['SubmissionsCount'] ?? 0;
              final String submissionsSoFar = "Submissions so far: $submissionCount";
              
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      challengeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                        color: textColor,
                      ),
                    ),
                    challengeName.isNotEmpty
                      ? Text(
                          challengeName,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0,
                            color: textColor,
                          ),
                        )
                      : Container(),
                    Text(
                      timeRemaining,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16.0,
                        color: textColor,
                      ),
                    ),
                    Text(
                      submissionsSoFar,
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
