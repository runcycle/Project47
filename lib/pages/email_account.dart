import 'dart:async';
//import 'package:WatchA/widgets/progress.dart';
import 'dart:io';

import 'package:WatchA/models/user.dart';
//import 'package:WatchA/pages/activity_feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:WatchA/widgets/header.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:WatchA/pages/home.dart';

class EmailAccount extends StatefulWidget {
  @override
  _EmailAccountState createState() => _EmailAccountState();
}

class _EmailAccountState extends State<EmailAccount> {
  final _auth = FirebaseAuth.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  //PageController pageController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  String displayName;
  String email;
  String username;
  String password;
  String confirmPassword;
  bool _showProgress = false;
  String uid;
  User user;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  getUserId() {
    user = _auth.currentUser;
    uid = user.uid;
  }

  submit() async {
    final form = _formKey.currentState;
    DocumentSnapshot doc = await usersRef.doc(uid).get();

    setState(() {
      _showProgress = true;
    });

    if (form.validate()) {
      form.save();
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } catch (e) {
        print(e);
      }
      usersRef.doc(uid).set({
        "id": uid,
        "username": username,
        "photoUrl": "",
        "email": email,
        "displayName": displayName,
        "bio": "",
        "timestamp": timestamp,
      });
      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .doc(uid)
          .collection("userFollowers")
          .doc(uid)
          .set({});

      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
    //doc = await usersRef.document(uid).get();
    currentUser = UserModel.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
    configurePushNotifications();
  }

  configurePushNotifications() async {
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef.doc(uid).update({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message["data"]["recipient"];
        final String body = message["notification"]["body"];
        if (recipientId == uid) {
          print("Notification shown!");
          SnackBar snackbar =
              SnackBar(content: Text(body, overflow: TextOverflow.ellipsis));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Setting registered: $settings");
    });
  }

  void dispose() {
    _displayName.dispose();
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: header(context,
            titleText: "Create Your Account", removeBackButton: false),
        body: ModalProgressHUD(
            inAsyncCall: _showProgress,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Text(
                      "Please Enter Your Full Name",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    TextFormField(
                      controller: _displayName,
                      validator: (val) {
                        if (val.trim().length < 3 || val.isEmpty) {
                          return "Username too short";
                        } else if (val.trim().length > 50) {
                          return "Username too long";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => displayName = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Full Name",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 3 characters",
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Please Enter Your Email Address",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val.trim().length < 3 || val.isEmpty) {
                          return "Email address too short";
                        } else if (val.trim().length > 50) {
                          return "Email address too long";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => email = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email Address",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 3 characters",
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Please Enter A Username",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    TextFormField(
                      controller: _username,
                      validator: (val) {
                        if (val.trim().length < 3 || val.isEmpty) {
                          return "Username too short";
                        } else if (val.trim().length > 50) {
                          return "Username too long";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => username = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Username",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 3 characters",
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Please Enter A Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      validator: (val) {
                        if (val.trim().length < 6 || val.isEmpty) {
                          return "Password Too short";
                        } else if (val.trim().length > 50) {
                          return "Password Too Long";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => password = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 3 characters",
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Please Confirm Your Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    TextFormField(
                      controller: _confirmPass,
                      obscureText: true,
                      validator: (val) {
                        if (val != _password.text) {
                          return "Passwords Do Not Match";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => confirmPassword = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password Confirmation",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 3 characters",
                      ),
                    ),
                    SizedBox(height: 25.0),
                    GestureDetector(
                      onTap: submit,
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Text(
                            "Submit",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ]),
            )));
  }
}
