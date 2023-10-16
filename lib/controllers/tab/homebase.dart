// ignore_for_file: unused_element, unused_local_variable, prefer_typing_uninitialized_variables

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/cinemas/cinema_list.dart';
import 'package:gsc_app/controllers/fnb/fnb.dart';
import 'package:gsc_app/controllers/home/home.dart';
import 'package:gsc_app/controllers/movies/movie_list.dart';
import 'package:gsc_app/controllers/profile/profile.dart';
import 'package:gsc_app/controllers/tab/tab_item.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:gsc_app/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:gsc_app/routes/approutes.dart';

import '../../cache/app_cache.dart';
import '../../const/constants.dart';

class HomeBase extends StatefulWidget {
  static final GlobalKey homeBaseKey = GlobalKey(debugLabel: 'btm_app_bar');
  static final GlobalKey<_HomeBaseState> homeKey =
      GlobalKey(debugLabel: 'homebase_key');

  final bool? showPush;
  final int? tab;
  final bool? hasLogin;
  final dynamic config;
  const HomeBase(
      {Key? key, this.showPush = false, this.tab, this.hasLogin, this.config})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeBaseState();
  }
}

class _HomeBaseState extends State<HomeBase> {
  var currentTab;
  var isLogin = false;

  @override
  void initState() {
    super.initState();
    if (widget.tab != null) {
      if (widget.tab == 0) {
        currentTab = TabItem.movie;
      } else if (widget.tab == 3) {
        currentTab = TabItem.profile;
      } else if (widget.tab == 1) {
        currentTab = TabItem.cinema;
      }
    }

    if (widget.hasLogin != null) {
      setState(() {
        isLogin = widget.hasLogin!;
      });
    } else {
      _checkLoginState();
    }
    if (widget.config != null) {
      if (Constants.IS_HUAWEI) {
        Utils.checkHuaweiAppVersion(
            context, widget.config as Map<dynamic, dynamic>);
      } else {
        Utils.checkAppVersion(context, widget.config as FirebaseRemoteConfig);
      }
    }

    checkPush();
  }

