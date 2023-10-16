import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/rewards_center/rewards_center_details.dart';

import '../../const/analytics_constant.dart';
import '../../const/constants.dart';
import '../../dio/api/as_member.api.dart';
import '../../models/json/rewards_center_response.dart';
import '../../models/json/rewards_voucher_type_list.dart';

class RewardsCenterListing extends StatefulWidget {
  const RewardsCenterListing({Key? key}) : super(key: key);

  @override
  State<RewardsCenterListing> createState() {
    return _RewardsCenterListing();
  }
}

class _RewardsCenterListing extends State<RewardsCenterListing> {
  List<RewardsVoucherTypeList>? rewards;
  int page = 1;
  int pageCount = 20;
  final _controller = ScrollController();
  int totalData = 0;
  List<RewardsVoucherTypeList> data = [];
  bool shudRefresh = false;

  @override
  void initState() {
    super.initState();
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_REWARD_LISTING_SCREEN);

    _controller.addListener(_scrollListener);

    getFullRewardListing(page, pageCount);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      if (rewards != null && rewards!.length < totalData) {
        setState(() {
          page += 1;
          getFullRewardListing(page, pageCount);
        });
      }
    }
  }

  Future<void> callRefreshData(BuildContext ctx) async {
    Utils.printInfo("pull refresh");
    data.clear();
    page = 1;
    totalData = 0;
    getFullRewardListing(page, pageCount);
  }

  Future<RewardsCenterResponse> getRewardListing(
      BuildContext context, bool includeExpire, int page, int pageCount) async {
    AsMemberApi asMemberApi = AsMemberApi(context);
    return asMemberApi.getRewardsCenterListing(
        context, includeExpire, page, pageCount);
  }

  getFullRewardListing(int page, int pageCount) async {
    EasyLoading.show();
    await getRewardListing(context, false, page, pageCount).then((value) {
      if (value.ReturnStatus == 1) {
        setState(() {
          totalData = value.TotalResults!;
          for (var val in value.VoucherTypeLists!) {
            data.add(val);
          }
          rewards = data;
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
    }).whenComplete(() => EasyLoading.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return WillPopScope(
        onWillPop: () => returnButton(),
        child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                toolbarHeight: 70,
                centerTitle: true,
                title: Text(Utils.getTranslated(context, 'rewards_centre'),
                    style: AppFont.montRegular(18, color: Colors.white)),
                elevation: 0,
                backgroundColor: AppColor.backgroundBlack(),
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context, shudRefresh);
                    },
                    child: Image.asset(
                        Constants.ASSET_IMAGES + 'white-left-icon.png'))),
            body: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
                width: width,
                height: height,
                child: SafeArea(
                    child: RefreshIndicator(
                  backgroundColor: Colors.transparent,
                  color: AppColor.appYellow(),
                  onRefresh: () => callRefreshData(context),
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      controller: _controller,
                      itemCount: rewards?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _rewardItems(context, index);
                      }),
                )))));
  }

  returnButton() {
    return Navigator.pop(context, shudRefresh);
  }

  Widget _rewardItems(BuildContext context, int index) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 19),
          child: InkWell(
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                RewardsCenterDetails(details: rewards![index])))
                    .then((value) {
                  if (value != null) {
                    if (value == true) {
                      setState(() {
                        shudRefresh = true;
                      });
                    }
                  }
                });
              },
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          height: 100,
                          width: 164,
                          imageUrl: rewards![index].ImageLink.toString(),
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) {
                            return Image.asset(
                                'assets/images/Default placeholder_app_img.png',
                                fit: BoxFit.fitWidth);
                          },
                        ),
                        rewards![index].CurrentIssuedCount > 0 &&
                                rewards![index].IssuanceLimit > 0 &&
                                rewards![index].CurrentIssuedCount >=
                                    rewards![index].IssuanceLimit
                            ? Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppColor.dividerColor()
                                        .withOpacity(0.78)),
                                height: 100,
                                width: 164,
                                child: Center(
                                  child: Text(
                                    Utils.getTranslated(
                                            context, "fully_redeemed")
                                        .toUpperCase(),
                                    style: AppFont.poppinsBold(22,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ))
                            : Container(),
                      ],
                    )),
                Expanded(
                    child: Container(
                        height: 100,
                        padding: const EdgeInsets.only(top: 6.25, left: 12),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rewards![index].Name.toString(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style:
                                    AppFont.montMedium(14, color: Colors.white),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    rewards?[index].VoucherRedemptionValue !=
                                            null
                                        ? rewards![index]
                                                    .VoucherRedemptionValue !=
                                                0
                                            ? rewards![index]
                                                .VoucherRedemptionValue
                                                .toString()
                                                .substring(
                                                    0,
                                                    rewards![index]
                                                        .VoucherRedemptionValue
                                                        .toString()
                                                        .indexOf('.'))
                                            : rewards![index]
                                                .VoucherRedemptionValue
                                                .toStringAsFixed(0)
                                        : '',
                                    style: AppFont.poppinsSemibold(14,
                                        color: AppColor.appYellow()),
                                  ),
                                  if (rewards?[index].VoucherRedemptionValue !=
                                      null)
                                    const SizedBox(
                                      width: 5,
                                    ),
                                  if (rewards?[index].RefInfo?.Ref1 != null)
                                    Padding(
                                        padding: const EdgeInsets.only(
                                          right: 2,
                                        ),
                                        child: Text(
                                          rewards![index]
                                              .RefInfo!
                                              .Ref1
                                              .toString()
                                              .substring(rewards![index]
                                                      .RefInfo!
                                                      .Ref1!
                                                      .lastIndexOf('|') +
                                                  1),
                                          style: AppFont.poppinsRegular(10,
                                              color: AppColor.greyWording(),
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        )),
                                  Text(
                                    Utils.getTranslated(
                                        context, "gsc_member_coin_title"),
                                    style: AppFont.poppinsRegular(10,
                                        color: AppColor.greyWording()),
                                  ),
                                ],
                              )
                            ])))
              ]))),
      index != rewards!.length - 1
          ? const Divider(color: Colors.white38, height: 0)
          : Container(),
    ]);
  }
}
