import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/as_member.api.dart';
import 'package:gsc_app/models/json/as_qr_token_model.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../main.dart';

class QrMemberScreen extends StatefulWidget {
  final bool isFromProfile;

  const QrMemberScreen({Key? key, required this.isFromProfile})
      : super(key: key);

  @override
  _QrMemberScreen createState() => _QrMemberScreen();
}

class _QrMemberScreen extends State<QrMemberScreen> with RouteAware {
  var isLogin = false;
  String? qrData;
  Timer? _timer;
  int seconds = 0;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_QR_MEMBER_SCREEN);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    _checkLoginState();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (mounted) {
      if (!isLogin && AppCache.me != null) {
        _checkLoginState();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _startTimer(int countdown) {
    seconds = countdown;
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (seconds > 0) {
            seconds--;
          }
          if (seconds == 0) {
            getMemberToken();
          }
        });
      }
    });
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken) {
      setState(() {
        isLogin = true;
      });
    }

    if (isLogin) {
      AppCache.getStringValue(AppCache.MEMBER_QR_EXPIRY).then((value) {
        if (value.isNotEmpty) {
          var cacheData = jsonDecode(value);
          var now = DateTime.now();
          DateTime dt2 = DateTime.parse(cacheData['time']);
          setState(() {
            qrData = cacheData['token'];
            AppCache.qrCode = qrData;
          });
          Duration diff = dt2.difference(now);
          if (diff.inSeconds.isNegative) {
            getMemberToken();
          } else {
            if (_timer == null) {
              _startTimer(diff.inSeconds > 180 ? 180 : diff.inSeconds);
            }
          }
        } else {
          getMemberToken();
        }
      });
    }
  }

  Future<QrTokenDTO> _getQrToken(BuildContext context) async {
    AsMemberApi asMemberApi = AsMemberApi(context);
    return asMemberApi.memberQrToken(
      context,
      AppCache.me!.CardLists!.first.CardNo!,
    );
  }

  getMemberToken() async {
    EasyLoading.show();
    await _getQrToken(context).then((value) {
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
            qrData = value.token ?? "";
            AppCache.qrCode = qrData;
          }

          if (value.expiryDateTime != null) {
            var date = Utils.getEpochUnix(value.expiryDateTime!);

            var convertDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(
                Utils.epochToDateMiliseconds(int.parse(date.toString())));
            Utils.printInfo("CONVERT DATE: $convertDate");
            var res = {'time': convertDate, 'token': value.token};
            AppCache.setString(AppCache.MEMBER_QR_EXPIRY, json.encode(res));
            var now = DateTime.now();
            DateTime dt2 = DateTime.parse(convertDate);
            Duration diff = dt2.difference(now);
            if (!diff.inSeconds.isNegative) {
              _startTimer(diff.inSeconds > 180 ? 180 : diff.inSeconds);
            } else {
              _startTimer(180);
            }
          }
        });
      }
    }).whenComplete(() => EasyLoading.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return WillPopScope(
      onWillPop: () => returnButton(),
      child: Container(
        width: screenWidth,
        height: availableHeight,
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: screenWidth,
                  height: 60,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.zero,
                          iconSize: 40,
                          onPressed: () {
                            Navigator.pop(context, qrData);
                          },
                        ),
                      )),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isLogin || AppCache.me == null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          child: Text(
                            Utils.getTranslated(context, "member_qr_not_login"),
                            style: AppFont.montSemibold(16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (isLogin && AppCache.me != null)
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(80.0, 0, 80.0, 0),
                            child: Image.asset(
                              Constants.ASSET_IMAGES + "gsc-rewards-logo.png",
                              width: 180,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      if (isLogin && AppCache.me != null)
                        const SizedBox(
                          height: 50,
                        ),
                      if (isLogin && AppCache.me != null)
                        Text(
                          Utils.getTranslated(context, "member_qr_title"),
                          style: AppFont.montBold(18),
                          textAlign: TextAlign.center,
                        ),
                      if (isLogin && AppCache.me != null)
                        Container(
                            width: 250,
                            height: 250,
                            margin: const EdgeInsets.fromLTRB(25, 15, 25, 10),
                            alignment: Alignment.center,
                            child: QrImage(data: qrData ?? "")),
                      if (isLogin && AppCache.me != null)
                        SizedBox(
                          width: screenWidth,
                          height: 30,
                          child: Text(
                            formatedTime(timeInSecond: seconds),
                            style:
                                AppFont.poppinsRegular(14, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: screenWidth - 40,
                  height: 50,
                  child: (isLogin && AppCache.me != null) &&
                          !widget.isFromProfile
                      ? TextButton(
                          child: Text(
                              Utils.getTranslated(context, "my_tickets_btn")),
                          onPressed: () {
                            // Navigator.pop(context);
                            Navigator.pushNamed(
                                context, AppRoutes.myTicketRoute);
                          },
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            backgroundColor: AppColor.appYellow(),
                            textStyle:
                                AppFont.montSemibold(14, color: Colors.black),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                        )
                      : (!isLogin || AppCache.me == null)
                          ? TextButton(
                              child: Text(
                                  Utils.getTranslated(context, "login_btn")),
                              onPressed: () async {
                                var res = await Navigator.pushNamed(
                                    context, AppRoutes.loginRoute);
                                if (res != null) {
                                  if (res == true) {
                                    Utils.printInfo("LOGIN SUCCESS");
                                    Navigator.pop(context, true);
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                                backgroundColor: AppColor.appYellow(),
                                textStyle: AppFont.montSemibold(14,
                                    color: Colors.black),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0)),
                              ),
                            )
                          : Container(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  formatedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "$min" : "$min";
    String second = sec.toString().length <= 1 ? "$sec" : "$sec";
    // String minute = min.toString().length <= 1 ? "0$min" : "$min";
    // String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return min < 1 ? "$second s" : " $minute min $second s";
  }

  returnButton() {
    return Navigator.pop(context, qrData);
  }
}
