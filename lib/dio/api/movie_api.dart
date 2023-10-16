import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/dio/dio_repo.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_listing.dart';
import 'package:gsc_app/models/json/movie_listing_details.dart';
import 'package:gsc_app/models/json/movie_model.dart';
import 'package:xml2json/xml2json.dart';

import '../../models/json/movie_showtimes.dart';

class MovieApi extends DioRepo {
  MovieApi(BuildContext context) {
    dioContext = context;
  }

  final myTransformer = Xml2Json();

  Future<MovieModel> getAllMovies() async {
    mDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    final body = {'includeChild': 'true', 'parent': ''};

    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getEpaymentMovie_ParentChild",
        queryParameters: body,
      );

      myTransformer.parse(response.data);

      var data = myTransformer.toGData();

      var jsonData = json.decode(data);

      return MovieModel.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }

  Future<MovieEpaymentDTO> getMovie() async {
    var params = {'includeChild': true, 'parent': ''};

    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getEpaymentMovie_ParentChild",
        queryParameters: params,
      );

      if (response.data != null) {
        myTransformer.parse(response.data);
        var jsonString = myTransformer.toGData();
        var jsonData = json.decode(jsonString);
        MovieEpaymentDTO data = MovieEpaymentDTO.fromJson(jsonData);

        return data;
      }
      return MovieEpaymentDTO();
    } catch (e) {
      rethrow;
    }
  }

  //from swagger
  Future<MovieListing> getMovieListing(String operationDate) async {
    try {
      var params = {'oprndate': operationDate};
      Response response =
          await mDio.get('/gsc/epay/GetMovieList', queryParameters: params);

      Map<String, dynamic> jsonData = json.decode(response.data);

      return MovieListing.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }

  Future<MovieDetails> getMovieDetails(String parentCode) async {
    try {
      var params = {'parentCode': parentCode};

      Response response = await mDio.get(
          '/gsc/epay/GetMovieDetailsByParentCode',
          queryParameters: params);
      Map<String, dynamic> jsonData = json.decode(response.data);

      return MovieDetails.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }

  Future<MovieEpaymentDTO> getAllAurumMovie() async {
    var params = {'includeChild': true, 'parent': ''};
    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getEpaymentMovie_ParentChildAurum",
        queryParameters: params,
      );

      if (response.data != null) {
        myTransformer.parse(response.data);
        var jsonString = myTransformer.toGData();
        var jsonData = json.decode(jsonString);
        MovieEpaymentDTO data = MovieEpaymentDTO.fromJson(jsonData);
        return data;
      }
      return MovieEpaymentDTO();
    } catch (e) {
      rethrow;
    }
  }

  Future<MovieShowtimesDTO> getAurumShowtimesByOpsdate(
      String opsdate, String parentId) async {
    var params = {'oprndate': opsdate, 'parentid': parentId};
    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getShowTimesByMovie_ParentChildAurum",
        queryParameters: params,
      );
      if (response.data != null) {
        myTransformer.parse(response.data);

        var data = myTransformer.toGData();

        var jsonData = json.decode(data);

        return MovieShowtimesDTO.fromJson(jsonData);
      }
      return MovieShowtimesDTO();
    } catch (e) {
      rethrow;
    }
  }
}
