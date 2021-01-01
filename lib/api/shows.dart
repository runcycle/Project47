// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/material.dart';
// //import "package:WatchA/api/networking.dart";
// import 'package:WatchA/models/show.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class Shows extends StatefulWidget {
//   @override
//   _ShowsState createState() => _ShowsState();
// }

// class _ShowsState extends State<Shows> {
//   List<Shows> _shows = new List<Shows>();
//   final apiKey = DotEnv().env['API_KEY'];
//   final url = "http://www.omdbapi.com/";

//   @override
//   void initState() {
//     super.initState();
//     _populateShows();
//   }

//   void _populateShows(show) async {
//     final shows = await _getShow(show);
//     setState(() {
//       _shows = shows;
//     });
//   }

//   //show will come from upload.dart file

//   Future<List<Show>> _getShow(show) async {
//     //final response = http.get("$url?t=$show&apiKey=$apiKey");

//     final response = await http.get("http://www.omdbapi.com/?t=$show&apikey=974478bf");

//     if (response.statusCode == 200) {
//       final result = jsonDecode(response.body);
//       Iterable list = result["Search"];
//       return list.map((show) => Show.fromJson(show)).toList();
//     } else {
//       throw Exception("Failed to load request.")
//     }
    
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// API Key (v3 auth)
// 5362b48d513a9b5e2951344ceaa0c40a
// https://api.themoviedb.org/3/movie/550?api_key=5362b48d513a9b5e2951344ceaa0c40a
// API Read Access Token (v4 auth)
// eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1MzYyYjQ4ZDUxM2E5YjVlMjk1MTM0NGNlYWEwYzQwYSIsInN1YiI6IjVmZDI3ZThhNmM4NGQ2MDAzZjM1ZGYwNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.ETyZbthZqmNGupiEBnuwj97ESQT8cs5uzq9B3Qpg3Hg