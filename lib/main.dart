import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bingeable/pages/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

Future main() async {
  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //MobileAds.instance.initialize();
  runApp(MyApp());
}

String getAppId() {
  if (Platform.isIOS) {
    return '';
  } else if (Platform.isAndroid) {
    return "ca-app-pub-6574097995292239~6589840728";
  }
  return null;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bingeable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFab47bc),
        accentColor: Color(0xFF42a5f5),
      ),
      home: Home(),
      // initialRoute: "/",
      // routes: {
      //   "/": (context) => Home(),
      //   "/timeline": (context) => Timeline(),
      // }
    );
  }
}
