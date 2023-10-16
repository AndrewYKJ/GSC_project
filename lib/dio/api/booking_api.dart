import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/models/json/booking_model.dart';
import 'package:xml2json/xml2json.dart';

import '../../const/utils.dart';
import '../dio_repo.dart';

class BookingApi extends DioRepo {
  BookingApi(BuildContext context) {
    dioContext = context;
  }

  final myTransformer = Xml2Json();

  Future<BookingWrapper> getTickets(String curdt, String mbrid, String emailid,
      String phoneno, String token) async {
    var params = {
      'curdt': curdt,
      'mbrid': mbrid,
      'emailid': emailid,
      'phoneno': phoneno,
      'token': token
    };

    try {
      Response response = await mDio.post(
        "/EasiMemberInboxWs/EasiMemberInboxWs.asmx/doGetTrxnStatus_v4",
        data: params,
        options: Options(
          receiveTimeout: const Duration(milliseconds: 60000),
          sendTimeout: const Duration(milliseconds: 60000),
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      Utils.printInfo(response.data.toString());
      if (response.data != null) {
        myTransformer.parse(response.data);

        var data = myTransformer.toGData();

        var jsonData = json.decode(data);

        if (jsonData['error'] != null) {
          return BookingWrapper.fromJson(jsonData['error']);
        }
        return BookingWrapper.fromJson(jsonData['bookings']);
      }
      return BookingWrapper();
    } catch (e) {
      rethrow;
    }
  }
}
