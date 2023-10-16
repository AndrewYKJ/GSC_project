import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/dio/dio_repo.dart';
import 'package:gsc_app/models/json/nearby_location_model.dart';
import 'package:xml2json/xml2json.dart';

import '../../models/json/movie_showtimes.dart';
import '../../models/json/showtimes_by_cinema_model.dart';

class CinemaApi extends DioRepo {
  CinemaApi(BuildContext context) {
    dioContext = context;
  }

  final myTransformer = Xml2Json();

  Future<CinemaDTO> getCinemaList() async {
    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getEpaymentLocations",
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.data != null) {
        myTransformer.parse(response.data);
        var jsonString = myTransformer.toGData();
        var jsonData = json.decode(jsonString);

        if (jsonData['error'] != null) {
          return CinemaDTO.fromJson(jsonData['error']);
        }
        CinemaDTO data = CinemaDTO.fromJson(jsonData);

        return data;
      }
      return CinemaDTO();
    } catch (e) {
      rethrow;
    }
  }

  Future<ShowtimesByCinemaDTO> getShowtimesByLocation(
      String opsdate, String locId, String? hallGroup) async {
    var params = {
      'oprndate': opsdate,
      'locationid': locId,
      'hallGroup': hallGroup ?? ""
    };

    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getShowTimesByLocation_ParentChild_V2",
        queryParameters: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.data != null) {
        myTransformer.parse(response.data);

        var data = myTransformer.toGData();

        var jsonData = json.decode(data);

        if (jsonData['error'] != null) {
          return ShowtimesByCinemaDTO.fromJson(jsonData['error']);
        }
        return ShowtimesByCinemaDTO.fromJson(jsonData);
      }
      return ShowtimesByCinemaDTO();
    } catch (e) {
      rethrow;
    }
  }

  //from swagger

  Future<NearbyLocationBody> getNearbyLocation(
      String? long, String? lat) async {
    try {
      var longitude = {'longitude': long};
      var latitude = {'latitude': lat};
      Map<String, dynamic> params = {};
      params.addAll(longitude);
      if (long != null && lat != null) {
        params.addAll(longitude);
        params.addAll(latitude);
      }
      Response response = await mDio.get('/gsc/epay/GetEpaymentLocations',
          queryParameters: params);

      NearbyLocationDTO jsonData = NearbyLocationDTO.fromRawJson(response.data);
      // Utils.printWrapped(jsonData.response.toString());
      return jsonData.response!.body!;
    } catch (e) {
      rethrow;
    }
  }
}
