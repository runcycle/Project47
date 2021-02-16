class Show {
  final int id;
  final String title;
  final String poster;
  final String overview;
  final String date;
  final String name;

  Show({
    this.id,
    this.title,
    this.poster,
    this.overview,
    this.date,
    this.name,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json["id"],
      title: json["title"],
      poster: json["poster_path"],
      overview: json["overview"],
      date: json["release_date"],
      name: json["name"],
    );
  }
}
