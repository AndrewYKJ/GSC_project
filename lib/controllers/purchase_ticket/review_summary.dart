import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/arguments/init_transaction_arguments.dart';
import 'package:gsc_app/models/json/check_booking_status_response.dart';
import 'package:gsc_app/models/json/init_sales_trans_reponse.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:intl/intl.dart';

import '../../const/analytics_constant.dart';
import '../../dio/api/transactions_api.dart';
import '../../models/arguments/payment_result_arguments.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_web_view.dart';
import '../tab/homebase.dart';

class ReviewSummaryScreen extends StatefulWidget {
  final InitSalesTransactionArg data;
  const ReviewSummaryScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ReviewSummaryScreen> createState() => _ReviewSummaryScreenState();
}

class _ReviewSummaryScreenState extends State<ReviewSummaryScreen> {
  InitSalesDTO? initSalesDTO;
  static const int initialSeconds = 8 * 60; // 8 minutes in seconds
  late Timer timer;
  int secondsRemaining = initialSeconds;
  bool agreeTnc = false;

  Future<BookingResponseDTO> cancelTransaction(BuildContext context) async {
    TransactionsApi itm = TransactionsApi(context);
    return itm.cancelTransaction(
      widget.data.initSalesDTO!.prepareStatus!.status!.tranRef!,
      widget.data.locationId,
    );
  }

