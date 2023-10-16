import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';

import '../cache/app_cache.dart';
import '../models/json/as_update_device_model.dart';

class RemoveDevicesHelper {
  static Future<UpdateDeviceDTO> getRemoveDeviceInfo(
    BuildContext context,
  ) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      return AppCache.getStringValue(AppCache.DEVICE_INFO).then((value) {
        var dataMap = json.decode(value);

        var appVersion = dataMap["appVersion"];
        var deviceUUID = dataMap["deviceUUID"];
        var deviceModel = dataMap["deviceModel"];

        return asAuthApi.removeDeviceToken(
            AppCache.me?.MemberLists?.first.MemberID ?? '',
            appVersion,
            deviceUUID,
            AppCache.fcmToken!,
            deviceModel);
      });
    }
    return UpdateDeviceDTO();
  }
}
