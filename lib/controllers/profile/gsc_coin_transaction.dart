import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:intl/intl.dart';

import '../../const/analytics_constant.dart';
import '../../models/json/as_gscoin_transaction_model.dart';

class CoinTransactionPage extends StatefulWidget {
  const CoinTransactionPage({Key? key}) : super(key: key);

  @override
  State<CoinTransactionPage> createState() => _CoinTransactionPageState();
}

class _CoinTransactionPageState extends State<CoinTransactionPage> {
  List<TransactionList> transactionLists = [];
  int page = 1;
  bool noMoreData = false;

  ScrollController activeVoucherSController = ScrollController();
  Future<CoinTransactionDTO> coinTransaction(BuildContext context) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getCoinTransactionList(
        AppCache.me!.MemberLists!.first.MemberID!,
        AppCache.me!.CardLists!.first.CardNo!,
        page);
  }

  Future<void> callRefreshData() async {
    transactionLists.clear();

    page = 1;

    noMoreData = false;
    EasyLoading.show();
    getCoinTransaction(context);
  }

  getCoinTransaction(BuildContext context) async {
    if (AppCache.me != null) {
      EasyLoading.show(maskType: EasyLoadingMaskType.black);
      await coinTransaction(context)
          .then((value) {
            if (value.returnStatus != 1) {
              Utils.showAlertDialog(
                  context,
                  Utils.getTranslated(context, "error_title"),
                  value.returnMessage != null
                      ? value.returnMessage.toString().isNotEmpty
                          ? value.returnMessage.toString()
                          : Utils.getTranslated(context, "general_error")
                      : Utils.getTranslated(context, "general_error"),
                  true,
                  null, () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            } else {
              setState(() {
                if (value.transactionLists == null) {
                  noMoreData = true;
                } else {
                  if (value.transactionLists!.isEmpty) {
                    noMoreData = true;
                  } else {
                    transactionLists = [
                      ...transactionLists,
                      ...value.transactionLists ?? []
                    ];
                  }
                }
              });
            }
          })
          .whenComplete(() => EasyLoading.dismiss())
          .catchError((e) {
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
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_GSCOIN_TRANSACTION_LIST_SCREEN);
    getCoinTransaction(context);
    activeVoucherSController.addListener(() {
      if (activeVoucherSController.offset >=
              activeVoucherSController.position.maxScrollExtent &&
          !activeVoucherSController.position.outOfRange) {
        if (noMoreData) {
          return;
        }
        EasyLoading.show(maskType: EasyLoadingMaskType.black);
        page += 1;
        getCoinTransaction(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      color: Colors.black,
      child: SingleChildScrollView(
        controller: activeVoucherSController,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerView(context),
              const SizedBox(
                height: 12,
              ),
              if (transactionLists.isNotEmpty)
                for (var data in transactionLists)
                  transactionListItem(context, data),
              if (transactionLists.isEmpty) emptyScreen(context)
            ]),
      ),
    );
  }

  Widget emptyScreen(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
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
      ),
    );
  }

  Widget transactionListItem(
    BuildContext context,
    TransactionList data,
  ) {
    num points = data.points ?? 0;

    data.salesRelatedTransactionList?.forEach((element) {
      points += element.points ?? 0;
    });
    String displayName = data.transactType !=
            Constants.AS_COIN_VOUCHER_ISSUANCE_TYPE
        ? data.voucherTypeName!.isNotEmpty
            ? data.voucherTypeName!
            : "${Utils.getTranslated(context, "gscoin_transc_booking_id_text")} - ${data.receiptNo!}"
        : data.issuedVoucherLists!.first['VoucherTypeName'];

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppFont.poppinsRegular(14, color: Colors.white),
                  ),
                  itemDateTime(data),
                ],
              ),
              Text(
                points.toString(),
                style: AppFont.poppinsRegular(16,
                    color: points >= 0
                        ? AppColor.positiveGreen()
                        : AppColor.errorRed()),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 14),
            child: Divider(
              color: AppColor.dividerColor(),
            ),
          )
        ],
      ),
    );
  }

  Text itemDateTime(TransactionList data) {
    var date = DateFormat('d MMM, yyyy').format(
        Utils.epochToDate(int.parse(Utils.getEpochUnix(data.transactDate!))));

    var time = DateFormat('hh:mm a')
        .format(DateFormat('HH:mm:ss').parse(data.transactTime!));
    return Text(
      time + ', ' + date,
      style: AppFont.poppinsRegular(12, color: AppColor.greyWording()),
    );
  }

  Widget coinTransactionListAppBar(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      margin: EdgeInsets.only(
          left: 16, right: 16, top: MediaQuery.of(context).viewPadding.top),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset('assets/images/white-left-icon.png')),
          SizedBox(
            width: MediaQuery.of(context).size.width - 32 - 30,
            child: Center(
              child: Text(
                Utils.getTranslated(context, "gsc_coin_page_title"),
                style: AppFont.montRegular(18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerView(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth,
        child: Stack(
          children: [
            backgroundGradient(context),
            gsCoinsUI(),
            coinTransactionListAppBar(context),
          ],
        ));
  }

  Widget gsCoinsUI() {
    final coinValue = NumberFormat("#,##0", "en_US");
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          top: 156 / 2 + kToolbarHeight / 2 + 10,
        ),
        width: 164,
        height: 164,
        decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(width: 8, color: AppColor.backgroundBlack())),
        child: Stack(
          children: [
            Image.asset(Constants.ASSET_IMAGES + 'gscoin-base.png'),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coinValue
                        .format(AppCache.me?.CardLists?.first.PointsBAL ?? 0),
                    style: AppFont.poppinsBold(28, color: Colors.black),
                  ),
                  Text(
                    Utils.getTranslated(context, "gscoin_transc_balance_text"),
                    style: AppFont.poppinsRegular(12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container backgroundGradient(BuildContext context) {
    return Container(
      height: 156 + kToolbarHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.appSecondaryBlack(),
            AppColor.appYellow(),
          ],
          stops: const [.7, 1],
        ),
      ),
      width: MediaQuery.of(context).size.width,
    );
  }
}
