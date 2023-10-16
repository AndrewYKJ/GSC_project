import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/rewards_center/rewards_center_details.dart';
import 'package:gsc_app/dio/api/as_member.api.dart';
import 'package:gsc_app/dio/api/as_messages_api.dart';
import 'package:gsc_app/dio/api/as_vouchers_api.dart';
import 'package:gsc_app/models/json/as_messages_model.dart';
import 'package:gsc_app/models/json/as_vouchers_model.dart';
import 'package:gsc_app/models/json/rewards_center_response.dart';
import 'package:gsc_app/models/json/rewards_voucher_type_list.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../dio/api/as_auth_api.dart';
import '../../main.dart';
import '../../models/json/as_qr_token_model.dart';
import '../../models/json/as_update_device_model.dart';
import '../../models/json/user_model.dart';
import '../../widgets/custom_dialog.dart';
import '../tab/homebase.dart';

class ProfileScreen extends StatefulWidget {
  final bool isLogin;
  final VoidCallback isLogoutSuccess;
  final VoidCallback isLoginSuccess;

  const ProfileScreen(
      {Key? key,
      required this.isLogin,
      required this.isLogoutSuccess,
      required this.isLoginSuccess})
      : super(key: key);

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> with RouteAware {
  var loginProfileItems = {
    "profile_section_value": [
      "profile_value_ticket",
      "profile_value_rewards",
      // "profile_value_referral"
    ],
    "profile_section_rewards": [],
    "profile_section_account": [
      "profile_account_fav",
      "profile_account_message",
      // "profile_account_language"
    ],
    "profile_section_general": [
      "profile_general_help",
      "profile_general_faq",
      "profile_general_settings",
      "profile_general_contact",
      "profile_general_terms&conditions",
      "profile_general_privacy",
      "profile_general_abac",
      "profile_general_whistle"
    ]
  };
  var withoutLoginProfileItems = {
    "profile_section_value": ["profile_value_ticket", "profile_value_rewards"],
    "profile_section_general": [
      "profile_general_help",
      "profile_general_faq",
      "profile_general_contact",
      "profile_general_terms&conditions",
      "profile_general_privacy",
      "profile_general_abac",
      "profile_general_whistle"
    ]
  };

  String appVersion = '';
  List<RewardsVoucherTypeList>? rewards;
  List<RewardsVoucherTypeList> fullRewards = [];
  List<RewardsVoucherTypeList> data = [];
  VoucherCardInfoDTO? cardDetails;
  int inappMessageCount = 0;
  int myRewardsCount = 0;
  String? deviceUUID;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_PROFILE_SCREEN);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    getAllInfo();
    _checkPlatform();

