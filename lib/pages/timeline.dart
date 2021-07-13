import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/search.dart';
import 'package:bingeable/services/admob_service.dart';
import 'package:bingeable/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bingeable/widgets/progress.dart';
import 'package:bingeable/pages/home.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final usersRef = FirebaseFirestore.instance.collection("users");

class Timeline extends StatefulWidget {
  final UserModel currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];
  BannerAd _ad;
  bool isLoaded;
  bool insertAd = false;

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.mediumRectangle,
      listener: AdListener(onAdLoaded: (_) {
        setState(
          () {
            isLoaded = true;
          },
        );
      }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        //print("Ad Failed to Load with Error: $error");
      }),
    );
    _ad.load();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
    //print(currentUser.username);
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection("userFollowing")
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Widget buildAd() {
    if (isLoaded == true) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: AdWidget(ad: _ad),
            ),
            width: _ad.size.width.toDouble(),
            height: _ad.size.height.toDouble(),
            alignment: Alignment.center,
          ),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView.builder(
        clipBehavior: Clip.none,
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          if (index % 5 == 0) {
            return buildAd();
          } else {
            return Column(
              children: posts,
            );
          }
        },
      );
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy("timestamp", descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.docs.forEach((doc) {
          UserModel user = UserModel.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.person_add,
                        color: Theme.of(context).primaryColor, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                      "A few users to get you started ...",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: userResults),
            ],
          ),
        );
      },
    );
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bingeable', style: TextStyle(fontFamily: 'CherryCreamSoda', fontSize: 25.0)),
        centerTitle: true,
        elevation: 15,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
