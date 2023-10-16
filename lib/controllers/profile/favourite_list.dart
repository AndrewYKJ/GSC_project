import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:gsc_app/routes/approutes.dart';

import '../../const/analytics_constant.dart';
import '../../dio/api/cinema_api.dart';
import '../../models/json/as_dynamic_field_model.dart';
import '../../models/json/as_gscoin_transaction_model.dart';
import '../../models/json/as_list_favourite_cinema_model.dart';
import '../../models/json/nearby_location_model.dart';
import '../../models/json/user_model.dart';

class FavouriteCinemaList extends StatefulWidget {
  const FavouriteCinemaList({Key? key}) : super(key: key);

  @override
  State<FavouriteCinemaList> createState() => _FavouriteCinemaListState();
}

class _FavouriteCinemaListState extends State<FavouriteCinemaList> {
  List<TransactionList>? transactionLists;
  bool isSelectAll = false;
  int countCheckedMsg = 0;
  bool isLoading = true;

  NearbyLocationBody? cinemaDTO;
  List<SwaggerLocation> dataList = [];
  List<CheckBoxSwaggerLocation> checkBoxList = [];
  List<AS_FAVOURITE_CINEMA> rawData = [];
  Future<NearbyLocationBody> getNearbyLocation(
      BuildContext context, String? long, String? lat) async {
    CinemaApi showtimesApi = CinemaApi(context);
    return showtimesApi.getNearbyLocation(long, lat);
  }

