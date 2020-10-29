import 'dart:async';
import 'package:WatchA/widgets/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:WatchA/widgets/header.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EmailAccount extends StatefulWidget {
  @override
  _EmailAccountState createState() => _EmailAccountState();
}

class _EmailAccountState extends State<EmailAccount> {
  // final _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  String email;
  String username;
  String password;
  String confirmPassword;
  bool _showProgress = false;

  showCircularProgress() {
    if (_showProgress == true) {
      return circularProgress();
    }
  }

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
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
            autovalidate: true,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 20.0
                ),
                Text("Please Enter Your Email Address", 
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
                Text("Please Enter A Username", 
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
                Text("Please Enter A Password", 
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  validator: (val) {
                    if (val.trim().length < 3 || val.isEmpty) {
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
                Text("Please Confirm Your Password", 
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
                      borderRadius: BorderRadius.circular(20.0),
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
            ]
          ),
        )   
      )
    );
  }
}

// Form(
//                   key: _formKey,
//                   autovalidate: true,
//                   child: TextFormField(
//                     validator: (val) {
//                       if (val.trim().length < 3 || val.isEmpty) {
//                         return "Email address too short";
//                       } else if (val.trim().length > 50) {
//                         return "Email address too long";
//                       } else {
//                         return null;
//                       }
//                     },
//                     onSaved: (val) => email = val,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: "Email Address",
//                       labelStyle: TextStyle(fontSize: 15.0),
//                       hintText: "Must be at least 3 characters",
//                     ),
//                   ),
//                 ),