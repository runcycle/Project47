class Show {
  final int id;
  final double popularity;
  final String title;
  final String poster;
  final String overview;
  final double rating;

  Show({
    this.id,
    this.popularity,
    this.title,
    this.poster,
    this.overview,
    this.rating,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json["id"],
      popularity: json["popularity"],
      title: json["title"],
      poster: json["poster_path"],
      overview: json["overview"],
      rating: json["rating"]
    );
  }
}
