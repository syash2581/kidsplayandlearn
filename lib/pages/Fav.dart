import 'package:flutter/material.dart';

class Fav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_outline,
      size: 40.0,
      color: Colors.pink,
    );
  }
  static Widget getIcon(bool isFav)
  {
    if(isFav)
    {
      return Icon(
        Icons.star,
        size: 40.0,
        color: Colors.pink,
      );
    }
    else
    {
      return Icon(
        Icons.star_outline,
        size: 40.0,
        color: Colors.pink,
      );
    }
  }
}
