// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:gsc_app/const/localization.dart';
import 'package:gsc_app/widgets/analytics_handler.dart';
import 'package:gsc_app/models/json/as_list_favourite_cinema_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cache/app_cache.dart';
import '../models/json/splash_popup_model.dart';
import '../widgets/custom_dialog.dart';
import 'app_color.dart';
import 'app_font.dart';
import 'constants.dart';

class Utils {
  static void setFirebaseAnalyticsCurrentScreen(String curScreenName) {
    AnalyticsHandler.setAnalyticsCurrentScreen(curScreenName);
  }

  static List<AS_FAVOURITE_CINEMA> setASFavCinemaToList(String? data) {
    String splitData = data ?? '';
    if (splitData.isNotEmpty) {
      return splitData.split(',').map((item) {
        List<String> parts = item.split('|');
        int id = int.tryParse(parts[0]) ?? 0;
        String name = parts[1];
        return AS_FAVOURITE_CINEMA(id, name);
      }).toList();
    } else {
      return [];
    }
  }

  static String setASFavCinemaToString(List<AS_FAVOURITE_CINEMA>? data) {
    if (data != null) {
      return data.join(',');
    } else {
      return '';
    }
  }

  static int compareAndArrangeTimes(String a, String b) {
    int aMinutes =
        int.parse(a.substring(0, 2)) * 60 + int.parse(a.substring(2));
    int bMinutes =
        int.parse(b.substring(0, 2)) * 60 + int.parse(b.substring(2));

    if ((aMinutes >= 600 && aMinutes <= 2359) &&
        (bMinutes >= 0 && bMinutes <= 360)) {
      return -1;
    } else if ((bMinutes >= 600 && bMinutes <= 2359) &&
        (aMinutes >= 0 && aMinutes <= 360)) {
      return 1;
    } else {
      return aMinutes.compareTo(bMinutes);
    }
  }

  static int? getDefaultVoucherPoints(String? ref) {
    if (ref != null && ref.isNotEmpty) {
      var splitData = ref.split('|');

      if (splitData[splitData.length - 1].trim().isNotEmpty) {
        return int.parse(splitData[splitData.length - 1]);
      }
    }

    return null;
  }

