import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gsc_app/models/json/aurum_ecombo.dart';
import 'package:flutter/material.dart';
import 'package:xml2json/xml2json.dart';

import '../dio_repo.dart';

class EComboApi extends DioRepo {
  EComboApi(BuildContext context) {
    dioContext = context;
  }

  final myTransformer = Xml2Json();

  Future<AurumEcomboMain> getAurumEcombo(dynamic body) async {
    try {
      var resBody = json.encode(body);
      Response response = await mDio.post(
        "/ConcessionWs/service.asmx/doGetBundleDetail",
        data: resBody,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.data != null) {
        return AurumEcomboMain.fromJson(json.decode(response.data));
      }
      return AurumEcomboMain();
    } catch (e) {
      rethrow;
    }
  }
}
