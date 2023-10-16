import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/constants.dart';
import '../../const/utils.dart';
import '../../dio/api/as_auth_api.dart';
import '../../models/json/as_otp_model.dart';
import '../../models/json/user_model.dart';
import '../otp/otp.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordScreen();
  }
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String mobileNo = "";
  var phoneCodeList = [
    Constants.COUNTRY_CODE_MY,
    Constants.COUNTRY_CODE_SG,
    Constants.COUNTRY_CODE_BR
  ];
  dynamic phoneCode = Constants.COUNTRY_CODE_MY;
  bool openMobileMenu = false;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_FORGOT_PWD_SCREEN);
    super.initState();
  }

  Future<OtpDTO> getOtp(BuildContext context, String mobile) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getOTP(mobile, Constants.FORGET_SMS_MSG);
  }

  Future<UserModel> verifyMobile(BuildContext context, String mobile) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.verifyMobile(mobile);
  }

  checkVerification(BuildContext context, String mobile) async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await verifyMobile(context, mobile).then((value) {
      if (value.ReturnStatus == 1) {
        getOtpCode(context, mobile);
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
    EasyLoading.show();
    await getOtp(context, mobile).then((value) {
      if (value.returnStatus == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OtpScreen(
                      code: phoneCode.toString(),
                      number: mobileNo,
                      type: Constants.OTP_FORGET,
                    )));
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
            toolbarHeight: 0,
            backgroundColor: Colors.black,
          ),
          body: Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              color: Colors.black,
              height: height,
              width: width,
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
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Image.asset(
                                        'assets/images/white-left-icon.png') // child: Image.asset('assets/images/white-left-icon.png')
                                    )),
                            _forgotPasswordTitle(),
                            _insertYourPhoneNo(),
                            _mobileNoTitle(),
                            _mobileInfo(),
                          ]))))),
          bottomNavigationBar: _submitBtn(),
        ));
  }

  Widget _forgotPasswordTitle() {
    return Text(Utils.getTranslated(context, "forgot_password"),
        style: AppFont.montBold(22,
            color: Colors
                .white)); //Text(Utils.getTranslated(context, "otp_verification"), style: AppFont.montBold(22, color: Colors.white)
  }

  Widget _insertYourPhoneNo() {
    return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(Utils.getTranslated(context, "insert_phone_no"),
            style: AppFont.poppinsRegular(12,
                color: Colors
                    .white))); //Text(Utils.getTranslated(context, "otp_verification"), style: AppFont.montBold(22, color: Colors.white)
  }

  Widget _mobileNoTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 36, bottom: 8),
        child: Text(Utils.getTranslated(context, "mobile_number"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _mobileInfo() {
    var openMenu = false;
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
                      // buttonWidth: 137,
                      dropdownWidth: 137,
                      offset: const Offset(0, -18),
                      // onTap: () {
                      //   setState(() {
                      //     openMenu = !openMenu;
                      //   });
                      // },
                      icon: Visibility(
                          visible: true,
                          child: openMenu == false
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Image.asset(
                                    'assets/images/white-arrow-down.png',
                                  ))
                              : SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Image.asset(
                                    'assets/images/white-arrow-up.png',
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
                    style: AppFont.montRegular(14, color: Colors.white),
                    validator: (value) {
                      if (phoneCode == Constants.COUNTRY_CODE_MY &&
                          !value.toString().startsWith("0")) {
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

  Widget _submitBtn() {
    if (mobileNo.isNotEmpty && _formKey.currentState!.validate()) {
      return BottomAppBar(
          color: Colors.black,
          child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 13),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: AppColor.appYellow()), //change color
                  onPressed: () {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        checkVerification(context, phoneCode + mobileNo);
                      }
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Text(Utils.getTranslated(context, "next"),
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
                  child: Text(Utils.getTranslated(context, "next"),
                      textAlign: TextAlign.center,
                      style: AppFont.montSemibold(14, color: Colors.black)))));
    }
  }
}
