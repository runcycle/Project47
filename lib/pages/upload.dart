import 'dart:async';
//import 'dart:io';
import 'dart:convert';
import 'package:WatchA/models/show.dart';
import 'package:WatchA/widgets/shows_tile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:WatchA/models/user.dart';
//import 'package:WatchA/models/show.dart';
//import 'package:WatchA/pages/home.dart';
//import 'package:WatchA/widgets/progress.dart';
//import 'package:WatchA/widgets/shows_tile.dart';
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final UserModel currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isUploading = false;
  String postId = Uuid().v4();
  final apiKey = DotEnv().env['API_KEY'];
  String query = "";
  List<Show> _shows = new List<Show>();

  // createPostInFirestore(
  //     {String mediaUrl, String location, String description}) {
  //   postsRef
  //       .doc(widget.currentUser.id)
  //       .collection("userPosts")
  //       .doc(postId)
  //       .set({
  //     "postId": postId,
  //     "ownerId": widget.currentUser.id,
  //     "username": widget.currentUser.username,
  //     "mediaUrl": mediaUrl,
  //     "description": description,
  //     "location": location,
  //     "timestamp": timestamp,
  //     "likes": {},
  //   });
  //   captionController.clear();
  //   searchController.clear();
  //   setState(() {
  //     //file = null;
  //     isUploading = false;
  //     postId = Uuid().v4();
  //   });
  // }


  searchShows(query) async {
    final response = await http.get(
        "https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query");
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(result);
      Iterable list = result["results"];
      final showList = list.map((query) => Show.fromJson(query)).toList();
      setState(() {
        _shows = showList;
        isUploading = false;
      });
      FocusManager.instance.primaryFocus.unfocus();
    } else {
      throw Exception("Failed to load request.");
    }
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      _shows = [];
    });
  }

  clearCaption() {
    captionController.clear();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => {},
        ),
        title: Text(
          "Create a Post",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 10),
          TextFormField(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a show...",
                filled: true,
                prefixIcon: Icon(
                  Icons.search,
                  size: 28.0,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: clearSearch,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a search term";
                }
                return null;
              }),
              SizedBox(height: 10),
          Container(
              width: MediaQuery.of(context).size.width,
              height: 30.0,
              alignment: Alignment.center,
              child: ElevatedButton(
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  searchShows(query);
                  isUploading = true;
                },
              )),
          Container(
            child: ShowsTile(shows: _shows),
          ),
        ],
      )
    );
  }
}