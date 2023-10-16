import 'movie_parent.dart';

class MovieModel {
  MovieParent? films;

  MovieModel({this.films});

  MovieModel.fromJson(Map<String, dynamic> json) {
    films = MovieParent.fromJson(json['films']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['films'] = films;

    return data;
  }
}
