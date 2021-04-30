import 'dart:io';
import 'package:bingeable/services/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bingeable/pages/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adStateProvider = ScopedProvider<AdHelper>(null);

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv.load(fileName: ".env");
  await Firebase.initializeApp();
  final adsInitialization = MobileAds.instance.initialize();
  final adState = AdHelper(initialization: adsInitialization);
  runApp(ProviderScope(overrides: [
    adStateProvider.overrideWithValue(adState),
  ], child: MyApp()));
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
