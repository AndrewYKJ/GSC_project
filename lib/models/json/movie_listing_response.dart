// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/movie_listing_body.dart';
import 'package:gsc_app/models/json/movie_listing_header.dart';

class MovieListingResponse {
  MovieListingHeader? Header;
  MovieListingBody? Body;

  MovieListingResponse({this.Header});

  MovieListingResponse.fromJson(Map<String, dynamic> json) {
    Header = MovieListingHeader.fromJson(json['Header']);
    Body = MovieListingBody.fromJson(json['Body']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Header'] = Header;
    data['Body'] = Body;

    return data;
  }
}
