import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/models/json/experience_promotion_model.dart';
import 'package:gsc_app/models/json/splash_popup_model.dart';

import '../../models/json/cms_experience_model.dart';
import '../../models/json/cms_promotion_model.dart';
import '../dio_repo.dart';

class OthersApi extends DioRepo {
  OthersApi(BuildContext context) {
    dioContext = context;
  }

  Future<ExpNPromoResponse> getPromoNExp() async {
    mDio.options.headers['Accept'] = "application/json";
    mDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    mDio.options.baseUrl = Constants.ESERVICES_GSC;

    mDio.options.headers["Authorization"] =
        "${AppCache.tokenType} ${AppCache.accessToken}";
    try {
      Response response = await mDio.get(
        '/Promotions_Usps.json',
      );

      ExpNPromoResponse data = ExpNPromoResponse.fromJson(response.data);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CMS_PROMOTION>> getPromotion() async {
    mDio.options.headers['Accept'] = "application/json";
    mDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    mDio.options.baseUrl = Constants.ESERVICES_CMS;

    mDio.options.headers["Authorization"] =
        "${AppCache.tokenType} ${AppCache.accessToken}";
    try {
      Response response = await mDio.get(
        '/api/mobile/promotions/all',
      );

      List<CMS_PROMOTION> data = List<CMS_PROMOTION>.from(
          response.data.map((x) => CMS_PROMOTION.fromJson(x)));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CMS_EXPERIENCE>> getExperience() async {
    mDio.options.headers['Accept'] = "application/json";
    mDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    mDio.options.baseUrl = Constants.ESERVICES_CMS;

    mDio.options.headers["Authorization"] =
        "${AppCache.tokenType} ${AppCache.accessToken}";
    try {
      Response response = await mDio.get(
        '/api/mobile/experiences/all',
      );

      List<CMS_EXPERIENCE> data = List<CMS_EXPERIENCE>.from(
          response.data.map((x) => CMS_EXPERIENCE.fromJson(x)));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<SplashPopUpData> getSplashScreenPopUp() async {
    try {
      Response response = await mDio.get(
        '/gsc/epay/master/GetSplashImages',
      );

      Map<String, dynamic> jsonData = json.decode(response.data);

      SplashPopUpDTO data = SplashPopUpDTO.fromJson(jsonData);
      return data.response!;
    } catch (e) {
      rethrow;
    }
  }
}
