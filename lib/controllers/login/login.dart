import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:gsc_app/models/json/as_update_device_model.dart';
import 'package:gsc_app/models/json/user_model.dart';
import 'package:gsc_app/routes/approutes.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../../models/json/as_otp_model.dart';
import '../../widgets/custom_dialog.dart';
import '../otp/otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> with RouteAware {
  final _formKey = GlobalKey<FormState>();

  var phoneCodeList = [
    Constants.COUNTRY_CODE_MY,
    Constants.COUNTRY_CODE_SG,
    Constants.COUNTRY_CODE_BR
  ];
  dynamic phoneCode = Constants.COUNTRY_CODE_MY;
  bool onTapPassword = false;
  bool showPassword = false;
  String mobileNo = "";
  String password = "";

  bool openMenu = false;
  late String appVersion;
  late String deviceUUID;
  late String deviceName;
  late String deviceModel;
  late String deviceVersion;
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_LOGIN_SCREEN);
    super.initState();
    getAllInfo();
    _checkAccessTokenState();
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

  Future<void> _checkAccessTokenState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.AS_API_ACCESS_TOKEN_PREF);
    if (!hasAccessToken) {
      getASToken();
    }
  }

  Future generateASToken(BuildContext context) async {
    AsAuthApi itm = AsAuthApi(context);
    return itm.generateASApiToken();
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

  Future<UserModel> verifyMobile(BuildContext context, String mobile) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.verifyMobile(mobile);
  }

  Future<OtpDTO> getOtp(BuildContext context, String mobile) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getOTP(mobile, Constants.FIRST_TIME_SMS_MSG);
  }

  getASToken() async {
    await generateASToken(context).then((value) {
      setState(() {
        if (value != null) {
          var tokenData = value;
          Utils.printInfo("ASCENTIS TOKEN: $tokenData");
          AppCache.setString(
              AppCache.AS_API_ACCESS_TOKEN_PREF, tokenData["access_token"]);
        }
      });
    }).catchError((error) {
      Utils.printInfo(error);
    });
  }

  checkVerification(BuildContext context, String mobile) async {
    await verifyMobile(context, mobile).then((value) {
      if (value.ReturnStatus == 1) {
        getOtpCode(context, phoneCode + mobileNo);
      } else {
        EasyLoading.dismiss();
        Utils.printInfo('VERIFY MOBILE ${value.ReturnMessage}');
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.ReturnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            "failed-icon.png",
            false,
            false, () {
          Navigator.of(context).pop();
        });
      }
    }, onError: (e) {
      EasyLoading.dismiss();
      Utils.printInfo('GET VERIFY MOBILE ERROR: $e');
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "login_error_title"),
          e ?? Utils.getTranslated(context, "general_error"),
          true,
          "failed-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
    });
  }

  getOtpCode(BuildContext context, String mobile) async {
    await getOtp(context, mobile).then((value) {
      if (value.returnStatus == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OtpScreen(
                    code: phoneCode.toString(),
                    number: mobileNo,
                    type: Constants.OTP_FIRST_TIME_LOGIN)));
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
      Utils.printInfo('GET OTP ERROR: $e');

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
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        body: Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            height: height,
            width: width,
            color: Colors.black,
            child: SafeArea(
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _loginTitle(width),
                        _mobileNoTitle(),
                        _mobileInfo(),
                        _passwordTitle(),
                        _passwordField(),
                        _forgetPasswordText(),
                      ],
                    ))))),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: SizedBox(
              height: 130, child: Column(children: [_login(), _signUp()])),
        ),
      ),
    );
  }

  Widget _loginTitle(double width) {
    return SizedBox(
        width: width,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(Utils.getTranslated(context, 'login_btn'),
              style: AppFont.montBold(22, color: Colors.white)),
          InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                Constants.ASSET_IMAGES + 'close-circle.png',
                height: 30,
                width: 30,
              ))
        ]));
  }

  Widget _mobileNoTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 8),
        child: Text(Utils.getTranslated(context, "mobile_number"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _mobileInfo() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 117,
              height: 50,
              child: Container(
                  padding: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white)),
                  child: DropdownButtonFormField2(
                      onMenuStateChange: (isOpen) {
                        setState(() {
                          openMenu = !openMenu;
                        });
                      },
                      dropdownPadding: EdgeInsets.zero,
                      dropdownDecoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(6)),
                      itemPadding: EdgeInsets.zero,
                      dropdownWidth: 137,
                      offset: const Offset(0, -18),
                      icon: Visibility(
                          visible: true,
                          child: openMenu == false
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Image.asset(
                                    Constants.ASSET_IMAGES +
                                        'white-arrow-down.png',
                                  ))
                              : SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Image.asset(
                                    Constants.ASSET_IMAGES +
                                        'white-arrow-up.png',
                                  ))),
                      decoration: const InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none),
                      validator: (value) {
                        return null;
                      },
                      value: phoneCode,
                      selectedItemBuilder: (context) {
                        return phoneCodeList.map((String value) {
                          return Row(children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 6, right: 8),
                                child: SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: Image.asset(
                                      MapPhoneCode.flag[value].toString(),
                                    ))),
                            Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  phoneCode,
                                  style: AppFont.montRegular(14,
                                      color: Colors.white),
                                )),
                          ]);
                        }).toList();
                      },
                      items: phoneCodeList.map((String items) {
                        return DropdownMenuItem(
                            alignment: Alignment.bottomCenter,
                            value: items,
                            child: Container(
                                alignment: Alignment.center,
                                width: 137,
                                decoration: BoxDecoration(
                                    color: phoneCode == items
                                        ? AppColor.appYellow()
                                        : Colors.white,
                                    border: (phoneCodeList.indexOf(items) !=
                                            (phoneCodeList.length - 1))
                                        ? Border(
                                            bottom: BorderSide(
                                                color: AppColor.borderGrey()))
                                        : const Border(
                                            bottom: BorderSide.none)),
                                child: Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Row(children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 7, right: 7),
                                          child: SizedBox(
                                              height: 32,
                                              width: 32,
                                              child: Image.asset(MapPhoneCode
                                                  .flag[items]
                                                  .toString()))),
                                      Text(MapPhoneCode.countryCode[items],
                                          style: AppFont.montRegular(14,
                                              color: Colors.black)),
                                      Text(' (' + items + ')',
                                          style: AppFont.montRegular(14,
                                              color: Colors.black))
                                    ]))));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          phoneCode = value;
                        });
                      }))),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.only(left: 11, right: 11),
                  child: TextFormField(
                    cursorColor: Colors.white,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        errorMaxLines: 2,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.5, horizontal: 11),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                              color: Colors.white), //<-- SEE HERE
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppColor.errorRed()),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                              color: AppColor.appYellow()), //<-- SEE HERE
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppColor.errorRed()),
                        )),
                    style: AppFont.poppinsRegular(14, color: Colors.white),
                    validator: (value) {
                      if (phoneCode == Constants.COUNTRY_CODE_MY &&
                          !value.toString().startsWith('0')) {
                        return Utils.getTranslated(context, "msia_mobile_err");
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        mobileNo = value;
                      });
                    },
                  )))
        ]);
  }

  Widget _passwordTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "password"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _passwordField() {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 11),
        child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            onTap: () {
              setState(() {});
            },
            obscureText: !showPassword,
            obscuringCharacter: '*',
            cursorColor: Colors.white,
            style: AppFont.poppinsRegular(14, color: Colors.white),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 11),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      const BorderSide(color: Colors.white), //<-- SEE HERE
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      BorderSide(color: AppColor.appYellow()), //<-- SEE HERE
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      BorderSide(color: AppColor.errorRed()), //<-- SEE HERE
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      BorderSide(color: AppColor.errorRed()), //<-- SEE HERE
                ),
                suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    child: !showPassword
                        ? Image.asset(
                            Constants.ASSET_IMAGES + 'invisible-icon.png')
                        : Image.asset(
                            Constants.ASSET_IMAGES + 'visible-icon.png'))),
            validator: (value) {
              return null;
            },
            onChanged: (value) {
              setState(() {
                password = value;
              });
            }));
  }

  Widget _forgetPasswordText() {
    return Container(
        alignment: Alignment.topRight,
        child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.forgotPasswordRoute);
            },
            child: Text(Utils.getTranslated(context, "forgot_password") + "?",
                style: AppFont.poppinsRegular(
                  12,
                  decoration: TextDecoration.underline,
                  color: AppColor.appYellow(),
                ))));
  }

  Widget _login() {
    if (mobileNo.isNotEmpty &&
        password.isNotEmpty &&
        _formKey.currentState!.validate()) {
      return InkWell(
          onTap: () {},
          child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(primary: AppColor.appYellow()),
                    onPressed: () async {
                      onLogin(context, phoneCode + mobileNo, password);
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Text(Utils.getTranslated(context, "login"),
                            style:
                                AppFont.montSemibold(14, color: Colors.black))),
                  ))));
    } else {
      return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
          child: Container(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColor.darkYellow()),
              width: MediaQuery.of(context).size.width,
              child: Text(Utils.getTranslated(context, "login"),
                  textAlign: TextAlign.center,
                  style: AppFont.montSemibold(14, color: Colors.black))));
    }
  }

  Widget _signUp() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(Utils.getTranslated(context, "not_a_member") + ' ',
              style: AppFont.montRegular(14, color: Colors.white)),
          InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, AppRoutes.signUpRoute)
                    .then((value) {
                  if (value != null) {
                    if (value == true) {
                      Utils.printInfo(">>>>>>>> true from push sign up");
                    }
                  }
                });
              },
              child: Text(Utils.getTranslated(context, "sign_up_now"),
                  style: AppFont.montSemibold(14,
                      color: AppColor.appYellow(),
                      decoration: TextDecoration.underline)))
        ]));
  }

  Future<void> onLogin(
      BuildContext context, String mobile, String password) async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    verifyMobile(context, mobile).then((value) {
      if (value.ReturnStatus == 1) {
        if (value.MemberLists != null) {
          if (value.MemberLists!.isNotEmpty) {
            if (value.MemberLists!.first.DynamicFieldLists != null) {
              var migrated = value.MemberLists!.first.DynamicFieldLists!
                  .firstWhere((element) =>
                      element.name ==
                      Constants.ASCENTIS_DYNAMIC_MIGRATED_MEMBER)
                  .colValue;
              if (migrated != null && migrated == "Y") {
                getOtpCode(context, phoneCode + mobileNo);
              } else {
                loginUser(mobile, password);
              }
            } else {
              loginUser(mobile, password);
            }
          } else {
            EasyLoading.dismiss();
            Utils.printInfo("USER MEMBER LIST = 0");
            Utils.showErrorDialog(
                context,
                Utils.getTranslated(context, "login_error_title"),
                Utils.getTranslated(context, "general_error"),
                true,
                "failed-icon.png",
                false,
                false, () {
              Navigator.pop(context);
            });
          }
        } else {
          EasyLoading.dismiss();
          Utils.printInfo("USER MEMBER LIST NULL");
          Utils.showErrorDialog(
              context,
              Utils.getTranslated(context, "login_error_title"),
              Utils.getTranslated(context, "general_error"),
              true,
              "failed-icon.png",
              false,
              false, () {
            Navigator.pop(context);
          });
        }
      } else {
        EasyLoading.dismiss();
        Utils.printInfo('VERIFY MOBILE ${value.ReturnMessage}');
        if (value.ReturnStatus == 51) {
          Navigator.pushReplacementNamed(context, AppRoutes.signUpRoute)
              .then((value) {
            if (value != null) {
              if (value == true) {
                Utils.printInfo(">>>>>>>> true from push sign up");
              }
            }
          });
          Utils.showErrorDialog(
              context,
              Utils.getTranslated(context, "info_title"),
              Utils.getTranslated(context, "user_not_exist"),
              true,
              null,
              false,
              false,
              () {});
        } else {
          Utils.showErrorDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              value.ReturnMessage ??
                  Utils.getTranslated(context, "general_error"),
              true,
              "failed-icon.png",
              false,
              false, () {
            Navigator.of(context).pop();
          });
        }
      }
    }, onError: (err) {
      EasyLoading.dismiss();
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "login_error_title"),
          err.toString() != ''
              ? err.toString()
              : Utils.getTranslated(context, "general_error"),
          true,
          "failed-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
      Utils.printInfo("VERIFY MOBILE ERROR: $err");
    });
  }

  void loginUser(String mobile, String password) {
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
              // Utils.printWrapped(value.toJson().toString());
            });

            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return CustomDialogBox(
                    title: Utils.getTranslated(context, "login_successful"),
                    message: '',
                    img: "success-icon.png",
                    showButton: false,
                    showConfirm: false,
                    showCancel: false,
                    confirmStr: null,
                    onConfirm: () {},
                  );
                }).then((value) {
              if (value != null) {
                if (value == true) {
                  Navigator.of(context).pop(true);
                }
              }
            });
            updateDevice(
                context, AppCache.me?.MemberLists?.first.MemberID ?? '');
            Future.delayed(const Duration(seconds: 2)).then((value) {
              Navigator.of(context).pop(true);
            });
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
}
