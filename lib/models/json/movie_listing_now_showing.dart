// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/movie_listing_details.dart';

class MovieListingNowShowing {
  List<MovieListingDetails>? NowShowing;

  MovieListingNowShowing({this.NowShowing});

  MovieListingNowShowing.fromJson(Map<String, dynamic> json) {
    var list = json['NowShowing'] as List;

    if (list.isNotEmpty) {
      NowShowing = list.map((e) => MovieListingDetails.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    // ignore: prefer_collection_literals
    Map<String, dynamic> data = Map<String, dynamic>();

    data['NowShowing'] = NowShowing;

    return data;
  }
}
