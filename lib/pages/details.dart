//import 'package:WatchA/models/show.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  final details;

  DetailsPage({this.details});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movie Details"),
      ),
      body: Column(
        children: <Widget>[
          Text(""),
        ],
      )
    );
  }
}
