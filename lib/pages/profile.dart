import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/edit_profile.dart';
import 'package:bingeable/pages/following.dart';
import 'package:bingeable/pages/home.dart';
import 'package:bingeable/widgets/post.dart';
import 'package:bingeable/widgets/post_tile.dart';
import 'package:bingeable/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  String postOrientation = "grid";
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  String postType = "";
  String headerTitle = "All Posts";

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection("userFollowing")
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(count.toString(),
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: "Edit Profile/Logout", function: editProfile);
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUserId)
        .collection("userFollowing")
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item
    activityFeedRef
        .doc(widget.profileId)
        .collection("feedItems")
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUserId)
        .set({});
    // put THAT user in YOUR following collection (update your following collection)
    followingRef
        .doc(currentUserId)
        .collection("userFollowing")
        .doc(widget.profileId)
        .set({});
    // add activity feed item for THAT user to notify about new follower
    activityFeedRef
        .doc(widget.profileId)
        .collection("feedItems")
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  navigateToFollowing() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Following(profileId: widget.profileId)));
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserModel user = UserModel.fromDocument(snapshot.data);
        return Padding(
          padding:
              EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("Posts", postCount),
                            buildCountColumn("Followers", followerCount),
                            buildCountColumn("Following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                          TextButton(
                            onPressed: () => navigateToFollowing(),
                            child: Text("View")),
                        ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio,
                  style: TextStyle(
                    color: Colors.grey[700],
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset("assets/images/no_content.svg", height: 200.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts Yet!",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  filterMedia() async {
    if (postType == "all") {
      QuerySnapshot snapshot =
          await postsRef.doc(widget.profileId).collection("userPosts").get();
      setState(() {
        posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
        headerTitle = "All Posts";
      });
      buildProfilePosts();
    } else if (postType == "movie") {
      QuerySnapshot snapshot = await postsRef
          .doc(widget.profileId)
          .collection("userPosts")
          .where("mediaType", isEqualTo: "movie")
          .get();
      setState(() {
        posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
        headerTitle = "Movies";
      });
      buildProfilePosts();
    } else if (postType == "tv") {
      QuerySnapshot snapshot = await postsRef
          .doc(widget.profileId)
          .collection("userPosts")
          .where("mediaType", isEqualTo: "tv")
          .get();
      setState(() {
        posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
        headerTitle = "TV Shows";
      });
      buildProfilePosts();
    } else if (postType == "podcast") {
      QuerySnapshot snapshot = await postsRef
          .doc(widget.profileId)
          .collection("userPosts")
          .where("mediaType", isEqualTo: "podcast")
          .get();
      setState(() {
        posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
        headerTitle = "Podcasts";
      });
      buildProfilePosts();
    }
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        PopupMenuButton(
          onSelected: (result) {
            setState(() {
              postType = result;
            });
            print(postType);
            filterMedia();
          },
          icon: Icon(Icons.filter_alt_outlined, color: Colors.grey),
          color: Colors.purple[400],
          elevation: 2.0,
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                  value: "all",
                  child: Text("All",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              PopupMenuItem(
                  value: "movie",
                  child: Text("Movies",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              PopupMenuItem(
                  value: "tv",
                  child: Text("TV Shows",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              PopupMenuItem(
                value: "podcast",
                child: Text("Podcasts (Soon)",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ];
          },
        ),
      ],
    );
  }

  buildPostHeader() {
    return Row(children: <Widget>[
      Container(
          height: 25.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(width: 2.0, color: Colors.grey),
                bottom: BorderSide(width: 2.0, color: Colors.grey)),
            //color: Colors.grey
          ),
          child: Center(
            child: Text(
              headerTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ))
    ]);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Profile',
            style: TextStyle(fontFamily: 'CherryCreamSoda', fontSize: 25.0)),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          // Divider(
          //   thickness: 1.5,
          //   color: Colors.grey[300]),
          buildTogglePostOrientation(),
          buildPostHeader(),
          Divider(
            height: 5.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}

// header(context, titleText: "Profile"),
