import 'package:flutter/material.dart';

AppBar header(context, { bool isAppTitle = false, String titleText }) {
  return AppBar(
    title: Text(
      isAppTitle ? "WhatchA" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "CherryCreamSoda" : "",
        fontSize: isAppTitle ? 30.0 : 25.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