  static Future<Size> getImageSize(String s) async {
    final Completer<Size> completer = Completer<Size>();
    final ImageStream imageStream = Image.network(
      s,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/Default placeholder_app_img.png',
          fit: BoxFit.cover,
        );
      },
    ).image.resolve(ImageConfiguration.empty);

    imageStream.addListener(
      ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          final Size imageSize = Size(
            imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble(),
          );
          completer.complete(imageSize);
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          completer.complete(const Size(100, 100));
        },
      ),
    );

    return completer.future;
  }

  static Future callPopUpDialog(
    BuildContext context,
    SplashImage splashImage,
    bool nextSplash,
  ) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          double maxHeight = 253;
          double maxWidth = 336;
          return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: maxWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () async => nextSplash
                              ? {
                                  Navigator.of(context).pop(),
                                  await callPopUpDialog(
                                      context,
                                      AppCache.splashImages?[2] ??
                                          SplashImage(imageLink: ''),
                                      false),
                                }
                              : {
                                  Navigator.pop(context, true),
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Image.asset(
                              Constants.ASSET_IMAGES + "close-icon.png",
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: Utils.getImageSize(
                        splashImage.imageLink ?? '',
                      ),
                      builder:
                          (BuildContext context, AsyncSnapshot<Size> snapshot) {
                        if (snapshot.hasData) {
                          final Size imageSize = snapshot.data!;

                          if (imageSize.aspectRatio == 1) {
                            maxHeight = 336;
                            maxWidth = 336;
                          } else if (imageSize.aspectRatio < 1) {
                            maxHeight = 482;
                            maxWidth = 336;
                          }
                          return Container(
                            constraints: BoxConstraints(
                                maxHeight: maxHeight, maxWidth: maxWidth),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 4),
                                borderRadius: BorderRadius.circular(16)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: imageSize.aspectRatio,
                                child: Image.network(
                                  splashImage.imageLink ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                        'assets/images/Default placeholder_app_img.png',
                                        fit: BoxFit.cover);
                                  },
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                              width: maxWidth,
                              height: maxHeight,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                  color: AppColor.appSecondaryBlack(),
                                  border:
                                      Border.all(color: Colors.white, width: 4),
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Center(
                                child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator()),
                              ));
                        }
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  static printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static printInfo(Object object) {
    if (Constants.IS_DEBUG) {
      print(object);
    }
  }

  static Future<bool> isHuawei() async {
    Utils.printInfo(">>>>>>>> CHECK IS HUAWEI");

    if (Platform.operatingSystem == 'android') {
      GooglePlayServicesAvailability availability = await GoogleApiAvailability
          .instance
          .checkGooglePlayServicesAvailability();
      Utils.printInfo(">>>>> AVAILABILITY: $availability");

      if (availability ==
              GooglePlayServicesAvailability.notAvailableOnPlatform ||
          availability == GooglePlayServicesAvailability.serviceDisabled ||
          availability == GooglePlayServicesAvailability.serviceInvalid ||
          availability == GooglePlayServicesAvailability.serviceMissing ||
          availability == GooglePlayServicesAvailability.unknown) {
        Utils.printInfo(">>>>> AVAILABILITY NOT HUAWEI: $availability");
        Constants.IS_HUAWEI = true;
        return true;
      } else {
        Constants.IS_HUAWEI = false;
        return false;
      }
    } else {
      Constants.IS_HUAWEI = false;
      return false;
    }
  }

  static String buildQueryParameters(Map<String, String> params) {
    List<String> query = [];
    params.forEach((key, value) {
      final encodedKey = Uri.encodeComponent(key);
      final encodedValue = Uri.encodeComponent(value);
      query.add('$encodedKey=$encodedValue');
    });
    return query.join('&');
  }

  static void checkAppVersion(
      BuildContext context, FirebaseRemoteConfig _remoteConfig) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    var updateUrl = _remoteConfig.getString('update_url');
    var minimumVersion = _remoteConfig.getString('version_force_update');
    var currentVersion = _remoteConfig.getString('version_optional_update');
    var forceUpdateEnabled = _remoteConfig.getBool('force_update_enabled');
    var optionalText = _remoteConfig.getString('message_optional_update');
    var forcedText = _remoteConfig.getString('message_force_update');

    var compareIsMin = appVersion.compareTo(minimumVersion);
    var compareIsLatest = appVersion.compareTo(currentVersion);
    Utils.printInfo(
        'CURRENT APP VERSION: $appVersion|| MIN APP VERSION: $minimumVersion  || LATEST APP VERSION: $currentVersion || UPDATE URL: $updateUrl');
    Utils.printInfo('FORCE UPDATE ENABLED: $forceUpdateEnabled');
    Utils.printInfo("COMPARE NEW with OLD VERSION: $compareIsMin");
    Utils.printInfo("OPTIONAN TEXT: $optionalText");
    Utils.printInfo("FORCED TEXT: $forcedText");

    if (compareIsMin < 0) {
      Utils.printInfo('currentVersion is lower');
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogBox(
                  title: "",
                  message: forcedText,
                  img: 'attention-icon.png',
                  showButton: true,
                  showConfirm: true,
                  showCancel: true,
                  confirmStr: "OK",
                  onCancel: () {
                    exit(0);
                  },
                  onConfirm: () async {
                    launchBrowser(updateUrl);
                  });
            });
      } catch (e) {
        printInfo(e.toString());
      }
    } else {
      Utils.printInfo('currentVersion is bigger than minumum');
      if (compareIsLatest < 0) {
        Utils.printInfo('currentVersion is lower than Latest');
        try {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return CustomDialogBox(
                    title: "",
                    message: optionalText,
                    img: 'attention-icon.png',
                    showButton: true,
                    showConfirm: true,
                    showCancel: true,
                    confirmStr: "OK",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onConfirm: () async {
                      Navigator.pop(context);
                      launchBrowser(updateUrl);
                    });
              });
        } catch (e) {
          printInfo(e.toString());
        }
      } else if (compareIsLatest == 0) {
        Utils.printInfo('currentVersion is same as Latest');
      } else {
        Utils.printInfo('currentVersion is bigger');
      }
    }
  }

  static void checkHuaweiAppVersion(
      BuildContext context, Map<dynamic, dynamic> _remoteConfig) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    var updateUrl = _remoteConfig['update_url'];
    var minimumVersion = _remoteConfig['version_force_update'];
    var currentVersion = _remoteConfig['version_optional_update'];
    var optionalText = _remoteConfig['message_optional_update'];
    var forcedText = _remoteConfig['message_force_update'];

    var compareIsMin = appVersion.compareTo(minimumVersion);
    var compareIsLatest = appVersion.compareTo(currentVersion);
    Utils.printInfo(
        'CURRENT APP VERSION: $appVersion|| MIN APP VERSION: $minimumVersion  || LATEST APP VERSION: $currentVersion || UPDATE URL: $updateUrl');
    Utils.printInfo("COMPARE NEW with OLD VERSION: $compareIsMin");
    Utils.printInfo("OPTIONAN TEXT: $optionalText");
    Utils.printInfo("FORCED TEXT: $forcedText");

    if (compareIsMin < 0) {
      Utils.printInfo('currentVersion is lower');
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogBox(
                  title: "",
                  message: forcedText,
                  img: 'attention-icon.png',
                  showButton: true,
                  showConfirm: true,
                  showCancel: true,
                  confirmStr: "OK",
                  onCancel: () {
                    exit(0);
                  },
                  onConfirm: () async {
                    launchBrowser(updateUrl);
                  });
            });
      } catch (e) {
        printInfo(e.toString());
      }
    } else {
      Utils.printInfo('currentVersion is bigger than minumum');
      if (compareIsLatest < 0) {
        Utils.printInfo('currentVersion is lower than Latest');
        try {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return CustomDialogBox(
                    title: "",
                    message: optionalText,
                    img: 'attention-icon.png',
                    showButton: true,
                    showConfirm: true,
                    showCancel: true,
                    confirmStr: "OK",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onConfirm: () async {
                      Navigator.pop(context);
                      launchBrowser(updateUrl);
                    });
              });
        } catch (e) {
          printInfo(e.toString());
        }
      } else if (compareIsLatest == 0) {
        Utils.printInfo('currentVersion is same as Latest');
      } else {
        Utils.printInfo('currentVersion is bigger');
      }
    }
  }

  static launchBrowser(String website) async {
    String url = website;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static List<String> sortAlphanumericSeat(List<String> items) {
    items.sort((a, b) {
      RegExp alphaRegex = RegExp(r'[A-Za-z]+');
      RegExp numRegex = RegExp(r'\d+');
      String aAlpha = alphaRegex.stringMatch(a)!;
      String bAlpha = alphaRegex.stringMatch(b)!;
      int? aNum = int.parse(numRegex.stringMatch(a)!);
      int? bNum = int.parse(numRegex.stringMatch(b)!);
      int cmp = bAlpha.compareTo(aAlpha);
      if (cmp != 0) {
        return cmp;
      }

      return aNum.compareTo(bNum);
    });

    return items;
  }

  static String formatDuration(String mins) {
    int minutes = int.parse(mins);
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    String hoursText = hours > 0 ? '$hours h ' : '';
    String minutesText = '${remainingMinutes.toString().padLeft(2, '0')} m';
    return '$hoursText$minutesText';
  }

  static String time24totime12(String time) {
    var temp = int.parse(time.substring(0, 2));
    String t;
    if (temp >= 12 && temp < 24) {
      t = " PM";
    } else {
      t = " AM";
    }
    if (temp > 12) {
      temp = temp - 12;
      if (temp < 10) {
        time = time.replaceRange(0, 2, "$temp:");
        time += t;
      } else {
        time = time.replaceRange(0, 2, "$temp:");
        time += t;
      }
    } else if (temp == 00) {
      time = time.replaceRange(0, 2, '12:');
      time += t;
    } else {
      var subtime = time.substring(0, 2);
      time = time.replaceRange(0, 2, '$subtime:');
      time += t;
    }
    return time;
  }

  static String capitalizeEveryWord(String input) {
    late String data;

    if (input.toLowerCase().contains('twin') && input.length > 4) {
      data = input.substring(0, 4) + " " + input.substring(4);
    } else {
      data = input;
    }

    return data.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      } else {
        return word;
      }
    }).join(' ');
  }

  static int dateToEpochUnix(DateTime date) {
    return date.toUtc().millisecondsSinceEpoch;
  }

  static DateTime epochToDate(int unix) {
    return DateTime.fromMillisecondsSinceEpoch(unix);
  }

  static DateTime epochToDateMiliseconds(int unix) {
    return DateTime.fromMillisecondsSinceEpoch(unix);
  }

  static String getEpochUnix(String date) {
    RegExp exp = RegExp(r'\((.*)\)');
    final match = exp.firstMatch(date);
    final expiryStr = match?[0]?.replaceAll("(", "").replaceAll(")", "");
    return expiryStr ?? "";
  }

  static String seatImage(String id, bool isAurum) {
    switch (id) {
      case '1':
        return Constants.ASSET_IMAGES + "available-icon.png";
      case '2':
        return Constants.ASSET_IMAGES + "twin-seat-icon.png";
      case '3':
        return Constants.ASSET_IMAGES + "oku-seat-icon.png";
      case '4':
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case '5':
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case '6':
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case '7':
        return isAurum
            ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
            : Constants.ASSET_IMAGES + "selected-icon.png";

      case '1008':
        return Constants.ASSET_IMAGES + "locked-seat-icon.png";
      case '1007':
        return Constants.ASSET_IMAGES + "aurum_seat_underepair_icon.png";
      case '1015':
        return Constants.ASSET_IMAGES + "aurum-recliner-seat.png";
      case '13':
        return Constants.ASSET_IMAGES + "aurum_cabin_seat_icon.png";
      case '14':
        return Constants.ASSET_IMAGES + "aurum_getha_seat_icon.png";
      case '1012':
        return Constants.ASSET_IMAGES + "aurum_cabin_seat_icon.png";
      case '1013':
        return Constants.ASSET_IMAGES + "aurum_getha_seat_icon.png";
      case '1014':
        return Constants.ASSET_IMAGES + "aurum_ps_seat_icon.png";
      case '1016':
        return Constants.ASSET_IMAGES + "aurum_ps_seat_icon.png";
      case '1018':
        return Constants.ASSET_IMAGES + "cuddlecouch_icon.png";
      case '10':
        return Constants.ASSET_IMAGES + "cuddlecouch_icon.png";

      case '1019':
        return Constants.ASSET_IMAGES + "beanbag_icon.png";
      case '11':
        return Constants.ASSET_IMAGES + "beanbag_icon.png";
      case '1020':
        return Constants.ASSET_IMAGES + "louger_icon.png";
      case '1017':
        return Constants.ASSET_IMAGES + "aurum-recliner-seat.png";
      case '15':
        return Constants.ASSET_IMAGES + "aurum_ps_seat_icon.png";
      case '17':
        return Constants.ASSET_IMAGES + "aurum-seat-icon.png";

      case '16':
        return Constants.ASSET_IMAGES + "aurum-recliner-seat.png";

      case '1011':
        return Constants.ASSET_IMAGES + "aurum-4seats.png";
      case '12':
        return Constants.ASSET_IMAGES + "aurum-4seats.png";
      default:
        return "";
    }
  }

  static Color seatLableColor(String id, bool isAurum) {
    switch (id) {
      case '1':
        return Colors.white;
      case '2':
        return AppColor.twinSeatColor();
      case '3':
        return AppColor.okuSeatColor();
      case '4':
        return AppColor.greyWording();
      case '5':
        return AppColor.greyWording();
      case '6':
        return AppColor.greyWording();
      case '7':
        return isAurum ? AppColor.aurumGold() : AppColor.appYellow();
      case '8':
        return isAurum ? AppColor.aurumGold() : AppColor.appYellow();
      case '1008':
        return AppColor.greyWording();
      case '1007':
        return AppColor.greyWording();
      case '1015':
        return Colors.white;
      case '1012':
        return Colors.white;
      case '1013':
        return Colors.white;
      case '1014':
        return Colors.white;
      case '1016':
        return Colors.white;

      case '1017':
        return Colors.white;
      case '1018':
        return Colors.white;
      case '1019':
        return Colors.white;
      case '1020':
        return Colors.white;
      case '1011':
        return Colors.white;
      default:
        return AppColor.greyWording();
    }
  }

  static String getLanguageName(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'eng':
        return 'English';
      case 'tam':
        return 'Tamil';
      case 'hin':
        return 'Tamil';

      case 'bm':
        return 'Bahasa Malaysia';
      default:
        return 'English';
    }
  }

  static TValue customSwitch<TOptionType, TValue>(
      TOptionType selectedOption, Map<TOptionType, TValue> branches,
      [TValue? defaultValue]) {
    if (!branches.containsKey(selectedOption)) {
      return defaultValue!;
    }

    return branches[selectedOption]!;
  }

  static Locale myLocale(String languageCode) {
    switch (languageCode) {
      case Constants.LANGUAGE_CODE_EN:
        return const Locale(Constants.ENGLISH);
      default:
        return const Locale(Constants.ENGLISH);
    }
  }

  static String getTranslated(BuildContext context, String key) {
    return MyLocalization.of(context).translate(key);
  }

  static String getInitials(String username) => username.isNotEmpty
      ? username.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
      : '';

  static showAlertDialog(BuildContext context, String title, String message,
      bool dismissable, bool? isAurum, Function()? onConfirm) {
    showDialog(
        context: context,
        barrierDismissible: dismissable,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title: title,
              message: message,
              img: isAurum != null
                  ? isAurum
                      ? "aurum-attention.png"
                      : "attention-icon.png"
                  : "attention-icon.png",
              showButton: true,
              showConfirm: true,
              showCancel: false,
              isAurum: isAurum,
              confirmStr: Utils.getTranslated(context, "ok_btn"),
              onConfirm: onConfirm);
        });
  }

  static showErrorDialog(
      BuildContext context,
      String title,
      String message,
      bool dismissable,
      String? img,
      bool? isAurum,
      bool? showBtn,
      Function()? onConfirm) {
    showDialog(
        context: context,
        barrierDismissible: dismissable,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title: title,
              message: message,
              img: img ??
                  (isAurum != null
                      ? isAurum
                          ? "aurum-attention.png"
                          : "attention-icon.png"
                      : "attention-icon.png"),
              showButton: showBtn ?? true,
              showConfirm: showBtn ?? true,
              showCancel: false,
              isAurum: isAurum,
              confirmStr: Utils.getTranslated(context, "ok_btn"),
              onConfirm: onConfirm);
        });
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class MapPhoneCode {
  static Map<String, dynamic> countryCode = {
    "+6": "MY",
    "+65": "SG",
    "+673": "BN"
  };

  static Map<String, dynamic> flag = {
    "+6": "assets/images/malaysia-flag.png",
    "+65": "assets/images/singapore-flag.png",
    "+673": "assets/images/brunei-flag.png"
  };
}

