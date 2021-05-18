
import 'package:bingeable/pages/home.dart';
import 'package:bingeable/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Followers extends StatefulWidget {
  
  // profileId will come from profile page
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

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
