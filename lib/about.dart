import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Icon(GroovinMaterialIcons.information_outline),
      ),
    );
  }
}
