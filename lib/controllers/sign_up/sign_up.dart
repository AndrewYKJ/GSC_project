// ignore_for_file: unused_element, unused_local_variable

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/otp/otp.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:gsc_app/models/arguments/sign_up_arguments.dart';
import 'package:gsc_app/models/json/as_otp_model.dart';
import 'package:gsc_app/models/json/user_model.dart';
import 'package:gsc_app/widgets/custom_web_view.dart';
import 'package:intl/intl.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../login/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpScreen();
  }
}

enum GenderType { female, male }

class _SignUpScreen extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  var phoneCodeList = [
    Constants.COUNTRY_CODE_MY,
    Constants.COUNTRY_CODE_SG,
    Constants.COUNTRY_CODE_BR
  ];
  dynamic phoneCode = Constants.COUNTRY_CODE_MY;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isVerifyAge = false;
  bool isVerifyPromotion = true;
  String fullName = "";
  String mobileNo = "";
  String emailAddress = "";
  String referralCode = "";
  String password = "";
  String confirmPassword = "";
  dynamic dob;
  dynamic selectedProfession = "";
  dynamic selectedGender;
  dynamic selectedLocation = "";
  dynamic selectedRace = "";
  bool openMobileMenu = false;
  bool openProfessionMenu = false;
  bool openRaceMenu = false;
  bool openLocationMenu = false;
  dynamic currentTime;
  bool showBlur = false;
  dynamic formattedDob;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SIGN_UP_SCREEN);
    super.initState();
  }

  Future<OtpDTO> getOtp(BuildContext context, String mobile) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.getOTP(mobile, Constants.SIGN_UP_SMS_MSG);
  }

  Future<UserModel> verifyMobile(BuildContext context, String mobile) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.verifyMobile(mobile);
  }

  Future<UserModel> verifyEmail(BuildContext context, String email) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.verifyEmail(email);
  }

  getOtpCode(
      BuildContext context, String mobile, SignUpArguments registerData) async {
    await getOtp(context, mobile).then((value) {
      if (value.returnStatus == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OtpScreen(
                      code: phoneCode.toString(),
                      number: mobileNo,
                      type: Constants.OTP_SIGN_UP,
                      signUpData: registerData,
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
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
  }

  checkVerification(BuildContext context, String email, String mobile,
      SignUpArguments signUpData) async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await verifyMobile(context, mobile).then((value) {
      if (value.ReturnStatus == 51) {
        verifyEmail(context, email).then((value) {
          if (value.ReturnStatus == 51) {
            getOtpCode(context, phoneCode + mobileNo, signUpData);
          } else {
            EasyLoading.dismiss();

            Utils.printInfo('VERIFY EMAIL ${value.ReturnMessage}');
            Utils.showErrorDialog(
                context,
                Utils.getTranslated(context, "error_title"),
                Utils.getTranslated(context, "signup_email_exists"),
                true,
                "failed-icon.png",
                false,
                false, () {
              Navigator.of(context).pop();
            });
          }
        }, onError: (err) {
          EasyLoading.dismiss();

          Utils.showErrorDialog(
              context,
              Utils.getTranslated(context, "login_error_title"),
              err ?? Utils.getTranslated(context, "general_error"),
              true,
              "failed-icon.png",
              false,
              false, () {
            Navigator.pop(context);
          });
        });
      } else {
        EasyLoading.dismiss();
        Utils.printInfo('VERIFY MOBILE ${value.ReturnMessage}');
        Utils.showErrorDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            Utils.getTranslated(context, "signup_mobile_exists"),
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

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              backgroundColor: Colors.black,
            ),
            body: Container(
                padding: const EdgeInsets.only(top: 36, left: 16, right: 16),
                color: Colors.black,
                height: height,
                width: width,
                child: SafeArea(
                    child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _signUpTitle(),
                                  _login(),
                                  _fullNameTitle(),
                                  _fullNameText(),
                                  _mobileNoTitle(),
                                  _mobileInfo(),
                                  _emailTitle(),
                                  _emailField(),
                                  // _referralTitle(),
                                  // _referralField(),
                                  _passwordTitle(),
                                  _passwordField(),
                                  _confirmPasswordTitle(),
                                  _confirmPasswordField(),
                                  _genderTitle(),
                                  _genderRadio(),
                                  _raceTitle(),
                                  _raceField(),
                                  _dobTitle(),
                                  _dobField(),
                                  _dobInfo(),
                                  _professionTitle(),
                                  _professionField(),
                                  _locationTitle(),
                                  _locationField(),
                                  _ageVerificationCheckbox(),
                                  _promotionCheckbox(),
                                  _submitBtn()
                                ])))))));
  }

  Widget _signUpTitle() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Utils.getTranslated(context, "sign_up"),
              style: AppFont.montBold(22, color: Colors.white)),
          InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                  height: 30,
                  width: 30,
                  child: Image.asset(
                    Constants.ASSET_IMAGES + 'close-circle.png',
                    color: Colors.white,
                    fit: BoxFit.contain,
                  )))
        ]);
  }

  Widget _login() {
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 37),
        child: Row(children: [
          Text(Utils.getTranslated(context, "already_be_a_member"),
              style: AppFont.montRegular(14, color: Colors.white)),
          InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginScreen(),
                    ));
              },
              child: Text(Utils.getTranslated(context, "log_in_now"),
                  style: AppFont.montSemibold(14,
                      color: AppColor.appYellow(),
                      decoration: TextDecoration.underline)))
        ]));
  }

  Widget _fullNameTitle() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(Utils.getTranslated(context, "full_name"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _fullNameText() {
    return SizedBox(
        child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textCapitalization: TextCapitalization.words,
            style: AppFont.montRegular(14, color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 11),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      const BorderSide(color: Colors.white), //<-- SEE HERE
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.errorRed()),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      BorderSide(color: AppColor.appYellow()), //<-- SEE HERE
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.errorRed()),
                )),
            validator: (value) {
              if (value != null) {
                if (value.startsWith(" ")) {
                  return "Full Name cannot start with space";
                }
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                fullName = value.trim();
              });
            }));
  }

  Widget _mobileNoTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
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
                          openMobileMenu = !openMobileMenu;
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
                          child: openMobileMenu == false
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
                      if (phoneCode == Constants.COUNTRY_CODE_MY) {
                        if (!value.toString().startsWith('0')) {
                          return Utils.getTranslated(
                              context, "msia_mobile_err");
                        }

                        if (value.toString().length != 10 &&
                            value.toString().length != 11) {
                          return Utils.getTranslated(context, "mobile_err");
                        }
                      } else if (phoneCode == Constants.COUNTRY_CODE_BR) {
                        if (value.toString().startsWith('0') ||
                            value.toString().startsWith('1') ||
                            value.toString().startsWith('6') ||
                            value.toString().startsWith('9')) {
                          return Utils.getTranslated(context, "mobile_err");
                        }

                        if (value.toString().length != 7) {
                          return Utils.getTranslated(context, "mobile_err");
                        }
                      } else if (phoneCode == Constants.COUNTRY_CODE_SG) {
                        if (!value.toString().startsWith('8') &&
                            !value.toString().startsWith('9')) {
                          return Utils.getTranslated(context, "mobile_err");
                        }

                        if (value.toString().length != 8) {
                          return Utils.getTranslated(context, "mobile_err");
                        }
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

  Widget _emailTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "email_address"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _emailField() {
    return SizedBox(
        child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppFont.montRegular(14, color: Colors.white),
            cursorColor: Colors.white,
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
                )),
            validator: (value) {
              if (!isValidEmail(value.toString())) {
                return 'Email is not valid';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                emailAddress = value;
              });
            }));
  }

  Widget _referralTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "referral_code"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _referralField() {
    return SizedBox(
        child: TextFormField(
            style: AppFont.montRegular(14, color: Colors.white),
            cursorColor: Colors.white,
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
            ),
            validator: (value) {
              return null;
            },
            onChanged: (value) {
              setState(() {
                referralCode = value;
              });
            }));
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
                return 'Password is too short. (min 6 chars)';
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
                return 'Password does not match';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                confirmPassword = value;
              });
            }));
  }

  Widget _genderTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "gender"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _genderRadio() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Row(children: [
        Radio(
            activeColor: AppColor.appYellow(),
            visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: 'male', //GenderType.male
            groupValue: selectedGender,
            onChanged: ((value) {
              setState(() {
                selectedGender = value;
              });
            })),
        Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(Utils.getTranslated(context, "male_m"),
                style: AppFont.poppinsRegular(14, color: Colors.white))),
      ])),
      Expanded(
          child: Row(children: [
        Radio(
            activeColor: AppColor.appYellow(),
            visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: 'female', //GenderType.female
            groupValue: selectedGender,
            onChanged: ((value) {
              setState(() {
                selectedGender = value;
              });
            })),
        Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(Utils.getTranslated(context, "female_f"),
                style: AppFont.poppinsRegular(14, color: Colors.white))),
      ]))
    ]);
  }

  Widget _dobTitle() {
    return Container(
        margin: const EdgeInsets.only(top: 26, bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(Utils.getTranslated(context, "dob"),
              style: AppFont.montRegular(14, color: AppColor.greyWording())),
          Container(
              padding: const EdgeInsets.only(left: 6, top: 1),
              child: Image.asset('assets/images/info-icon.png',
                  height: 12, width: 12, color: AppColor.appYellow()))
        ]));
  }

  Widget _dobField() {
    return InkWell(
        onTap: () {
          setState(() {
            var today = DateTime.now();
            DatePicker.showDatePicker(context,
                theme: DatePickerTheme(
                  cancelStyle: AppFont.montSemibold(16, color: Colors.black),
                  doneStyle:
                      AppFont.montSemibold(16, color: AppColor.tncBlue()),
                ),
                showTitleActions: true,
                minTime: DateTime(today.year - 100, today.month, today.day),
                maxTime: DateTime(today.year - 18, today.month, today.day),
                onConfirm: (date) {
              setState(() {
                currentTime = date;
                dob = DateFormat('dd/MM/yyyy').format(date);
                formattedDob = date.millisecondsSinceEpoch.toString();
              });
            }, currentTime: currentTime);
          });
        },
        child: Container(
            alignment: Alignment.centerLeft,
            height: 50,
            padding: const EdgeInsets.only(left: 11, right: 11),
            width: MediaQuery.of(context).size.width,
            // width: 20,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(6)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dob.toString() == 'null' ? '' : dob.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white)),
                  Image.asset('assets/images/calender-icon.png')
                ])));
  }

  Widget _dobInfo() {
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [
          Image.asset('assets/images/info-icon.png',
              height: 14, width: 14, color: AppColor.appYellow()),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                      Utils.getTranslated(
                          context, "cannot_change_after_submission"),
                      style: AppFont.poppinsRegular(12,
                          color: AppColor.appYellow()))))
        ]));
  }

  Widget _raceTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "race"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _raceField() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
            padding: const EdgeInsets.only(left: 11, right: 11),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white)),
            child: DropdownButtonFormField2(
                dropdownMaxHeight: 48 * 5,
                dropdownPadding: EdgeInsets.zero,
                dropdownWidth: MediaQuery.of(context).size.width - 32,
                dropdownDecoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6)),
                itemPadding: EdgeInsets.zero,
                hint: Text(Utils.getTranslated(context, "select_race"),
                    style:
                        AppFont.montRegular(14, color: AppColor.greyWording())),
                offset: const Offset(-14, -18),
                onMenuStateChange: (isOpen) {
                  setState(() {
                    openRaceMenu = !openRaceMenu;
                  });
                },
                icon: Visibility(
                    visible: true,
                    child: openRaceMenu == false
                        ? Image.asset('assets/images/white-arrow-down.png')
                        : Image.asset('assets/images/white-arrow-up.png')),
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
                validator: (value) {
                  return null;
                },
                selectedItemBuilder: (context) {
                  return RaceList.raceList.map((String value) {
                    return Row(children: [
                      Text(
                        selectedRace,
                        style: AppFont.montRegular(14, color: Colors.white),
                      )
                    ]);
                  }).toList();
                },
                items: RaceList.raceList.map((String items) {
                  return DropdownMenuItem(
                    alignment: Alignment.bottomCenter,
                    value: items,
                    child: Container(
                        padding: const EdgeInsets.only(left: 16),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width - 32,
                        decoration: BoxDecoration(
                            color: selectedRace == items
                                ? AppColor.appYellow()
                                : Colors.white,
                            border: (RaceList.raceList.indexOf(items) !=
                                    (RaceList.raceList.length - 1))
                                ? Border(
                                    bottom: BorderSide(
                                        color: AppColor.borderGrey()))
                                : const Border(bottom: BorderSide.none)),
                        child: Text(items,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppFont.montRegular(14, color: Colors.black))),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRace = value;
                  });
                })));
  }

  Widget _professionTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "profession"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _professionField() {
    var openMenu = false;
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
            padding: const EdgeInsets.only(left: 11, right: 11),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white)),
            child: DropdownButtonFormField2(
                dropdownMaxHeight: 48 * 5,
                dropdownPadding: EdgeInsets.zero,
                dropdownWidth: MediaQuery.of(context).size.width - 32,
                dropdownDecoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6)),
                itemPadding: EdgeInsets.zero,
                hint: Text(Utils.getTranslated(context, "select_profession"),
                    style:
                        AppFont.montRegular(14, color: AppColor.greyWording())),
                offset: const Offset(-14, -18),
                onMenuStateChange: (isOpen) {
                  setState(() {
                    openProfessionMenu = !openProfessionMenu;
                  });
                },
                icon: Visibility(
                    visible: true,
                    child: openProfessionMenu == false
                        ? Image.asset('assets/images/white-arrow-down.png')
                        : Image.asset('assets/images/white-arrow-up.png')),
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
                validator: (value) {
                  return null;
                },
                selectedItemBuilder: (context) {
                  return ProfessionList.professionList.map((String value) {
                    return Row(children: [
                      Text(
                        selectedProfession,
                        style: AppFont.montRegular(14, color: Colors.white),
                      )
                    ]);
                  }).toList();
                },
                items: ProfessionList.professionList.map((String items) {
                  return DropdownMenuItem(
                    alignment: Alignment.bottomCenter,
                    value: items,
                    child: Container(
                        padding: const EdgeInsets.only(left: 16),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width - 32,
                        decoration: BoxDecoration(
                            color: selectedProfession == items
                                ? AppColor.appYellow()
                                : Colors.white,
                            border: (ProfessionList.professionList
                                        .indexOf(items) !=
                                    (ProfessionList.professionList.length - 1))
                                ? Border(
                                    bottom: BorderSide(
                                        color: AppColor.borderGrey()))
                                : const Border(bottom: BorderSide.none)),
                        child: Text(items,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppFont.montRegular(14, color: Colors.black))),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfession = value;
                  });
                })));
  }

  Widget _locationTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "location"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _locationField() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
            margin: const EdgeInsets.only(bottom: 38),
            padding: const EdgeInsets.only(left: 11, right: 11),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white)),
            child: DropdownButtonFormField2(
                dropdownMaxHeight: 48 * 5,
                dropdownPadding: EdgeInsets.zero,
                dropdownWidth: MediaQuery.of(context).size.width - 32,
                dropdownDecoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6)),
                itemPadding: EdgeInsets.zero,
                offset: const Offset(-14, -18),
                onMenuStateChange: (isOpen) {
                  setState(() {
                    openLocationMenu = !openLocationMenu;
                  });
                },
                hint: Text(Utils.getTranslated(context, "select_location"),
                    style:
                        AppFont.montRegular(14, color: AppColor.greyWording())),
                icon: Visibility(
                    visible: true,
                    child: openLocationMenu == false
                        ? Image.asset('assets/images/white-arrow-down.png')
                        : Image.asset('assets/images/white-arrow-up.png')),
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
                validator: (value) {
                  return null;
                },
                selectedItemBuilder: (context) {
                  return LocationList.locationList.map((String value) {
                    return Row(children: [
                      Text(
                        selectedLocation,
                        style: AppFont.montRegular(14, color: Colors.white),
                      )
                    ]);
                  }).toList();
                },
                items: LocationList.locationList.map((String items) {
                  return DropdownMenuItem(
                    alignment: Alignment.bottomCenter,
                    value: items,
                    child: Container(
                        padding: const EdgeInsets.only(left: 16),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width - 32,
                        decoration: BoxDecoration(
                            color: selectedLocation == items
                                ? AppColor.appYellow()
                                : Colors.white,
                            border: (LocationList.locationList.indexOf(items) !=
                                    (LocationList.locationList.length - 1))
                                ? Border(
                                    bottom: BorderSide(
                                        color: AppColor.borderGrey()))
                                : const Border(bottom: BorderSide.none)),
                        child: Text(items,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppFont.montRegular(14, color: Colors.black))),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                })));
  }

  Widget _ageVerificationCheckbox() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          height: 18,
          width: 18,
          child: Checkbox(
              side: BorderSide(color: AppColor.greyWording()),
              activeColor: AppColor.appYellow(),
              checkColor: Colors.black,
              value: isVerifyAge,
              onChanged: (value) {
                setState(() {
                  isVerifyAge = value!;
                });
              })),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.only(left: 9),
              child: RichText(
                  text: TextSpan(
                      text: Utils.getTranslated(context, "certify_18"),
                      style: AppFont.poppinsRegular(14, color: Colors.white),
                      children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WebView(
                                              url: Constants.TERMS_CONDITION,
                                              title: Utils.getTranslated(
                                                  context,
                                                  "terms_and_condition"),
                                            )))
                              },
                        text:
                            Utils.getTranslated(context, "terms_and_condition"),
                        style: AppFont.poppinsRegular(14,
                            color: AppColor.underlineGreen(),
                            decoration: TextDecoration.underline)),
                    TextSpan(
                        text: Utils.getTranslated(context, "and"),
                        style: AppFont.poppinsRegular(14, color: Colors.white)),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WebView(
                                            url: Constants.PRIVACY_POLICY,
                                            title: Utils.getTranslated(
                                                context, "privacy_policy"))))
                              },
                        text: Utils.getTranslated(context, "privacy_policy"),
                        style: AppFont.poppinsRegular(14,
                            color: AppColor.underlineGreen(),
                            decoration: TextDecoration.underline)),
                    TextSpan(
                        text: Utils.getTranslated(
                            context, "confirm_provided_info"),
                        style: AppFont.poppinsRegular(14, color: Colors.white)),
                  ]))))
    ]);
  }

  Widget _promotionCheckbox() {
    return Padding(
        padding: const EdgeInsets.only(top: 31, bottom: 30),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              height: 18,
              width: 18,
              child: Checkbox(
                  side: BorderSide(color: AppColor.greyWording()),
                  activeColor: AppColor.appYellow(),
                  checkColor: Colors.black,
                  value: isVerifyPromotion,
                  onChanged: (value) {
                    setState(() {
                      isVerifyPromotion = value!;
                    });
                  })),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: Text(Utils.getTranslated(context, "receive_promotion"),
                      style: AppFont.poppinsRegular(14, color: Colors.white))))
        ]));
  }

  Widget _submitBtn() {
    if (fullName.isNotEmpty &&
        mobileNo.isNotEmpty &&
        emailAddress.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        selectedGender != null &&
        selectedRace != null &&
        selectedRace.length > 0 &&
        dob != null &&
        selectedProfession != null &&
        selectedProfession.length > 0 &&
        selectedLocation != null &&
        selectedLocation.length > 0 &&
        isVerifyAge == true &&
        _formKey.currentState!.validate()) {
      var myDob = "/Date($formattedDob)/";

      var signUpData = SignUpArguments(
          name: fullName,
          dob: myDob,
          email: emailAddress,
          mobile: phoneCode + mobileNo,
          password: password,
          isVerifyPromo: isVerifyPromotion ? 1 : 0,
          gender: formatGender(selectedGender),
          location: selectedLocation,
          profession: selectedProfession,
          race: selectedRace,
          countryCode: phoneCode,
          referral: referralCode);

      return Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: AppColor.appYellow()), //change color
              onPressed: () {
                setState(() {
                  if (_formKey.currentState!.validate()) {
                    checkVerification(context, emailAddress,
                        phoneCode + mobileNo, signUpData);
                  }
                });
              },
              child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(Utils.getTranslated(context, "submit"),
                      style: AppFont.montSemibold(14, color: Colors.black)))));
    } else {
      return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
          child: Container(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColor.darkYellow()),
              // color: Colors.deepOrange,
              width: MediaQuery.of(context).size.width,
              child: Text(Utils.getTranslated(context, "submit"),
                  textAlign: TextAlign.center,
                  style: AppFont.montSemibold(14, color: Colors.black))));
    }
  }

  bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  String formatGender(String gender) {
    switch (gender) {
      case 'female':
        return 'F';
      case 'male':
        return 'M';
      default:
        return '';
    }
  }
}
