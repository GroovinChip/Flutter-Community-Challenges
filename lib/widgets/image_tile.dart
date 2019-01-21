import 'dart:io';

import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final File image;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Image child;

  ImageTile({
    Key key,
    @required this.image,
    @required this.child,
    this.onLongPress,
    this.onTap
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    print(image.path);
    return GridTile(
      child: GestureDetector(
        onLongPress: () => this.onLongPress(),
        onTap: () => this.onTap(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Hero(
            child: child,
            tag: image.path,
          ),
        )
      ),
    );
  }
}