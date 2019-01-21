import 'package:flutter/material.dart';
import 'package:flutter_community_challenges/Login/check_login.dart';
import 'package:flutter_community_challenges/HallOfFame/hall_of_fame.dart';
import 'package:flutter_community_challenges/Login/login_screen.dart';
import 'package:flutter_community_challenges/CurrentChallenge/current_challenge.dart';
import 'package:flutter_community_challenges/Settings/settings.dart';
import 'package:flutter_community_challenges/CurrentChallenge/submit_entry.dart';
import 'package:flutter_community_challenges/ChallengeSuggestions/suggest_challenge.dart';
import 'package:flutter_community_challenges/UpcomingChallenges/upcoming_challenges.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter_community_challenges/ChallengeSuggestions/vote_challenge_suggestions.dart';
import 'package:simple_auth_flutter/simple_auth_flutter.dart';

void main() => runApp(FlutterCommunityChallenges());

class FlutterCommunityChallenges extends StatefulWidget {
  @override
  FlutterCommunityChallengesState createState() {
    return FlutterCommunityChallengesState();
  }
}

class FlutterCommunityChallengesState extends State<FlutterCommunityChallenges> {
  @override
  void initState() {
    super.initState();
    SimpleAuthFlutter.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        brightness: brightness,
        primarySwatch: Colors.indigo,
        primaryColor: Colors.indigo,
        accentColor: Colors.indigoAccent,
        //fontFamily: 'GoogleSans'
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'Flutter Community Challenges',
          theme: theme,
          home: CheckLogin(),
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            "/LoginScreen": (BuildContext context) => LoginScreen(),
            "/CurrentChallenge": (BuildContext context) => CurrentChallenge(),
            "/HallOfFame": (BuildContext context) => HallOfFame(),
            "/UpcomingChallenges": (BuildContext context) => UpcomingChallenges(),
            "/VoteOnChallengeSuggestions": (BuildContext context) => VoteOnChallengeSuggestions(),
            "/SuggestChallenge": (BuildContext context) => SuggestChallenge(),
            "/SubmitEntryToChallenge": (BuildContext context) => SubmitEntryToChallenge(),
            "/Settings": (BuildContext context) => Settings(),
          },
        );
      }
    );
  }
}