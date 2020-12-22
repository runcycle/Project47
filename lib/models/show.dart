class Show {
  final String imdbId;
  final String title;
  final String poster;
  final String year;
  // final String overview;
  // final double rating;

  Show({
    this.imdbId,
    this.title,
    this.poster,
    this.year,
    // this.overview,
    // this.rating,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      imdbId: json["imdbId"],
      poster: json["Poster"],
      title: json["Title"],
      year: json["Year"]
    );
  }
}