class RaceList {
  static List<String> raceList = ['Malay', 'Chinese', 'Indian', 'Others'];
}

class ProfessionList {
  static List<String> professionList = [
    'Student',
    'Corporate',
    'Business Owner',
    'Unemployed',
    'Others'
  ];
}

class CinemaRegion {
  static Map<String, int> regionList = {
    'East Coast': 5,
    'East Malaysia': 6,
    'Klang Valley': 2,
    'Southern': 3,
    'Northern': 4
  };
}

class LocationList {
  static List<String> locationList = [
    'Selangor',
    'Kuala Lumpur',
    'Putrajaya',
    'Penang',
    'Kedah',
    'Johor',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Sabah',
    'Sarawak',
    'Labuan',
    'Terengganu'
  ];
}

class MapCinemaExperiences {
  static Map<String, dynamic> experiences = {
    "4D": "assets/images/4dx_logo_experience_w.png",
    "ATMOS": "assets/images/da_logo_experience_w.png",
    "DBOX": "assets/images/dbox_logo_experience_w.png",
    "BIG": "assets/images/wb_big.png",
    "DIGITAL2D": "assets/images/wb_2d.png",
    "DIGITAL3D": "assets/images/wb_3d.png",
    "IMAX": "assets/images/IMAX_logo_experience_w.png",
    "ONYX": "assets/images/onyx_logo_experience_w.png",
    "PREMIERECLASS": "assets/images/wb_pr.png",
    "PREMIEREPLUS": "assets/images/wb_pr.png",
    "PLAYPLUS": "assets/images/playplus_logo_experience_w.png",
    "MX4D": "assets/images/mx4d_logo_experience_w.png",
    "SCREENX": "assets/images/screenx_logo_experience_w.png",
    "GETHALUXSUITE": "assets/images/wb_lux.png",
    "4DX": "assets/images/4dx_logo_experience_w.png",
    "EXTREME4DX": "assets/images/4dx_logo_experience_w.png",
    "MAXXHALL": "assets/images/maxx_logo_experience_w.png",
    "COMFORTCABIN": "assets/images/wb_comfort.png",
    "ESCAPESTUDIO": "assets/images/wb_escape.png",
    "PRIVATESCREEN": "assets/images/wb_private.png",
    "SKYBOX": "assets/images/Skybox_logo_experience_w.png",
  };