    if (widget.isLogin && AppCache.me != null) {
      getFullRewardListing();
      if (AppCache.qrCode == null) {
        getMemberToken(AppCache.me!.CardLists!.first.CardNo!);
      }
      getCardEnquiry();
    }
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (mounted) {
      if (widget.isLogin == false) {
        _checkLoginState();
      }
    }
  }

  Future<UserModel> getProfile(
      BuildContext context, String mobile, String email, String member) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getProfile(member, mobile, email);
  }

  Future<VouchersDTO> getCard(BuildContext context, String cardNo) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getCard(cardNo);
  }

  Future<UpdateDeviceDTO> updateDevice(
      BuildContext context,
      String member,
      String appVersion,
      String deviceUUID,
      String deviceName,
      String deviceModel,
      String deviceVersion) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.updateMemberDevice(member, appVersion, deviceUUID,
        AppCache.fcmToken!, deviceName, deviceModel, deviceVersion);
  }

  Future<QrTokenDTO> _getQrToken(BuildContext context, String cardNo) async {
    AsMemberApi asMemberApi = AsMemberApi(context);
    return asMemberApi.memberQrToken(
      context,
      cardNo,
    );
  }

  updateDeviceInfo() async {
    await AppCache.getStringValue(AppCache.DEVICE_INFO).then((value) async {
      var dataMap = json.decode(value);

      var appVersion = dataMap["appVersion"];
      var deviceUUID = dataMap["deviceUUID"];
      var deviceModel = dataMap["deviceModel"];
      var deviceName = dataMap["deviceName"];
      var deviceVersion = dataMap["deviceVersion"];
      await updateDevice(context, AppCache.me!.MemberLists!.first.MemberID!,
          appVersion, deviceUUID, deviceName, deviceModel, deviceVersion);
    });
  }

  getUserProfile(String member) async {
    await getProfile(context, "", "", member).then((value) {
      if (value.ReturnStatus == 1) {
        if (value.CardLists != null) {
          if (value.CardLists!.isEmpty) {
            Utils.printInfo("no member list");

            AppCache.removeValues(context);
          } else {
            setState(() {
              AppCache.me = value;
              updateDeviceInfo();
            });
          }
        } else {
          AppCache.removeValues(context);
        }
      } else {
        AppCache.removeValues(context);
      }
    }, onError: (error) {
      EasyLoading.dismiss();
      Utils.printInfo('GET USER PROFILE ERROR: $error');
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "info_title"),
          error ?? Utils.getTranslated(context, "general_error"),
          true,
          false, () {
        Navigator.pop(context);
      });
      Utils.printInfo("LOGIN ERROR: $error");
    }).whenComplete(() => getCardEnquiry());
  }

  getCardEnquiry() async {
    await getCard(context, AppCache.me!.CardLists!.first.CardNo!).then((value) {
      if (value.returnStatus == 1) {
        if (value.voucherCardInfoDTO != null) {
          setState(() {
            cardDetails = value.voucherCardInfoDTO;
            //  Utils.printWrapped(jsonEncode(cardDetails));
          });
        } else {}
      } else {}
    }, onError: (error) {
      EasyLoading.dismiss();
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "login_error_title"),
          error.toString() != ''
              ? error.toString()
              : Utils.getTranslated(context, "general_error"),
          true,
          "failed-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
      Utils.printInfo("LOGIN ERROR: $error");
    });
  }

  Future<RewardsCenterResponse> getRewardListing(BuildContext context,
      bool includeExpire, int pageNo, int pageCount) async {
    AsMemberApi asMemberApi = AsMemberApi(context);
    return asMemberApi.getRewardsCenterListing(
        context, includeExpire, pageNo, pageCount);
  }

  getFullRewardListing() async {
    rewards = [];
    data = [];
    fullRewards = [];
    EasyLoading.show();
    await getRewardListing(context, false, 1, 10).then((value) {
      // clarify this
      if (value.ReturnStatus == 1) {
        setState(() {
          if (value.VoucherTypeLists != null) {
            for (var itm in value.VoucherTypeLists!) {
              if (itm.IsRedeemable == true) {
                data.add(itm);
              }
            }
            rewards = data;

            fullRewards = value.VoucherTypeLists ?? [];
          }
        });
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.ReturnMessage != null
                ? value.ReturnMessage!
                : Utils.getTranslated(context, "general_error"),
            true,
            null, () {
          Navigator.pop(context);
        });
      }
    }, onError: (error) {
      EasyLoading.dismiss();
      Utils.printInfo('GET REWARD CENTER LISTING ERROR: $error');
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "info_title"),
          error ?? Utils.getTranslated(context, "general_error").toString(),
          true,
          null, () {
        Navigator.pop(context);
      });
    }).whenComplete(() {
      callGetInAppMessageList(context, Constants.MessageAppName,
          AppCache.me?.MemberLists?.first.MemberID ?? '');
    });
  }

  getMemberToken(String cardNo) async {
    await _getQrToken(context, cardNo).then((value) {
      if (value.returnStatus != 1) {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "info_title"),
            value.returnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          if (value.token != null) {
            AppCache.qrCode = value.token ?? "";
          }
        });
      }
    });
  }

  Future<void> callRefreshData(BuildContext ctx, String member) async {
    if (widget.isLogin) {
      await getUserProfile(member);
      getFullRewardListing();
    }
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken) {
      setState(() {
        widget.isLoginSuccess();
        getFullRewardListing();
        if (AppCache.me != null) {
          getMemberToken(AppCache.me!.CardLists!.first.CardNo!);
        }
        getCardEnquiry();
      });
    }
  }

  Future<void> _checkPlatform() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.version.isNotEmpty) {
      appVersion = "V " + packageInfo.version;
    }
  }

  Future getAllInfo() async {
    await AppCache.getStringValue(AppCache.DEVICE_INFO).then((value) {
      var dataMap = json.decode(value);

      deviceUUID = dataMap["deviceUUID"];
    });

    setState(() {});
  }

  Future<InAppMessageDTO> getInAppMessagesList(
      BuildContext context, String appName, String memberId) async {
    AsMessagesApi asMessagesApi = AsMessagesApi(context);
    return asMessagesApi.getInAppMessagesList(
        context, appName, memberId, deviceUUID ?? '', 1, 20);
  }

  callGetInAppMessageList(
      BuildContext context, String appName, String memberId) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    setState(() {
      inappMessageCount = 0;
    });
    await getInAppMessagesList(context, appName, memberId).then((value) {
      if (value.returnStatus == 1) {
        if (value.inAppMessageInfoList != null &&
            value.inAppMessageInfoList!.isNotEmpty) {
          for (var element in value.inAppMessageInfoList!) {
            !element.readStatus! ? inappMessageCount += 1 : null;
          }
        }
      }
    }).onError((error, stackTrace) {
      Utils.printInfo('GET IN APP MESSAGES ERROR: $error');
    }).whenComplete(() {
      callGetVouchersList(context);
    });
  }

  Future<VouchersDTO> getVouchersList(BuildContext context) async {
    AsVouchersApi asVouchersApi = AsVouchersApi(context);
    return asVouchersApi.getVouchersList(context,
        AppCache.me!.CardLists!.first.CardNo!, 1, 20, true, true, true, 10, 1);
  }

  callGetVouchersList(BuildContext context) async {
    await getVouchersList(context).then((value) {
      if (value.returnStatus == 1) {
        myRewardsCount = value.totalActiveVoucherCount ?? 0;
      }
    }).onError((error, stackTrace) {
      Utils.printInfo('GET VOUCHER LIST ERROR: $error');
    }).whenComplete(() {
      setState(() {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      });
    });
  }

  void _goToQr() {
    Navigator.pushNamed(context, AppRoutes.qrMemberRoute, arguments: [true])
        .then((value) {
      if (value != null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = (screenWidth / 2) - 50;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      backgroundColor: Colors.black,
                      flexibleSpace: Center(
                        child: Text(
                          Utils.getTranslated(context, "profile_header"),
                          textAlign: TextAlign.center,
                          style: AppFont.montBold(18, color: Colors.white),
                        ),
                      ),
                      automaticallyImplyLeading: false,
                      actions: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            const HomeBase(),
                                      ));
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: Image.asset(
                                  Constants.ASSET_IMAGES + "New_home_icon.png",
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ],
              body: RefreshIndicator(
                backgroundColor: Colors.transparent,
                color: AppColor.appYellow(),
                onRefresh: () => callRefreshData(
                    context, AppCache.me?.MemberLists?.first.MemberID ?? ""),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: (widget.isLogin && AppCache.me != null)
                        ? loginProfileItems.length + 2
                        : withoutLoginProfileItems.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return (widget.isLogin && AppCache.me != null)
                            ? _headerView(context)
                            : _loginHeaderView(context);
                      } else if ((widget.isLogin && AppCache.me != null)
                          ? index == loginProfileItems.length + 1
                          : index == withoutLoginProfileItems.length + 1) {
                        return Container(
                            width: screenWidth,
                            color: AppColor.backgroundBlack(),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    appVersion,
                                    style: AppFont.montRegular(14,
                                        color: AppColor.lightGrey()),
                                  ),
                                ),
                                widget.isLogin && AppCache.me != null
                                    ? const SizedBox(
                                        height: 16,
                                      )
                                    : const SizedBox(
                                        height: 50,
                                      ),
                                if (widget.isLogin && AppCache.me != null)
                                  TextButton(
                                    onPressed: () async {
                                      var result = await showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext context) {
                                            return CustomDialogBox(
                                              title: Utils.getTranslated(
                                                  context, "logout_content"),
                                              message: "",
                                              img: "logout-icon.png",
                                              showButton: true,
                                              showConfirm: true,
                                              showCancel: true,
                                              contentWidth: 300,
                                              confirmStr: "OK",
                                              onCancel: () {
                                                Navigator.of(context).pop();
                                              },
                                              onConfirm: () async {
                                                myRewardsCount = 0;
                                                inappMessageCount = 0;
                                                cardDetails = null;
                                                AppCache.removeValues(context);
                                                Navigator.of(context).pop(true);
                                              },
                                            );
                                          });

                                      if (result != null) {
                                        if (result) {
                                          widget.isLogoutSuccess();
                                        }
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 50),
                                      primary: AppColor.logoutRed(),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                    ),
                                    child: Text(
                                      Utils.getTranslated(
                                          context, "logout_btn"),
                                      style: AppFont.poppinsRegular(14,
                                          color: AppColor.logoutRed()),
                                    ),
                                  ),
                                if (widget.isLogin && AppCache.me != null)
                                  const SizedBox(
                                    height: 50,
                                  ),
                              ],
                            ));
                      } else {
                        index -= 1;
                        String key = widget.isLogin && AppCache.me != null
                            ? loginProfileItems.keys.elementAt(index)
                            : withoutLoginProfileItems.keys.elementAt(index);
                        var items = widget.isLogin && AppCache.me != null
                            ? loginProfileItems[key]?.toList()
                            : withoutLoginProfileItems[key]?.toList();
                        if (items != null) {
                          if (items.isNotEmpty) {
                            return Container(
                              width: screenWidth,
                              decoration: widget.isLogin && AppCache.me != null
                                  ? BoxDecoration(
                                      color: AppColor.appSecondaryBlack(),
                                      borderRadius: index == 0
                                          ? const BorderRadius.only(
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16))
                                          : index == 2
                                              ? const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16))
                                              : BorderRadius.circular(0))
                                  : BoxDecoration(
                                      color: AppColor.appSecondaryBlack(),
                                    ),
                              child: Container(
                                  width: screenWidth,
                                  color: Colors.transparent,
                                  child: Container(
                                      margin: index == 0
                                          ? const EdgeInsets.fromLTRB(
                                              20, 0, 20, 20)
                                          : const EdgeInsets.symmetric(
                                              vertical: 25, horizontal: 20),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 20, 10),
                                      width: screenWidth,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(children: [
                                        _sectionView(context, screenWidth,
                                            Utils.getTranslated(context, key)),
                                        for (var i = 0; i < items.length; i++)
                                          _profileItem(
                                              context,
                                              screenWidth,
                                              items[i],
                                              i == items.length - 1
                                                  ? false
                                                  : true,
                                              null),
                                      ]))),
                            );
                          } else {
                            if (widget.isLogin &&
                                key == 'profile_section_rewards' &&
                                rewards != null &&
                                rewards!.isNotEmpty) {
                              return Container(
                                color: Colors.black,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                width: screenWidth,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          Utils.getTranslated(context,
                                              "profile_section_rewards"),
                                          style: AppFont.montMedium(16,
                                              color: Colors.white),
                                        ),
                                        TextButton(
                                            onPressed: () async {
                                              await Navigator.pushNamed(
                                                      context,
                                                      AppRoutes
                                                          .rewardsCenterListingRoute)
                                                  .then((value) {
                                                if (value != null) {
                                                  if (value == true) {
                                                    if (value == true) {
                                                      Utils.printInfo(
                                                          "IS REDEEM TRUE");
                                                      callRefreshData(
                                                          context,
                                                          AppCache
                                                                  .me
                                                                  ?.MemberLists
                                                                  ?.first
                                                                  .MemberID ??
                                                              "");
                                                    }
                                                  }
                                                }
                                              });
                                            },
                                            child: Text(
                                              Utils.getTranslated(
                                                  context, "view_more"),
                                              style: AppFont.montRegular(12,
                                                  color: AppColor.appYellow(),
                                                  decoration:
                                                      TextDecoration.underline),
                                            ))
                                      ],
                                    ),
                                    SizedBox(
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: rewards!.length >= 4
                                            ? 4
                                            : rewards?.length,
                                        itemBuilder: (context, index) {
                                          return _rewardItem(context,
                                              screenWidth, rewards?[index]);
                                        },
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 10,
                                                childAspectRatio: (itemWidth /
                                                    180)), //itemWidth / itemHeight
                                      ),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              Container(
                                  color: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  width: screenWidth);
                            }
                          }
                        }
                        return Container();
                      }
                    }),
              ))),
    );
  }

  Widget _headerView(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        width: screenWidth,
        height: 240,
        color: Colors.black,
        child: Stack(
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + 'profile-base.png',
              width: screenWidth,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
                width: screenWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    _memberCardView(context, screenWidth),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ))
          ],
        ));
  }

  Widget _loginHeaderView(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        width: screenWidth,
        height: 260,
        color: Colors.black,
        child: Stack(
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + 'profile-base.png',
              width: screenWidth,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Constants.ASSET_IMAGES + 'placeholder-icon.png',
                      width: 110,
                      height: 110,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.black,
                          backgroundColor: AppColor.appYellow(),
                          textStyle:
                              AppFont.montSemibold(14, color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                        onPressed: () async {
                          var res = await Navigator.pushNamed(
                              context, AppRoutes.loginRoute);
                          if (res != null) {
                            if (res == true) {
                              Utils.printInfo("LOGIN SUCCESS:");
                              setState(() {
                                widget.isLoginSuccess();
                              });
                            }
                          }
                        },
                        child: Text(
                          Utils.getTranslated(context, "login_btn")
                              .toUpperCase(),
                          style: AppFont.poppinsSemibold(14),
                        ))
                  ],
                ))
          ],
        ));
  }

  Widget _sectionView(BuildContext context, double screenWidth, String item) {
    return SizedBox(
      width: screenWidth,
      height: 30,
      child: Text(
        item,
        style: AppFont.montMedium(16, color: Colors.white),
      ),
    );
  }

  Widget _profileItem(BuildContext context, double screenWidth, String title,
      bool showDivider, String? bubbleCount) {
    double bubbleSize = 30;
    if (title == 'profile_account_message') {
      bubbleCount = inappMessageCount > 0 ? "" : null;
      bubbleSize = 10;
    } else if (title == 'profile_value_rewards') {
      bubbleCount = widget.isLogin
          ? myRewardsCount > 0
              ? "$myRewardsCount"
              : null
          : null;
    }
    return InkWell(
      onTap: () {
        if (title == 'profile_value_ticket') {
          Navigator.pushNamed(context, AppRoutes.myTicketRoute);
        }

        if (title == 'profile_general_settings') {
          Navigator.pushNamed(context, AppRoutes.settingsRoute,
              arguments: widget.isLogoutSuccess);
        }

        if (title == 'profile_account_message') {
          Navigator.pushNamed(context, AppRoutes.messageCenterRoute)
              .then((value) {
            callGetInAppMessageList(context, Constants.MessageAppName,
                AppCache.me?.MemberLists?.first.MemberID ?? '');
          });
        }
        if (title == 'profile_account_fav') {
          Navigator.pushNamed(context, AppRoutes.favouriteCinemaRoute);
        }

        if (title == 'profile_general_help') {
          Utils.launchBrowser(Constants.GSC_HLB_CC);
        }

        if (title == 'profile_general_faq') {
          Utils.launchBrowser(Constants.GSC_FAQ);
        }

        if (title == 'profile_general_contact') {
          Utils.launchBrowser(Constants.GSC_CONTACT_US);
        }
        if (title == 'profile_general_terms&conditions') {
          Utils.launchBrowser(Constants.TERMS_CONDITION);
        }
        if (title == 'profile_general_privacy') {
          Utils.launchBrowser(Constants.PRIVACY_POLICY);
        }

        if (title == 'profile_general_abac') {
          Utils.launchBrowser(Constants.GSC_ABAC);
        }

        if (title == 'profile_general_whistle') {
          Utils.launchBrowser(Constants.GSC_WHISTLEBLOWING);
        }

        if (title == 'profile_value_rewards') {
          Navigator.pushNamed(context, AppRoutes.myRewardsRoute,
              arguments: fullRewards);
        }
      },
      child: SizedBox(
          width: screenWidth,
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Utils.getTranslated(context, title),
                    style: AppFont.poppinsRegular(14,
                        color: AppColor.greyWording()),
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        if (bubbleCount != null)
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(2),
                            width: bubbleSize,
                            height: bubbleSize,
                            decoration: BoxDecoration(
                                color: AppColor.appYellow(),
                                borderRadius: BorderRadius.circular(100)),
                            child: Center(
                              child: Text(
                                bubbleCount,
                                style: AppFont.poppinsRegular(14,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        Image.asset(
                          Constants.ASSET_IMAGES + 'right-simple-arrow.png',
                          width: 20,
                          height: 20,
                        )
                      ],
                    ),
                  )
                ],
              ),
              if (showDivider)
                Container(
                  width: screenWidth - 30,
                  height: 1,
                  color: AppColor.dividerColor(),
                )
            ],
          )),
    );
  }

  Widget _memberCardView(BuildContext context, double screenWidth) {
    return InkWell(
        onTap: () {
          // _goToQr();
        },
        child: Container(
          height: 190,
          width: screenWidth - 32,
          decoration: BoxDecoration(
            color: AppColor.appYellow(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.membercardYellowOrange(),
                              AppColor.membercardYellowLight(),
                              AppColor.membercardYellowOrange()
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12))),
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  child: Image.asset(
                                Constants.ASSET_IMAGES + 'GSC rewards_img.png',
                                height: 20,
                                width: 87,
                                fit: BoxFit.fitWidth,
                              )),
                              InkWell(
                                  onTap: () async {
                                    final result = await Navigator.pushNamed(
                                        context, AppRoutes.editProfileRoute);
                                    if (result is bool && result) {
                                      setState(() {});
                                    }
                                  },
                                  child: SizedBox(
                                    height: 30,
                                    width: 50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                          size: 12,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          Utils.getTranslated(
                                              context, "edit_profile"),
                                          style: AppFont.montRegular(10,
                                              color: Colors.black,
                                              decoration:
                                                  TextDecoration.underline),
                                        )
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 15),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                _memberCardUserInfo(context, screenWidth),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  width: screenWidth - 50,
                                  color: Colors.black,
                                  height: 1,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            AppRoutes.gsCoinsTransactionRoute);
                                      },
                                      child: _memberCoinView(context),
                                    ),
                                    Container(
                                      width: 1,
                                      color: Colors.black,
                                      height: 65,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, AppRoutes.myRewardsRoute,
                                            arguments: fullRewards);
                                      },
                                      child: _memberRewardsView(context),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ))),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 6, 5, 15),
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.settingsRoute,
                                arguments: widget.isLogoutSuccess);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(top: 3),
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, 'profile_general_settings'),
                                  style: AppFont.montRegular(10,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline),
                                )
                              ],
                            ),
                          )),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            Constants.ASSET_IMAGES + 'zoom-icon.png',
                            width: 10,
                            height: 10,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            onTap: () {
                              _goToQr();
                            },
                            child: Container(
                                height: 65,
                                width: 65,
                                color: Colors.white,
                                child: QrImage(
                                    padding: const EdgeInsets.all(5),
                                    data: AppCache.qrCode ??
                                        (AppCache.me?.MemberLists?.first
                                                .MobileNo ??
                                            ""))),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _memberCardUserInfo(BuildContext context, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(25)),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              Utils.getInitials(
                  AppCache.me?.MemberLists?.first.Name ?? "Guest User"),
              style: AppFont.montSemibold(20, color: AppColor.appYellow()),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Utils.getTranslated(context, "gsc_reward_member"),
                  style: AppFont.poppinsRegular(8, color: Colors.black38),
                ),
                Text(
                  AppCache.me?.MemberLists?.first.Name ?? "Guest User",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.montMedium(14, color: Colors.black),
                ),
                Text(
                  Utils.getTranslated(context, "gsc_member_card_no") +
                      (AppCache.me?.CardLists?.first.CardNo ?? ""),
                  style: AppFont.poppinsRegular(10,
                      color: AppColor.appSecondaryBlack()),
                ),
              ],
            ))
      ],
    );
  }

  Widget _memberCoinView(BuildContext context) {
    final coinValue = NumberFormat("#,##0", "en_US");
    String? expiry = cardDetails?.rewardCycleLists?.first.pointsExpiringDate;

    String formattedExpiryDate = expiry != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(expiry))
        : '';

    return Column(
      children: [
        Text(
          Utils.getTranslated(context, "gsc_member_coin_title"),
          style: AppFont.poppinsRegular(12, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          coinValue
              .format(cardDetails?.rewardCycleLists?.first.pointsBALValue ?? 0),
          style: AppFont.montSemibold(20, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          Utils.getTranslated(context, "gsc_member_coin_valid") +
              formattedExpiryDate,
          style: AppFont.poppinsRegular(8, color: AppColor.appSecondaryBlack()),
        ),
      ],
    );
  }

  Widget _memberRewardsView(BuildContext context) {
    return Column(
      children: [
        Text(
          Utils.getTranslated(context, "gsc_member_reward_title"),
          style: AppFont.poppinsRegular(12, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "$myRewardsCount",
          style: AppFont.montSemibold(20, color: Colors.black),
        ),
      ],
    );
  }

  Widget _rewardItem(BuildContext context, double screenWidth, dynamic reward) {
    return InkWell(
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RewardsCenterDetails(details: reward)))
              .then((value) {
            Utils.printInfo("IS REDEEM");
            if (value != null) {
              if (value == true) {
                Utils.printInfo("IS REDEEM TRUE");
                callRefreshData(
                    context, AppCache.me?.MemberLists?.first.MemberID ?? "");
              }
            }
          });
        },
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColor.lightGrey(),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            height: 100,
                            width: double.infinity,
                            imageUrl: reward.ImageLink.toString(),
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return Image.asset(
                                  'assets/images/Default placeholder_app_img.png',
                                  fit: BoxFit.fitWidth);
                            },
                          ),
                        )),
                    reward.CurrentIssuedCount > 0 &&
                            reward.IssuanceLimit > 0 &&
                            reward.CurrentIssuedCount >= reward.IssuanceLimit
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color:
                                    AppColor.dividerColor().withOpacity(0.78)),
                            height: 120,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                Utils.getTranslated(context, "fully_redeemed")
                                    .toUpperCase(),
                                style: AppFont.poppinsBold(22,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ))
                        : Container()
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 35,
                child: Text(
                  reward.Name.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: AppFont.montMedium(14, color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    reward.VoucherRedemptionValue != null &&
                            reward.VoucherRedemptionValue.toString() != '0'
                        ? reward.VoucherRedemptionValue.toString().substring(
                            0,
                            reward.VoucherRedemptionValue.toString()
                                .indexOf('.'))
                        : reward.VoucherRedemptionValue.toString(),
                    style: AppFont.poppinsSemibold(14,
                        color: AppColor.appYellow()),
                  ),
                  if (reward.VoucherRedemptionValue != null)
                    const SizedBox(
                      width: 3,
                    ),

                  // KEEPING THIS -> for this discount price
                  if (reward.RefInfo.Ref1 != null)
                    Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Text(
                          reward.RefInfo.Ref1.toString().substring(
                              reward.RefInfo.Ref1.lastIndexOf('|') + 1),
                          style: AppFont.poppinsRegular(10,
                              color: AppColor.greyWording(),
                              decoration: TextDecoration.lineThrough),
                        )),
                  Text(
                    Utils.getTranslated(context, "gsc_member_coin_title"),
                    style: AppFont.poppinsRegular(10,
                        color: AppColor.greyWording()),
                  ),
                  const SizedBox(
                    height: 5,
                  )
                ],
              )
            ],
          ),
        ));
  }
}
