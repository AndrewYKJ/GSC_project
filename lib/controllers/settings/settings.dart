import 'package:flutter/material.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/routes/approutes.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';

class SettingScreen extends StatefulWidget {
  final VoidCallback isLogoutSuccess;
  const SettingScreen({Key? key, required this.isLogoutSuccess})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingScreen();
  }
}

class _SettingScreen extends State<SettingScreen> {
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SETTING_SCREEN);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: AppColor.backgroundBlack(),
        centerTitle: true,
        title: Text(
          Utils.getTranslated(context, 'profile_general_settings'),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 19),
                child: Text(
                  Utils.getTranslated(context, 'settings_security'),
                  style: AppFont.montMedium(
                    14,
                    color: AppColor.greyWording(),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                      context, AppRoutes.settingsChangePasswordRoute,
                      arguments: widget.isLogoutSuccess);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          Utils.getTranslated(
                              context, 'settings_change_password'),
                          style: AppFont.montRegular(
                            14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Image.asset(
                        Constants.ASSET_IMAGES + 'right-simple-arrow.png',
                        width: 20,
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
              Divider(
                color: AppColor.backgroundBlack(),
              ),
              Container(
                margin: const EdgeInsets.only(top: 19),
                child: Text(
                  Utils.getTranslated(context, 'settings_account_management'),
                  style: AppFont.montMedium(
                    14,
                    color: AppColor.greyWording(),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                      context, AppRoutes.settingsDeleteAccountRoute);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          Utils.getTranslated(
                              context, 'settings_delete_account'),
                          style: AppFont.montRegular(
                            14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Image.asset(
                        Constants.ASSET_IMAGES + 'right-simple-arrow.png',
                        width: 20,
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
              Divider(
                color: AppColor.backgroundBlack(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
