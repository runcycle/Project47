import 'package:http/http.dart' as http;
import 'dart:convert';
//import "package:WatchA/api/networking.dart";
import 'package:WatchA/models/show.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Shows extends StatefulWidget {
  @override
  _ShowsState createState() => _ShowsState();
}

class _ShowsState extends State<Shows> {
  List<Shows> _shows = new List<Shows>();
  final apiKey = DotEnv().env['API_KEY'];
  final url = "http://www.omdbapi.com/";

  @override
  void initState() {
    super.initState();
    _populateShows();
  }

  void _populateShows() async {
    final shows = await _getShow();
    setState(() {
      _shows = shows;
    });
  }

  //show will come from upload.dart file

  Future<List<Show>> _getShow() async {
    final response = http.get("$url?t=$show&apiKey=$apiKey");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      Iterable list = result["Search"];
      return list.map((show) => Show.fromJson(show)).toList();
    } else {
      throw Exception("Failed to load request.")
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//http://www.omdbapi.com/?i=tt3896198&apikey=974478bf
//1 change
