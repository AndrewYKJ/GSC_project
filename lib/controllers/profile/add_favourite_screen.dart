import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:gsc_app/dio/api/cinema_api.dart';
import 'package:gsc_app/models/json/user_model.dart';

import 'package:collection/collection.dart';
import '../../const/analytics_constant.dart';
import '../../models/json/as_dynamic_field_model.dart';
import '../../models/json/as_list_favourite_cinema_model.dart';
import '../../models/json/nearby_location_model.dart';

class AddFavouriteCinemaScreen extends StatefulWidget {
  final List<SwaggerLocation> cinemaData;
  const AddFavouriteCinemaScreen({Key? key, required this.cinemaData})
      : super(key: key);

  @override
  State<AddFavouriteCinemaScreen> createState() =>
      _AddFavouriteCinemaScreenState();
}

class _AddFavouriteCinemaScreenState extends State<AddFavouriteCinemaScreen> {
  bool isLoading = true;
  NearbyLocationBody? cinemaDTO;
  List<SwaggerLocation> allCinemaList = [];
  List<AS_FAVOURITE_CINEMA> favCinemaList = [];
  int selectedRegionCode = 2;

  List<AS_FAVOURITE_CINEMA> selectedFavourite = [];
  List<AS_DYNAMIC_MODEL>? parseData;
  String selectedRegionKey = 'Klang Valley';

  Future<NearbyLocationBody> getNearbyLocation(
      BuildContext context, String? long, String? lat) async {
    CinemaApi showtimesApi = CinemaApi(context);
    return showtimesApi.getNearbyLocation(long, lat);
  }

  dynamic currentTime;
  bool showBlur = false;
  dynamic formattedDob;