  static Map<String, dynamic> experiencesSelected = {
    "4D": "assets/images/4dx_logo_experience_b.png",
    "ATMOS": "assets/images/da_logo_experience_b.png",
    "DBOX": "assets/images/dbox_logo_experience_b.png",
    "BIG": "assets/images/y_big.png",
    "DIGITAL2D": "assets/images/y_2d.png",
    "DIGITAL3D": "assets/images/y_3d.png",
    "IMAX": "assets/images/IMAX_logo_experience_b.png",
    "ONYX": "assets/images/onyx_logo_experience_b.png",
    "PREMIERECLASS": "assets/images/y_pr.png",
    "PREMIEREPLUS": "assets/images/y_pr.png",
    "PLAYPLUS": "assets/images/playplus_logo_experience_b.png",
    "MX4D": "assets/images/mx4d_logo_experience_b.png",
    "SCREENX": "assets/images/screenx_logo_experience_b.png",
    "GETHALUXSUITE": "assets/images/y_lux.png",
    "4DX": "assets/images/4dx_logo_experience_b.png",
    "EXTREME4DX": "assets/images/4dx_logo_experience_b.png",
    "MAXXHALL": "assets/images/maxx_logo_experience_b.png",
    "COMFORTCABIN": "assets/images/y_comfort.png",
    "ESCAPESTUDIO": "assets/images/y_escape.png",
    "PRIVATESCREEN": "assets/images/y_private.png",
    "SKYBOX": "assets/images/Skybox_logo_experience_b.png",
  };

