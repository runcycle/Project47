import 'package:WatchA/models/show.dart';
import 'package:flutter/material.dart';

class ShowsTile extends StatelessWidget {
  final List<Show> shows;

  ShowsTile({this.shows});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return ListTile(
              title: Row(children: [
            SizedBox(
                child: SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (show.poster) == null
                    ? Image.asset("assets/images/noPoster.png")
                    : Image.network(
                        "https://image.tmdb.org/t/p/w500/" + show.poster),
              ),
            )),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(show.title),
                    Text(show.date != null ? show.date : ""),
                  ],
                ),
              ),
            )
          ])

              //   GestureDetector(
              //     onTap: () {},
              //       child: Container(
              //       width: 100,
              //       height: 100,
              //         //I need to provide a poster if data returns null
              //       decoration: BoxDecoration(
              //         shape: BoxShape.rectangle,
              //         image: DecorationImage(
              //           image: (show.poster) == null
              //               ? AssetImage("assets/images/noPoster.png")
              //               : NetworkImage(
              //                 "https://image.tmdb.org/t/p/w500/" + show.poster),
              //       ),
              //     )
              //   ),
              // ),
              );
        });
  }
}
