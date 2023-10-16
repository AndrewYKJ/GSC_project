import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:gsc_app/models/json/as_dynamic_field_model.dart';
import 'package:gsc_app/models/json/user_model.dart';
import 'package:gsc_app/widgets/custom_dialog.dart';
import 'package:intl/intl.dart';

import '../../const/analytics_constant.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var phoneCodeList = [
    Constants.COUNTRY_CODE_MY,
    Constants.COUNTRY_CODE_SG,
    Constants.COUNTRY_CODE_BR
  ];
  final _formKey = GlobalKey<FormState>();
  dynamic phoneCode = Constants.COUNTRY_CODE_MY;

  bool isVerifyPromotion = false;
  String fullName = "";
  String mobileNo = "";
  String emailAddress = "";
  List<AS_DYNAMIC_MODEL> fieldList = [];
  List<AS_DYNAMIC_MODEL> colList = [];
  dynamic dob = '';
  dynamic selectedRace = "Others";
  dynamic selectedProfession = "Others";
  dynamic selectedGender = 'female';
  dynamic selectedLocation = "Selangor";
  bool openMobileMenu = false;
  bool openProfessionMenu = false;
  bool openLocationMenu = false;
  dynamic currentTime;
  bool showBlur = false;
  dynamic formattedDob;
  Future<UserModel> verifyEmail(BuildContext context, String email) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.verifyEmail(email);
  }

  Future<UserModel> updateProfile(BuildContext context) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.updateProfileV3(
        AppCache.me!.MemberLists!.first.MemberID!,
        fullName,
        mobileNo,
        selectedGender.toString().substring(0, 1).toUpperCase(),
        emailAddress,
        isVerifyPromotion ? 'GSC Rewards' : '',
        colList,
        fieldList);
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_EDIT_PROFILE_SCREEN);

    setUserDetails();
    super.initState();
  }

  setUserDetails() {
    setState(() {
      fullName = AppCache.me?.MemberLists?.first.Name ?? '';
      mobileNo = AppCache.me?.MemberLists?.first.MobileNo ?? '';
      if (mobileNo.isNotEmpty) {
        if (mobileNo.startsWith(Constants.COUNTRY_CODE_BR)) {
          phoneCode = Constants.COUNTRY_CODE_BR;
        } else if (mobileNo.startsWith(Constants.COUNTRY_CODE_SG)) {
          phoneCode = Constants.COUNTRY_CODE_SG;
        } else if (mobileNo.startsWith(Constants.COUNTRY_CODE_MY)) {
          phoneCode = Constants.COUNTRY_CODE_MY;
        }
      }

      emailAddress = AppCache.me?.MemberLists?.first.Email ?? '';

      AppCache.me?.MemberLists?.first.Gender != null
          ? AppCache.me!.MemberLists!.first.Gender!.toLowerCase().contains('m')
              ? selectedGender = 'male'
              : selectedGender = 'female'
          : '';

      dob = AppCache.me?.MemberLists?.first.DOB != null
          ? Utils.getEpochUnix(AppCache.me!.MemberLists!.first.DOB!)
          : '';

      if (AppCache.me?.MemberLists?.first.DynamicColumnLists != null) {
        for (var element
            in AppCache.me!.MemberLists!.first.DynamicColumnLists!) {
          switch (element.name!) {
            case Constants.ASCENTIS_DYNAMIC_GENDER_CODE:
              if (element.colValue!.toLowerCase().contains('m')) {
                selectedGender = 'male';
              } else {
                selectedGender = 'female';
              }
              break;

            case Constants.ASCENTIS_DYNAMIC_RACE_CODE:
              selectedRace = Utils.capitalizeEveryWord(
                  element.colValue!.isNotEmpty ? element.colValue! : 'others');
              break;
            case Constants.ASCENTIS_DYNAMIC_OCCUPATION_CODE:
              selectedProfession = Utils.capitalizeEveryWord(
                  element.colValue!.isNotEmpty ? element.colValue! : 'others');
              break;
            default:
          }
        }
      }
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        for (var element
            in AppCache.me!.MemberLists!.first.DynamicFieldLists!) {
          switch (element.name!) {
            case Constants.ASCENTIS_DYNAMIC_STATE_CODE:
              selectedLocation = Utils.capitalizeEveryWord(
                  element.colValue!.isNotEmpty
                      ? element.colValue!
                      : 'selangor');
              break;
            case Constants.ASCENTIS_DYNAMIC_MARKETING_CODE:
              isVerifyPromotion = element.colValue == "1" ? true : false;
              break;

            default:
          }
        }
      }
    });
  }

  getUpdateProfile() async {
    String exisitingEmail = AppCache.me?.MemberLists?.first.Email ?? '';
    if (exisitingEmail != emailAddress) {
      verifyEmail(context, emailAddress).then((value) async {
        if (value.ReturnStatus == 51) {
          await updateProfile(context).then((value) {
            if (value.IsValid == false) {
            } else {
              setState(() {
                // Utils.printWrapped('GET UPDATE PROFILE ERROR: $value');
                value.MemberLists != null
                    ? AppCache.me!.MemberLists = value.MemberLists
                    : null;
              });
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return CustomDialogBox(
                      title: Utils.getTranslated(context, "save_successful"),
                      message: '',
                      img: "success-icon.png",
                      showButton: false,
                      showConfirm: false,
                      showCancel: false,
                      confirmStr: null,
                    );
                  }).then((value) {
                Navigator.of(context).pop(true);
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
      await updateProfile(context).then((value) {
        if (value.ReturnStatus == 1) {
          if (value.IsValid == false) {
          } else {
            setState(() {
              // Utils.printWrapped('GET UPDATE PROFILE ERROR: $value');
              value.MemberLists != null
                  ? AppCache.me!.MemberLists = value.MemberLists
                  : null;
            });
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return CustomDialogBox(
                    title: Utils.getTranslated(context, "save_successful"),
                    message: '',
                    img: "success-icon.png",
                    showButton: false,
                    showConfirm: false,
                    showCancel: false,
                    confirmStr: null,
                  );
                }).then((value) {
              Navigator.of(context).pop(true);
            });
          }
        } else {
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              Utils.getTranslated(context, "general_error"),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.appSecondaryBlack(),
        body: Stack(
          children: [
            SafeArea(
                child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        editProfileAppBar(context),
                      ];
                    },
                    body: GestureDetector(
                      onTap: (() {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      }),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 0, bottom: 24),
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _headerView(context),
                                Form(
                                    key: _formKey,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fullNameTitle(),
                                            _fullNameText(),
                                            _mobileNoTitle(),
                                            _mobileInfo(),
                                            _emailTitle(),
                                            _emailField(),
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
                                            _promotionCheckbox(),
                                            _submitBtn()
                                          ]),
                                    ))
                              ]),
                        ),
                      ),
                    ))),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black,
                height: MediaQuery.of(context).padding.bottom,
              ),
            )
          ],
        ));
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
                value: selectedRace,
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

  SliverAppBar editProfileAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColor.appSecondaryBlack(),
      elevation: 0,
      automaticallyImplyLeading: true,
      leading: InkWell(
        onTap: () => Navigator.of(context).pop(true),
        child: Image.asset(
          Constants.ASSET_IMAGES + 'white-left-icon.png',
          width: 20,
          height: 20,
        ),
      ),
      centerTitle: true,
      title: Text(
        Utils.getTranslated(context, "edit_profile_title_text"),
        style: AppFont.montRegular(18, color: Colors.white),
      ),
    );
  }

  Widget _headerView(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth,
        height: 250,
        child: Stack(
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + 'profile-base.png',
              width: screenWidth,
              fit: BoxFit.fitWidth,
            ),
            Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10.0,
                      spreadRadius: 0,
                      color: Colors.black38,
                    ),
                  ],
                ),
                height: 250,
                width: screenWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 4, color: AppColor.appYellow())),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          Utils.getInitials(fullName.trim()),
                          style: AppFont.montSemibold(20,
                              color: AppColor.appYellow()),
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          fullName,
                          style: AppFont.montBold(14, color: Colors.white),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ));
  }

  Widget _fullNameTitle() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(Utils.getTranslated(context, "full_name"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _fullNameText() {
    return SizedBox(
        child: TextFormField(
            initialValue: fullName,
            style: AppFont.montRegular(14, color: Colors.white),
            cursorColor: Colors.white,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.5, horizontal: 11),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.appYellow()),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.errorRed()),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.errorRed()),
                )),
            validator: (value) {
              if (fullName.trim().isEmpty) {
                return 'Please Enter a Valid Name';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                fullName = value;
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
    return Row(children: [
      AbsorbPointer(
        child: SizedBox(
            width: 117,
            height: 50,
            child: Container(
                padding: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColor.iconGrey()),
                ),
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
                    dropdownWidth: 137,
                    offset: const Offset(0, -18),
                    icon: Visibility(
                        visible: true,
                        child: openMobileMenu == false
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: Image.asset(
                                  'assets/images/white-arrow-down.png',
                                  color: AppColor.iconGrey(),
                                ))
                            : SizedBox(
                                height: 18,
                                width: 18,
                                child: Image.asset(
                                  'assets/images/white-arrow-up.png',
                                  color: AppColor.iconGrey(),
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
                              padding: const EdgeInsets.only(left: 6, right: 8),
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
                                    color: AppColor.iconGrey()),
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
                                      : const Border(bottom: BorderSide.none)),
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
      ),
      Expanded(
          child: AbsorbPointer(
        child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: TextFormField(
              initialValue: mobileNo.contains('+')
                  ? mobileNo.replaceAll(phoneCode, '')
                  : mobileNo.replaceAll(phoneCode.toString().substring(1), ''),
              cursorColor: Colors.white,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.5, horizontal: 11),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColor.iconGrey()),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColor.appYellow()),
                  )),
              style: AppFont.montRegular(14, color: AppColor.iconGrey()),
              validator: (value) {
                return null;
              },
              onChanged: (value) {
                setState(() {
                  mobileNo = value;
                });
              },
            )),
      ))
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
            initialValue: emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppFont.montRegular(14, color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.5, horizontal: 11),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.appYellow()),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.errorRed()),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColor.errorRed()),
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
            value: 'male',
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
            value: 'female',
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
    DateTime dobDisplayTime = Utils.epochToDate(int.parse(dob.toString()));

    if (dobDisplayTime.isBefore(DateTime(1982, 1, 1))) {
      dobDisplayTime = dobDisplayTime.add(Duration(hours: 8));
    }
    return Container(
        alignment: Alignment.centerLeft,
        height: 50,
        padding: const EdgeInsets.only(left: 11, right: 11),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: AppColor.iconGrey()),
            borderRadius: BorderRadius.circular(6)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
              dob.toString() == ''
                  ? ''
                  : DateFormat('dd/MM/yyyy').format(dobDisplayTime),
              textAlign: TextAlign.center,
              style: AppFont.montRegular(14, color: AppColor.iconGrey())),
        ]));
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

  Widget _professionTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(Utils.getTranslated(context, "profession"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _professionField() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
            padding: const EdgeInsets.only(left: 11, right: 11),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white)),
            child: DropdownButtonFormField2(
                value: selectedProfession,
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
                value: selectedLocation,
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

  Widget _promotionCheckbox() {
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 30),
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
        selectedGender != null &&
        dob != null &&
        selectedProfession != null &&
        selectedProfession.length > 0 &&
        selectedLocation != null &&
        selectedLocation.length > 0) {
      return Container(
          padding: const EdgeInsets.only(bottom: 34),
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: AppColor.appYellow()),
              onPressed: () {
                fieldList.clear();
                colList.clear();

                setState(() {
                  fieldList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_STATE_CODE,
                      colValue: selectedLocation,
                      type: 'PlainText'));
                  fieldList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_MARKETING_CODE,
                      colValue: isVerifyPromotion ? '1' : '0',
                      type: 'PlainText'));
                  if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any(
                      (element) =>
                          element.name ==
                          Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
                    fieldList.add(AS_DYNAMIC_MODEL(
                        colValue: AppCache
                            .me!.MemberLists!.first.DynamicFieldLists!
                            .firstWhere((element) =>
                                element.name ==
                                Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                            .colValue,
                        name: Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE,
                        type: 'PlainText'));
                  }
                  colList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_GENDER_CODE,
                      colValue: selectedGender
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      type: 'nvarchar(1)'));
                  colList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_COUNTRY_CODE,
                      colValue: phoneCode,
                      type: 'nvarchar(10)'));
                  colList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_RACE_CODE,
                      colValue: selectedRace.toUpperCase(),
                      type: 'nvarchar(50)'));
                  colList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_OCCUPATION_CODE,
                      colValue: selectedProfession.toUpperCase(),
                      type: 'nvarchar(50)'));
                  colList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_NOTIFY_POST,
                      colValue: isVerifyPromotion ? 'True' : 'False',
                      type: 'nvarchar(50)'));
                  colList.add(AS_DYNAMIC_MODEL(
                      name: Constants.ASCENTIS_DYNAMIC_NOTIFY_SMS,
                      colValue: isVerifyPromotion ? 'True' : 'False',
                      type: 'nvarchar(50)'));

                  if (_formKey.currentState!.validate()) {
                    getUpdateProfile();
                  }
                });
              },
              child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(Utils.getTranslated(context, "saved_btn"),
                      style: AppFont.montSemibold(14, color: Colors.black)))));
    } else {
      return Container(
          margin: const EdgeInsets.only(bottom: 34),
          child: Container(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColor.darkYellow()),
              width: MediaQuery.of(context).size.width,
              child: Text(Utils.getTranslated(context, "saved_btn"),
                  textAlign: TextAlign.center,
                  style: AppFont.montSemibold(14, color: Colors.black))));
    }
  }

  bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }
}
