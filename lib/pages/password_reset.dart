import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PasswordReset extends StatefulWidget {
  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();

  String email;
  String error;
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
  }

  submit() async {
    final form = _formKey.currentState;

    setState(() {
      _showProgress = true;
    });

    if (form.validate()) {
      form.save();
      try {
        await _auth.sendPasswordResetEmail(email: email);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("A password reset email has been sent to $email.")));
        Timer(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        //print(e);
        setState(() {
          error = e.message;
          _showProgress = false;
        });
      }
    }
  }

  // void setPrefs(bool newValue) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     rememberMe = newValue;
  //     if (rememberMe = true) {
  //       prefs.setString("rememberedEmail", _email.text);
  //     }
  //   });
  // }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 15,
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Password Reset',
                style:
                    TextStyle(fontFamily: 'CherryCreamSoda', fontSize: 25.0)),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: ModalProgressHUD(
            inAsyncCall: _showProgress,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  children: <Widget>[
                    //SizedBox(height: 5.0),
                    showAlert(),
                    SizedBox(height: 10.0),
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
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: submit,
                      child: Container(
                        height: 50.0,
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
