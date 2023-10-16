// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/arguments/sign_up_arguments.dart';
import 'package:gsc_app/models/json/as_otp_model.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:pinput/pinput.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../const/app_font.dart';
import '../../dio/api/as_auth_api.dart';
import '../../models/json/as_update_device_model.dart';
import '../../models/json/user_model.dart';
import '../../widgets/custom_dialog.dart';

class OtpScreen extends StatefulWidget {
  String code;
  String number;
  String type;
  SignUpArguments? signUpData;
  OtpScreen(
      {Key? key,
      required this.code,
      required this.number,
      required this.type,
      this.signUpData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OtpScreen();
  }
}

class _OtpScreen extends State<OtpScreen> {
  dynamic otpCode;
  Timer? _timer;
  int seconds = 0;
  bool otpIsValid = false;
  int timerCount = 180;
  late String appVersion;
  late String deviceUUID;
  late String deviceName;
  late String deviceModel;
  late String deviceVersion;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_OTP_SCREEN);

    super.initState();
    getAllInfo();
    _startTimer();
  }

  Future getAllInfo() async {
    await AppCache.getStringValue(AppCache.DEVICE_INFO).then((value) {
      var dataMap = json.decode(value);

      appVersion = dataMap["appVersion"];
      deviceUUID = dataMap["deviceUUID"];
      deviceModel = dataMap["deviceModel"];
      deviceName = dataMap["deviceName"];
      deviceVersion = dataMap["deviceVersion"];
    });

    setState(() {});
  }

  Future<OtpDTO> verifyOtp(
      BuildContext context, String mobile, String code) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.verifyOTP(mobile, code);
  }

  Future<UserModel> signUp(BuildContext context) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.signUp(context, widget.signUpData!);
  }

  Future<OtpDTO> getOtp(BuildContext context, String mobile) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getOTP(mobile, getType(widget.type));
  }

  Future<UserModel> login(
      BuildContext context, String mobile, String password) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.login(context, mobile, password);
  }

  Future<UserModel> getProfile(
      BuildContext context, String mobile, String email, String member) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getProfile(member, mobile, email);
  }

  Future<UpdateDeviceDTO> updateDevice(
      BuildContext context, String member) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.updateMemberDevice(member, appVersion, deviceUUID,
        AppCache.fcmToken!, deviceName, deviceModel, deviceVersion);
  }

  getOtpCode(BuildContext context, String mobile) async {
    EasyLoading.show();
    await getOtp(context, mobile).then((value) {
      EasyLoading.dismiss();
      if (value.returnStatus == 1) {
        setState(() {
          _startTimer();
        });
      } else {
        Utils.printInfo('GET OTP CODE STATUS NOT 1 ${value.returnMessage}');
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.returnMessage != null
                ? value.returnMessage!
                : Utils.getTranslated(context, "general_error"),
            true,
            null, () {
          Navigator.of(context).pop();
        });
      }
    }, onError: (e) {
      EasyLoading.dismiss();
      Utils.printInfo('GET UPDATE PROFILE ERROR: $e');

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

  verifyOtpCode(BuildContext context, String mobile, String otp) async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await verifyOtp(context, mobile, otp).then((value) {
      if (value.returnStatus == 1) {
        if (widget.type == Constants.OTP_SIGN_UP && widget.signUpData != null) {
          signUpProfile(widget.signUpData?.mobile ?? "",
              widget.signUpData?.password ?? "");
        } else if (widget.type == Constants.OTP_FIRST_TIME_LOGIN) {
          Navigator.pushNamed(context, AppRoutes.firstTimeLoginRoute,
              arguments: mobile);
        } else {
          Navigator.pushNamed(context, AppRoutes.resetPasswordRoute,
              arguments: [mobile]);
        }
      } else {
        Utils.printInfo('GET OTP CODE STATUS NOT 1 ${value.returnMessage}');
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, getErrorTitle(widget.type)),
            value.returnMessage != null
                ? value.returnMessage!
                : Utils.getTranslated(context, "general_error"),
            true,
            "failed-icon.png",
            false,
            false, () {
          Navigator.pop(context);
        });
      }
    }, onError: (e) {
      EasyLoading.dismiss();
      Utils.printInfo('VERIFY OTP ERROR: $e');
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, getErrorTitle(widget.type)),
          e != null
              ? e.toString().isNotEmpty
                  ? e.toString()
                  : Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          "failed-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
  }

  void loginUser(String mobile, String password) {
    EasyLoading.show();
    login(context, mobile, password).then((loginValue) async {
      if (loginValue.ReturnStatus == 1 && loginValue.IsValid == true) {
        await getProfile(context, "", "", loginValue.MemberInfo!.MemberID!)
            .then((value) {
          EasyLoading.dismiss();
          if (value.ReturnStatus != 1) {
            Utils.printInfo("USER PROFILE STATUS NOT VALIDs: $value");
            Utils.showErrorDialog(
                context,
                Utils.getTranslated(context, "login_error_title"),
                value.ReturnMessage ??
                    Utils.getTranslated(context, "general_error"),
                true,
                "failed-icon.png",
                false,
                false, () {
              Navigator.pop(context);
            });
          } else {
            setState(() {
              if (loginValue.MemberInfo != null) {
                if (loginValue.MemberInfo!.MemberID != null) {
                  AppCache.setString(AppCache.ACCESS_TOKEN_PREF,
                      loginValue.MemberInfo!.MemberID!);
                }
              }

              AppCache.me = value;
            });

            updateDevice(
                context, AppCache.me?.MemberLists?.first.MemberID ?? '');
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        }, onError: (error) {
          EasyLoading.dismiss();
          Utils.printInfo('GET USER PROFILE ERROR: $error');
          Utils.showErrorDialog(
              context,
              Utils.getTranslated(context, "login_error_title"),
              error ?? Utils.getTranslated(context, "general_error"),
              true,
              "failed-icon.png",
              false,
              false, () {
            Navigator.pop(context);
          });
        });
      } else {
        EasyLoading.dismiss();
        Utils.printInfo("LOGIN STATUS NOT 1 $loginValue");
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, "login_error_title"),
            loginValue.IsValid == false && loginValue.ReturnStatus == 1
                ? Utils.getTranslated(context, "login_error_password")
                : loginValue.ReturnMessage ??
                    Utils.getTranslated(context, "general_error"),
            true,
            "failed-icon.png",
            false,
            false, () {
          Navigator.pop(context);
        });
      }
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
    }).whenComplete(() {});
  }

  signUpProfile(String mobile, String password) async {
    await signUp(context).then((value) {
      EasyLoading.dismiss();
      if (value.ReturnStatus == 1) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: Utils.getTranslated(context, "sign_up_successful"),
                message: '',
                img: "success-icon.png",
                showButton: false,
                showConfirm: false,
                showCancel: false,
                confirmStr: null,
                onConfirm: () {
                  Navigator.of(context).pop(true);
                },
              );
            }).then((value) {
          if (value != null) {
            if (value == true) {
              loginUser(mobile, password);
            }
          }
        });

        Future.delayed(const Duration(seconds: 2)).then((value) {
          Navigator.of(context).pop(true);
        });
      } else {
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, "signup_error_title"),
            value.ReturnMessage != null
                ? value.ReturnMessage!
                : Utils.getTranslated(context, "general_error"),
            true,
            "failed-icon.png",
            false,
            false, () {
          Navigator.pop(context);
        });
      }
    }, onError: (e) {
      EasyLoading.dismiss();
      Utils.printInfo('SIGN UP ERROR: $e');
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "signup_error_title"),
          e != null
              ? e.toString().isNotEmpty
                  ? e.toString()
                  : Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          "failed-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
    });
  }

  String getType(String type) {
    switch (type) {
      case Constants.OTP_SIGN_UP:
        return Constants.SIGN_UP_SMS_MSG;
      case Constants.OTP_FORGET:
        return Constants.FORGET_SMS_MSG;
      case Constants.OTP_FIRST_TIME_LOGIN:
        return Constants.FIRST_TIME_SMS_MSG;
      default:
        return '';
    }
  }

  String getErrorTitle(String type) {
    switch (type) {
      case Constants.OTP_SIGN_UP:
        return 'signup_error_title';
      case Constants.OTP_FORGET:
        return 'forget_error_title';
      case Constants.OTP_FIRST_TIME_LOGIN:
        return 'first_time_error_title';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.black,
        ),
        body: Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            height: height,
            width: width,
            color: Colors.black,
            child: SafeArea(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 24),
                      child: InkWell(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Image.asset(
                              'assets/images/white-left-icon.png') // child: Image.asset('assets/images/white-left-icon.png')
                          )),
                  _otpTitle(),
                  _otpInfoText(),
                  _otpSection(),
                  _resendOtp()
                ])))),
        bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            child: otpIsValid == false //otpCode == null || otpCode.length < 4
                ? Container(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 13),
                    width: MediaQuery.of(context).size.width - 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: AppColor.darkYellow()),
                      onPressed: () {
                        setState(() {});
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                              widget.type == Constants.OTP_SIGN_UP
                                  ? Utils.getTranslated(context, "next")
                                  : Utils.getTranslated(context, "verify_btn"),
                              style: AppFont.montSemibold(14,
                                  color: Colors.black))),
                    ))
                : Container(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 13),
                    width: MediaQuery.of(context).size.width - 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: AppColor.appYellow()),
                      onPressed: () async {
                        verifyOtpCode(
                            context, widget.code + widget.number, otpCode);
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                              widget.type == Constants.OTP_SIGN_UP
                                  ? Utils.getTranslated(context, "next")
                                  : Utils.getTranslated(
                                      context, "verify_btn"), //
                              style: AppFont.montSemibold(14,
                                  color: Colors.black))),
                    ))),
      ),
    );
  }

  Widget _otpTitle() {
    return Text(Utils.getTranslated(context, "otp_verification"),
        style: AppFont.montBold(22, color: Colors.white));
  }

  Widget _otpSection() {
    final defaultPinTheme = PinTheme(
      width: 57,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      textStyle: AppFont.poppinsBold(26, color: Colors.white),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.appYellow()),
      borderRadius: BorderRadius.circular(6),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.appYellow()),
      borderRadius: BorderRadius.circular(6),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.errorRed()),
      borderRadius: BorderRadius.circular(6),
    );

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      errorPinTheme: errorPinTheme,
      errorTextStyle: AppFont.poppinsRegular(12, color: AppColor.errorRed()),
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
      onChanged: ((value) {
        setState(() {
          otpIsValid = value.length == 4;
          otpCode = value;
        });
      }),
      validator: (s) {
        return null;
      },
      showCursor: true,
      onCompleted: (pin) => {
        setState(() {
          if (pin.length == 4) {
            otpIsValid = true;
          } else {
            otpIsValid = false;
          }
        })
      },
    );
  }

  Widget _otpInfoText() {
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        child: RichText(
            text: TextSpan(
                text: Utils.getTranslated(context, "enter_verification_title"),
                style: AppFont.montRegular(14),
                children: [
              TextSpan(
                text: widget.code,
                style: AppFont.montSemibold(14),
              ),
              TextSpan(
                  text: formatMobileNo(widget.number),
                  style: AppFont.montSemibold(14))
            ])));
  }

  Widget _resendOtp() {
    if (seconds == 0) {
      return Container(
          padding: const EdgeInsets.only(top: 36),
          child: Wrap(children: [
            Text(Utils.getTranslated(context, "did_not_receive_otp"),
                style: AppFont.poppinsRegular(14, color: Colors.white)),
            InkWell(
                onTap: () {
                  getOtpCode(context, widget.code + widget.number);
                },
                child: Text(Utils.getTranslated(context, "resend_otp"),
                    style: AppFont.poppinsRegular(14,
                        color: AppColor.yellow(),
                        decoration: TextDecoration.underline)))
          ]));
    } else {
      return Container(
          padding: const EdgeInsets.only(top: 36),
          child: Wrap(children: [
            Text(Utils.getTranslated(context, "did_not_receive_otp"),
                style: AppFont.poppinsRegular(14, color: Colors.white)),

            Text(Utils.getTranslated(context, "resend_otp"),
                style: AppFont.poppinsRegular(14, color: AppColor.appYellow())),

            Text(formatedTime(timeInSecond: seconds),
                style: AppFont.poppinsRegular(14, color: AppColor.appYellow()))
            // Text(' (' + seconds.toString() + 's' ')',
            //     style: AppFont.poppinsRegular(14,
            //         color: AppColor.appYellow()))
          ]));
    }
  }

  void _startTimer() {
    seconds = timerCount;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (seconds > 0) {
            seconds--;
          }
          if (seconds == 0) {
            timer.cancel();
          }
        });
      }
    });
  }

  String formatMobileNo(String phoneNo) {
    String formattedPhone = "";

    if (phoneNo.length > 4) {
      var len = phoneNo.length - 4;
      int count = 0;
      for (int i = 0; i < phoneNo.length; i++) {
        if (count < len) {
          formattedPhone += '*';
        } else {
          formattedPhone += phoneNo[i];
        }
        count++;
      }
    } else {
      formattedPhone = phoneNo;
    }
    return formattedPhone;
  }

  formatedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "$min" : "$min";
    String second = sec.toString().length <= 1 ? "$sec" : "$sec";
    // String minute = min.toString().length <= 1 ? "0$min" : "$min";
    // String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return min < 1 ? " ($second s)" : " ($minute min $second s)";
  }
}
