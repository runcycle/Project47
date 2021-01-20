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
                child: Center(
                    child: Container(
                        height: 380,
                        width: 255,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: (details.poster) == null ? AssetImage("assets/images/noPoster.png")
                          : NetworkImage(
                            "https://image.tmdb.org/t/p/w500/" + details.poster),
                                )
                              )
                      
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Card(
                  child: Text((details.overview) == null ? "" : details.overview),
                )
              ),
              SizedBox(
              width: 150,
              height: 30,
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
      )
    );
  }
}

// Column(
//           children: <Widget>[
//             Card(
//               elevation: 5,
//               child: Container(
//                 height: 380,
//                 width: 255,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   image: DecorationImage(
//                     fit: BoxFit.fitHeight,
//                     image: (details.poster) == null ? AssetImage("assets/images/noPoster.png")
//                   : NetworkImage(
//                     "https://image.tmdb.org/t/p/w500/" + details.poster),
//                   )
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(details.overview),
//             ),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                   child: Text(
//                     "Add to Post",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   onPressed: () {

//                   },
//                 ),
//             )
//           ],
//         )
