import 'package:WatchA/models/show.dart';
import 'package:flutter/material.dart';

class ShowsTile extends StatelessWidget {
  final List<Show> shows;

  ShowsTile({this.shows});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return ListTile(
            title: Row(children: [
              SizedBox(
                width: 100,
                //I need to provide a poster if data returns null
                child: show.poster == null ? AssetImage("assets/images/noPoster.png") : NetworkImage(show.poster)
                // (profile.imgUrl == null) ? AssetImage('images/user-avatar.png') : NetworkImage(profile.imgUrl)
              ),
              Column(children: [
                Text(show.title),
                ],
              )
            ],
          )
        );
      }
    );
  }
}