  static Map<String, dynamic> aurumExperiences = {
    "4D": "assets/images/4DX_logo_experience_g.png",
    "ATMOS": "assets/images/DA_logo_experience_g.png",
    "DBOX": "assets/images/DBOX_logo_experience_g.png",
    "BIG": "assets/images/gb_big.png",
    "DIGITAL2D": "assets/images/gb_2d.png",
    "DIGITAL3D": "assets/images/gb_3d.png",
    "IMAX": "assets/images/IMAX_logo_experience_g.png",
    "ONYX": "assets/images/ONYX_logo_experience_g.png",
    "PREMIERECLASS": "assets/images/gb_pr.png",
    "PREMIEREPLUS": "assets/images/gb_pr.png",
    "PLAYPLUS": "assets/images/playplus_logo_experience_g.png",
    "MX4D": "assets/images/MX4D_logo_experience_g.png",
    "SCREENX": "assets/images/ScreenX_logo_experience_g.png",
    "GETHALUXSUITE": "assets/images/gb_lux.png",
    "4DX": "assets/images/4DX_logo_experience_g.png",
    "EXTREME4DX": "assets/images/4DX_logo_experience_g.png",
    "MAXXHALL": "assets/images/maxx_logo_experience_b.png",
    "COMFORTCABIN": "assets/images/gb_comfort.png",
    "ESCAPESTUDIO": "assets/images/gb_escape.png",
    "PRIVATESCREEN": "assets/images/gb_private.png",
    "SKYBOX": "assets/images/Skybox_logo_experience_g.png",
  };

