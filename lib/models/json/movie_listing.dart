// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/movie_listing_response.dart';

class MovieListing {
  MovieListingResponse? Response;

  MovieListing({this.Response});

  MovieListing.fromJson(Map<String, dynamic> json) {
    Response = MovieListingResponse.fromJson(json['Response']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Response'] = Response;

    return data;
  }
}
