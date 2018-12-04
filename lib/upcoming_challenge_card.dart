import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpcomingChallengeCard extends StatefulWidget {
  final EdgeInsets columnPadding;
  final String challengeName;
  final String submittedBy;
  final String challengeDescription;
  final String challengeCategory;
  final IconData challengeTypeIcon;

  const UpcomingChallengeCard({Key key, this.columnPadding, this.challengeName, this.challengeDescription, this.challengeCategory, this.submittedBy, this.challengeTypeIcon}) : super(key: key);

  @override
  _UpcomingChallengeCardState createState() => _UpcomingChallengeCardState();
}

class _UpcomingChallengeCardState extends State<UpcomingChallengeCard> {
  @override
  Widget build(BuildContext context) {
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
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Padding(
                      padding: widget.columnPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Text(
                                widget.challengeName + " - Submitted by " + widget.submittedBy,
                                style: TextStyle(
                                    fontSize: 16.0
                                ),
                              ),
                            ],
                          ),
                          widget.challengeDescription != "" ? Wrap(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  widget.challengeDescription,
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
                                Icon(widget.challengeTypeIcon),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(widget.challengeCategory),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /*Padding(
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
                  ),*/
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
  }
}
