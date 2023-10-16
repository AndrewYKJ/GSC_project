import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/dio_repo.dart';
import 'package:gsc_app/models/json/movie_seat_selection_model.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:gsc_app/models/json/ticket_item_wrapper.dart';
import 'package:xml2json/xml2json.dart';

class MovieShowtimes extends DioRepo {
  MovieShowtimes(BuildContext context) {
    dioContext = context;
  }

  final myTransformer = Xml2Json();

  Future<MovieShowtimesDTO> getShowtimesByOpsdate(
      String opsdate, String parentId) async {
    var params = {'oprndate': opsdate, 'parentid': parentId};

    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getShowTimesByMovie_ParentChild_V2",
        queryParameters: params,
      );

      if (response.data != null) {
        myTransformer.parse(response.data);

        var data = myTransformer.toGData();

        var jsonData = json.decode(data);

        if (jsonData['error'] != null) {
          return MovieShowtimesDTO.fromJson(jsonData['error']);
        }
        return MovieShowtimesDTO.fromJson(jsonData);
      }
      return MovieShowtimesDTO();
    } catch (e) {
      rethrow;
    }
  }

  Future<SeatSelectionDTO> getHallSeating(String locationid, String hallid,
      String showdate, String showtime) async {
    var params = {
      'locationid': locationid,
      'hallid': hallid,
      'showdate': showdate,
      'showtime': showtime,
    };
    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getHallSeatStatus",
        queryParameters: params,
      );
      if (response.data != null) {
        myTransformer.parse(response.data);

        var data = myTransformer.toGData();

        var jsonData = json.decode(data);
        if (jsonData['error'] != null) {
          return SeatSelectionDTO.fromJson(jsonData['error']);
        }
        return SeatSelectionDTO.fromJson(jsonData);
      }
      return SeatSelectionDTO();
    } catch (e) {
      rethrow;
    }
  }

  Future<TicketWrapper> getTicketComboDetailsByShowtime(String locationId,
      String hallId, String filmId, String showdate, String showtime) async {
    var params = {
      'locationid': locationId,
      'hallid': hallId,
      'filmid': filmId,
      'showdate': showdate,
      'showtime': showtime
    };
    try {
      Response response = await mDio.get(
        "/showtimews/service.asmx/getTicketPricingEpaySpecialV4",
        queryParameters: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      Utils.printInfo(response.data.toString());
      if (response.data != null) {
        myTransformer.parse(response.data);

        var data = myTransformer.toGData();

        var jsonData = json.decode(data);

        if (jsonData['error'] != null) {
          return TicketWrapper.fromJson(jsonData['error']);
        }
        return TicketWrapper.fromJson(jsonData['price']);
      }
      return TicketWrapper();
    } catch (e) {
      rethrow;
    }
  }
}
