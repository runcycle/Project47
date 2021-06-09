import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DetailsPage extends StatefulWidget {
  final details;
  final UserModel currentUser;

  DetailsPage({this.details, this.currentUser});

  @override
  _DetailsState createState() => _DetailsState(details, currentUser);
}

class _DetailsState extends State<DetailsPage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  firebase_storage.Reference noPosterRef =
      firebase_storage.FirebaseStorage.instance.ref("noPoster.jpg");
  final details;
  final currentUser;
  _DetailsState(this.details, this.currentUser);

  final TextEditingController _comment = TextEditingController();
  String postId = Uuid().v4();
  bool isUploading = false;
  String description = "";
  bool renderPage = false;
  final mediaUrl = "https://image.tmdb.org/t/p/w342/";
  String network;
  List networksList = [
    "Netflix",
    "Hulu",
    "Disney+",
    "Amazon Prime",
    "YouTube TV",
    "Peacock (NBC)",
    "CBS All Access",
    "Curiosity Stream",
    "Sling TV",
    "Philo",
    "Kanopy",
    "fuboTV",
    "KweliTV",
    "PBS Documentaries",
    "Plex",
    "Tubi",
    "VRV",
    "Crunchyroll",
    "Dazn",
    "discovery+",
    "ESPN+",
    "Funimation",
    "Apple TV+",
    "HBO Now",
    "IFC Films Unlimited",
    "IMDbTV",
    "Locast",
    "Mubi",
    "NFL Game Pass",
    "Ovid.tv",
    "RetroCrush",
    "Shudder",
    "The Criterion Channel",
    "Acorn TV",
    "AT&T TV",
    "BET+",
    "BritBox",
    "Crackle",
    "DC Universe",
    "Filmatique",
    "Hidive",
    "NFL Sunday Ticket",
    "Pluto TV",
    "Quibi",
    "Screambox",
    "Showtime",
    "Starz",
    "Sundance Now",
    "BlackOakTV",
    "Xumo"
  ];

  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Widget buildNetworkList() => Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButton(
            hint: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("Choose a streaming service ...",
                  style: TextStyle(fontSize: 17)),
            ),
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 30,
            isExpanded: true,
            underline: SizedBox(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            value: network,
            onChanged: (newValue) {
              setState(() {
                network = newValue;
              });
            },
            items: networksList.map((valueItem) {
              return DropdownMenuItem(
                  value: valueItem,
                  child: Center(
                    child: Text(
                      valueItem,
                    ),
                  ));
            }).toList(),
          ),
        ),
      ));

  createPostInFirestore() async {
    final noPoster = await noPosterRef.getDownloadURL();
    final poster =
        details.poster != null ? mediaUrl + details.poster : noPoster;
    postsRef
        .doc(widget.currentUser.id)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": poster,
      "description": description,
      "network": network,
      "timestamp": timestamp,
      "title": details.title != null ? details.title : details.name,
      "likes": {},
      "mediaType": details.mediaType,
    });
    _comment.clear();
    setState(() {
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).primaryColor,
              expandedHeight: 350.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  details.title != null ? details.title : details.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'CherryCreamSoda',
                  ),
                ),
                background: Stack(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: double.infinity,
                    child: details.poster != null
                        ? Image.network(mediaUrl + details.poster)
                        : Image.asset("assets/images/noPoster.png"),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.black.withOpacity(0.7),
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
                  )),
              SizedBox(
                height: 5.0,
              ),
              Text(
                  details.overview != null
                      ? details.overview
                      : "No overview available.",
                  textAlign: TextAlign.justify),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: _comment,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Add a comment ...",
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              SizedBox(height: 15.0),
              Text("Which network did you watch this on?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  )),
              SizedBox(height: 10.0),
              // Start building checkboxes right here!
              buildNetworkList(),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.purple[400],
                      elevation: 2.0,
                      //side: BorderSide(color: Colors.grey[600], width: 1.0),
                      //visualDensity: VisualDensity.compact,
                    ),
                  onPressed: () async {
                    await createPostInFirestore();
                    isUploading = true;
                    Navigator.pop(context);
                  },
                  child:
                      const Text("Create Post", style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),
                  // color: Colors.blue,
                  // textColor: Colors.white,
                  // elevation: 5,
                ),
              ),
            ])),
      ),
    );
  }
}
