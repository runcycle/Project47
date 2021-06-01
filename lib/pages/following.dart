import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/home.dart';
//import 'package:bingeable/pages/search.dart';
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
  Future<QuerySnapshot> followingFuture;

  @override
  void initState() {
    super.initState();
    getFollowers();
  }

  getFollowers() async {
    Future<QuerySnapshot> userIds =
        followingRef.doc(widget.profileId).collection("userFollowing").get();
    setState(() {
      followingFuture = userIds;
    });
    print(followingFuture);
  }

//   buildFollowingList() {
//     return FutureBuilder(
//         future: followingFuture,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return circularProgress();
//           }
//           List<UserResult> followingResults = [];
//           snapshot.data.docs.forEach((doc) {
//             UserModel user = UserModel.fromDocument(doc);
//             UserResult followingResult = UserResult(user);
//             followingResults.add(followingResult);
//           });
//           return ListView(
//             children: followingResults,
//           );
//         });
//   }

//   // UserModel user = UserModel.fromDocument(snapshot.data);

//   buildNoContent() {
//     //final Orientation orientation = MediaQuery.of(context).orientation;
//     return Container(
//       child: Center(
//         child: ListView(
//           shrinkWrap: true,
//           children: <Widget>[Text("You are not following any users.")],
//         ),
//       ),
//     );
//   }
//   // Implement the build method that will choose either content or no content
//    @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      //backgroundColor: Theme.of(context).accentColor.withOpacity(0.5),
      appBar: AppBar(
        elevation: 15,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Users you are Following",
          style: TextStyle(fontFamily: 'CherryCreamSoda', fontSize: 25.0),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 10),
          // Container(
          //   height: MediaQuery.of(context).size.height,
          //   child: followingFuture == null
          //       ? buildNoContent()
          //       : buildFollowingList(),
          // ),
        ],
      ),
    );
  }
// }

// class UserResult extends StatelessWidget {
//   final UserModel user;

//   UserResult(this.user);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//         child: Column(
//           children: <Widget>[
//             Card(
//               elevation: 5.0,
//               child: Container(
//                 color: Colors.grey[300],
//                 child: GestureDetector(
//                   onTap: () => showProfile(context, profileId: user.id),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                         radius: 25.0,
//                         backgroundColor: Colors.white,
//                         backgroundImage:
//                             CachedNetworkImageProvider(user.photoUrl)),
//                     title: Text(
//                       user.displayName,
//                       style: TextStyle(
//                           color: Colors.black, fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(
//                       user.username,
//                       style: TextStyle(
//                         color: Colors.grey[700],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Divider(
//               height: 2.0,
//               color: Colors.white54,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}
