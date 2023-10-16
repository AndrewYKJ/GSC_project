import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:gsc_app/models/json/settings_model.dart';
import 'package:gsc_app/routes/approutes.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../../widgets/custom_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  final VoidCallback isLogoutSuccess;
  const ChangePasswordScreen({Key? key, required this.isLogoutSuccess})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordScreen();
  }
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String currentPassword = "";
  String newPassword = "";
  String confirmPassword = "";
  bool showCurrentPassword = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<ChangePasswordModel> changePassword(BuildContext context,
      String mobileNo, String oldPass, String newPass) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.changePassword(mobileNo, oldPass, newPass);
  }

  callChangePassword() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    var mobileNo = AppCache.me!.MemberLists!.first.MobileNo!;
    await changePassword(context, mobileNo, currentPassword, newPassword).then(
        (value) {
      if (value.IsValid == true && value.ReturnStatus == 1) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: Utils.getTranslated(
                    context, "change_password_success_dialog_msg"),
                message: '',
                img: "change-password-success-icon.png",
                showButton: false,
                showConfirm: false,
                showCancel: false,
                confirmStr: null,
                onConfirm: () {
                  Navigator.of(context).pop(true);
                },
              );
            }).then((value) async {
          if (value != null && value == true) {
            AppCache.removeValues(context);
            widget.isLogoutSuccess();
            var count = 0;
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginRoute,
                (route) {
              return count++ == 3;
            });
          }
        });
        Future.delayed(const Duration(seconds: 2)).then((value) {
          Navigator.of(context).pop(true);
        });
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.ReturnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      }
    }, onError: (error) {
      Utils.printInfo('CHANGE PASSWORD ERROR: $error');
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          error != null
              ? error.toString().isNotEmpty
                  ? error.toString()
                  : Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          "failed-icon.png",
          false,
          false, () {
        Navigator.pop(context);
      });
    }).whenComplete(() {
      setState(() {
        EasyLoading.dismiss();
      });
    });
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_CHANGE_PWD_SCREEN);
    super.initState();
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
            toolbarHeight: 60,
            backgroundColor: AppColor.backgroundBlack(),
            centerTitle: true,
            title: Text(
              Utils.getTranslated(context, 'settings_change_password'),
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
                      _currentPasswordTitle(),
                      _currentPasswordField(),
                      _passwordTitle(),
                      _passwordField(),
                      _confirmPasswordTitle(),
                      _confirmPasswordField()
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _submitBtn(),
        ));
  }

  Widget _currentPasswordTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(
            Utils.getTranslated(context, "change_password_current_password"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _currentPasswordField() {
    return Container(
        alignment: Alignment.center,
        child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscuringCharacter: '*',
            obscureText: !showCurrentPassword,
            cursorColor: Colors.white,
            style: AppFont.montRegular(14, color: Colors.white),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.5, horizontal: 11),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                      color: AppColor.rectBorderGrey()), //<-- SEE HERE
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
                        showCurrentPassword = !showCurrentPassword;
                      });
                    },
                    child: !showCurrentPassword
                        ? Image.asset('assets/images/invisible-icon.png')
                        : Image.asset('assets/images/visible-icon.png'))),
            validator: (value) {
              return null;
            },
            onChanged: (value) {
              setState(() {
                currentPassword = value;
              });
            }));
  }

  Widget _passwordTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
            Utils.getTranslated(context, "change_password_new_password"),
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
                  borderSide: BorderSide(
                      color: AppColor.rectBorderGrey()), //<-- SEE HERE
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
                newPassword = value;
              });
            }));
  }

  Widget _confirmPasswordTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
            Utils.getTranslated(context, "change_password_retype_password"),
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
                  borderSide: BorderSide(
                      color: AppColor.rectBorderGrey()), //<-- SEE HERE
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
              if (newPassword.length >= 6 && value != newPassword) {
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
    if (currentPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
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
                      if (currentPassword != newPassword) {
                        callChangePassword();
                      } else {
                        Utils.showErrorDialog(
                            context,
                            Utils.getTranslated(context, "error_title"),
                            Utils.getTranslated(context,
                                "change_password_new_pass_current_pass_same"),
                            true,
                            "failed-icon.png",
                            false,
                            false, () {
                          Navigator.pop(context);
                        });
                      }
                    }
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
