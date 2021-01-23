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

  final TextEditingController _comment = TextEditingController();

  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.lightBlueAccent,
              expandedHeight: 400.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  details.title != null ? details.title : details.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                background: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                      child: details.poster != null
                          ? Image.network(
                              "https://image.tmdb.org/t/p/w342/" + details.poster)
                          : Image.asset("assets/images/noPoster.png"),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ])),
                    ),
                  ]),
              ),
            ),
          ];
        },
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: ListView(children: <Widget>[
              Text("Overview", 
                textAlign: TextAlign.center, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15.0,
                )
              ),
               SizedBox(
                height: 5.0,
              ),
              Text(details.overview != null ? details.overview : "No overview available.", 
              textAlign: TextAlign.justify),
              SizedBox(
                height: 20.0,
              ),
              //Text("Add a comment ...", style: TextStyle(color: Colors.lightBlue[700])),
              TextField(
                controller: _comment,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Add a comment ...",
                ),
              ),
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: () {},
                  child:
                      const Text("Create Post", style: TextStyle(fontSize: 15)),
                  color: Colors.blue,
                  textColor: Colors.white,
                  elevation: 5,
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}