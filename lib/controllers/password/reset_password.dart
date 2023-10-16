import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../../dio/api/as_auth_api.dart';
import '../../models/json/user_model.dart';
import '../../widgets/custom_dialog.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String mobile;
  const ResetPasswordScreen({Key? key, required this.mobile}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordScreen();
  }
}

class _ResetPasswordScreen extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String password = "";
  String confirmPassword = "";
  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<UserModel> forgotPassword(String mobile, String password) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.forgetPassword(mobile, password, null);
  }

  forgotPasswordProfile(String mobile, String password) async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await forgotPassword(mobile, password).then((value) {
      EasyLoading.dismiss();
      if (value.ReturnStatus == 1) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: Utils.getTranslated(context, "reset_password_success"),
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

        Future.delayed(const Duration(seconds: 2)).then((value) {
          Navigator.of(context).pop(true);
        });
      } else {
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, "forget_error_title"),
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
      Utils.printInfo('FORGET ERROR: $e');
      Utils.showErrorDialog(
          context,
          Utils.getTranslated(context, "forget_error_title"),
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
    }).whenComplete(() => EasyLoading.dismiss());
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_RESET_PWD_SCREEN);
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
                                      Navigator.pop(context);
                                    },
                                    child: Image.asset(
                                        'assets/images/white-left-icon.png') // child: Image.asset('assets/images/white-left-icon.png')
                                    )),
                            _resetPasswordTitle(),
                            _passwordTitle(),
                            _passwordField(),
                            _confirmPasswordTitle(),
                            _confirmPasswordField()
                          ]))))),
          bottomNavigationBar: _submitBtn(),
        ));
  }

  Widget _resetPasswordTitle() {
    return Text(Utils.getTranslated(context, "reset_password"),
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
                      forgotPasswordProfile(widget.mobile, password);
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