  Future<UserModel> getUpdateFavCinema(
      BuildContext context, List<AS_DYNAMIC_MODEL> data) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.updateCinemaFavourite(
      AppCache.me!.MemberLists!.first.MemberID!,
      data,
    );
  }

  getCinemaListData() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
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
          AppCache.allLocationList = value.locations;
          getFavDataList();
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

  getFavDataList() {
    dataList = [];
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any((element) =>
            element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
          rawData = Utils.setASFavCinemaToList(AppCache
              .me!.MemberLists!.first.DynamicFieldLists!
              .firstWhere((element) =>
                  element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
              .colValue);

          for (var raw in rawData) {
            cinemaDTO!.locations!.any((element) =>
                    element.cinemaCode == raw.id &&
                    element.hallGroup == raw.hallGroup)
                ? dataList.add(cinemaDTO!.locations!.firstWhere((element) =>
                    element.cinemaCode == raw.id &&
                    element.hallGroup == raw.hallGroup))
                : null;
          }
        }
      }
    }
  }

  getUpdateProfile(int code, String group) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    List<AS_FAVOURITE_CINEMA> tempData = [];
    if (code == 0) {
      for (var element in checkBoxList) {
        !element.isChecked!
            ? tempData.add(AS_FAVOURITE_CINEMA(
                element.location!.cinemaCode!, element.location!.hallGroup!))
            : null;
      }
    } else {
      dataList.removeWhere((element) =>
          element.cinemaCode == code && element.hallGroup == group);

      for (var element in dataList) {
        tempData
            .add(AS_FAVOURITE_CINEMA(element.cinemaCode!, element.hallGroup!));
      }
    }

    await getUpdateFavCinema(context, [
      AS_DYNAMIC_MODEL(
          colValue: tempData.join(','),
          name: Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE,
          type: 'PlainText')
    ]).then((value) {
      if (value.ReturnStatus == 1) {
        setState(() {
          value.MemberLists != null
              ? value.MemberLists!.first.DynamicFieldLists != null
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
                  : AppCache.me!.MemberLists!.first.DynamicFieldLists!
                      .firstWhere((element) =>
                          element.name ==
                          Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                      .colValue = null
              : null;
        });
      } else {
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            Utils.getTranslated(context, "general_error"),
            true,
            "failed-icon.png",
            false,
            false, () {
          Navigator.pop(context);
        });
      }
    }, onError: (error) {
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          Utils.getTranslated(context, "general_error"),
          true,
          "failed-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
    }).whenComplete(
      () {
        EasyLoading.dismiss();
        setState(() {
          isSelectAll = false;
          getFavDataList();
        });
      },
    );
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_FAVOURITE_CINEMA_LIST_SCREEN);
    AppCache.allLocationList != null
        ? {
            cinemaDTO = NearbyLocationBody(locations: AppCache.allLocationList),
            getFavDataList()
          }
        : getCinemaListData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _submitBtn(),
        backgroundColor: AppColor.appSecondaryBlack(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 0, bottom: 24),
            physics: const ClampingScrollPhysics(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  favouriteListAppBar(context),
                  dataList.isNotEmpty
                      ? !isSelectAll
                          ? SlidableAutoCloseBehavior(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: dataList
                                    .map((e) => favouriteCinemaItem(context, e))
                                    .toList(),
                              ),
                            )
                          : Column(
                              children: checkBoxList
                                  .map((e) => favouriteCinemaItemWithCheckbox(
                                      context, e))
                                  .toList(),
                            )
                      : Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Image.asset(
                                  'assets/images/no-records-icon.png',
                                ),
                                Text(
                                    Utils.getTranslated(
                                        context, 'no_record_found'),
                                    style: AppFont.montRegular(16,
                                        color: AppColor.dividerColor()))
                              ])),
                        ),
                  !isSelectAll ? addCinemaBtn(context) : const SizedBox(),
                ]),
          ),
        ));
  }

  Widget addCinemaBtn(BuildContext context) {
    return InkWell(
      onTap: () async {
        cinemaDTO!.locations != null
            ? await Navigator.pushNamed(
                    context, AppRoutes.addFavouriteCinemaRoute,
                    arguments: cinemaDTO!.locations!)
                .then((value) {
                setState(() {
                  getFavDataList();
                });
              })
            : null;
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        width: MediaQuery.of(context).size.width,
        height: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + 'plus-icon.png',
              width: 16,
              height: 16,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              Utils.getTranslated(context, "add_btn"),
              style: AppFont.montRegular(14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget favouriteCinemaItem(BuildContext context, SwaggerLocation data) {
    return Column(
      children: [
        Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.2,
            motion: const BehindMotion(),
            children: [
              CustomSlidableAction(
                autoClose: false,
                padding: const EdgeInsets.all(15),
                onPressed: (context) {},
                backgroundColor: AppColor.msgDeleteActionBackground(),
                foregroundColor: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    getUpdateProfile(data.cinemaCode!, data.hallGroup!);
                  },
                  child: Image.asset(
                    Constants.ASSET_IMAGES + 'delete-icon.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 25, bottom: 25),
                decoration: const BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.epaymentName ?? '',
                            style: AppFont.montMedium(14, color: Colors.white),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            data.region ?? '',
                            style: AppFont.poppinsRegular(12,
                                color: AppColor.iconGrey()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 1,
            color: AppColor.dividerColor(),
          ),
        ),
      ],
    );
  }

  Widget favouriteCinemaItemWithCheckbox(
      BuildContext context, CheckBoxSwaggerLocation data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                ),
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  checkColor: Colors.black,
                  activeColor: AppColor.appYellow(),
                  value: data.isChecked,
                  onChanged: (value) {
                    setState(() {
                      data.isChecked = value!;

                      if (!data.isChecked!) {
                        countCheckedMsg -= 1;
                      } else {
                        countCheckedMsg += 1;
                      }
                    });
                  },
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.location!.epaymentName ?? '',
                        style: AppFont.montMedium(14, color: Colors.white),
                      ),
                      Text(
                        data.location!.region ?? '',
                        style: AppFont.poppinsRegular(12,
                            color: AppColor.iconGrey()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: AppColor.dividerColor(),
            ),
          )
        ],
      ),
    );
  }

  Widget favouriteListAppBar(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top + 16, bottom: 16),
        color: AppColor.appSecondaryBlack(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(true),
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  Constants.ASSET_IMAGES + 'white-left-icon.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 36),
                child: Center(
                  child: Text(
                    Utils.getTranslated(context, "profile_account_fav"),
                    style: AppFont.montRegular(18, color: Colors.white),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (dataList.isNotEmpty) {
                    checkBoxList.clear();
                    isSelectAll = !isSelectAll;

                    if (isSelectAll) {
                      for (var element in dataList) {
                        checkBoxList.add(CheckBoxSwaggerLocation(
                            isChecked: true, location: element));
                      }
                      countCheckedMsg = checkBoxList.length;
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 16),
                width: 74,
                decoration: BoxDecoration(
                    color: AppColor.lightGrey(),
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text(
                    !isSelectAll
                        ? Utils.getTranslated(context, "select_all_btn")
                        : Utils.getTranslated(context, "cancel_btn"),
                    style: AppFont.montRegular(10, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget _submitBtn() {
    if (isSelectAll) {
      return BottomAppBar(
        color: Colors.black,
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 13),
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: countCheckedMsg > 0
                    ? AppColor.msgDeleteActionBackground()
                    : AppColor.soldOutRed()),
            onPressed: () async {
              countCheckedMsg > 0
                  ? setState(() {
                      getUpdateProfile(0, '');
                    })
                  : null;
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                Utils.getTranslated(context, "message_delete_btn")
                    .replaceAll('<number>', '$countCheckedMsg'),
                style: TextStyle(
                    fontSize: 14,
                    color: countCheckedMsg > 0
                        ? Colors.white
                        : AppColor.greyWording()),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
