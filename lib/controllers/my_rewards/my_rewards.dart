import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/as_vouchers_api.dart';
import 'package:gsc_app/models/json/as_vouchers_model.dart';
import 'package:gsc_app/models/json/rewards_voucher_type_list.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/custom_no_val_screen.dart';
import 'package:intl/intl.dart';

class MyRewardsScreen extends StatefulWidget {
  final List<RewardsVoucherTypeList> fullRewardList;
  const MyRewardsScreen({Key? key, required this.fullRewardList})
      : super(key: key);

  @override
  State<MyRewardsScreen> createState() => _MyRewardsScreenState();
}

class _MyRewardsScreenState extends State<MyRewardsScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int currentTab = 0;
  late TabController tabController = TabController(length: 2, vsync: this);
  bool isLogin = false;
  List<VoucherItemDTO> vouchersList = [];
  List<VoucherItemDTO> pastvouchersList = [];
  List<VoucherItemDTO> prevExpiredvouchersList = [];
  List<VoucherItemDTO> prevRedeemedListvouchersList = [];
  int page = 1;
  int pastPage = 1;
  int pastRewardpage = 1;
  int pageSize = 20;
  int totalActiveLen = 0;
  int totalPastLen = 0;
  ScrollController activeVoucherSController = ScrollController();
  ScrollController expiredVoucherSController = ScrollController();
  bool isLoading = false;
  bool noMoreData = false;
  bool noMorePastData = false;

  Future<void> checkLoginState(BuildContext context) async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken) {
      setState(() {
        isLogin = true;
        EasyLoading.show();
        vouchersList.clear();
        callGetMainVouchersList(context);
      });
    }
  }

  Future<VouchersDTO> getVouchersList(
      BuildContext context, bool active, bool past) async {
    AsVouchersApi asVouchersApi = AsVouchersApi(context);
    return asVouchersApi.getVouchersList(
      context,
      AppCache.me!.CardLists!.first.CardNo!,
      page,
      pageSize,
      active,
      past,
      past,
      30,
      pastPage,
    );
  }

  callGetMainVouchersList(BuildContext context) async {
    await getVouchersList(context, true, true).then((value) {
      if (value.returnStatus == 1) {
        if (value.activeVoucherList != null &&
                value.activeVoucherList!.isNotEmpty ||
            ((value.redeemedVoucherList != null &&
                    value.redeemedVoucherList!.isNotEmpty ||
                value.expiredVoucherList != null &&
                    value.expiredVoucherList!.isNotEmpty))) {
          if (vouchersList.length + value.activeVoucherList!.length >
              value.totalActiveVoucherCount!) {
            noMoreData = true;
          }

          if (value.redeemedVoucherList!.isEmpty &&
              value.expiredVoucherList!.isEmpty) {
            noMorePastData = true;
          }

          totalActiveLen = value.totalActiveVoucherCount!;
          // totalPastLen = value.totalExpiredVoucherCount! +
          //     value.totalRedeemedVoucherCount!;
          vouchersList = [...vouchersList, ...value.activeVoucherList!];

          pastvouchersList = [
            ...value.redeemedVoucherList!.toList(),
            ...value.expiredVoucherList!.toList()
          ];
          pastvouchersList.sort((a, b) {
            // Convert the date strings to DateTime objects
            // DateTime dateA = convertDate(a.voucherIssuedOn ?? a.validTo ?? '');
            // DateTime dateB = convertDate(a.voucherIssuedOn ?? a.validTo ?? '');
            DateTime displayDateA;
            DateTime displayDateB;
            a.voucherUsedOn != null
                ? displayDateA = Utils.epochToDate(
                    int.parse(Utils.getEpochUnix(a.voucherUsedOn!)))
                : displayDateA = (Utils.epochToDate(
                        int.parse(Utils.getEpochUnix(a.validTo!))))
                    .add(const Duration(days: 1));
            b.voucherUsedOn != null
                ? displayDateB = Utils.epochToDate(
                    int.parse(Utils.getEpochUnix(b.voucherUsedOn!)))
                : displayDateB = (Utils.epochToDate(
                        int.parse(Utils.getEpochUnix(b.validTo!))))
                    .add(const Duration(days: 1));
            // Sort in descending order
            return displayDateB.compareTo(displayDateA);
          });

          getVoucherImageAndTnc();
        } else {
          noMoreData = true;
          noMorePastData = true;
        }
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.returnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      }
    }).whenComplete(() {
      setState(() {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      });
    });
  }

  callGetPastVouchersList(BuildContext context) async {
    await getVouchersList(context, false, true).then((value) {
      if (value.returnStatus == 1) {
        if (value.expiredVoucherList!.isEmpty ||
            value.expiredVoucherList!.length < pageSize) {
          if (pastvouchersList.length +
                  value.expiredVoucherList!.length +
                  value.redeemedVoucherList!.length >
              value.totalExpiredVoucherCount! +
                  value.totalRedeemedVoucherCount!) {
            noMorePastData = true;
          }

          prevExpiredvouchersList = [
            ...prevExpiredvouchersList,
            ...value.expiredVoucherList!.toList()
          ];
          prevRedeemedListvouchersList = [
            ...prevRedeemedListvouchersList,
            ...value.redeemedVoucherList!.toList()
          ];
          pastvouchersList = [
            ...prevRedeemedListvouchersList,
            ...prevExpiredvouchersList
          ];

          pastvouchersList.sort((a, b) {
            // Convert the date strings to DateTime objects
            // DateTime dateA = convertDate(a.voucherIssuedOn ?? a.validTo ?? '');
            // DateTime dateB = convertDate(a.voucherIssuedOn ?? a.validTo ?? '');
            DateTime displayDateA;
            DateTime displayDateB;
            a.voucherUsedOn != null
                ? displayDateA = Utils.epochToDate(
                    int.parse(Utils.getEpochUnix(a.voucherUsedOn!)))
                : displayDateA = (Utils.epochToDate(
                        int.parse(Utils.getEpochUnix(a.validTo!))))
                    .add(const Duration(days: 1));
            b.voucherUsedOn != null
                ? displayDateB = Utils.epochToDate(
                    int.parse(Utils.getEpochUnix(b.voucherUsedOn!)))
                : displayDateB = (Utils.epochToDate(
                        int.parse(Utils.getEpochUnix(b.validTo!))))
                    .add(const Duration(days: 1));
            // Sort in descending order
            return displayDateB.compareTo(displayDateA);
          });

          getVoucherImageAndTnc();
        } else {
          noMorePastData = true;
        }
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.returnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      }
    }).whenComplete(() {
      setState(() {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      });
    });
  }

  callGetVouchersList(BuildContext context) async {
    await getVouchersList(context, true, false).then((value) {
      if (value.returnStatus == 1) {
        if (value.activeVoucherList != null &&
            value.activeVoucherList!.isNotEmpty) {
          if (vouchersList.length + value.activeVoucherList!.length >
              value.totalActiveVoucherCount!) {
            noMoreData = true;
          }

          // Utils.printWrapped("MY VOUCHERS: ${value.activeVoucherList}");

          vouchersList = [...vouchersList, ...value.activeVoucherList!];

          // Utils.printWrapped("VOUCHER LIST COUNT: ${vouchersList.length}");

          getVoucherImageAndTnc();
        } else {
          noMoreData = true;
        }
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.returnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      }
    }).whenComplete(() {
      setState(() {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      });
    });
  }

  Future<void> callRefreshData() async {
    vouchersList.clear();
    pastvouchersList.clear();
    prevExpiredvouchersList.clear();
    prevRedeemedListvouchersList.clear();
    page = 1;
    pastPage = 1;
    noMorePastData = false;
    noMoreData = false;
    EasyLoading.show();
    callGetMainVouchersList(scaffoldKey.currentState!.context);
  }

  getVoucherImageAndTnc() {
    if (vouchersList.isNotEmpty && widget.fullRewardList.isNotEmpty) {
      for (var rewardElement in widget.fullRewardList) {
        for (var voucherElement in vouchersList) {
          if (rewardElement.Code == voucherElement.voucherTypeCode) {
            voucherElement.voucherImageLink = rewardElement.ImageLink;
            voucherElement.voucherTnc = rewardElement.TnC;
          }
        }
        for (var voucherElement in pastvouchersList) {
          if (rewardElement.Code == voucherElement.voucherTypeCode) {
            voucherElement.voucherImageLink = rewardElement.ImageLink;
            voucherElement.voucherTnc = rewardElement.TnC;
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    activeVoucherSController.addListener(() {
      if (activeVoucherSController.offset >=
              activeVoucherSController.position.maxScrollExtent &&
          !activeVoucherSController.position.outOfRange) {
        if (noMoreData || vouchersList.length >= totalActiveLen) {
          return;
        }
        EasyLoading.show(maskType: EasyLoadingMaskType.black);
        page += 1;
        callGetVouchersList(scaffoldKey.currentState!.context);
      }
    });
    // expiredVoucherSController.addListener(() {
    //   if (expiredVoucherSController.offset >=
    //           expiredVoucherSController.position.maxScrollExtent &&
    //       !expiredVoucherSController.position.outOfRange) {
    //     if (noMorePastData || pastvouchersList.length >= totalPastLen) {
    //       return;
    //     }
    //     EasyLoading.show(maskType: EasyLoadingMaskType.black);
    //     pastRewardpage += 1;
    //     callGetPastVouchersList(scaffoldKey.currentState!.context);
    //   }
    // });

    checkLoginState(context);
  }

  @override
  void dispose() {
    activeVoucherSController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return isLogin
        ? Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 60,
              backgroundColor: AppColor.backgroundBlack(),
              centerTitle: true,
              title: Text(
                Utils.getTranslated(context, 'profile_value_rewards'),
                style: AppFont.montRegular(18, color: Colors.white),
              ),
              leading: InkWell(
                onTap: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Image.asset('assets/images/white-left-icon.png'),
              ),
            ),
            body: Container(
              width: screenWidth,
              height: screenHeight,
              color: Colors.black,
              child: SafeArea(
                child: Column(
                  children: [
                    _tabController(),
                    _borderUnderline(),
                    _tabView(),
                  ],
                ),
              ),
            ),
          )
        : NoValScreen(title: 'profile_value_rewards');
  }

  Widget _tabView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: TabBarView(
        controller: tabController,
        children: [
          RefreshIndicator(
            backgroundColor: Colors.transparent,
            color: AppColor.appYellow(),
            onRefresh: () => callRefreshData(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 19),
              child: ListView.builder(
                controller: activeVoucherSController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: vouchersList.isNotEmpty ? vouchersList.length : 1,
                itemBuilder: (context, index) {
                  if (vouchersList.isEmpty) {
                    return SizedBox(
                        height: screenHeight - 180,
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
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
                            ]));
                  }
                  var item = vouchersList[index];
                  return rewardsItem(
                      context, index, item, false, vouchersList.length);
                },
              ),
            ),
          ),
          RefreshIndicator(
            backgroundColor: Colors.transparent,
            color: AppColor.appYellow(),
            onRefresh: () => callRefreshData(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 19),
              child: ListView.builder(
                controller: expiredVoucherSController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: pastvouchersList.isNotEmpty
                    ? pastvouchersList.length > 30
                        ? 30
                        : pastvouchersList.length
                    : 1,
                itemBuilder: (context, index) {
                  if (pastvouchersList.isEmpty) {
                    return SizedBox(
                        height: screenHeight - 180,
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
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
                            ]));
                  }
                  var item = pastvouchersList[index];
                  return rewardsItem(
                      context, index, item, true, pastvouchersList.length);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _borderUnderline() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColor.appYellow()))),
    );
  }

  Widget _tabController() {
    return Container(
        color: AppColor.backgroundBlack(),
        child: DefaultTabController(
            length: 2,
            child: TabBar(
              controller: tabController,
              padding: const EdgeInsets.only(left: 12, right: 12),
              labelColor: Colors.black,
              labelStyle: AppFont.montSemibold(14),
              unselectedLabelStyle: AppFont.montRegular(14),
              unselectedLabelColor: AppColor.lightGrey(),
              onTap: (value) => {
                setState(() {
                  currentTab = value;
                })
              },
              indicatorColor: Colors.transparent,
              indicator: BoxDecoration(
                  color: AppColor.appYellow(),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              tabs: [
                Tab(
                    child: Text(Utils.getTranslated(
                        context, "myreward_tab_title_active"))),
                Tab(
                    child: Text(Utils.getTranslated(
                        context, "myreward_tab_title_expired")))
              ],
            )));
  }

  Widget rewardsItem(BuildContext context, int index,
      VoucherItemDTO voucherItemDTO, bool isPast, int lens) {
    String displayDate = '';
    if (isPast) {
      voucherItemDTO.voucherUsedOn != null
          ? displayDate = Utils.getTranslated(context, 'used_date')
              .replaceFirst(
                  '<date>',
                  DateFormat('dd MMM yyyy').format(Utils.epochToDate(int.parse(
                      Utils.getEpochUnix(voucherItemDTO.voucherUsedOn!)))))
          : displayDate = Utils.getTranslated(context, 'expired_date')
              .replaceFirst(
                  '<date>',
                  DateFormat('dd MMM yyyy').format((Utils.epochToDate(int.parse(
                          Utils.getEpochUnix(voucherItemDTO.validTo!))))
                      .add(const Duration(days: 1))));
    } else {
      displayDate = Utils.getTranslated(context, 'valid_date').replaceFirst(
          '<date>',
          DateFormat('dd MMM yyyy').format(Utils.epochToDate(
              int.parse(Utils.getEpochUnix(voucherItemDTO.validTo!)))));
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.myRewardsDetailRoute,
            arguments: [voucherItemDTO, isPast]);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 164 / 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ColorFiltered(
                          colorFilter: isPast
                              ? const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                )
                              : const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.multiply,
                                ),
                          child: Image.network(
                            '${voucherItemDTO.voucherImageLink}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                  'assets/images/Default placeholder_app_img.png',
                                  width: 164,
                                  height: 100,
                                  fit: BoxFit.cover);
                            },
                          ),
                        ),
                      ),
                    ),
                    isPast
                        ? Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              voucherItemDTO.voucherUsedOn != null
                                  ? Utils.getTranslated(context, "used")
                                  : Utils.getTranslated(context, "expired"),
                              style: AppFont.poppinsMedium(10,
                                  color: Colors.black),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Text(
                        '${voucherItemDTO.voucherTypeName}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.montMedium(
                          14,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            displayDate,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFont.poppinsRegular(14,
                                color: AppColor.greyWording()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          index != lens - 1
              ? Divider(color: AppColor.dividerColor())
              : const SizedBox(),
        ],
      ),
    );
  }
}
