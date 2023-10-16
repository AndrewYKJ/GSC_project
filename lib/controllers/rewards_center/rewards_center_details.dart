import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gsc_app/models/json/voucher_issuance_model.dart';
import 'package:intl/intl.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/constants.dart';
import '../../const/utils.dart';
import '../../dio/api/as_member.api.dart';
import '../../models/json/rewards_voucher_type_list.dart';
import '../../widgets/custom_dialog.dart';

class RewardsCenterDetails extends StatefulWidget {
  final RewardsVoucherTypeList details;

  const RewardsCenterDetails({Key? key, required this.details})
      : super(key: key);

  @override
  State<RewardsCenterDetails> createState() {
    return _RewardsCenterDetails();
  }
}

class _RewardsCenterDetails extends State<RewardsCenterDetails> {
  RewardsVoucherTypeList? rewards;
  double? availablePoints;
  bool hasRedeemed = false;
  bool willPop = true;
  String? cardNo;

  @override
  void initState() {
    super.initState();
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_REWARD_ITEM_DETAILS_SCREEN);
    rewards = widget.details;
    availablePoints = AppCache.me?.CardLists?.first.PointsBAL ?? 0.0;
  }

  Future<VoucherIssuanceModel> redeemVoucher(
      BuildContext context, String cardNo, String itmCode, int quantity) async {
    AsMemberApi asMemberApi = AsMemberApi(context);
    return asMemberApi.redeemRewardCentreVoucher(
        context, cardNo, itmCode, quantity);
  }

  redeemRewardsVoucher(
      String cardNo, String itmCode, int quantity, String voucherName) async {
    EasyLoading.show();
    await redeemVoucher(context, cardNo, itmCode, quantity).then((value) {
      if (value.ReturnStatus == 1) {
        setState(() {
          willPop = false;
          hasRedeemed = true;
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return CustomDialogBox(
                  title: Utils.getTranslated(context, "redeem_successful"),
                  message: Utils.getTranslated(context, "redeem_success_msg")
                      .replaceAll(RegExp(r'\<type>'), voucherName),
                  img: "redeem-success-icon.png",
                  showButton: false,
                  showConfirm: false,
                  showCancel: false,
                  confirmStr: null,
                );
              }).then((value) {
            Navigator.of(context).pop(true);
          });

          Future.delayed(const Duration(seconds: 1)).then((value) {
            Navigator.of(context).pop(true);
          });
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
      Utils.printInfo('REDEEM REWARDS ERROR: $error');
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "info_title"),
          error ?? Utils.getTranslated(context, "general_error"),
          false,
          false, () {
        Navigator.pop(context);
      });
    }).whenComplete(() => EasyLoading.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.black,
        body: WillPopScope(
          onWillPop: () async => willPop,
          child: SafeArea(
              child: Container(
                  height: height,
                  width: width,
                  color: Colors.black,
                  child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: rewards != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  _rewardImg(),
                                  _detailsContainer(context),
                                  _border(context),
                                  _rewardDescription(),
                                  _termsAndCondition()
                                ])
                          : Container()))),
        ),
        bottomNavigationBar: rewards != null
            ? BottomAppBar(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 19, bottom: 19),
                  child: SizedBox(
                      height: 49,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (hasRedeemed == false &&
                                  availablePoints != null &&
                                  availablePoints! >=
                                      double.parse(rewards!
                                          .VoucherRedemptionValue
                                          .toString())) {
                                redeemRewardsVoucher(
                                    AppCache.me?.CardLists?.first.CardNo ?? "",
                                    rewards!.Code.toString(),
                                    1,
                                    rewards!.Name ?? "");
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              primary: hasRedeemed
                                  ? AppColor.buttonGrey()
                                  : availablePoints != null &&
                                          availablePoints! >=
                                              double.parse(rewards!
                                                  .VoucherRedemptionValue
                                                  .toString()) &&
                                          rewards!.IsRedeemable == true &&
                                          (rewards!.CurrentIssuedCount > 0 &&
                                                  rewards!.IssuanceLimit > 0 &&
                                                  rewards!.CurrentIssuedCount <
                                                      rewards!.IssuanceLimit ||
                                              rewards!.CurrentIssuedCount ==
                                                      0 &&
                                                  rewards!.IssuanceLimit == 0)
                                      ? AppColor.appYellow()
                                      : AppColor.darkYellow()),
                          child: Text(
                              rewards!.CurrentIssuedCount > 0 &&
                                      rewards!.IssuanceLimit > 0 &&
                                      rewards!.CurrentIssuedCount >=
                                          rewards!.IssuanceLimit
                                  ? Utils.getTranslated(
                                      context, "fully_redeemed")
                                  : Utils.getTranslated(context, "redeem"),
                              style: AppFont.montSemibold(14,
                                  color: Colors.black)))),
                ),
              )
            : const BottomAppBar());
  }

  Widget _rewardImg() {
    return SizedBox(
        height: 250,
        child: Stack(children: [
          CachedNetworkImage(
            height: 250,
            width: double.infinity,
            imageUrl: rewards!.ImageLink.toString(),
            fit: BoxFit.cover,
            errorWidget: (context, error, stackTrace) {
              return Image.asset(
                  'assets/images/Default placeholder_app_img.png',
                  fit: BoxFit.fitWidth);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16),
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                    Constants.ASSET_IMAGES + 'white-left-icon.png')),
          ),
          Positioned(
              bottom: -5,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: const SizedBox(height: 30)))
        ]));
  }

  Widget _detailsContainer(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: Text(rewards!.Name.toString(),
                      textAlign: TextAlign.center,
                      style: AppFont.montSemibold(16, color: Colors.white))),
              const SizedBox(height: 33),
              Container(
                  height: 43,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(right: 13.5),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      Utils.getTranslated(
                                          context, "gsc_member_coin_title"),
                                      style: AppFont.montRegular(12,
                                          color: AppColor.greyWording())),
                                  Container(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 6),
                                                  child: Text(
                                                    rewards?.VoucherRedemptionValue !=
                                                            null
                                                        ? rewards?.VoucherRedemptionValue !=
                                                                0
                                                            ? rewards!
                                                                .VoucherRedemptionValue
                                                                .toString()
                                                                .substring(
                                                                    0,
                                                                    rewards!
                                                                        .VoucherRedemptionValue
                                                                        .toString()
                                                                        .indexOf(
                                                                            '.'))
                                                            : rewards!
                                                                .VoucherRedemptionValue
                                                                .toStringAsFixed(
                                                                    0)
                                                        : '',
                                                    style:
                                                        AppFont.poppinsSemibold(
                                                            14,
                                                            color: AppColor
                                                                .appYellow()),
                                                  )),
                                              if (rewards!.RefInfo?.Ref1 !=
                                                  null)
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 2),
                                                    child: Text(
                                                      rewards!.RefInfo!.Ref1
                                                          .toString()
                                                          .substring(rewards!
                                                                  .RefInfo!
                                                                  .Ref1!
                                                                  .lastIndexOf(
                                                                      '|') +
                                                              1),
                                                      maxLines: 2,
                                                      style: AppFont.poppinsRegular(
                                                          10,
                                                          color: AppColor
                                                              .greyWording(),
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                    )),
                                              // Text(
                                              //   Utils.getTranslated(context,
                                              //       "gsc_member_coin_title"),
                                              //   style: AppFont.poppinsRegular(
                                              //       10,
                                              //       color:
                                              //           AppColor.greyWording()),
                                              // ),
                                            ])
                                          ]))
                                ])),
                        _rewardValidity()
                      ]))
            ])));
  }

  Widget _rewardValidity() {
    return Container(
        padding: const EdgeInsets.only(left: 13.5),
        decoration: BoxDecoration(
            border: Border(left: BorderSide(color: AppColor.greyBorder()))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            Utils.getTranslated(context, 'validity'),
            style: AppFont.montRegular(12, color: AppColor.greyWording()),
          ),
          rewards!.RefInfo!.Ref2!.split('|-|').last.trim().isNotEmpty
              ? Container(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(rewards!.RefInfo!.Ref2!.split('|-|').last,
                      style: AppFont.poppinsRegular(14, color: Colors.white)))
              : Container(
                  padding: const EdgeInsets.only(top: 7),
                  child: Wrap(children: [
                    Text(
                        DateFormat('dd MMM yyyy').format(Utils.epochToDate(
                            int.parse(Utils.getEpochUnix(
                                rewards!.StartDate.toString())))),
                        style: AppFont.poppinsRegular(14, color: Colors.white)),
                    Padding(
                        padding: const EdgeInsets.only(left: 3, right: 3),
                        child: Text('-',
                            style: AppFont.poppinsRegular(14,
                                color: Colors.white))),
                    Text(
                        DateFormat('dd MMM yyyy').format(Utils.epochToDate(
                            int.parse(Utils.getEpochUnix(
                                rewards!.EndDate.toString())))),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.poppinsRegular(14, color: Colors.white)),
                  ]))
        ]));
  }

  Widget _border(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Container(
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColor.greyBorder())))),
    );
  }

  Widget _rewardDescription() {
    if (rewards!.Description != null && rewards!.Description!.isNotEmpty) {
      return Container(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: Text(rewards!.Description.toString(),
              style: AppFont.poppinsRegular(12, color: Colors.white)));
    } else {
      return Container();
    }
  }

  Widget _termsAndCondition() {
    if (rewards!.TnC != '' && rewards!.TnC != Constants.EMPTY_TNC) {
      return Padding(
          padding: const EdgeInsets.only(top: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                child: Text(
                    Utils.getTranslated(context, "Terms_and_Conditions"),
                    style:
                        AppFont.montMedium(14, color: AppColor.greyWording()))),
            Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 10, top: 0),
                child: Html(
                  data: rewards!.TnC,
                  style: {
                    "head":
                        Style(margin: Margins.all(0), padding: EdgeInsets.zero),
                    "body": Style(
                        // backgroundColor: Colors.green,
                        margin:
                            Margins.only(left: 8, right: 8, top: 0, bottom: 0),
                        padding: EdgeInsets.zero,
                        textAlign: TextAlign.start,
                        fontSize: FontSize(12),
                        lineHeight: const LineHeight(1.5),
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins')
                  },
                ))
          ]));
    } else {
      return Container();
    }
  }
}
