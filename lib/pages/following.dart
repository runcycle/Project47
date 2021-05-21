import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/home.dart';
import 'package:bingeable/pages/search.dart';
import 'package:bingeable/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bingeable/pages/activity_feed.dart';

class Followers extends StatefulWidget {
  final String profileId;

  Followers({this.profileId});

  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers>
    with AutomaticKeepAliveClientMixin<Followers> {
  bool get wantKeepAlive => true;
  List<QueryDocumentSnapshot> following;

  @override
  void initState() {
    super.initState();
    getFollowers();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection("userFollowing")
        .get();
    setState(() {
      following = snapshot.docs;
    });
  }

  buildNoContent() {
    //final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            // SvgPicture.asset(
            //   "assets/images/search.svg",
            //   height: orientation == Orientation.portrait ? 250.0 : 150.0,
            // ),
            // Text(
            //   "Find Users",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontStyle: FontStyle.italic,
            //     fontWeight: FontWeight.w600,
            //     fontSize: 50.0,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 5.0,
              child: Container(
                color: Colors.grey[300],
                child: GestureDetector(
                  onTap: () => showProfile(context, profileId: widget.profileId),
                  child: ListTile(
                    leading: CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl)),
                    title: Text(
                      user.displayName,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      user.username,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              height: 2.0,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
