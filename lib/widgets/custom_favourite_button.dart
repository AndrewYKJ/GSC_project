// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/cinema_api.dart';
import 'package:gsc_app/models/json/as_list_favourite_cinema_model.dart';

import '../cache/app_cache.dart';
import '../dio/api/as_auth_api.dart';
import '../models/json/as_dynamic_field_model.dart';
import '../models/json/nearby_location_model.dart';
import '../models/json/user_model.dart';

class FavouriteButton extends StatefulWidget {
  final bool isFavourite;
  final String hallGroup;
  final int cinemaId;
  final bool isAurum;
  // ignore: prefer_typing_uninitialized_variables
  final isReload;
  const FavouriteButton({
    Key? key,
    required this.isFavourite,
    required this.hallGroup,
    required this.cinemaId,
    required this.isAurum,
    this.isReload,
  }) : super(key: key);

  @override
  _FavouriteButtonState createState() => _FavouriteButtonState(
        state: isFavourite,
      );
}

class _FavouriteButtonState extends State<FavouriteButton> {
  bool state;
  bool isLogged = false;
  bool isFav = false;
  _FavouriteButtonState({required this.state});

  Future<UserModel> getUpdateFavCinema(
      BuildContext context, List<AS_DYNAMIC_MODEL> data) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.updateCinemaFavourite(
      AppCache.me!.MemberLists!.first.MemberID!,
      data,
    );
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken) {
      setState(() {
        isLogged = true;
      });
    }
  }

  Future<NearbyLocationBody> getNearbyLocation(
      BuildContext context, String? long, String? lat) async {
    CinemaApi showtimesApi = CinemaApi(context);
    return showtimesApi.getNearbyLocation(long, lat);
  }

  getCinemaListData() async {
    if (AppCache.isLocationCalled == false) {
      AppCache.isLocationCalled = true;
      await getNearbyLocation(context, null, null).then((value) async {
        if (value.status != null &&
            value.status!.respNearbyLocationBodyStatus == '-1') {
        } else {
          setState(() {
            AppCache.allLocationList = value.locations;
          });
        }
      }).whenComplete(() {
        getFavDataList();
      }).catchError((e) {
        AppCache.isLocationCalled = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    setState(() {
      if (AppCache.me?.MemberLists?.first.MemberID != null) {
        List<AS_FAVOURITE_CINEMA> data = [];
        if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
          if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any(
              (element) =>
                  element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
            data = Utils.setASFavCinemaToList(AppCache
                .me!.MemberLists!.first.DynamicFieldLists!
                .firstWhere((element) =>
                    element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                .colValue);
            if (data.isNotEmpty) {
              for (var element in data) {
                if (element.id == widget.cinemaId &&
                    element.hallGroup == widget.hallGroup) {
                  isFav = true;

                  break;
                } else {
                  isFav = false;
                }
              }
            } else {
              isFav = false;
            }
          }
        }
      }
    });

    super.didUpdateWidget(oldWidget);
  }

  getFavDataList() {
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      List<AS_FAVOURITE_CINEMA> data = [];
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any((element) =>
            element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
          data = Utils.setASFavCinemaToList(AppCache
              .me!.MemberLists!.first.DynamicFieldLists!
              .firstWhere((element) =>
                  element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
              .colValue);
          for (var element in data) {
            if (element.id == widget.cinemaId &&
                element.hallGroup == widget.hallGroup) {
              isFav = true;

              break;
            } else {
              isFav = false;
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    _checkLoginState();
    AppCache.allLocationList == null ? getCinemaListData() : getFavDataList();

    super.initState();
  }

  void validationFavourite(bool curState) async {
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      List<AS_FAVOURITE_CINEMA> data = [];
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any((element) =>
            element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
          data = Utils.setASFavCinemaToList(AppCache
              .me!.MemberLists!.first.DynamicFieldLists!
              .firstWhere((element) =>
                  element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
              .colValue);
        }
      }

      if (isFav) {
        data.removeWhere((element) =>
            element.id == widget.cinemaId &&
            element.hallGroup == widget.hallGroup);
        getUpdateProfile([
          AS_DYNAMIC_MODEL(
              colValue: data.join(','),
              name: Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE,
              type: 'PlainText')
        ]);
      } else {
        if (data.length + 1 > int.parse(Constants.MAX_FAVOURITE_COUNT)) {
          Utils.showErrorDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              Utils.getTranslated(context, "max_fav_error")
                  .replaceAll("{{ max }}", Constants.MAX_FAVOURITE_COUNT),
              true,
              "attention-icon.png",
              false,
              false, () {
            Navigator.pop(context);
          });
        } else {
          if (AppCache.allLocationList!.any((element) =>
              element.cinemaCode == widget.cinemaId &&
              element.hallGroup == widget.hallGroup)) {
            data.add(AS_FAVOURITE_CINEMA(widget.cinemaId, widget.hallGroup));
            getUpdateProfile([
              AS_DYNAMIC_MODEL(
                  colValue: data.join(','),
                  name: Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE,
                  type: 'PlainText')
            ]);
          } else {
            Utils.showErrorDialog(
                context,
                Utils.getTranslated(context, "error_title"),
                Utils.getTranslated(context, "unable_to_fav_error"),
                true,
                "failed-icon.png",
                false,
                false, () {
              Navigator.pop(context);
            });
          }
        }
      }
    } else {
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          Utils.getTranslated(context, "general_error"),
          true,
          "attention-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
    }
  }

  showErrorDialogLoginFirst() {
    return Utils.showErrorDialog(
        context,
        Utils.getTranslated(context, "error_title"),
        Utils.getTranslated(context, "login_first_error"),
        true,
        "attention-icon.png",
        false,
        false, () {
      Navigator.pop(context);
    });
  }

  getUpdateProfile(data) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getUpdateFavCinema(context, data).then((value) {
      if (value.IsValid == false) {
      } else {
        setState(() {
          if (value.MemberLists?.first.DynamicFieldLists != null) {
            if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any(
                (element) =>
                    element.name ==
                    Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
              AppCache.me!.MemberLists!.first.DynamicFieldLists!
                      .firstWhere((element) =>
                          element.name ==
                          Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                      .colValue =
                  value.MemberLists!.first.DynamicFieldLists!
                      .firstWhere((element) =>
                          element.name ==
                          Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                      .colValue;
            } else {
              AppCache.me!.MemberLists!.first.DynamicFieldLists!.add(
                  AS_DYNAMIC_MODEL(
                      colValue: value.MemberLists!.first.DynamicFieldLists!
                          .firstWhere((element) =>
                              element.name ==
                              Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                          .colValue,
                      name: Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE,
                      type: 'PlainText'));
            }
          }

          widget.isReload();
        });
      }
    }, onError: (e) {
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          e != null
              ? e.toString().isNotEmpty
                  ? e.toString()
                  : Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          null, () {
        Navigator.of(context).pop();
      });
    }).whenComplete(() {
      EasyLoading.dismiss();

      if (AppCache.me?.MemberLists?.first.MemberID != null) {
        List<AS_FAVOURITE_CINEMA> data = [];
        if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
          if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any(
              (element) =>
                  element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
            data = Utils.setASFavCinemaToList(AppCache
                .me!.MemberLists!.first.DynamicFieldLists!
                .firstWhere((element) =>
                    element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                .colValue);
            if (data.isNotEmpty) {
              for (var element in data) {
                if (element.id == widget.cinemaId &&
                    element.hallGroup == widget.hallGroup) {
                  isFav = true;

                  break;
                } else {
                  isFav = false;
                }
              }
            } else {
              isFav = false;
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF).then((value) {
          value ? validationFavourite(state) : showErrorDialogLoginFirst();
        });
      },
      child: Image.asset(
        isFav
            ? Constants.ASSET_IMAGES + 'love-hover-icon.png'
            : Constants.ASSET_IMAGES + 'love-icon.png',
        height: 30,
        width: 30,
        color: widget.isAurum
            ? isFav
                ? AppColor.aurumGold()
                : null
            : null,
      ),
    );
  }
}