  static Map<String, dynamic> aurumExperiencesSelected = {
    "4D": "assets/images/4DX_logo_experience_gb.png",
    "ATMOS": "assets/images/DA_logo_experience_gb.png",
    "DBOX": "assets/images/DBOX_logo_experience_gb.png",
    "BIG": "assets/images/g_big.png",
    "DIGITAL2D": "assets/images/g_2d.png",
    "DIGITAL3D": "assets/images/g_3d.png",
    "IMAX": "assets/images/IMAX_logo_experience_gb.png",
    "ONYX": "assets/images/ONYX_logo_experience_gb.png",
    "PREMIERECLASS": "assets/images/g_pr.png",
    "PREMIEREPLUS": "assets/images/g_pr.png",
    "PLAYPLUS": "assets/images/playplus_logo_experience_gb.png",
    "MX4D": "assets/images/MX4D_logo_experience_gb.png",
    "SCREENX": "assets/images/ScreenX_logo_experience_gb.png",
    "GETHALUXSUITE": "assets/images/g_lux.png",
    "4DX": "assets/images/4dx_logo_experience_b.png",
    "EXTREME4DX": "assets/images/4DX_logo_experience_gb.png",
    "MAXXHALL": "assets/images/MAXX_logo_experience_gb.png",
    "COMFORTCABIN": "assets/images/g_comfort.png",
    "ESCAPESTUDIO": "assets/images/g_escape.png",
    "PRIVATESCREEN": "assets/images/g_private.png",
    "SKYBOX": "assets/images/Skybox_logo_experience_gb.png",
  };

