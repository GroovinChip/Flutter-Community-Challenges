import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class ChallengeSuggestions extends StatefulWidget {
  @override
  _ChallengeSuggestionsState createState() => _ChallengeSuggestionsState();
}

class _ChallengeSuggestionsState extends State<ChallengeSuggestions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Icon(GroovinMaterialIcons.comment_plus_outline),
      ),
    );
  }
}
