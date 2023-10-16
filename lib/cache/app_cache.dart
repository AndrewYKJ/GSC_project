// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_listing.dart';
import 'package:gsc_app/models/json/splash_popup_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const/remove_device_helper.dart';
import '../models/arguments/appcache_object_model.dart';
import '../models/json/booking_model.dart';
import '../models/json/experience_promotion_model.dart';
import '../models/json/nearby_location_model.dart';
import '../models/json/user_model.dart';

class AppCache {
  static const String ACCESS_TOKEN_PREF = "ACCESS_TOEKN_PREF"; //Member ID
  static const String ACCESS_LOCATION = "ACCESS_LOCATION";
  static const String AS_API_ACCESS_TOKEN_PREF = "AS_API_ACCESS_TOKEN_PREF";

  static const String SPLASH_SCREEN_REF = "SPLASH_SCREEN_REF";
  static const String MEMBER_QR_EXPIRY = "MEMBER_QR_EXPIRY";
  static const String DEVICE_INFO = 'DEVICE_INFO';
  static List<SwaggerLocation>? allLocationList;
  static List<SplashImage>? splashImages;
  static MovieListing? movieListing;
  static MovieEpaymentDTO? movieEpaymentList;
  static List<BookingModel>? tickets;
  static String? accessToken;
  static String? tokenType;
  static Map<String, dynamic>? payload;
  // static ExpNPromoResponse? expNpromoList;
  static CMSExpNPromoResponse? expNpromoList;
  static bool reSetCacheModel = false;
  static bool isLocationCalled = false;
  static bool showPopUp = true;
  static AppCacheObjectModel? cacheData;
  static UserModel? me;
  static String? fcmToken;
  static String? qrCode;

  static Future<void> setInteger(String key, int value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(key, value);
  }

  static Future<int> getIntegerValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt(key) ?? 0;
  }

  static Future<void> setDouble(String key, double value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble(key, value);
  }

  static Future<double> getDoubleValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getDouble(key) ?? 0.0;
  }

  static Future<void> setBoolean(String key, bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  static Future<bool?> getbooleanValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }

  static Future<void> setString(String key, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
  }

  static Future<String> getStringValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String data = pref.getString(key) ?? "";
    return data;
  }

  static void setAuthToken(String accessToken, String refreshToken) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(ACCESS_TOKEN_PREF, accessToken);
  }

  static void removeValues(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    RemoveDevicesHelper.getRemoveDeviceInfo(context);
    prefs.remove(ACCESS_TOKEN_PREF);
    prefs.remove(AS_API_ACCESS_TOKEN_PREF);
    prefs.remove(MEMBER_QR_EXPIRY);
    prefs.remove(SPLASH_SCREEN_REF);
    tickets = null;
    me = null;
  }

  static Future<bool> containValue(String key) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool checkValue = _prefs.containsKey(key);
    return checkValue;
  }

  static Future<bool> setStringList(String key, List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, list);
  }

  static Future<List<String>?> getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }
}