  static Map<String, dynamic> experiencesFilter = {
    "4D": "assets/images/4dx_logo_w.png",
    "ATMOS": "assets/images/da_logo_w.png",
    "DBOX": "assets/images/dbox_logo_w.png",
    "BIG": "assets/images/big_logo_w.png",
    "DIGITAL2D": "assets/images/2D_trans_icon.png",
    "DIGITAL3D": "assets/images/3D_trans_icon.png",
    "IMAX": "assets/images/IMAX_logo_w.png",
    "ONYX": "assets/images/onyx_logo_w.png",
    "PREMIERECLASS": "assets/images/premiere_logo_w.png",
    "PREMIEREPLUS": "assets/images/premiere_logo_w.png",
    "PLAYPLUS": "assets/images/playplus_logo_w.png",
    "MX4D": "assets/images/mx4d_logo_w.png",
    "SCREENX": "assets/images/screenx_logo_w.png",
    "GETHALUXSUITE": "assets/images/Movie Confirmation_Getha Lux Suite_img.png",
    "4DX": "assets/images/4dx_logo_w.png",
    "MAXXHALL": "assets/images/maxx_logo_w.png",
    "EXTREME4DX": "assets/images/4dx_logo_w.png",
    "COMFORTCABIN": "assets/images/w_comfort.png",
    "ESCAPESTUDIO": "assets/images/w_escape.png",
    "PRIVATESCREEN": "assets/images/w_private.png",
    "SKYBOX": "assets/images/skybox_logo_w.png",
  };
}

class MovieClassification {
  static Map<String, dynamic> movieRating = {
    "P12": "assets/images/Klasifikasi P12_img.png",
    "13": "assets/images/Klasifikasi 13_img.png",
    "16": "assets/images/Klasifikasi 16_img.png",
    "18": "assets/images/Klasifikasi 18_img.png",
    "U": "assets/images/Klasifikasi U_img.png",
    "NA": "",
    "Not Available": ""
  };

