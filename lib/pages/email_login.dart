import 'dart:async';

import 'package:WatchA/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:WatchA/widgets/header.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:WatchA/pages/home.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String email;
  String password;
  String username;
  String error;
  bool _showProgress = false;
  String uid;
  User loggedInUser;

  submit() async {
    final form = _formKey.currentState;

    setState(() {
      _showProgress = true;
    });

    if (form.validate()) {
      form.save();
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        if (user != null) {
          final User getUserId = _auth.currentUser;
          final uid = getUserId.uid;
          DocumentSnapshot doc = await usersRef.doc(uid).get();
          currentUser = UserModel.fromDocument(doc);
          setState(() {
            username = currentUser.username;
          });
          print(username);
          print(uid);

          SnackBar snackbar =
              SnackBar(content: Text("Welcome Back $username!"));
          _scaffoldKey.currentState.showSnackBar(snackbar);
          Timer(Duration(seconds: 2), () {
            Navigator.pop(context, username);
          });
        }
      } catch (e) {
        print(e);
        setState(() {
          error = e.message;
          _showProgress = false;
        });
      }
    }
  }

  Widget showAlert() {
    if (error != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: AutoSizeText(error, maxLines: 3),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      error = null;
                    });
                  }),
            ),
          ],
        ),
      );
    }
    return SizedBox(height: 0.0);
  }

  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: header(context, titleText: "Login", removeBackButton: false),
        body: ModalProgressHUD(
            inAsyncCall: _showProgress,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    showAlert(),
                    SizedBox(height: 20.0),
                    Text(
                      "Please Enter Your Email Address",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    TextFormField(
                      controller: _email,
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
                          return "Password too short";
                        } else if (val.trim().length > 50) {
                          return "Password too long";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => password = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 8 characters",
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
                            "Login",
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
