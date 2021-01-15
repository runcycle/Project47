import 'package:WatchA/models/show.dart';
import 'package:WatchA/pages/details.dart';
import 'package:flutter/material.dart';

class ShowsTile extends StatefulWidget {
  final List<Show> shows;

  ShowsTile({this.shows});

  @override
  _ShowsTileState createState() => _ShowsTileState();
}

class _ShowsTileState extends State<ShowsTile> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.shows.length,
        itemBuilder: (context, index) {
          final show = widget.shows[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DetailsPage(
                    details: show
                  )
                )
              );
            },
            child: ListTile(
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
            ])),
          );
        });
  }
}
