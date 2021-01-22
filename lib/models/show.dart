class Show {
  final int id;
  final double popularity;
  final String title;
  final String poster;
  final String overview;
  final String date;
  final String name;

  Show({
    this.id,
    this.popularity,
    this.title,
    this.poster,
    this.overview,
    this.date,
    this.name,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json["id"],
      popularity: json["popularity"],
      title: json["title"],
      poster: json["poster_path"],
      overview: json["overview"],
      date: json["release_date"],
      name: json["name"],
    );
  }
}