  Future<BookingResponseDTO> checkBookingStatus(BuildContext context) async {
    TransactionsApi itm = TransactionsApi(context);
    return itm.checkTransactionStatus(
      widget.data.initSalesDTO!.prepareStatus!.status!.referenceNo!,
    );
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_REVIEW_SUMMARY_SCREEN);

    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    var count = 0;
    var targetTime = DateTime.now().add(const Duration(minutes: 8));
    timer = Timer.periodic(const Duration(seconds: 1), (Timer _timer) {
      Duration difference = targetTime.difference(DateTime.now());
      setState(() {
        if (!difference.isNegative) {
          if (count == 8) {
            checkBookingStatus(context).then((value) {
              if (value.bookings!.bookingStatus!.status == "S") {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.successPaymentRoute,
                  (route) => false,
                  arguments: TransactionResultArg(
                      movieTitle: widget.data.movieTitle, isSuccess: true),
                );
                _timer.cancel();
              }
              if (value.bookings!.bookingStatus!.status == "E") {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.successPaymentRoute,
                  (route) => false,
                  arguments: TransactionResultArg(
                      movieTitle: widget.data.movieTitle, isSuccess: false),
                );
                _timer.cancel();
              }
            });
            count = 0;
          }
          secondsRemaining = difference.inSeconds;
          count++;
        } else {
          _timer.cancel();
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return const HomeBase();
          }), (route) => false);
        }
      });
    });
  }

  callCancelBookingDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title: Utils.getTranslated(context, 'cancel_booking_title'),
              message: Utils.getTranslated(context, 'cancel_booking_message'),
              img: widget.data.isAurum != null && widget.data.isAurum!
                  ? "aurum-attention.png"
                  : "attention-icon.png",
              showButton: true,
              showConfirm: true,
              showCancel: true,
              isAurum: widget.data.isAurum,
              confirmStr: "OK",
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () {
                timer.cancel();
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                  return const HomeBase();
                }), (route) => false);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () => callCancelBookingDialog(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: Text(Utils.getTranslated(context, 'review_summary_title'),
              style: AppFont.montRegular(18, color: Colors.white)),
          leading: InkWell(
              onTap: () async {
                callCancelBookingDialog();
              },
              child: Image.asset('assets/images/white-left-icon.png')),
          backgroundColor: AppColor.appSecondaryBlack(),
        ),
        body: Container(
          height: height,
          width: width,
          color: Colors.black,
          child: Column(
            children: [
              timerUI(width),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        movieName(width),
                        cinemaName(width),
                        movieShowTimes(width),
                        seatList(width),
                        Divider(
                          thickness: 1,
                          color: widget.data.isAurum == true
                              ? AppColor.aurumDay()
                              : AppColor.dividerColor(),
                        ),
                        ticketTypeList(width),
                        ecomboList(width),
                      ],
                    ),
                  ),
                ),
              ),
              totalAmt(width),
              agreeTnC(width),
              checkOutBtn(context, width)
            ],
          ),
        ),
      ),
    );
  }

  Container checkOutBtn(BuildContext context, double width) {
    return Container(
      color: AppColor.appSecondaryBlack(),
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 20),
      width: width,
      child: InkWell(
        onTap: () {
          agreeTnc
              ? Navigator.pushNamed(context, AppRoutes.paymentGatewayRoute,
                  arguments: widget.data)
              : null;
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: agreeTnc
                  ? widget.data.isAurum == true
                      ? AppColor.aurumGold()
                      : AppColor.appYellow()
                  : widget.data.isAurum == true
                      ? AppColor.aurumConfirmBtnDim()
                      : AppColor.checkOutDisabled(),
              borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(
                Utils.getTranslated(context, 'review_summary_checkout_btn'),
                style: AppFont.montSemibold(14, color: Colors.black)),
          ),
        ),
      ),
    );
  }

  Widget agreeTnC(double width) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 6, 16, 10),
      width: width,
      decoration: BoxDecoration(color: AppColor.appSecondaryBlack()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: agreeTnc,
            onChanged: (value) {
              setState(() {
                agreeTnc = !agreeTnc;
              });
            },
            side: const BorderSide(color: Colors.white, width: 2),
            checkColor: Colors.black,
            activeColor: widget.data.isAurum == true
                ? AppColor.aurumGold()
                : AppColor.appYellow(),
          ),
          Container(
            width: width - 32 - 32,
            margin: const EdgeInsets.only(top: 10),
            child: RichText(
              text: TextSpan(
                text: 'I agree to GSC’s ',
                style: AppFont.poppinsRegular(
                  12,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                        color: AppColor.tncBlue(),
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.tncBlue()),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebView(
                                      url: Constants.TERMS_CONDITION,
                                      title: Utils.getTranslated(
                                          context, "terms_and_condition"),
                                    )));
                      },
                  ),
                  TextSpan(
                    text: ' and ',
                    style: AppFont.poppinsRegular(
                      12,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: ' Privacy Policy',
                    style: TextStyle(
                        color: AppColor.tncBlue(),
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.tncBlue()),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebView(
                                    url: Constants.PRIVACY_POLICY,
                                    title: Utils.getTranslated(
                                        context, "privacy_policy"))));
                      },
                  ),
                  TextSpan(
                    text:
                        ', and hereby confirm my selection and movie details.',
                    style: AppFont.poppinsRegular(
                      12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container totalAmt(double width) {
    var totalAmt = 0.0;
    for (var data in widget.data.selectedTicket!) {
      totalAmt += double.parse(data.price!) * data.qty!;
    }
    for (var data in widget.data.selectedCombo!) {
      totalAmt += double.parse(data.price!.replaceAll("RM ", "")) * data.qty!;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      width: width,
      height: 50,
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(
                  color: widget.data.isAurum == true
                      ? AppColor.aurumGold()
                      : AppColor.appYellow(),
                  width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Utils.getTranslated(context, 'total'),
              style: AppFont.poppinsRegular(16,
                  color: widget.data.isAurum == true
                      ? AppColor.aurumGold()
                      : AppColor.appYellow())),
          Text(
              "RM ${totalAmt.toStringAsFixed(2)}", // Utils.getTranslated(context, 'profile_value_ticket'),
              style: AppFont.poppinsSemibold(16,
                  color: widget.data.isAurum == true
                      ? AppColor.aurumGold()
                      : AppColor.appYellow())),
        ],
      ),
    );
  }

  Padding movieName(double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Utils.getTranslated(context, 'review_summary_movie'),
                style: AppFont.montRegular(14,
                    color: widget.data.isAurum == true
                        ? Colors.white
                        : AppColor.greyWording())),
            Text(widget.data.movieTitle,
                style: AppFont.poppinsMedium(14,
                    color: widget.data.isAurum == true
                        ? AppColor.aurumGold()
                        : Colors.white)),
          ],
        ),
      ),
    );
  }

  Padding cinemaName(double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Utils.getTranslated(context, 'review_summary_cinema'),
                style: AppFont.montRegular(14,
                    color: widget.data.isAurum == true
                        ? Colors.white
                        : AppColor.greyWording())),
            Text(
                widget.data
                    .cinemaName, // Utils.getTranslated(context, 'profile_value_ticket'),
                style: AppFont.poppinsMedium(14,
                    color: widget.data.isAurum == true
                        ? AppColor.aurumGold()
                        : Colors.white)),
          ],
        ),
      ),
    );
  }

  Padding seatList(double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Utils.getTranslated(context, 'review_summary_seat'),
                style: AppFont.montRegular(14,
                    color: widget.data.isAurum == true
                        ? Colors.white
                        : AppColor.greyWording())),
            Text(
                widget.data.seats.join(
                    ', '), // Utils.getTranslated(context, 'profile_value_ticket'),
                style: AppFont.poppinsMedium(14,
                    color: widget.data.isAurum == true
                        ? AppColor.aurumGold()
                        : Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget ticketTypeList(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Utils.getTranslated(context, 'review_summary_ticket'),
                style: AppFont.montRegular(14,
                    color: widget.data.isAurum == true
                        ? Colors.white
                        : AppColor.greyWording())),
            Column(
              children: [
                for (var data in widget.data.selectedTicket!)
                  SizedBox(
                    width: width - 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "${data.id!} x${data.qty.toString()}", // Utils.getTranslated(context, 'profile_value_ticket'),
                            style: AppFont.poppinsMedium(14,
                                color: widget.data.isAurum == true
                                    ? AppColor.aurumGold()
                                    : Colors.white)),
                        Text(
                            "RM ${(double.parse(data.price!) * data.qty!).toStringAsFixed(2)}", // Utils.getTranslated(context, 'profile_value_ticket'),
                            style: AppFont.poppinsMedium(14,
                                color: widget.data.isAurum == true
                                    ? AppColor.aurumGold()
                                    : Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget ecomboList(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.data.aurumCombo != null
                ? Text(Utils.getTranslated(context, "food_selection"),
                    style: AppFont.montRegular(14,
                        color: widget.data.isAurum == true
                            ? Colors.white
                            : AppColor.greyWording()))
                : const SizedBox(),
            widget.data.aurumCombo != null
                ? widget.data.aurumCombo!.isNotEmpty
                    ? Column(
                        children: [
                          for (var data in widget.data.aurumCombo!)
                            data.qty != 0
                                ? SizedBox(
                                    width: width - 32,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width - 110,
                                          child: Text(
                                              "${data.desc!} x${data.qty.toString()}", // Utils.getTranslated(context, 'profile_value_ticket'),
                                              style: AppFont.poppinsMedium(14,
                                                  color: widget.data.isAurum ==
                                                          true
                                                      ? AppColor.aurumGold()
                                                      : Colors.white)),
                                        ),
                                        Text(
                                            widget.data.isAurum == true
                                                ? ""
                                                : data.price == '0'
                                                    ? ""
                                                    : "RM ${(double.parse(data.price!.replaceAll("RM ", "")) * data.qty!).toStringAsFixed(2)}", // Utils.getTranslated(context, 'profile_value_ticket'),
                                            style: AppFont.poppinsMedium(14,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  )
                                : Container()
                        ],
                      )
                    : Text(
                        "N / A", // Utils.getTranslated(context, 'profile_value_ticket'),
                        style: AppFont.poppinsMedium(14, color: Colors.white))
                : const SizedBox(),
            widget.data.aurumCombo != null
                ? const SizedBox(
                    height: 16,
                  )
                : const SizedBox(),
            widget.data.showEcombo == true
                ? Text(Utils.getTranslated(context, "e_combo_review"),
                    style: AppFont.montRegular(14,
                        color: widget.data.isAurum == true
                            ? Colors.white
                            : AppColor.greyWording()))
                : const SizedBox(),
            widget.data.showEcombo == true
                ? widget.data.selectedCombo!.isNotEmpty &&
                        widget.data.selectedCombo!
                            .any((element) => element.qty! > 0)
                    ? Column(
                        children: [
                          for (var data in widget.data.selectedCombo!)
                            data.qty != 0
                                ? SizedBox(
                                    width: width - 32,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width - 110,
                                          child: Text(
                                              "${data.desc!} x${data.qty.toString()}", // Utils.getTranslated(context, 'profile_value_ticket'),
                                              style: AppFont.poppinsMedium(14,
                                                  color: widget.data.isAurum ==
                                                          true
                                                      ? AppColor.aurumGold()
                                                      : Colors.white)),
                                        ),
                                        Text(
                                            widget.data.isAurum == true
                                                ? ""
                                                : data.price == '0'
                                                    ? ""
                                                    : "RM ${(double.parse(data.price!.replaceAll("RM ", "")) * data.qty!).toStringAsFixed(2)}", // Utils.getTranslated(context, 'profile_value_ticket'),
                                            style: AppFont.poppinsMedium(14,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  )
                                : Container()
                        ],
                      )
                    : Text(
                        "N / A", // Utils.getTranslated(context, 'profile_value_ticket'),
                        style: AppFont.poppinsMedium(14, color: Colors.white))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Padding movieShowTimes(double width) {
    String displayDateTIme = '';

    if (widget.data.showDate == widget.data.opsDate) {
      displayDateTIme =
          "${DateFormat("E d MMM").format(DateFormat("yyyy-MM-d").parse(widget.data.showDate))}, ${Utils.time24totime12(widget.data.showTime)}";
    } else {
      var oprnDate = DateFormat("yyyy-MM-d")
          .parse(widget.data.showDate)
          .subtract(const Duration(days: 1));

      displayDateTIme =
          "${DateFormat("E d MMM").format(oprnDate)}, ${Utils.time24totime12(widget.data.showTime)} (${DateFormat("E d MMM").format(oprnDate)})";
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Utils.getTranslated(context, 'time'),
                style: AppFont.montRegular(14,
                    color: widget.data.isAurum == true
                        ? Colors.white
                        : AppColor.greyWording())),
            Text(displayDateTIme,
                style: AppFont.poppinsMedium(14,
                    color: widget.data.isAurum == true
                        ? AppColor.aurumGold()
                        : Colors.white)),
          ],
        ),
      ),
    );
  }

  Container timerUI(double width) {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return Container(
      width: width,
      height: 50,
      color: AppColor.appSecondaryBlack(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            widget.data.isAurum != null && widget.data.isAurum!
                ? 'assets/images/aurum-clock-icon.png'
                : 'assets/images/yellow-clock-icon.png',
            height: 18,
            width: 18,
          ) // child: Image.asset('assets/images/white-left-icon.png')
          ,
          const SizedBox(
            width: 7,
          ),
          Text(
              "${Utils.getTranslated(context, 'time_left')} $minutesStr:$secondsStr", // Utils.getTranslated(context, 'profile_value_ticket'),
              style: AppFont.montRegular(14,
                  color: widget.data.isAurum != null && widget.data.isAurum!
                      ? AppColor.aurumGold()
                      : AppColor.appYellow())),
        ],
      ),
    );
  }
}
