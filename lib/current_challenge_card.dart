import 'package:flutter/material.dart';

class CurrentChallengeCard extends StatefulWidget {
  @override
  _CurrentChallengeCardState createState() => _CurrentChallengeCardState();
}

class _CurrentChallengeCardState extends State<CurrentChallengeCard> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final backgroundColor =
      isLightTheme
        ? Colors.white
        : Colors.grey.shade800;

    final textColor =
      isLightTheme
      ? Colors.black
      : Colors.white;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 400.0,
              child: Card(
                elevation: 2.0,
                color: backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Current Challenge:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "Challenge Name",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 20.0,
                          color: textColor,
                        ),
                      ),
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
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
