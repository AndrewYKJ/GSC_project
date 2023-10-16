import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/dio/api/as_auth_api.dart';
import 'package:gsc_app/models/json/settings_model.dart';
import 'package:gsc_app/widgets/custom_dialog.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../splash_screen.dart';

class ReasonsDTO {
  int? id;
  bool? isChecked;
  String? reasons;

  ReasonsDTO({this.id, this.isChecked, this.reasons});
}

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DeleteAccountScreen();
  }
}

class _DeleteAccountScreen extends State<DeleteAccountScreen> {
  List<ReasonsDTO> reasonList = [
    ReasonsDTO(id: 1, isChecked: false, reasons: 'delete_account_reason_1'),
    ReasonsDTO(id: 2, isChecked: false, reasons: 'delete_account_reason_2'),
    ReasonsDTO(id: 3, isChecked: false, reasons: 'delete_account_reason_3'),
    ReasonsDTO(id: 4, isChecked: false, reasons: 'delete_account_reason_4'),
    ReasonsDTO(id: 5, isChecked: false, reasons: 'delete_account_reason_5'),
    ReasonsDTO(id: 6, isChecked: false, reasons: 'delete_account_reason_6'),
    ReasonsDTO(id: 7, isChecked: false, reasons: 'delete_account_reason_7'),
    ReasonsDTO(id: 8, isChecked: false, reasons: 'delete_account_reason_8'),
  ];
  ReasonsDTO? selectedReason;

  Future<MembershipCancellationModel> membershipCancellation(
      BuildContext context, String memberId) async {
    AsAuthApi asAuthApi = AsAuthApi(context);
    return asAuthApi.membershipCancellation(memberId);
  }

  callMembershipCancellation() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    var memberId = AppCache.me!.MemberLists!.first.MemberID!;
    await membershipCancellation(context, memberId).then((value) async {
      if (value.ReturnStatus == 1) {
        AppCache.removeValues(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false);
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
      Utils.printInfo('MEMBERSHIP CANCELLATION ERROR: $error');
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
        AnalyticsConstants.ANALYTICS_DELETE_ACCOUNT_SCREEN);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appBar(context, width),
                description(context),
                reasonLabel(context),
                showReasonList(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _submitBtn(),
    );
  }

  Widget appBar(BuildContext context, double width) {
    return Container(
      height: kToolbarHeight,
      width: width,
      decoration: BoxDecoration(
        color: AppColor.backgroundBlack(),
      ),
      child: Stack(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            padding: const EdgeInsets.only(left: 6),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset(
              Constants.ASSET_IMAGES + 'white-left-icon.png',
              fit: BoxFit.cover,
              width: 23,
              height: 23,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(Utils.getTranslated(context, 'settings_delete_account'),
              style: AppFont.montRegular(18, color: Colors.white)),
        )
      ]),
    );
  }

  Widget description(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      color: AppColor.backgroundBlack(),
      child: RichText(
        text: TextSpan(
          text: Utils.getTranslated(context, 'delete_account_description_1'),
          style: AppFont.montBold(14, color: Colors.white),
          children: [
            TextSpan(
              text:
                  Utils.getTranslated(context, 'delete_account_description_2'),
              style: AppFont.montRegular(14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget reasonLabel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 13),
      child: Text(
        Utils.getTranslated(context, 'delete_account_reason_label'),
        style: AppFont.montBold(16, color: AppColor.appYellow()),
      ),
    );
  }

  Widget showReasonList(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reasonList.map((e) => reasonItem(context, e)).toList(),
    );
  }

  Widget reasonItem(BuildContext context, ReasonsDTO reasonsDTO) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          checkColor: Colors.black,
          activeColor: AppColor.appYellow(),
          value: reasonsDTO.isChecked,
          onChanged: (value) {
            setState(() {
              for (var element in reasonList) {
                element.isChecked = false;
              }

              reasonsDTO.isChecked = value;

              if (selectedReason == null ||
                  selectedReason!.id != reasonsDTO.id) {
                selectedReason = reasonsDTO;
              } else {
                selectedReason = null;
              }
            });
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width * .85,
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            Utils.getTranslated(context, reasonsDTO.reasons!),
            style: AppFont.poppinsRegular(14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _submitBtn() {
    if (selectedReason != null) {
      return BottomAppBar(
          color: Colors.black,
          child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 13),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: AppColor.appYellow()), //change color
                  onPressed: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                              title: '',
                              message: Utils.getTranslated(
                                  context, 'delete_account_confirmation_msg'),
                              img: "attention-icon.png",
                              showButton: true,
                              showConfirm: true,
                              showCancel: true,
                              confirmStr:
                                  Utils.getTranslated(context, 'confirm_btn'),
                              cancelStr:
                                  Utils.getTranslated(context, 'cancel_btn'),
                              onCancel: () => Navigator.of(context).pop(),
                              onConfirm: () => callMembershipCancellation());
                        });
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