  Future<void> checkPush() async {
    Utils.printInfo("CHECK ENTER PUSH");
    if (AppCache.payload != null) {
      Utils.printInfo("GOT PAYLOAD");
      AppCache.payload = proccessPayload(AppCache.payload!);
      final pushPayload = AppCache.payload;
      Future.delayed(const Duration(microseconds: 10), (() {
        if (pushPayload!["ref"] != null) {
          if (pushPayload["ref"] == Constants.PAYLOAD_MOVIE_DETAILS) {
            Navigator.pushNamed(context, AppRoutes.movieDetailsRoute,
                arguments: [pushPayload["refId"], false, false]);
          } else if (pushPayload["ref"] == Constants.PAYLOAD_SHOWTIME_CINEMA) {
            CinemaListScreen.pushPayload = AppCache.payload;
            setState(() {
              currentTab = TabItem.cinema;
            });
          } else if (pushPayload["ref"] == Constants.PAYLOAD_SHOWTIME_MOVIE) {
            var content = pushPayload["refId"] as String;
            final splitData = content
                .split(",")
                .map((x) => x.trim())
                .where((element) => element.isNotEmpty)
                .toList();
            final movieCode = splitData[0];
            final oprnDate = splitData[1];
            Navigator.pushNamed(context, AppRoutes.movieShowtimesByOpsdate,
                arguments: MovieToBuyArgs(
                  selectedCode: movieCode,
                  firstDate: oprnDate,
                  availableDate: [],
                ));
          }
        }
        AppCache.payload = null;
      }));
    }
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken) {
      setState(() {
        isLogin = true;
      });
    }
  }

  Map<String, dynamic> proccessPayload(Map<String, dynamic> data) {
    var resData = data;
    const keys = [
      Constants.GSC_PN_MOVIE,
      Constants.GSC_PN_SHOWTIME_CINEMA,
      Constants.GSC_PN_SHOWTIME_MOVIE
    ];
    var item = resData.keys.where((item) => keys.contains(item));
    var specific = resData[item.first];
    return {"ref": item.first, "refId": specific};
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<DrawerState>(builder: (context, value, child) {
      bool drawerState =
          value.getState || MediaQuery.of(context).viewInsets.bottom != 0;
      // bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: _buildBody(context, isLogin),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Visibility(
          visible: !drawerState,
          child: Align(
            alignment: const Alignment(0.0, 1),
            child: Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.btmNavCenterFABOuterRing(),
                borderRadius: const BorderRadius.all(
                  Radius.circular(100),
                ),
              ),
              child: SizedBox(
                width: 70,
                height: 70,
                child: Container(
                  child: FloatingActionButton(
                      heroTag: UniqueKey(),
                      backgroundColor: AppColor.appYellow(),
                      onPressed: _pushToQr,
                      tooltip: 'Qr',
                      child: Image.asset(Constants.ASSET_IMAGES + 'qr-code.png',
                          width: 60, height: 60, fit: BoxFit.fitWidth)),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.btmNavCenterFABOuterRing(),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Visibility(
            visible: !drawerState,
            child: SizedBox(
              height: 66,
              child: BottomAppBar(
                elevation: 0,
                color: Colors.black,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      child: Column(
                        children: [
                          IconButton(
                            icon: currentTab != null
                                ? (currentTab.index == 0)
                                    ? Image.asset(
                                        Constants.ASSET_IMAGES +
                                            'movie-nav-hover.png',
                                      )
                                    : Image.asset(Constants.ASSET_IMAGES +
                                        'movie-nav.png')
                                : Image.asset(
                                    Constants.ASSET_IMAGES + 'movie-nav.png'),
                            iconSize: 30,
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              _selectTab(TabItem.movie, isLogin);
                            },
                          ),
                          Text(
                            Utils.getTranslated(
                                context, tabName[TabItem.movie]!),
                            textAlign: TextAlign.center,
                            style: AppFont.poppinsRegular(12,
                                color: currentTab != null
                                    ? (currentTab.index == 0
                                        ? AppColor.appYellow()
                                        : AppColor.iconGrey())
                                    : AppColor.iconGrey()),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        children: [
                          IconButton(
                            icon: currentTab != null
                                ? (currentTab.index == 1)
                                    ? Image.asset(
                                        Constants.ASSET_IMAGES +
                                            'cinema-nav-hover.png',
                                      )
                                    : Image.asset(Constants.ASSET_IMAGES +
                                        'cinema-nav.png')
                                : Image.asset(
                                    Constants.ASSET_IMAGES + 'cinema-nav.png'),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _selectTab(TabItem.cinema, isLogin);
                            },
                          ),
                          Text(
                            Utils.getTranslated(
                                context, tabName[TabItem.cinema]!),
                            textAlign: TextAlign.center,
                            style: AppFont.poppinsRegular(12,
                                color: currentTab != null
                                    ? (currentTab.index == 1
                                        ? AppColor.appYellow()
                                        : AppColor.iconGrey())
                                    : AppColor.iconGrey()),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 80, child: Text('')),
                    SizedBox(
                      child: Column(
                        children: [
                          IconButton(
                            icon: currentTab != null
                                ? (currentTab.index == 3)
                                    ? Image.asset(
                                        Constants.ASSET_IMAGES +
                                            'food-nav-hover.png',
                                      )
                                    : Image.asset(
                                        Constants.ASSET_IMAGES + 'food-nav.png')
                                : Image.asset(
                                    Constants.ASSET_IMAGES + 'food-nav.png'),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _selectTab(TabItem.fnb, isLogin);
                            },
                          ),
                          Text(
                            Utils.getTranslated(context, tabName[TabItem.fnb]!),
                            textAlign: TextAlign.center,
                            style: AppFont.poppinsRegular(12,
                                color: currentTab != null
                                    ? (currentTab.index == 3
                                        ? AppColor.appYellow()
                                        : AppColor.iconGrey())
                                    : AppColor.iconGrey()),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        children: [
                          IconButton(
                            icon: currentTab != null
                                ? (currentTab.index == 4)
                                    ? Image.asset(
                                        Constants.ASSET_IMAGES +
                                            'profile-nav-hover.png',
                                      )
                                    : Image.asset(Constants.ASSET_IMAGES +
                                        'profile-nav.png')
                                : Image.asset(
                                    Constants.ASSET_IMAGES + 'profile-nav.png'),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _selectTab(TabItem.profile, isLogin);
                            },
                          ),
                          Text(
                            Utils.getTranslated(
                                context, tabName[TabItem.profile]!),
                            textAlign: TextAlign.center,
                            style: AppFont.poppinsRegular(12,
                                color: currentTab != null
                                    ? (currentTab.index == 4
                                        ? AppColor.appYellow()
                                        : AppColor.iconGrey())
                                    : AppColor.iconGrey()),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _selectTab(TabItem tabItem, bool login) {
    _checkLoginState();
    Utils.printInfo("SELECT TAB: ${tabItem.name} || IS LOGIN: $login");
    setState(() {
      currentTab = tabItem;
      isLogin = login;
    });
  }

  Future<void> _pushToQr() async {
    var res = await Navigator.pushNamed(context, AppRoutes.qrMemberRoute,
        arguments: [false]);
    if (res != null) {
      if (res == true) {
        if (currentTab == TabItem.profile) {
          setState(() {
            isLogin = true;
          });
        } else if (currentTab == null) {
          setState(() {
            isLogin = true;
          });
        }
      }
    }
  }

  Widget _buildBody(BuildContext context, bool hasLogin, {int? accIndex}) {
    switch (currentTab) {
      case TabItem.movie:
        return const MovieListScreen();
      case TabItem.cinema:
        return const CinemaListScreen();
      case TabItem.fnb:
        return const FnbScreen(
          isFromPush: false,
        );
      case TabItem.profile:
        return ProfileScreen(
            isLogin: hasLogin, isLogoutSuccess: logout, isLoginSuccess: login);
      default:
        return HomeScreen(isLogin: hasLogin);
    }
  }

  void logout() {
    setState(() {
      isLogin = false;
    });
  }

  void login() {
    setState(() {
      isLogin = true;
    });
  }
}