  static Map<String, dynamic> moviewRatingStr = {
    "P12": "P12",
    "13": "P13",
    "16": "16",
    "18": "18",
    "U": "U",
    "NA": "",
    "Not Available": ""
  };
}

Widget sidebarDrawer(BuildContext context) {
  return Stack(children: [
    InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: ClipRRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: AppColor.iconGrey().withOpacity(0.2),
              ))),
    ),
    Container(
        decoration: const BoxDecoration(color: Colors.black, boxShadow: [
          BoxShadow(blurRadius: 8.0),
          BoxShadow(color: Colors.black, offset: Offset(0, -16)),
          BoxShadow(color: Colors.black, offset: Offset(0, 16)),
          BoxShadow(color: Colors.black, offset: Offset(-16, -16)),
          BoxShadow(color: Colors.black, offset: Offset(-16, 16)),
        ]),
        width: MediaQuery.of(context).size.width * 0.728,
        child: SafeArea(
          child: Container(
              padding: const EdgeInsets.only(left: 16),
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding:
                              const EdgeInsets.fromLTRB(22, 22, 24.5, 22.0),
                          child: Image.asset(
                            Constants.ASSET_IMAGES + 'close-icon.png',
                            fit: BoxFit.cover,
                            height: 18,
                            width: 18,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(Constants.GSC_CONTACT_US);
                      },
                      child: Container(
                          padding: const EdgeInsets.only(left: 14),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.dividerColor(),
                                      style: BorderStyle.solid,
                                      width: 1))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.getTranslated(
                                  context, 'sidebar_contactus_text'),
                              style: AppFont.montRegular(
                                16,
                                color: AppColor.sideBarText(),
                              ),
                            ),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(Constants.GSC_FAQ);
                      },
                      child: Container(
                          padding: const EdgeInsets.only(left: 14),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.dividerColor(),
                                      style: BorderStyle.solid,
                                      width: 1))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.getTranslated(context, 'sidebar_faq_text'),
                              style: AppFont.montRegular(
                                16,
                                color: AppColor.sideBarText(),
                              ),
                            ),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(Constants.GSC_HLB_CC);
                      },
                      child: Container(
                          padding: const EdgeInsets.only(left: 14),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.dividerColor(),
                                      style: BorderStyle.solid,
                                      width: 1))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.getTranslated(
                                  context, 'sidebar_GSC_HLB_Credit_Card'),
                              style: AppFont.montRegular(
                                16,
                                color: AppColor.sideBarText(),
                              ),
                            ),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(Constants.TERMS_CONDITION);
                      },
                      child: Container(
                          padding: const EdgeInsets.only(left: 14),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.dividerColor(),
                                      style: BorderStyle.solid,
                                      width: 1))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.getTranslated(
                                  context, 'sidebar_terms&conditions_text'),
                              style: AppFont.montRegular(
                                16,
                                color: AppColor.sideBarText(),
                              ),
                            ),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(Constants.PRIVACY_POLICY);
                      },
                      child: Container(
                          padding: const EdgeInsets.only(left: 14),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.dividerColor(),
                                      style: BorderStyle.solid,
                                      width: 1))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.getTranslated(
                                  context, 'sidebar_privacypolicy_text'),
                              style: AppFont.montRegular(
                                16,
                                color: AppColor.sideBarText(),
                              ),
                            ),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(Constants.GSC_ABAC);
                      },
                      child: Container(
                          padding: const EdgeInsets.only(left: 14),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.dividerColor(),
                                      style: BorderStyle.solid,
                                      width: 1))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.getTranslated(
                                  context, 'sidebar_abacpolicy_text'),
                              style: AppFont.montRegular(
                                16,
                                color: AppColor.sideBarText(),
                              ),
                            ),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(Constants.GSC_WHISTLEBLOWING);
                      },
                      child: Container(
                          padding: const EdgeInsets.only(left: 14),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppColor.dividerColor(),
                                      style: BorderStyle.solid,
                                      width: 1))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.getTranslated(
                                  context, 'sidebar_whistleblowingpolicy_text'),
                              style: AppFont.montRegular(
                                16,
                                color: AppColor.sideBarText(),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              )),
        ))
  ]);
}