  Future<UserModel> getUpdateFavCinema(
      BuildContext context, List<AS_DYNAMIC_MODEL> data) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.updateCinemaFavourite(
      AppCache.me!.MemberLists!.first.MemberID!,
      data,
    );
  }

  Map<String?, List<SwaggerLocation>>? cinemaTab;

  void groupByLastStatusData(List<SwaggerLocation> data) {
    final groups = groupBy(data, (SwaggerLocation e) {
      return e.region;
    });

    setState(() {
      cinemaTab = groups;
    });
  }

  getCinemaListData() async {
    await getNearbyLocation(context, null, null).then((value) async {
      if (value.status != null &&
          value.status!.respNearbyLocationBodyStatus == '-1') {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.status?.respDesc != null
                ? value.status?.respDesc ??
                    Utils.getTranslated(context, "general_error")
                : Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } else {
        setState(() {
          cinemaDTO = value;

          allCinemaList =
              value.locations != null ? value.locations!.toList() : [];

          groupByLastStatusData(allCinemaList);
        });
      }
    }).whenComplete(() {
      EasyLoading.dismiss();

      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
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
        Navigator.of(context).pop();
      });
    });
  }

  getUpdateProfile(data) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getUpdateFavCinema(context, data).then((value) {
      if (value.IsValid == false) {
      } else {
        setState(() {
          // Utils.printWrapped('GET UPDATE PROFILE ERROR: $value');
          List<AS_DYNAMIC_MODEL> tempFile = [];
          value.MemberLists != null
              ? value.MemberLists!.first.DynamicFieldLists != null
                  ? AppCache.me!.MemberLists!.first.DynamicFieldLists!.any(
                          (element) =>
                              element.name ==
                              Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                      ? AppCache.me!.MemberLists!.first.DynamicFieldLists!
                              .firstWhere((element) =>
                                  element.name ==
                                  Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                              .colValue =
                          value.MemberLists!.first.DynamicFieldLists!
                              .firstWhere((element) =>
                                  element.name ==
                                  Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                              .colValue
                      : {
                          tempFile = AppCache
                              .me!.MemberLists!.first.DynamicFieldLists!,
                          tempFile.add(AS_DYNAMIC_MODEL(
                              name: Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE,
                              colValue: value
                                  .MemberLists!.first.DynamicFieldLists!
                                  .firstWhere((element) =>
                                      element.name ==
                                      Constants
                                          .ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                                  .colValue)),
                          AppCache.me!.MemberLists!.first.DynamicFieldLists =
                              tempFile
                        }
                  : AppCache.me!.MemberLists!.first.DynamicFieldLists!
                      .firstWhere((element) =>
                          element.name ==
                          Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                      .colValue = null
              : null;
        });
      }
    }).whenComplete(() => {EasyLoading.dismiss(), Navigator.of(context).pop()});
  }

  getFavouriteData() {
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any((element) =>
            element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
          favCinemaList = Utils.setASFavCinemaToList(AppCache
              .me!.MemberLists!.first.DynamicFieldLists!
              .firstWhere((element) =>
                  element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
              .colValue);

          // favCinemaList.forEach((element) {
          //   selectedFavourite.add(element.id);
          // });
        }
      }
    }
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_ADD_FAVOURITE_CINEMA_SCREEN);
    super.initState();
    getFavouriteData();
    setState(() {
      allCinemaList = widget.cinemaData;

      groupByLastStatusData(allCinemaList);
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final availableHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        floatingActionButton: _savedFavourite(screenWidth),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Container(
          height: availableHeight,
          width: screenWidth,
          color: Colors.black,
          child: SafeArea(
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(),
                        _regionLabel(),
                        if (cinemaTab != null) _allCinema(screenWidth),
                      ]))),
        ));
  }

  Widget _savedFavourite(double width) {
    return InkWell(
      onTap: () {
        if (favCinemaList.length <= 9){
          if (favCinemaList.length + selectedFavourite.length <= 10){
            if (selectedFavourite.isNotEmpty) {
              List<AS_FAVOURITE_CINEMA> tempbuffer = [];
              setState(() {
                for (var data in allCinemaList) {
                  if (selectedFavourite.any((e) =>
                      e.id == data.cinemaCode && e.hallGroup == data.hallGroup)) {
                    var convertedJson = data.toJson();
                    AS_FAVOURITE_CINEMA tempData = AS_FAVOURITE_CINEMA(
                      convertedJson['CinemaCode'],
                      convertedJson["HallGroup"],
                    );
                    tempbuffer.add(tempData);
                  }
                }
                tempbuffer.addAll(favCinemaList);
                parseData = [
                  AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE,
                      colValue: tempbuffer.join(','),
                      type: 'PlainText')
                ];
              });

              getUpdateProfile(parseData);
            }
          } else {
            setState(() {
              selectedFavourite.clear();
            });
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
          }
        } else {
          setState(() {
            selectedFavourite.clear();
          });
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
        }
      },
      child: Container(
        width: width,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selectedFavourite.isNotEmpty
              ? AppColor.appYellow()
              : AppColor.checkOutDisabled(),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedFavourite.length.toString(),
                textAlign: TextAlign.center,
                style: AppFont.montSemibold(
                  14,
                  color: AppColor.backgroundBlack(),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                Utils.getTranslated(context, "favourite"),
                textAlign: TextAlign.center,
                style: AppFont.montSemibold(
                  14,
                  color: AppColor.backgroundBlack(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _regionLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            for (var data in CinemaRegion.regionList.entries)
              regionItem(data.key, data.value)
          ]
              // .map((key,e) => messageItemWithCheckbox(context, e))
              // .toList(),

              )),
    );
  }

  Widget regionItem(String region, int code) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedRegionCode = code;
          selectedRegionKey = region;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: selectedRegionCode != code || selectedRegionKey != region
                ? Colors.transparent
                : AppColor.appYellow(),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: selectedRegionCode != code || selectedRegionKey != region
                    ? Colors.white
                    : AppColor.appYellow())),
        child: Center(
          child: Text(
            region,
            style: selectedRegionCode != code || selectedRegionKey != region
                ? AppFont.poppinsMedium(12, color: Colors.white)
                : AppFont.poppinsSemibold(12, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget emptyScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/no-records-icon.png',
        ),
        Text(
          Utils.getTranslated(context, 'no_record_found'),
          style: AppFont.montRegular(
            16,
            color: AppColor.dividerColor(),
          ),
        ),
      ],
    );
  }

  Container _allCinema(double screenWidth) {
    List<SwaggerLocation> displayData = [];
    cinemaTab!.forEach((key, value) {
      if (key == selectedRegionCode.toString() || key == selectedRegionKey) {
        List<SwaggerLocation> bufftemp2 = value
            .where((v) => !favCinemaList.any((element) =>
                element.id == v.cinemaCode && element.hallGroup == v.hallGroup))
            .toList();
        displayData = bufftemp2;
      }
    });

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !isLoading
              ? displayData.isEmpty
                  ? Container(
                      padding: const EdgeInsets.only(top: 100),
                      width: MediaQuery.of(context).size.width,
                      child: emptyScreen(context))
                  : const SizedBox()
              : const SizedBox(),
          if (!isLoading)
            for (var data in displayData)
              InkWell(
                onTap: () {
                  !favCinemaList.any((element) =>
                          element.id == data.cinemaCode &&
                          element.hallGroup == data.hallGroup)
                      ? setState(() {
                          selectedFavourite.any((e) =>
                                  e.id == data.cinemaCode &&
                                  e.hallGroup == data.hallGroup)
                              ? selectedFavourite.removeWhere((e) =>
                                  e.id == data.cinemaCode &&
                                  e.hallGroup == data.hallGroup)
                              : selectedFavourite.add(AS_FAVOURITE_CINEMA(
                                  data.cinemaCode!, data.hallGroup!));
                        })
                      : null;
                },
                child: SizedBox(
                  height: 50,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            !favCinemaList.any((element) =>
                                    element.id == data.cinemaCode &&
                                    element.hallGroup == data.hallGroup)
                                ? selectedFavourite.any((e) =>
                                        e.id == data.cinemaCode &&
                                        e.hallGroup == data.hallGroup)
                                    ? Constants.ASSET_IMAGES +
                                        'love-hover-icon.png'
                                    : Constants.ASSET_IMAGES + 'love-icon.png'
                                : Constants.ASSET_IMAGES +
                                    'love-hover-icon.png',
                            height: 30,
                            width: 30,
                          ),
                          Container(
                            width: screenWidth - 32 - 30 - 8,
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              data.epaymentName ?? "",
                              style: AppFont.montRegular(14,
                                  color: selectedFavourite.any((e) =>
                                          e.id == data.cinemaCode &&
                                          e.hallGroup == data.hallGroup)
                                      ? AppColor.appYellow()
                                      : Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                        color: AppColor.dividerColor(),
                      )
                    ],
                  ),
                ),
              )
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: Image.asset(
                      Constants.ASSET_IMAGES + 'close-circle.png',
                      height: 30,
                      width: 30,
                    )),
              ],
            ),
            Text(
              Utils.getTranslated(context, "add_to_fav_cinema"),
              style: AppFont.montMedium(18, color: Colors.white),
            ),
          ],
        ));
  }
}
