import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/cinema_api.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:gsc_app/provider/home_provider.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/custom_favourite_button.dart';
import 'package:provider/provider.dart';

import 'package:location/location.dart' as loc;
import '../../const/analytics_constant.dart';
import '../../models/arguments/custom_selection_model.dart';
import '../../models/json/as_list_favourite_cinema_model.dart';
import '../../models/json/nearby_location_model.dart';
import '../../widgets/custom_dialog.dart';
import '../tab/homebase.dart';

class CinemaListScreen extends StatefulWidget {
  static Map<String, dynamic>? pushPayload;
  const CinemaListScreen({Key? key}) : super(key: key);

  @override
  _CinemaListScreen createState() => _CinemaListScreen();
}

class _CinemaListScreen extends State<CinemaListScreen>
    with WidgetsBindingObserver {
  var scaffoldHomeScreenKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isLocationPermission = true;
  bool isLocationService = true;
  bool isPermissionCalled = true;
  bool isOpenSetting = false;
  bool offFilter = true;

  Position? currentLocation;
  TextEditingController searchController = TextEditingController();
  List<Location>? cinemaListData;
  List<Location> cinemaDisplayData = [];
  NearbyLocationBody? cinemaDTO;
  List<SwaggerLocation> nearbyCinemaList = [];
  List<SwaggerLocation> allCinemaList = [];
  List<String> preferredRegionList = [];
  List<CustomSelector> regionFilterList = [];
  List<AS_FAVOURITE_CINEMA> selectedFavourite = [];
  Future<NearbyLocationBody> getNearbyLocation(
      BuildContext context, String? long, String? lat) async {
    CinemaApi showtimesApi = CinemaApi(context);
    return showtimesApi.getNearbyLocation(long, lat);
  }

  getFavouriteData() {
    selectedFavourite.clear();
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any((element) =>
            element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
          List<AS_FAVOURITE_CINEMA> favCinemaList = Utils.setASFavCinemaToList(
              AppCache.me!.MemberLists!.first.DynamicFieldLists!
                  .firstWhere((element) =>
                      element.name ==
                      Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                  .colValue);
          setState(() {
            for (var element in favCinemaList) {
              selectedFavourite
                  .add(AS_FAVOURITE_CINEMA(element.id, element.hallGroup));
            }
          });
        }
      }
    }
    return true;
  }

  getCinemaListData() async {
    await getNearbyLocation(context, currentLocation?.longitude.toString(),
            currentLocation?.latitude.toString())
        .then((value) async {
      EasyLoading.dismiss();
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
        });
      } else {
        setState(() {
          cinemaDTO = value;

          rearrangeDataList();
          isLoading = false;
        });
      }
    }).whenComplete(() {
      getRegionFilter();
      checkPush();
      EasyLoading.dismiss();
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
      });
    });
  }

  rearrangeDataList() async {
    final data = await getFavouriteData();
    if (data) {
      setState(() {
        if (cinemaDTO != null) {
          if (cinemaDTO!.topFive != null) {
            nearbyCinemaList = [];
            List<SwaggerLocation> preferredLoc = [];
            List<SwaggerLocation> othersLoc = [];
            for (var element in cinemaDTO!.topFive!) {
              if (selectedFavourite.any((e) =>
                  e.id == (element.cinemaCode) &&
                  e.hallGroup == element.hallGroup)) {
                preferredLoc.add(element);
              } else {
                othersLoc.add(element);
              }
            }
            nearbyCinemaList = [...preferredLoc, ...othersLoc];
          }
          if (cinemaDTO!.locations != null) {
            allCinemaList = [];
            List<SwaggerLocation> preferredLoc = [];
            List<SwaggerLocation> othersLoc = [];
            for (var element in cinemaDTO!.locations!) {
              if (selectedFavourite.any((e) =>
                  e.id == (element.cinemaCode) &&
                  e.hallGroup == element.hallGroup)) {
                preferredLoc.add(element);
              } else {
                othersLoc.add(element);
              }
            }
            allCinemaList = [...preferredLoc, ...othersLoc];
          }
        }
      });

      setState(() {
        isLoading = false;
      });
    }
  }

  checkPush() {
    if (CinemaListScreen.pushPayload != null) {
      if (CinemaListScreen.pushPayload?["ref"] ==
          Constants.PAYLOAD_SHOWTIME_CINEMA) {
        var content = CinemaListScreen.pushPayload?["refId"] as String;
        final splitData = content.split(",");
        final cinemaId = splitData[0];
        final hallGroup = splitData[1];
        final oprnDate = splitData[2];

        dynamic data;
        for (var element in allCinemaList) {
          if (element.cinemaCode == (int.parse(cinemaId)) &&
              element.hallGroup == hallGroup) {
            data = element;
            break;
          }
        }
        for (var element in nearbyCinemaList) {
          if (element.cinemaCode == (int.parse(cinemaId)) &&
              element.hallGroup == hallGroup) {
            data = element;
            break;
          }
        }

        if (data != null) {
          Navigator.pushNamed(context, AppRoutes.movieShowtimesByCinema,
              arguments: MovieToBuyArgs(
                  selectedCode: '',
                  firstDate: oprnDate,
                  availableDate: [],
                  swaggerLocation: data));
        }
        CinemaListScreen.pushPayload = null;
      }
    }
  }

  Future _determinePosition() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    bool serviceEnabled;
    currentLocation = null;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isLocationService = false;
      return Future.error('Location services are disabled.');
    }
    await AppCache.getbooleanValue(AppCache.ACCESS_LOCATION)
        .then((value) async {
      if (value!) {
        isPermissionCalled = true;

        permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.deniedForever) {
          if (permission == LocationPermission.denied) {
            setState(() {
              AppCache.setBoolean("ACCESS_LOCATION", false);
              isLocationPermission = false;
            });
          } else {
            currentLocation = await Geolocator.getCurrentPosition();
          }
        } else {
          isLocationPermission = false;
        }
      } else {
        setState(() {
          isPermissionCalled = false;
        });
      }
    }).whenComplete(() {
      getCinemaListData();
    });
  }

  callGPSDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title: "",
              message:
                  Utils.getTranslated(context, 'gps_service_failed_message'),
              img: "map-icon.png",
              showButton: true,
              showConfirm: true,
              showCancel: true,
              confirmStr: "OK",
              onCancel: onCancel,
              onConfirm: onConfirm);
        });
  }

  callGPSAlertDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title: "",
              message: Utils.getTranslated(context, 'gps_alert_message'),
              img: "attention-icon.png",
              showButton: true,
              showConfirm: true,
              showCancel: false,
              confirmStr: "OK",
              onConfirm: () {
                Navigator.pop(context);
              });
        });
  }

  onConfirm() async {
    Navigator.pop(context);
    Geolocator.openLocationSettings();
  }

  onCancel() async {
    Navigator.pop(context);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (serviceEnabled) {
      currentLocation = await Geolocator.getCurrentPosition();
    } else {
      callGPSAlertDialog();
    }
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_CINEMA_LIST_SCREEN);

    _determinePosition();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        isOpenSetting ? _determinePosition() : null;

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  getRegionFilter() {
    regionFilterList.clear();
    setState(() {
      for (var region in CinemaRegion.regionList.keys) {
        regionFilterList.add(CustomSelector(
            displayName: region, code: region, isSelected: false));
      }

      isOpenSetting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        key: scaffoldHomeScreenKey,
        onDrawerChanged: (isOpened) => _changeDrawerState(isOpened),
        drawerEnableOpenDragGesture: false,
        drawer: sidebarDrawer(context),
        body: Container(
          padding: const EdgeInsets.only(top: 13),
          width: screenWidth,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: SafeArea(
              child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _header(),
                        _searchBar(screenWidth),
                        _nearbyCinema(screenWidth),
                        _allCinema(screenWidth),
                      ])),
                  !offFilter
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.transparent),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          )),
        ));
  }

  Container _allCinema(double screenWidth) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslated(context, "cinema_listing_text_all"),
            style: AppFont.montSemibold(18, color: Colors.white),
          ),
          const SizedBox(
            height: 32,
          ),
          !isLoading
              ? allCinemaList.isEmpty
                  ? Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Text(
                          Utils.getTranslated(context, "cinema_no_available"),
                          textAlign: TextAlign.center,
                          style: AppFont.poppinsMedium(
                            14,
                            color: AppColor.greyWording(),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox()
              : const SizedBox(),
          if (allCinemaList.isNotEmpty)
            for (var data in allCinemaList)
              SizedBox(
                height: 50,
                child: Column(
                  children: [
                    Row(
                      children: [
                        FavouriteButton(
                          isReload: rearrangeDataList,
                          isFavourite: false,
                          isAurum: false,
                          hallGroup: data.hallGroup ?? '',
                          cinemaId: data.cinemaCode ?? 0,
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                                context, AppRoutes.movieShowtimesByCinema,
                                arguments: MovieToBuyArgs(
                                    selectedCode: '',
                                    firstDate: '',
                                    availableDate: [],
                                    swaggerLocation: data));

                            if (result != null) {
                              setState(() {
                                rearrangeDataList();
                              });
                            }
                          },
                          child: Container(
                            width: screenWidth - 32 - 30 - 8,
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              data.epaymentName ?? "",
                              style:
                                  AppFont.montRegular(14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
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
              )
        ],
      ),
    );
  }

  Container _nearbyCinema(double screenWidth) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslated(context, "cinema_listing_text_nearby"),
            style: AppFont.montSemibold(18, color: Colors.white),
          ),
          const SizedBox(
            height: 32,
          ),
          !isLoading
              ? nearbyCinemaList.isEmpty
                  ? InkWell(
                      onTap: () async {
                        if (isPermissionCalled) {
                          setState(() {
                            isOpenSetting = true;
                          });
                          if (!isLocationPermission && !isLocationService) {
                            Geolocator.openLocationSettings();
                          } else if (!isLocationPermission &&
                              isLocationService) {
                            Geolocator.openAppSettings();
                          } else if (isLocationPermission &&
                              !isLocationService) {
                            Geolocator.openLocationSettings();
                          }
                        } else {
                          loc.Location location = loc.Location();
                          bool _serviceEnabled =
                              await location.serviceEnabled();

                          if (!_serviceEnabled) {
                            await location.requestService();
                          }

                          await Geolocator.requestPermission().then((value) {
                            if (value == LocationPermission.denied) {
                              AppCache.setBoolean("ACCESS_LOCATION", false);
                            } else {
                              AppCache.setBoolean("ACCESS_LOCATION", true);
                            }
                          }).whenComplete(() => _determinePosition());
                        }
                      },
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Column(
                            children: [
                              !isPermissionCalled ||
                                      !isLocationPermission ||
                                      !isLocationService
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 11.0),
                                      child: Image.asset(
                                        Constants.ASSET_IMAGES +
                                            'detect-location-icon.png',
                                        height: 40,
                                        width: 40,
                                      ),
                                    )
                                  : const SizedBox(),
                              Text(
                                nearbyCinemaList.isEmpty &&
                                        isLocationPermission &&
                                        isLocationService &&
                                        isPermissionCalled
                                    ? Utils.getTranslated(
                                        context, "cinema_no_available")
                                    : !isLocationPermission &&
                                            !isLocationService
                                        ? Utils.getTranslated(context,
                                            "cinema_locationservice_disabled")
                                        : isLocationPermission &&
                                                !isLocationService
                                            ? Utils.getTranslated(context,
                                                "cinema_locationservice_disabled")
                                            : Utils.getTranslated(context,
                                                "cinema_locationpermission_disabled"),
                                textAlign: TextAlign.center,
                                style: AppFont.poppinsMedium(
                                  14,
                                  color: AppColor.greyWording(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox()
              : const SizedBox(),
          if (nearbyCinemaList.isNotEmpty)
            for (var data in nearbyCinemaList)
              SizedBox(
                height: 50,
                child: Column(
                  children: [
                    Row(
                      children: [
                        FavouriteButton(
                          isAurum: false,
                          isReload: rearrangeDataList,
                          isFavourite: false,
                          hallGroup: data.hallGroup ?? '',
                          cinemaId: data.cinemaCode ?? 0,
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                                context, AppRoutes.movieShowtimesByCinema,
                                arguments: MovieToBuyArgs(
                                    selectedCode: '',
                                    firstDate: '',
                                    availableDate: [],
                                    swaggerLocation: data));
                            if (result != null) {
                              setState(() {
                                rearrangeDataList();
                              });
                            }
                          },
                          child: Container(
                            width: screenWidth - 32 - 30 - 8,
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              data.epaymentName ?? "",
                              style:
                                  AppFont.montRegular(14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
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
              )
        ],
      ),
    );
  }

  Container _searchBar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColor.appSecondaryBlack()),
      width: screenWidth,
      height: 50,
      padding: const EdgeInsets.only(
        left: 8,
        right: 12,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(children: [
        Image.asset(
          Constants.ASSET_IMAGES + 'search-icon.png',
          height: 30,
          width: 30,
        ),
        Container(
          padding: const EdgeInsets.only(left: 4),
          width: screenWidth - 32 - 60 - 20,
          child: TextField(
            onChanged: (value) {
              setState(() {
                isLoading = true;
              });
              nearbyCinemaList = cinemaDTO!.topFive!;
              allCinemaList = cinemaDTO!.locations!;
              if (nearbyCinemaList.isNotEmpty) {
                List<SwaggerLocation> preferredLoc = [];
                List<SwaggerLocation> othersLoc = [];
                nearbyCinemaList = [];
                for (var element in cinemaDTO!.topFive!) {
                  if (selectedFavourite.any((e) =>
                      e.id == (element.cinemaCode) &&
                      e.hallGroup == element.hallGroup)) {
                    element.epaymentName!
                            .toLowerCase()
                            .contains(value.toLowerCase())
                        ? preferredLoc.add(element)
                        : null;
                  } else {
                    element.epaymentName!
                            .toLowerCase()
                            .contains(value.toLowerCase())
                        ? othersLoc.add(element)
                        : null;
                  }
                }
                nearbyCinemaList = [...preferredLoc, ...othersLoc];
              }
              if (allCinemaList.isNotEmpty) {
                List<SwaggerLocation> preferredLoc = [];
                List<SwaggerLocation> othersLoc = [];
                allCinemaList = [];
                for (var element in cinemaDTO!.locations!) {
                  if (selectedFavourite.any((e) =>
                      e.id == (element.cinemaCode) &&
                      e.hallGroup == element.hallGroup)) {
                    element.epaymentName!
                            .toLowerCase()
                            .contains(value.toLowerCase())
                        ? preferredLoc.add(element)
                        : null;
                  } else {
                    element.epaymentName!
                            .toLowerCase()
                            .contains(value.toLowerCase())
                        ? othersLoc.add(element)
                        : null;
                  }
                }
                allCinemaList = [...preferredLoc, ...othersLoc];
              }
              setState(() {
                isLoading = false;
              });
            },
            textInputAction: TextInputAction.search,
            style: AppFont.montRegular(14, color: Colors.white),
            controller: searchController,
            maxLines: 1,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: Utils.getTranslated(
                    context, 'cinema_listing_searchbar_hint_text'),
                hintStyle:
                    AppFont.montRegular(14, color: AppColor.greyWording())),
          ),
        ),
        regionFilterList.isNotEmpty
            ? InkWell(
                onTap: () async {
                  offFilter = false;
                  final result = await filterPopUp(context, regionFilterList);

                  if (result == null || result != null) {
                    setState(() {
                      offFilter = true;
                    });
                  }
                },
                child: Image.asset(
                  Constants.ASSET_IMAGES + 'New_filter_icon.png',
                  height: 30,
                  width: 30,
                ),
              )
            : const SizedBox(),
      ]),
    );
  }

  filterResetState() {
    preferredRegionList.clear();
    cinemaDisplayData = cinemaListData ?? [];

    for (var element in regionFilterList) {
      element.isSelected = false;
    }

    setState(() {});
  }

  filterShowTimesFunction() {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    preferredRegionList.clear();
    for (var element in regionFilterList) {
      element.isSelected!
          ? !preferredRegionList.contains(element.code!)
              ? preferredRegionList.add(element.code!)
              : null
          : null;
    }

    if (preferredRegionList.isNotEmpty) {
      if (cinemaDTO != null) {
        if (cinemaDTO!.topFive != null && cinemaDTO!.topFive!.isNotEmpty) {
          nearbyCinemaList = [];

          for (var data in cinemaDTO!.topFive!) {
            if (preferredRegionList.contains(data.region) &&
                data.epaymentName!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase())) {
              nearbyCinemaList.add(data);
            }
          }
        }
        if (cinemaDTO!.locations != null && cinemaDTO!.locations!.isNotEmpty) {
          allCinemaList = [];
          for (var data in cinemaDTO!.locations!) {
            if (preferredRegionList.contains(data.region) &&
                data.epaymentName!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase())) {
              allCinemaList.add(data);
            }
          }
        }
      }
    } else {
      nearbyCinemaList = cinemaDTO!.topFive!
          .where((element) => element.epaymentName!
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
      allCinemaList = cinemaDTO!.locations!
          .where((element) => element.epaymentName!
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {});
    EasyLoading.dismiss();
  }

  filterPopUp(BuildContext ctx, List<CustomSelector> reg) {
    List<CustomSelector> tempReg = [];

    for (var e in reg) {
      tempReg.add(CustomSelector(
          code: e.code, displayName: e.displayName, isSelected: e.isSelected));
    }

    return showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.white.withOpacity(0.2),
        context: ctx,
        builder: (c) => SingleChildScrollView(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewPadding.bottom + 20),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                            child: Text(
                          Utils.getTranslated(context, "filters_btn"),
                          style: AppFont.montMedium(18, color: Colors.white),
                        )),
                        width: MediaQuery.of(context).size.width,
                      ),
                      if (reg.isNotEmpty)
                        filterBtmModalRegionUI(setState, tempReg, context),
                      Container(
                        margin: const EdgeInsets.only(top: 32, bottom: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(c).pop(false),
                              child: Container(
                                height: 50,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 24,
                                decoration: BoxDecoration(
                                  color: AppColor.lightGrey(),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    Utils.getTranslated(context, "cancel_btn"),
                                    style: AppFont.montRegular(14,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                for (var e in tempReg) {
                                  e.isSelected!
                                      ? reg
                                          .firstWhere((element) =>
                                              element.code == e.code)
                                          .isSelected = true
                                      : reg
                                          .firstWhere((element) =>
                                              element.code == e.code)
                                          .isSelected = false;
                                }
                                filterShowTimesFunction();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 50,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 24,
                                decoration: BoxDecoration(
                                  color: AppColor.yellow(),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    Utils.getTranslated(
                                        context, "continue_btn"),
                                    style: AppFont.montSemibold(14,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget filterBtmModalRegionUI(
      StateSetter setState, List<CustomSelector> data, BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.transparent,
            child: Text(
              Utils.getTranslated(context, "regions"),
              style: AppFont.montRegular(14, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10),
            child: Wrap(
              runSpacing: 12,
              spacing: 12,
              children: data.map((e) => regFilterItem(context, e)).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget regFilterItem(BuildContext ctx, CustomSelector item) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        onTap: (() {
          item.isSelected = !item.isSelected!;

          setState(() {});
        }),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        item.isSelected! ? AppColor.appYellow() : Colors.white),
                color: item.isSelected! ? AppColor.appYellow() : Colors.white),
            child: Text(
              '${item.displayName}',
              textAlign: TextAlign.center,
              style: AppFont.poppinsMedium(10, color: Colors.black),
            )),
      );
    });
  }

  Widget _header() {
    return Container(
        padding: const EdgeInsets.only(left: 13, right: 13, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    scaffoldHomeScreenKey.currentState?.openDrawer();
                  });
                },
                child: Image.asset(
                  Constants.ASSET_IMAGES + 'menu-icon.png',
                  height: 30,
                  width: 30,
                )),
            Text(Utils.getTranslated(context, "tab_cinema"),
                style: AppFont.montBold(18, color: Colors.white)),
            InkWell(
                onTap: () {
                  setState(() {
                    Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeBase(),
                        ));
                  });
                },
                child:
                    Image.asset(Constants.ASSET_IMAGES + 'New_home_icon.png'))
          ],
        ));
  }

  void _changeDrawerState(bool isOpened) {
    if (isOpened) {
      Provider.of<DrawerState>(context, listen: false).setState(true);
    } else {
      Provider.of<DrawerState>(context, listen: false).setState(false);
    }
  }
}
