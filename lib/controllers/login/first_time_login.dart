import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/constants.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../../dio/api/as_auth_api.dart';
import '../../models/json/as_dynamic_field_model.dart';
import '../../models/json/as_update_device_model.dart';
import '../../models/json/user_model.dart';
import '../../widgets/custom_dialog.dart';

class FirstTimeLoginScreen extends StatefulWidget {
  final String mobile;
  const FirstTimeLoginScreen({Key? key, required this.mobile})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FirstTimeLoginScreen();
  }
}

class _FirstTimeLoginScreen extends State<FirstTimeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String password = "";
  String confirmPassword = "";
  bool showPassword = false;
  bool showConfirmPassword = false;

  late String appVersion;
  late String deviceUUID;
  late String deviceName;
  late String deviceModel;
  late String deviceVersion;

  Future<UserModel> updatePassword(String mobile, String password, List<AS_DYNAMIC_MODEL> data) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.forgetPassword(mobile, password, data);
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

  updatePasswordProfile(String mobile, String password) async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await updatePassword(mobile, password, [AS_DYNAMIC_MODEL(
                colValue: "N",
                name: Constants.ASCENTIS_DYNAMIC_MIGRATED_MEMBER,
                type: 'PlainText')]).then((value) {
      if (value.ReturnStatus == 1){
        loginUser(mobile, password);
      } else {
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, "first_time_error_title"),
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
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "first_time_error_title"),
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

  void loginUser(String mobile, String password){
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
                    title: Utils.getTranslated(context, "update_password_success"),
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
                  var count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 3;
                  });
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

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS__FIRST_TIME_LOGIN_SCREEN);
    super.initState();
    getAllInfo();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 0,
            backgroundColor: Colors.black,
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
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 24),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Image.asset(
                                        'assets/images/white-left-icon.png') // child: Image.asset('assets/images/white-left-icon.png')
                                    )),
                            _updatePasswordTitle(),
                            _passwordTitle(),
                            _passwordField(),
                            _confirmPasswordTitle(),
                            _confirmPasswordField()
                          ]))))),
          bottomNavigationBar: _submitBtn(),
        ));
  }

  Widget _updatePasswordTitle() {
    return Text(Utils.getTranslated(context, "first_time_login_password"),
        style: AppFont.montBold(22, color: Colors.white));
  }

  Widget _passwordTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(Utils.getTranslated(context, "reset_password_new"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _passwordField() {
    return Container(
        alignment: Alignment.center,
        child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscuringCharacter: '*',
            obscureText: !showPassword,
            cursorColor: Colors.white,
            style: AppFont.montRegular(14, color: Colors.white),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.5, horizontal: 11),
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
                        ? Image.asset('assets/images/invisible-icon.png')
                        : Image.asset('assets/images/visible-icon.png'))),
            validator: (value) {
              if (value != null && value.length < 6) {
                return Utils.getTranslated(context, 'password_short');
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                password = value;
              });
            }));
  }

  Widget _confirmPasswordTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "retype_password"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _confirmPasswordField() {
    return Container(
        alignment: Alignment.center,
        child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            obscuringCharacter: '*',
            obscureText: !showConfirmPassword,
            cursorColor: Colors.white,
            style: AppFont.montRegular(14, color: Colors.white),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.5, horizontal: 11),
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
                        showConfirmPassword = !showConfirmPassword;
                      });
                    },
                    child: !showConfirmPassword
                        ? Image.asset('assets/images/invisible-icon.png')
                        : Image.asset('assets/images/visible-icon.png'))),
            validator: (value) {
              if (password.length >= 6 && value != password) {
                return Utils.getTranslated(context, 'password_mismatch');
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                confirmPassword = value;
              });
            }));
  }

  Widget _submitBtn() {
    if (password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        _formKey.currentState!.validate()) {
      return BottomAppBar(
          color: Colors.black,
          child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 13),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: AppColor.appYellow()), //change color
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      updatePasswordProfile(widget.mobile, password);
                    } else {}
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Text(Utils.getTranslated(context, "confirm_btn"),
                          style: const TextStyle(color: Colors.black))))));
    } else {
      return BottomAppBar(
          color: Colors.black,
          child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 13),
              child: Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColor.darkYellow()),
                  width: MediaQuery.of(context).size.width,
                  child: Text(Utils.getTranslated(context, "confirm_btn"),
                      textAlign: TextAlign.center,
                      style: AppFont.montSemibold(14, color: Colors.black)))));
    }
  }
}
