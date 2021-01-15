//import 'package:WatchA/models/show.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  final details;

  DetailsPage({this.details});

  @override
  _DetailsState createState() => _DetailsState(details);
}

class _DetailsState extends State<DetailsPage> {
  final details;
  _DetailsState(this.details);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(details.title),
        ),
        body: ListView(
          children: <Widget>[
            Card(
              elevation: 5,
              child: Container(
                height: 300,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: (details.poster) == null ? AssetImage("assets/images/noPoster.png")
                  : NetworkImage(
                    "https://image.tmdb.org/t/p/w500/" + details.poster),
                  )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(details.overview),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                  child: Text(
                    "Add to Post",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
    
                  },
                ),
            )
          ],
        ));
  }
}
