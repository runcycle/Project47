import 'dart:io';
import 'package:bingeable/pages/email_account.dart';
import 'package:bingeable/pages/email_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/activity_feed.dart';
import 'package:bingeable/pages/create_account.dart';
import 'package:bingeable/pages/profile.dart';
import 'package:bingeable/pages/search.dart';
import 'package:bingeable/pages/timeline.dart';
import 'package:bingeable/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection("users");
final postsRef = FirebaseFirestore.instance.collection("posts");
final commentsRef = FirebaseFirestore.instance.collection("comments");
final activityFeedRef = FirebaseFirestore.instance.collection("feed");
final followersRef = FirebaseFirestore.instance.collection("followers");
final followingRef = FirebaseFirestore.instance.collection("following");
final timelineRef = FirebaseFirestore.instance.collection("timeline");
final DateTime timestamp = DateTime.now();
UserModel currentUser;
bool googleLogin = false;
bool emailLogin = false;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
    emailLogin = false;
    googleLogin = false;
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
        googleLogin = true;
        emailLogin = false;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef.doc(user.id).update({"androidNotificationToken": token});
    });

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("on message: $message\n");
    //     final String recipientId = message["data"]["recipient"];
    //     final String body = message["notification"]["body"];
    //     if (recipientId == user.id) {
    //       print("Notification shown!");

    //       ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(body, overflow: TextOverflow.ellipsis))
    //       );
    //       // SnackBar snackbar =
    //       //     SnackBar(content: Text(body, overflow: TextOverflow.ellipsis));
    //       // _scaffoldKey.currentState.showSnackBar(snackbar);
    //     }
    //     print("Notification NOT shown");
    //   },
    // );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      //AndroidNotification android = message.notification?.android;

      print("on message: $message\n");
      final String recipientId = message.messageId;
      final String body = notification.body;
      if (recipientId == currentUser.id) {
        print("Notification shown!");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body, overflow: TextOverflow.ellipsis)));
        // SnackBar snackbar =
        //     SnackBar(content: Text(body, overflow: TextOverflow.ellipsis));
        // _scaffoldKey.currentState.showSnackBar(snackbar);
      }
      print("Notification NOT shown");
    });
  }

  // getiOSPermission() {
  //   _firebaseMessaging.requestNotificationPermissions(
  //       IosNotificationSettings(alert: true, badge: true, sound: true));
  //   _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
  //     print("Setting registered: $settings");
  //   });
  // }

  getiOSPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their ID)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();
    // 2) is user does'nt exist, we will take them to the create account page
    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateAccount()),
      );
      // 3) get username from create account, use it to create new user document in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
      });
      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .doc(user.id)
          .collection("userFollowers")
          .doc(user.id)
          .set({});

      doc = await usersRef.doc(user.id).get();
    }
    currentUser = UserModel.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButton: floatingAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.grey[300]),
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.new_releases)),
          BottomNavigationBarItem(icon: SizedBox(width: 0.0)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  floatingAction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 15),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Upload(currentUser: currentUser)));
            },
            child: Icon(Icons.post_add, color: Colors.white),
            backgroundColor: Colors.purple[400],
            tooltip: "Create Post",
            elevation: 4.0,
          ),
        ),
      ],
    );
  }

  emailRegister() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EmailAccount()));
    setState(() {
      isAuth = true;
      //emailLogin = true;
    });
  }

  loginWithEmail() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EmailLogin()));
    setState(() {
      isAuth = true;
      //emailLogin = true;
    });
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 100),
            Text(
              'Bingeable',
              style: TextStyle(
                fontFamily: "CherryCreamSoda",
                fontSize: 50.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 200.0),
            GestureDetector(
              onTap: emailRegister,
              child: Container(
                child: Center(
                    child: Text("Create a New Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ))),
                width: 200.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.indigo[400],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            GestureDetector(
              onTap: loginWithEmail,
              child: Container(
                child: Center(
                    child: Text("Login With Email Address",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ))),
                width: 200.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.indigo[400],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
              ),
            ),
            SizedBox(height: 25.0),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 200.0,
                height: 50.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
