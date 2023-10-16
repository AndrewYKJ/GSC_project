// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../const/analytics_constant.dart';
import '../../models/arguments/init_transaction_arguments.dart';
import '../../models/arguments/payment_result_arguments.dart';

class PaymentGateway extends StatefulWidget {
  final InitSalesTransactionArg data;
  const PaymentGateway({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<PaymentGateway> createState() {
    return _PaymentGateway();
  }
}

class _PaymentGateway extends State<PaymentGateway> {
  late final WebViewController _controller;
  InAppWebViewController? webViewController;
  bool isLoading = false;
  bool paymentSuccess = false;
  late String html;
  late String queryParams;
  @override
  void initState() {
    super.initState();
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_PAYMENT_GATEWAY_SCREEN);

    setParams();
  }

  setParams() {
    var tranNoValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.tranNo}';
    var tranTypeValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.tranType}';
    var transDateValue = DateFormat('ddMMyyyy HH:mm:ss').format(
        DateFormat("dd MMM yyyy HH:mm").parse(
            '${widget.data.initSalesDTO!.prepareStatus!.status!.transDate}'));
    var tranAmtValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.tranAmt}';
    var tranRefValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.tranRef}';
    var emailAddressValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.emailaddress}';
    var phoneNoValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.phoneno}';
    var memberNameValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.memberName}';
    var memberNameID =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.memberId}';

    var movieTagValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.movieTag}';
    var ticketTagValue =
        '${widget.data.initSalesDTO!.prepareStatus!.status!.ticketTag}';
    var checksum = getCheckSum(tranNoValue, 'NA');

    var map = {
      'EM_VER': '2.0',
      'EM_EMALL_ID': 'NA',
      'EM_TX_TYPE': tranTypeValue,
      'EM_TX_DATE': transDateValue,
      'EM_TX_NBR': tranNoValue,
      'EM_TX_AMT': tranAmtValue,
      'EM_TX_REF': tranRefValue,
      'EM_EMAIL': emailAddressValue,
      'EM_PHONE_NO': phoneNoValue,
      'EM_MBR_NAME': memberNameValue,
      'EM_MBR_ID': memberNameID,
      'EM_MBR_IC': '',
      'EM_CHK_SUM': checksum.toString(),
      'MOVIE': movieTagValue,
      'TICKET': ticketTagValue,
    };
    queryParams = Utils.buildQueryParameters(map);
  }

  int getCheckSum(String trxNo, String emallID) {
    if (trxNo.isNotEmpty && emallID.isNotEmpty) {
      int trxNoChecksum = 0;
      int emallChecksum = 0;

      int t = 0;
      int e = 0;

      while (t < trxNo.length) {
        trxNoChecksum += trxNo.codeUnitAt(t);
        t += 1;
      }

      while (e < emallID.length) {
        emallChecksum += emallID.codeUnitAt(e);
        e += 1;
      }

      final finalChecksum = trxNoChecksum + emallChecksum;
      return finalChecksum;
    }
    return 0;
  }

  Future<void> _retrieveLabelText() async {
    if (webViewController != null) {
      const script = '''
        function getLabelWithText(text) {
        var labels = document.getElementsByTagName('label');
        for (var i = 0; i < labels.length; i++) {
          var label = labels[i];
          if (label.textContent.includes(text)) {
            var fontTag = label.querySelector('font');
            if (fontTag) {
              return fontTag.textContent.trim();
            }
          }
        }
        return null;
      }

        getLabelWithText("Status Description:");
      ''';

      try {
        final result =
            await webViewController!.evaluateJavascript(source: script);
        paymentSuccess =
            !result.toString().toLowerCase().contains("unsuccessful");
      } catch (e) {
        Utils.printInfo("Error retrieving label text: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.lightGrey(),
                ),
              )
            : SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: InAppWebView(
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        supportZoom: false,
                      ),
                    ),
                    initialUrlRequest: URLRequest(
                        url: Uri.parse(
                            Constants.ESERVICES_PAYMENTGATEWAY), //queryParams
                        method: 'POST',
                        body: Uint8List.fromList(utf8.encode(queryParams)),
                        headers: {
                          'Content-Type': 'application/x-www-form-urlencoded'
                        }),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStop: (controller, url) async {
                      _retrieveLabelText();

                      controller.evaluateJavascript(source: '''
  var closeButton = document.querySelector('button[value="Close"]');
  if (closeButton) {
    closeButton.addEventListener('click', function() {
    
      console.log("${Constants.PAYMENT_SUCCESS_CLOSE}");
    
    });
  }
  ''');
                    },
                    onCloseWindow: (controller) {},
                    onConsoleMessage: (controller, consoleMessage) {
                      if (consoleMessage.message
                          .contains(Constants.PAYMENT_SUCCESS_CLOSE)) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.successPaymentRoute,
                          (route) => false,
                          arguments: TransactionResultArg(
                              movieTitle: widget.data.movieTitle,
                              isSuccess: paymentSuccess),
                        );
                      }
                    },
                    onLoadHttpError:
                        (controller, url, statusCode, description) {},
                    onLoadError: (controller, url, code, message) {},
                    onPrint: (controller, url) {},
                  ),
                ),
              ));
  }
}
