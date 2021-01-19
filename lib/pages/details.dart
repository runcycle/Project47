//import 'package:WatchA/models/show.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  final details;

  DetailsPage({this.details});

  @override
  _DetailsState createState() => _DetailsState(details);
}

class _DetailsState extends State<DetailsPage> {
  ScrollController _scrollViewController;
  final details;
  _DetailsState(this.details);

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(details.title),
        ),
        body: NestedScrollView(
            controller: _scrollViewController,
            reverse: true,
            headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  forceElevated: boxIsScrolled,
                  expandedHeight: 100.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: (details.poster) == null ? Image.asset("assets/images/noPoster.png")
                  : Image.network(
                    "https://image.tmdb.org/t/p/w500/" + details.poster),
                  ),
                )
              ];
            },
            body:  Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(details.overview),
            ),
            
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
