import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/constants.dart';

import '../cache/app_cache.dart';
import '../controllers/splash_screen.dart';
import '../widgets/custom_dialog.dart';
import 'interceptor/logging.dart';

class AsDioRepo {
  late Dio asDio;
  int retryCount = 0;
  late BuildContext dioContext;

  Map<String, dynamic> baseParam(String command) {
    return {
      "Command": command,
      "EnquiryCode": Constants.ASCENTIS_CRM_ENQUIRY_CODE,
      "OutletCode": Constants.ASCENTIS_CRM_OUTLET_CODE,
      "PosID": Constants.ASCENTIS_CRM_POST_ID,
      "CashierID": Constants.ASCENTIS_CRM_CASHIER_ID,
      "IgnoreCCNchecking": Constants.ASCENTIS_CRM_IGNORE_CNN_CHECKING,
    };
  }

  Dio asBaseConfig() {
    Dio dio = Dio();
    dio.options.baseUrl = Constants.ASCENTIS_CRM_INSTANCE_URL;
    dio.options.connectTimeout = const Duration(milliseconds: 30000);
    dio.options.receiveTimeout = const Duration(milliseconds: 30000);
    dio.httpClientAdapter;

    return dio;
  }

  Dio asTokenBaseConfig() {
    Dio dio = Dio();
    dio.options.baseUrl = Constants.ASCENTIS_CRM_TOKEN_URL;
    dio.options.connectTimeout = const Duration(milliseconds: 30000);
    dio.options.receiveTimeout = const Duration(milliseconds: 30000);
    dio.httpClientAdapter;

    return dio;
  }

  AsDioRepo() {
    asDio = asBaseConfig();
    asDio.interceptors.addAll([
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          AppCache.getStringValue(AppCache.AS_API_ACCESS_TOKEN_PREF)
              .then((value) {
            if (value.isNotEmpty) {
              options.headers[HttpHeaders.authorizationHeader] =
                  'Bearer ' + value;
              options.headers['SoapAction'] = Constants.ASCENTIS_SOAP_ACTION;
            }
          });

          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            if (retryCount < 3) {
              return refreshTokenAndRetry(e.response!.requestOptions, handler);
            }
            showAlertDialog('System Error',
                'Opps, unexpected error has occured. Please try again later');
            return handler.next(e);
          }

          return handler.next(e);
        },
        onResponse: (response, handler) async {
          return handler.next(response);
        },
      ),
      LoggingInterceptors()
    ]);
  }

  Future<void> refreshTokenAndRetry(
      RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    bool isError = false;
    Dio tokenDio = asTokenBaseConfig();
    var param =
        "grant_type=${Constants.ASCENTIS_CRM_GRANT_TYPE}&scope=${Constants.ASCENTIS_CRM_SCOPE}&client_id=${Constants.ASCENTIS_CRM_CLIENT_ID}&client_secret=${Constants.ASCENTIS_CRM_CLIENT_SECRET}";
    tokenDio.options.headers['Accept'] = "application/json";
    tokenDio.options.headers['content-Type'] =
        'application/x-www-form-urlencoded';

    tokenDio.interceptors.add(LoggingInterceptors());
    try {
      tokenDio.post('', data: param).then((res) {
        if (res.statusCode == 200) {
          AppCache.setString(
              AppCache.AS_API_ACCESS_TOKEN_PREF, res.data['access_token']);
        } else {
          isError = true;
          EasyLoading.dismiss();

          AppCache.removeValues(dioContext);
          Navigator.pushAndRemoveUntil(
              dioContext,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (Route<dynamic> route) => false);
        }
      }).catchError((error) {
        isError = true;
        if (error is DioError) {
          if (error.response != null) {
            if (error.response!.data != null) {
              EasyLoading.dismiss();
              showAlertDialog(error.response!.data['code'],
                  error.response!.data['message']);
            } else {
              EasyLoading.dismiss();
              showAlertDialog('System Error',
                  'Opps, unexpected error has occured. Please try again later');
            }
          } else {
            AppCache.removeValues(dioContext);
            EasyLoading.dismiss();
            Navigator.pushAndRemoveUntil(
                dioContext,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (Route<dynamic> route) => false);
          }
        } else {
          AppCache.removeValues(dioContext);
          EasyLoading.dismiss();
          Navigator.pushAndRemoveUntil(
              dioContext,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (Route<dynamic> route) => false);
        }
      }).whenComplete(() async {
        final originResult = await asDio.fetch(requestOptions..path);

        if (originResult.statusCode != null &&
            originResult.statusCode! ~/ 100 == 2) {
          return handler.resolve(originResult);
        }
      }).then((e) {
        //repeat
        if (!isError) {
          retryCount++;
          asDio.fetch(requestOptions).then(
            (r) => handler.resolve(r),
            onError: (e) {
              handler.reject(e);
            },
          );
        }
      });
      // return;
    } on DioError {
      showAlertDialog("Error", "An error occurred");
    }
  }

  void showAlertDialog(String title, String message) {
    showDialog(
        context: dioContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: title,
            message: message,
            img: "attention-icon.png",
            showButton: true,
            showConfirm: true,
            showCancel: false,
            confirmStr: "Close",
            onConfirm: () {
              AppCache.removeValues(context);
              Navigator.pushAndRemoveUntil(
                  dioContext,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (Route<dynamic> route) => false);
            },
          );
        });
  }
}
