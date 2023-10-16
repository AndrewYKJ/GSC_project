// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/auth_api.dart';
import 'package:gsc_app/dio/api/movie_api.dart';
import 'package:gsc_app/dio/api/others_api.dart';
import 'package:gsc_app/main.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/splash_popup_model.dart';
import 'package:gsc_app/widgets/push_notification_handler.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import '../cache/app_cache.dart';
import '../const/analytics_constant.dart';
import '../const/app_font.dart';
import '../const/constants.dart';
import '../dio/api/as_auth_api.dart';
import '../models/arguments/appcache_object_model.dart';
import '../models/json/as_update_device_model.dart';
import '../models/json/cms_experience_model.dart';
import '../models/json/cms_promotion_model.dart';
import '../models/json/experience_promotion_model.dart';
import '../models/json/movie_listing.dart';
import '../models/json/user_model.dart';
import '../routes/approutes.dart';
import '../widgets/custom_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> with WidgetsBindingObserver {
  SplashPopUpData? splashData;
  SplashImage? splashIcon;

  bool splashExist = false;
  bool isNextDay = true;
  List<SplashImage>? popUpImages;
  Map<dynamic, dynamic> huaweiRemoteConfig = <dynamic, dynamic>{};
  FirebaseRemoteConfig? _remoteConfig;
  final MethodChannel _channel =
      const MethodChannel(Constants.BRIDGE_CHANNEL_NAME);

  @override
  void initState() {
    PushNotificationHandler.getToken();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SPLASH_SCREEN);
    if (Constants.IS_HUAWEI) {
      initHuaweiConfig();
    } else {
      _initConfig();
    }
    getPopUpData();
    _checkLastLoggedDay();
    _checkLoginState();
  }

  Future<UpdateDeviceDTO> updateDevice(
      BuildContext context,
      String member,
      String fcmToken,
      String appVersion,
      String deviceUUID,
      String deviceName,
      String deviceModel,
      String deviceVersion) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.updateMemberDevice(member, appVersion, deviceUUID,
        fcmToken, deviceName, deviceModel, deviceVersion);
  }

  Future<void> _initConfig() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    await _remoteConfig?.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 1),
      minimumFetchInterval: const Duration(seconds: 30),
    ));
    if (_remoteConfig != null) {
      _fetchConfig(_remoteConfig!);
    }
  }

  void _fetchConfig(FirebaseRemoteConfig config) async {
    await config.fetchAndActivate();
  }

  Future<Map> getHuaweiConfigMap() async {
    return await _channel.invokeMethod('getVersion');
  }

  void initHuaweiConfig() async {
    Map value = await getHuaweiConfigMap();
    setState(() {
      huaweiRemoteConfig = value;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<MovieEpaymentDTO> getEpaymentMovie(BuildContext context) async {
    MovieApi itm = MovieApi(context);
    return itm.getMovie();
  }

  Future<MovieListing> getMovieListings(
      BuildContext context, String operationDate) async {
    MovieApi itm = MovieApi(context);
    return itm.getMovieListing(operationDate);
  }

  Future generateToken(BuildContext context) async {
    AuthApi itm = AuthApi(context);
    return itm.generateToken();
  }

  Future<ExpNPromoResponse> getPromoNEXP() async {
    OthersApi itm = OthersApi(context);
    return itm.getPromoNExp();
  }

  Future<List<CMS_EXPERIENCE>> getEXP(BuildContext context) async {
    OthersApi itm = OthersApi(context);
    return itm.getExperience();
  }

  Future<List<CMS_PROMOTION>> getPromotion(BuildContext context) async {
    OthersApi itm = OthersApi(context);
    return itm.getPromotion();
  }

  Future<SplashPopUpData> getPopUpImage(BuildContext context) async {
    OthersApi itm = OthersApi(context);
    return itm.getSplashScreenPopUp();
  }

  Future<UserModel> getProfile(
      BuildContext context, String mobile, String email, String member) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getProfile(member, mobile, email);
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    var hasAsAccessToken =
        await AppCache.containValue(AppCache.AS_API_ACCESS_TOKEN_PREF);
    if (hasAccessToken && hasAsAccessToken) {
      AppCache.getStringValue(AppCache.ACCESS_TOKEN_PREF).then((value) {
        if (value.isNotEmpty) {
          _getUserProfile(value);
        } else {
          AppCache.removeValues(context);
        }
      });
    } else {
      AppCache.removeValues(context);
    }
  }

  _checkLastLoggedDay() async {
    await AppCache.getStringValue(AppCache.SPLASH_SCREEN_REF).then((value) {
      if (value.isNotEmpty) {
        var today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

        AppCacheObjectModel storedData =
            AppCacheObjectModel.fromJson(jsonDecode(value));

        var storedRecord = storedData.record;

        setState(() {
          if (storedRecord != null) {
            if (DateTime.parse(storedRecord).isAfter(today) ||
                DateTime.parse(storedRecord).isAtSameMomentAs(today)) {
              isNextDay = false;

              if (storedData.expList != null && storedData.promoList != null) {
                AppCache.expNpromoList = CMSExpNPromoResponse(
                    cms_experiences: storedData.expList,
                    cms_promotions: storedData.promoList);
              } else {
                isNextDay = true;
                AppCache.reSetCacheModel = true;
              }
              AppCache.splashImages = storedData.splash;
              AppCache.movieListing = storedData.swaggermovie;
            } else {
              isNextDay = true;
              AppCache.reSetCacheModel = true;
            }
          } else {
            isNextDay = true;
            AppCache.reSetCacheModel = true;
          }
        });
      } else {
        isNextDay = true;
        AppCache.reSetCacheModel = true;
      }
    }, onError: (error) {
      isNextDay = true;
      AppCache.reSetCacheModel = true;
    }).then((value) => startTimer());
  }

  _updateDeviceInfo() async {
    var fcmToken = AppCache.fcmToken;
    if (fcmToken != null) {
      await AppCache.getStringValue(AppCache.DEVICE_INFO).then((value) async {
        var dataMap = json.decode(value);

        var appVersion = dataMap["appVersion"];
        var deviceUUID = dataMap["deviceUUID"];
        var deviceModel = dataMap["deviceModel"];
        var deviceName = dataMap["deviceName"];
        var deviceVersion = dataMap["deviceVersion"];
        await updateDevice(
            context,
            AppCache.me!.MemberLists!.first.MemberID!,
            fcmToken,
            appVersion,
            deviceUUID,
            deviceName,
            deviceModel,
            deviceVersion);
      });
    }
  }

  _getUserProfile(String member) async {
    await getProfile(context, "", "", member).then((value) {
      if (value.ReturnStatus == 1) {
        if (value.CardLists != null) {
          if (value.CardLists!.isEmpty) {
            Utils.printInfo("no member list");

            AppCache.removeValues(context);
          } else {
            AppCache.me = value;
            _updateDeviceInfo();
          }
        } else {
          AppCache.removeValues(context);
        }
      } else {
        AppCache.removeValues(context);
      }
    }, onError: (error) {
      EasyLoading.dismiss();
      AppCache.removeValues(context);
      Utils.printInfo('GET USER PROFILE ERROR: $error');
    });
  }

  startTimer() {
    getToken();

    if (isNextDay) {
      getMovieListingInfo();
    }
    getEpaymantMovieListingInfo();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.homebaseRoute, (Route<dynamic> route) => false,
            arguments:
                Constants.IS_HUAWEI ? huaweiRemoteConfig : _remoteConfig);
        _determinePosition();
      }
    });
  }

  getMovieListingInfo() async {
    String operationDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await getMovieListings(context, operationDate)
        .then((data) {
          AppCache.movieListing = data;
        })
        .whenComplete(() => {})
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
        });
  }

  getPopUpData() async {
    await getPopUpImage(context).then((data) {
      splashData = data;
      if (splashData != null) {
        var len = splashData?.body?.images?.length ?? 0;

        setState(() {
          if (len > 0) {
            splashIcon = splashData?.body?.images?[0];
          } else {
            splashIcon = SplashImage(imageLink: "GSC-logo.png", isAsset: true);
          }

          len >= 3 ? len = 3 : null;
          if (!(len < 1)) {
            AppCache.splashImages = [];
            for (var i = 0; i < len; i++) {
              AppCache.splashImages!.add(splashData!.body!.images![i]);
            }
          }
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        splashIcon = SplashImage(imageLink: "GSC-logo.png", isAsset: true);
      });
    });
  }

  getPromoNEXPListing() async {
    var exp;
    var promo;
    await getEXP(context)
        .then((data) {
          exp = data;
        })
        .whenComplete(() => {})
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
        });

    await getPromotion(context)
        .then((data) {
          // AppCache.expNpromoList = data;
          promo = data;
        })
        .whenComplete(() => {})
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
        });
    AppCache.expNpromoList =
        CMSExpNPromoResponse(cms_experiences: exp, cms_promotions: promo);
  }

  getEpaymantMovieListingInfo() async {
    await getEpaymentMovie(context)
        .then((data) {
          AppCache.movieEpaymentList = data;
        })
        .whenComplete(() => {})
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
        });
  }

  getToken() async {
    await generateToken(context)
        .then((value) {
          if (value != null) {
            var tokenData = value;
            AppCache.accessToken = tokenData["access_token"];
            AppCache.tokenType = tokenData["token_type"];
            const MyApp().callStartTimer(context, tokenData["expires_in"]);
          }
        })
        .whenComplete(() => {
              if (isNextDay)
                {
                  getPromoNEXPListing(),
                }
            })
        .catchError((error) {
          Utils.printInfo(error);
        });
  }

  Future _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    await AppCache.getbooleanValue(AppCache.ACCESS_LOCATION)
        .then((value) async {
      if (value == null) {
        callGPSDialog();
      }
    });
  }

  callGPSDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title: "",
              message: Utils.getTranslated(context, 'gps_get_location_message'),
              img: "map-icon.png",
              showButton: true,
              showConfirm: true,
              cancelStr: Utils.getTranslated(context, 'btn_no'),
              showCancel: true,
              confirmStr: Utils.getTranslated(context, 'btn_yes'),
              onCancel: () {
                Navigator.pop(context);
                AppCache.setBoolean("ACCESS_LOCATION", false);
              },
              onConfirm: () async {
                Navigator.pop(context);

                Location location = Location();
                bool _serviceEnabled = await location.serviceEnabled();

                if (!_serviceEnabled) {
                  await location.requestService();
                }

                await Geolocator.requestPermission().then((value) {});
                AppCache.setBoolean("ACCESS_LOCATION", true);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            splashIcon != null
                ? Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(100.0, 0, 100.0, 0),
                      child: splashIcon!.imageLink != null &&
                              (splashIcon?.isAsset == false)
                          ? Image.network(
                              splashIcon!.imageLink!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  Constants.ASSET_IMAGES + 'GSC-logo.png',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              Constants.ASSET_IMAGES + "GSC-logo.png",
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  )
                : Container(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  Utils.getTranslated(context, "splash_copywrite"),
                  textAlign: TextAlign.center,
                  style: AppFont.poppinsRegular(
                    10,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
