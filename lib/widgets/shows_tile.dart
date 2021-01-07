import 'package:WatchA/models/show.dart';
import 'package:flutter/material.dart';

class ShowsTile extends StatelessWidget {
  final List<Show> shows;

  ShowsTile({this.shows});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return ListTile(
            leading: GestureDetector(
              onTap: () {},
                child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                  //I need to provide a poster if data returns null
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: (show.poster) == null
                        ? AssetImage("assets/images/noPoster.png")
                        : NetworkImage(
                          "https://image.tmdb.org/t/p/w500/" + show.poster),
                ),
              )
            ),
          ),
        );
      }
    );
  }
}
