import 'package:WatchA/models/show.dart';
import 'package:flutter/material.dart';

class ShowsTile extends StatelessWidget {
  final List<Show> shows;

  ShowsTile({this.shows});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shows.length, 
      itemBuilder: (context, index) {
        
      }
    );
  }
}
