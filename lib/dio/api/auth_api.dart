import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/constants.dart';

import '../dio_repo.dart';

class AuthApi extends DioRepo {
  AuthApi(BuildContext context) {
    dioContext = context;
  }

  Future generateToken() async {
    var body = {
      'grant_type': Constants.cms_grant_type,
      'client_id': Constants.cms_cliend_id,
      'client_secret': Constants.cms_cliend_sercet,
      'username': Constants.cms_username
    };
    mDio.options.headers['Accept'] = "application/json";
    mDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    mDio.options.baseUrl = Constants.ESERVICES_CMS;
    try {
      Response response = await mDio.post(
        '/oauth/token',
        data: body,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future generateASApiToken() async {
    var body =
        "grant_type=${Constants.ASCENTIS_CRM_GRANT_TYPE}&scope=${Constants.ASCENTIS_CRM_SCOPE}&client_id=${Constants.ASCENTIS_CRM_CLIENT_ID}&client_secret=${Constants.ASCENTIS_CRM_CLIENT_SECRET}";
    mDio.options.headers['Accept'] = "application/json";
    mDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    mDio.options.baseUrl = Constants.ASCENTIS_CRM_TOKEN_URL;
    try {
      Response response = await mDio.post(
        '',
        data: body,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Future login() async {
  //   var body = "grant_type=${Constants.ASCENTIS_CRM_GRANT_TYPE}&scope=${Constants.ASCENTIS_CRM_SCOPE}&client_id=${Constants.ASCENTIS_CRM_CLIENT_ID}&client_secret=${Constants.ASCENTIS_CRM_CLIENT_SECRET}";
  //   mDio.options.headers['Accept'] = "application/json";
  //   mDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
  //   mDio.options.baseUrl = Constants.ASCENTIS_CRM_TOKEN_URL;
  //   try {
  //     Response response = await mDio.post('',
  //       data: body,
  //     );
  //     return response.data;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

}
