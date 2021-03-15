import 'package:WatchA/models/show.dart';
import 'package:WatchA/models/user.dart';
import 'package:WatchA/pages/details.dart';
import 'package:flutter/material.dart';

class ShowsTile extends StatefulWidget {
  final List<Show> shows;
  final UserModel currentUser;

  ShowsTile({this.shows, this.currentUser});

  @override
  _ShowsTileState createState() => _ShowsTileState(currentUser);
}

class _ShowsTileState extends State<ShowsTile> {
  final currentUser;
  _ShowsTileState(this.currentUser);
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
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(
                            details: show,
                            currentUser: currentUser,
                          )));
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
                      Text(show.title != null ? show.title : show.name),
                      SizedBox(height: 5.0),
                      Text(show.date != null ? show.date.substring(0, 4).trim() : ""),
                    ],
                  ),
                ),
              )
            ])),
          );
        });
  }
}
