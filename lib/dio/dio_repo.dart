import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/constants.dart';

import 'interceptor/logging.dart';

class DioRepo {
  late Dio mDio;
  int retryCount = 0;
  late BuildContext dioContext;

  Dio baseConfig() {
    Dio dio = Dio();
    dio.options.baseUrl = Constants.ESERVICES_STG;
    dio.options.connectTimeout = const Duration(milliseconds: 30000);
    dio.options.receiveTimeout = const Duration(milliseconds: 30000);
    dio.httpClientAdapter;

    return dio;
  }

  DioRepo() {
    mDio = baseConfig();
    mDio.interceptors.addAll([LoggingInterceptors()]);
  }
}
