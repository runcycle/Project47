import "package:WatchA/api/networking.dart";

const apiKey = "974478bf";
const omdbUrl = "http://www.omdbapi.com/";

class ShowModel {
  Future<dynamic> getShowName(String, showName) async {
    NetworkHelper networkHelper =
        NetworkHelper("$omdbUrl?t=$showName&apiKey=$apiKey");
    var showData = await networkHelper.getData();
    return showData;
  }
}

//http://www.omdbapi.com/?i=tt3896198&apikey=974478bf
//1 change

