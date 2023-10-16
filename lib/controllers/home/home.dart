// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/aurum/aurum_showtimes.dart';
import 'package:gsc_app/controllers/movies/movie_details.dart';
import 'package:gsc_app/dio/api/movie_api.dart';
import 'package:gsc_app/dio/api/others_api.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:gsc_app/models/json/cms_experience_model.dart';
import 'package:gsc_app/models/json/experience_promotion_model.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_listing.dart';
import 'package:gsc_app/provider/home_provider.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../const/analytics_constant.dart';
import '../../dio/api/as_messages_api.dart';
import '../../main.dart';
import '../../models/json/as_messages_model.dart';
import '../../models/json/cms_promotion_model.dart';
import '../../models/json/movie_listing_details.dart';
import '../../models/json/splash_popup_model.dart';
import '../../widgets/custom_web_view.dart';
import '../tab/homebase.dart';

class HomeScreen extends StatefulWidget {
  bool isLogin;
  HomeScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  var scaffoldHomeScreenKey = GlobalKey<ScaffoldState>();
  var rewardCard = GlobalKey<ScaffoldState>();
  late WebViewController _controller1;
  double? rewardCardHeight;
  late WebViewController _controller2;
  late WebViewController _controller3;
  late WebViewController _controller4;
  var _selectedTabbar = 0;
  var _selectedSliderIndex = 0;
  bool refreshData = false;
  var maxSliderCount = 8;
  double? initialContext;
  double? contextHeight;
  int page = 1;
  int pageSize = 20;
  late TabController _controllerTab;
  late PageController _controllerSlider;
  DateTime todayDate = DateTime.now();
  Timer? _timer;
  bool loadSlider = false;
  List<int> adsPosition = [];
  List<InAppMessageInfoDTO> inAppMessgeInfoList = [];
  MovieListing movieListing = MovieListing();
  int sliderScrollPixel = 0;
  MovieEpaymentDTO? movieEpaymentDTO;
  List<MovieListingDetails> nowShowing = [];
  List<MovieListingDetails> advanceSale = [];
  List<String> mergedList = [];
  List<Widget>? sliderContent = [];
  List<Promotion>? promotionsList;
  List<Experience>? experienceList;

  List<CMS_PROMOTION>? cmspromotionsList;
  List<CMS_EXPERIENCE>? cmsexperienceList;
  int promotionsListCount = 9;
  int experienceListCount = 9;
  String? deviceUUID;

  Future getAllInfo() async {
    await AppCache.getStringValue(AppCache.DEVICE_INFO).then((value) {
      var dataMap = json.decode(value);

      deviceUUID = dataMap["deviceUUID"];
      callGetInAppMessageList(context, Constants.MessageAppName,
          AppCache.me?.MemberLists?.first.MemberID ?? '');
    });
  }

  Future<ExpNPromoResponse> getPromoNEXP(BuildContext context) async {
    OthersApi itm = OthersApi(context);
    return itm.getPromoNExp();
  }

  Future<List<CMS_EXPERIENCE>> getEXP(BuildContext context) async {
    OthersApi itm = OthersApi(context);
    return itm.getExperience();
  }

  Future<List<CMS_PROMOTION>> getPromotion(BuildContext context) async {
    OthersApi itm = OthersApi(context);
    return itm.getPromotion();
  }

  Future<MovieListing> getMovieListings(
      BuildContext context, String operationDate) async {
    MovieApi itm = MovieApi(context);
    return itm.getMovieListing(operationDate);
  }

  Future<MovieEpaymentDTO> getEpaymentMovie(BuildContext context) async {
    MovieApi itm = MovieApi(context);
    return itm.getMovie();
  }

  saveCachedData() {
    var res = {
      'splash': (AppCache.splashImages),
      'record': DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).toString(),
      // 'promotion': (AppCache.expNpromoList),
      'swaggermovie': (AppCache.movieListing),
      'expList': (AppCache.expNpromoList?.cms_experiences),
      'promoList': (AppCache.expNpromoList?.cms_promotions)
    };

    AppCache.setString(AppCache.SPLASH_SCREEN_REF, json.encode(res));
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SPLASH_SCREEN);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    getAllInfo();

    _controllerSlider = PageController(initialPage: _selectedSliderIndex);
    _controllerTab = TabController(length: 2, vsync: this);

    if (AppCache.showPopUp) {
      Future.delayed(const Duration(milliseconds: 100), () {
        checkPopUpImages();
        AppCache.showPopUp = false;
      });
    }

    getAllWebController().then((value) {
      AppCache.movieListing?.Response?.Body?.NowShowing?.isNotEmpty ?? false
          ? getMovieListingfromCache()
          : getMovieListingCallApi();
      AppCache.expNpromoList != null
          ? _setPromotionNExperience()
          : getPromoNEXPListing();
      AppCache.movieEpaymentList != null
          ? movieEpaymentDTO = AppCache.movieEpaymentList!
          : getEpaymentMovie(context);
    }).whenComplete(() {
      setState(() {
        loadSlider = true;
        if (AppCache.reSetCacheModel) {
          saveCachedData();
        }
      });
    });

    // getAllWebController();

    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialContext != null) {
        if (initialContext != MediaQuery.of(context).size.width) {
          setState(() {
            sliderContent = [];

            _buildSlider(context);
            initialContext = MediaQuery.of(context).size.width;
          });
        }
      } else {
        initialContext = MediaQuery.of(context).size.width;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _cancelTimer();
    _controllerSlider.dispose();
    _controllerTab.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (mounted) {
      _checkLoginState();
    }
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken && AppCache.me != null) {
      setState(() {
        widget.isLogin = true;
      });
    }
  }

  checkPopUpImages() async {
    if (AppCache.splashImages != null) {
      await Utils.callPopUpDialog(context,
          AppCache.splashImages?[1] ?? SplashImage(imageLink: ''), true);
    }
  }

  void _changeDrawerState(bool isOpened) {
    if (isOpened) {
      Provider.of<DrawerState>(context, listen: false).setState(true);
    } else {
      Provider.of<DrawerState>(context, listen: false).setState(false);
    }
  }

  void _setPromotionNExperience() {
    setState(() {
      cmspromotionsList = AppCache.expNpromoList!.cms_promotions!;
      cmsexperienceList = AppCache.expNpromoList!.cms_experiences!;
      cmspromotionsList!.length > 9
          ? null
          : promotionsListCount = promotionsList!.length;
      cmsexperienceList!.length > 9
          ? null
          : experienceListCount = experienceList!.length;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_selectedSliderIndex < _pageCount() - 1) {
        _selectedSliderIndex++;
      } else {
        _selectedSliderIndex = 0;
      }
      _controllerSlider.animateToPage(
        _selectedSliderIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      // _controller1.reload();
      // _controller2.reload();
      // _controller3.reload();
      // _controller4.reload();
      // if (adsPosition.contains(_selectedSliderIndex)) {
      //   _controller1.scrollTo(
      //       0, adsPosition.indexOf(_selectedSliderIndex) * sliderScrollPixel);
      // }
    });
  }

  int _pageCount() {
    return sliderContent!.length;
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  Future<void> getAllWebController() async {
    getWebController();
    getWebController2();
    getWebController3();
    getWebController4();
  }

  getMovieListingCallApi() async {
    String operationDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await getMovieListings(context, operationDate).then((data) {
      setState(() {
        movieListing = data;
        AppCache.movieListing = data;
        nowShowing = movieListing.Response!.Body!.NowShowing != null
            ? movieListing.Response!.Body!.NowShowing!.toList()
            : [];

        advanceSale = movieListing.Response!.Body!.AdvanceSales != null
            ? movieListing.Response!.Body!.AdvanceSales!.toList()
            : [];
      });
    }).whenComplete(() {
      saveCachedData();
    }).catchError((error) {
      Utils.printInfo(error);
    });
  }

  //getPromoNEXPListing() async {
  // await getPromoNEXP(context)
  //     .then((data) {
  //       setState(() {
  //         AppCache.expNpromoList = data;
  //         cmspromotionsList =
  //             AppCache.expNpromoList!.cms_promotions!.toList();
  //         cmsexperienceList =
  //             AppCache.expNpromoList!.cms_experiences!.toList();
  //         promotionsList!.length > 9
  //             ? null
  //             : promotionsListCount = promotionsList!.length;
  //         cmsexperienceList!.length > 9
  //             ? null
  //             : experienceListCount = experienceList!.length;
  //       });
  //     })
  //     .whenComplete(() => saveCachedData())
  //     .catchError((error) {
  //       print(error);
  //     });
  // }

  getPromoNEXPListing() async {
    dynamic exp;
    dynamic promo;
    await getEXP(context)
        .then((data) {
          // AppCache.expNpromoList = data;
          exp = data;
        })
        .whenComplete(() => {})
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
          // Utils.showAlertDialog(
          //     context,
          //     Utils.getTranslated(context, "error_title"),
          //     e != null
          //         ? e.message ?? Utils.getTranslated(context, "general_error")
          //         : Utils.getTranslated(context, "general_error"),
          //     true,
          //     true, () {
          //   Navigator.of(context).pop();
          // });
        });

    await getPromotion(context)
        .then((data) {
          // AppCache.expNpromoList = data;
          promo = data;
        })
        .whenComplete(() => {})
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
          // Utils.showAlertDialog(
          //     context,
          //     Utils.getTranslated(context, "error_title"),
          //     e != null
          //         ? e.message ?? Utils.getTranslated(context, "general_error")
          //         : Utils.getTranslated(context, "general_error"),
          //     true,
          //     true, () {
          //   Navigator.of(context).pop();
          // });
        });
    AppCache.expNpromoList =
        CMSExpNPromoResponse(cms_experiences: exp, cms_promotions: promo);
    cmspromotionsList = AppCache.expNpromoList!.cms_promotions!.toList();
    cmsexperienceList = AppCache.expNpromoList!.cms_experiences!.toList();
    cmspromotionsList!.length > 9
        ? null
        : promotionsListCount = promotionsList!.length;
    cmsexperienceList!.length > 9
        ? null
        : experienceListCount = experienceList!.length;
  }

  getMovieEpaymentCallApi() async {
    await getEpaymentMovie(
      context,
    )
        .then((data) {
          setState(() {
            movieEpaymentDTO = data;
            AppCache.movieEpaymentList = data;
          });
        })
        .whenComplete(() => {})
        .catchError((error) {
          Utils.printInfo(error);
        });
  }

  Future<void> _refreshData() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    setState(() {
      refreshData = true;
      sliderContent!.clear;
      nowShowing.clear();
      advanceSale.clear();
      movieListing = MovieListing();
      movieEpaymentDTO = null;
      AppCache.movieEpaymentList = null;
      AppCache.expNpromoList = null;
      AppCache.movieListing = null;
      promotionsList = null;
      experienceList = null;
    });
    getMovieListingCallApi();
    getPromoNEXPListing();
    getMovieEpaymentCallApi();
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        loadSlider = true;
        _selectedSliderIndex = 0;
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        saveCachedData();
      });
    });
  }

  Future<InAppMessageDTO> getInAppMessagesList(
      BuildContext context, String appName, String memberId) async {
    AsMessagesApi asMessagesApi = AsMessagesApi(context);
    return asMessagesApi.getInAppMessagesList(
        context, appName, memberId, deviceUUID ?? '', page, pageSize);
  }

  callGetInAppMessageList(
      BuildContext context, String appName, String memberId) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getInAppMessagesList(context, appName, memberId).then((value) {
      if (value.returnStatus == 1) {
        if (value.inAppMessageInfoList != null &&
            value.inAppMessageInfoList!.isNotEmpty) {
          inAppMessgeInfoList.addAll(value.inAppMessageInfoList!);
        }
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.returnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      }
    }).onError((error, stackTrace) {
      Utils.printInfo('GET IN APP MESSAGES ERROR: $error');
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          error != null
              ? error.toString().isNotEmpty
                  ? error.toString()
                  : Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          null, () {
        Navigator.of(context).pop();
      });
    }).whenComplete(() {
      setState(() {
        EasyLoading.dismiss();
      });
    });
  }

  getMovieListingfromCache() {
    setState(() {
      movieListing = AppCache.movieListing!;

      nowShowing = movieListing.Response!.Body!.NowShowing != null
          ? movieListing.Response!.Body!.NowShowing!
          : [];

      advanceSale = movieListing.Response!.Body!.AdvanceSales != null
          ? movieListing.Response!.Body!.AdvanceSales!
          : [];
    });
  }

  getWebController() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    bool isLoad = true;
    controller
      ..enableZoom(false)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            _controller1.setNavigationDelegate(NavigationDelegate(
              onNavigationRequest: (request) {
                if (request.url.contains("googleads")) {
                  if (!isLoad) {
                    isLoad = true;
                    Utils.launchBrowser(
                      request.url,
                    );
                  }

                  return NavigationDecision.navigate;
                }
                isLoad = false;
                return NavigationDecision.prevent;
              },
            ));
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
                      ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'BannerExtractor',
        onMessageReceived: (JavaScriptMessage message) {},
      )
      ..loadHtmlString(
          await rootBundle.loadString('assets/html/adScript0.html'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller1 = controller;
  }

  getWebController2() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    bool isLoad = true;
    controller
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            _controller2.setNavigationDelegate(NavigationDelegate(
              onNavigationRequest: (request) async {
                if (request.url.contains("googleads")) {
                  if (!isLoad) {
                    isLoad = true;
                    Utils.launchBrowser(
                      request.url,
                    );
                    // if (test is bool && true) {
                    //   isLoad = !isLoad;
                    // }
                  }

                  return NavigationDecision.navigate;
                }
                isLoad = false;
                return NavigationDecision.prevent;
              },
            ));
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
                      ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel('BannerExtractor',
          onMessageReceived: (JavaScriptMessage message) {})
      ..loadHtmlString(
          await rootBundle.loadString('assets/html/adScript1.html'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller2 = controller;
  }

  getWebController3() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    bool isLoad = true;
    controller
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');

            _controller3.setNavigationDelegate(NavigationDelegate(
              onNavigationRequest: (request) async {
                if (request.url.contains("googleads")) {
                  if (!isLoad) {
                    isLoad = true;
                    Utils.launchBrowser(
                      request.url,
                    );
                    // if (test is bool && true) {
                    //   isLoad = !isLoad;
                    // }
                  }

                  return NavigationDecision.navigate;
                }
                isLoad = false;
                return NavigationDecision.prevent;
              },
            ));
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
                      ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith("")) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        'BannerExtractor',
        onMessageReceived: (JavaScriptMessage message) {},
      )
      ..loadHtmlString(
          await rootBundle.loadString('assets/html/adScript2.html'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller3 = controller;
  }

  getWebController4() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    bool isLoad = true;
    controller
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            _controller4.setNavigationDelegate(NavigationDelegate(
              onNavigationRequest: (request) async {
                if (request.url.contains("googleads")) {
                  if (!isLoad) {
                    isLoad = true;
                    Utils.launchBrowser(
                      request.url,
                    );
                    // if (test is bool && true) {
                    //   isLoad = !isLoad;
                    // }
                  }

                  return NavigationDecision.navigate;
                }
                isLoad = false;
                return NavigationDecision.prevent;
              },
            ));
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
                      ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'BannerExtractor',
        onMessageReceived: (JavaScriptMessage message) {},
      )
      ..loadHtmlString(
          await rootBundle.loadString('assets/html/adScript3.html'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller4 = controller;
  }

  _buildSlider(BuildContext context) async {
    _controllerSlider.dispose();
    _controllerSlider = PageController(initialPage: _selectedSliderIndex);
    if (movieEpaymentDTO?.films?.parent != null) {
      adsPosition = [];
      _cancelTimer();
      List<Parent> randomMovie = movieEpaymentDTO!.films!.parent!;
      sliderContent = [];

      var bIndex = 0;
      var aIndex = 0;
      if (randomMovie.isNotEmpty) {
        sliderContent!.add(sliderMovieUI(context, randomMovie[0]));
        for (int i = 0; i < 11; i++) {
          if ((i) % 3 == 0) {
            sliderContent!.add(sliderAdvsUI(aIndex));
            adsPosition.add(i + 1 - bIndex);
            aIndex++;
          } else {
            String item = i < randomMovie.length
                ? randomMovie[i].child?.first.stills ?? ''
                : 'error404';
            if (!item.contains('error404')) {
              bIndex = 0;
              sliderContent!.add(sliderMovieUI(context, randomMovie[i]));
            } else {
              bIndex++;
              // adsPosition.last = adsPosition.last - 2;
            }
          }
        }
      } else {
        for (int i = 0; i < 4; i++) {
          adsPosition.add(i);
          sliderContent!.add(sliderAdvsUI(i));
        }
      }
    } else {
      sliderContent = [];
      adsPosition = [];
      for (int i = 0; i < 4; i++) {
        adsPosition.add(i);
        sliderContent!.add(sliderAdvsUI(i));
      }
    }
    setState(() {
      loadSlider = false;
      _startTimer();
      refreshData = false;
    });
  }

  Future<void> _launchUrl(link) async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void postFrameCallback(_) {
    setState(() {
      rewardCardHeight = rewardCard.currentContext?.size?.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    if (loadSlider) {
      _buildSlider(context);
    }
    rewardCardHeight != null
        ? null
        : SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Scaffold(
      key: scaffoldHomeScreenKey,
      onDrawerChanged: (isOpened) => _changeDrawerState(isOpened),
      drawerEnableOpenDragGesture: false,
      drawer: sidebarDrawer(context),
      floatingActionButton: fastTicketFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        backgroundColor: Colors.transparent,
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: Colors.black,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  fit: StackFit.passthrough,
                  children: [
                    _homeSlider(screenWidth, availableHeight, context),
                    appBar(context),
                  ],
                ),
                _movieWidget(screenWidth, context),
                SizedBox(
                  height: widget.isLogin ? 34 : 30,
                ),
                widget.isLogin ? gscRewardCard(context) : const SizedBox(),
                if (cmspromotionsList != null)
                  _promotionList(screenWidth, context),
                if (cmsexperienceList != null)
                  _cinemaExperience(screenWidth, context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column gscRewardCard(BuildContext context) {
    final value = NumberFormat("#,##0", "en_US");

    // final balance = 1500.0 - AppCache.me!.CardLists!.first.PointsBAL!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 9.0, left: 16),
          child: Text(
            Utils.getTranslated(context, "gsc_reward_card_title"),
            style: AppFont.montSemibold(14, color: Colors.white),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 28),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: MediaQuery.of(context).size.width,
          child: Stack(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * .33,
                        top: 17,
                        bottom: 17),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage(
                            Constants.ASSET_IMAGES + 'card-reward.png',
                          ),
                          fit: BoxFit.cover,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getTranslated(context, "gspoints_rewards"),
                          // Utils.getTranslated(
                          //     context, "home_promotions_title_text"),
                          style:
                              AppFont.orbitronRegular(17, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          value.format(
                              AppCache.me?.CardLists?.first.PointsBAL ?? 0),
                          // Utils.getTranslated(
                          //     context, "home_promotions_title_text"),
                          style: AppFont.montBold(
                            37,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0, // shadow blur
                                color: AppColor.aurumDay(), // shadow color
                                offset: const Offset(
                                    0.0, 2.0), // how much shadow will be shown
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .55,
                          child: RichText(
                            text: TextSpan(
                                style: AppFont.poppinsRegular(15),
                                children: [
                                  TextSpan(
                                      text:
                                          Utils.getTranslated(context, "left"),
                                      style: AppFont.montRegular(15,
                                          color: AppColor.aurumDay())),
                                  TextSpan(
                                      text: AppCache.me?.CardLists?.first
                                                      .PointsToNextTier !=
                                                  null &&
                                              AppCache.me!.CardLists!.first
                                                  .PointsToNextTier!.isNotEmpty
                                          ? " ${AppCache.me?.CardLists?.first.PointsToNextTier ?? 0} "
                                          : ' 0 ',
                                      style: AppFont.montBold(15,
                                          color: AppColor.aurumDay())),
                                  TextSpan(
                                      text: Utils.getTranslated(
                                          context, "get_new_rewards"),
                                      style: AppFont.montRegular(15,
                                          color: AppColor.aurumDay()))
                                ]),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.rewardsCenterListingRoute);
                          },
                          child: Container(
                            height: 24,
                            width: 24,
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: Image.asset(
                              Constants.ASSET_IMAGES + 'right-simple-arrow.png',
                              fit: BoxFit.cover,
                              color: AppColor.aurumBase(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            //gift-rewards-img
            SizedBox(
              width: MediaQuery.of(context).size.width * .31,
              child: Image.asset(
                Constants.ASSET_IMAGES + 'gift-rewards-img.png',
                fit: BoxFit.cover,
              ),
            )
          ]),
        ),
      ],
    );
  }

  Widget appBar(BuildContext context) {
    return Positioned(
      top: 0,
      child: Container(
        height: kToolbarHeight,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.transparent, boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 20.0,
            spreadRadius: 20.0,
            offset: Offset(0, -15),
          ),
        ]),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(
            onPressed: () {
              scaffoldHomeScreenKey.currentState?.openDrawer();
            },
            icon: Image.asset(
              Constants.ASSET_IMAGES + 'menu-icon.png',
              fit: BoxFit.cover,
              height: 28,
            ),
          ),
          Image.asset(
            Constants.ASSET_IMAGES + 'GSC-logo.png',
            fit: BoxFit.cover,
            height: 28,
            width: 94,
          ),
          widget.isLogin && AppCache.me != null
              ? Row(
                  children: [
                    //read_notification_icon
                    InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                                  context, AppRoutes.messageCenterRoute)
                              .then((value) {
                            callGetInAppMessageList(
                                context,
                                Constants.MessageAppName,
                                AppCache.me?.MemberLists?.first.MemberID ?? '');
                          }).then((value) => Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => HomeBase(
                                      tab: 3,
                                      hasLogin: widget.isLogin,
                                    ),
                                  )));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 15),
                          width: 24,
                          height: 24,
                          child: Image.asset(
                            inAppMessgeInfoList
                                    .any((element) => !element.readStatus!)
                                ? Constants.ASSET_IMAGES +
                                    'unread_notification_icon.png'
                                : Constants.ASSET_IMAGES +
                                    'read_notification_icon.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        )),

                    InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => HomeBase(
                                  tab: 3,
                                  hasLogin: widget.isLogin,
                                ),
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 15),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: AppColor.appYellow()),
                              borderRadius: BorderRadius.circular(25)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              Utils.getInitials(
                                  AppCache.me?.MemberLists?.first.Name ??
                                      "Guest User"),
                              style: AppFont.montSemibold(10,
                                  color: AppColor.appYellow()),
                            ),
                          ),
                        )),
                  ],
                )
              : Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => HomeBase(
                              tab: 3,
                              hasLogin: widget.isLogin,
                            ),
                          ));
                    },
                    icon: Image.asset(
                      Constants.ASSET_IMAGES + 'profile-icon.png',
                      width: 35,
                      height: 35,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
        ]),
      ),
    );
  }

  Widget sliderMovieUI(BuildContext ctx, Parent data) {
    return Container(
      padding: const EdgeInsets.only(bottom: 26),
      width: MediaQuery.of(ctx).size.width,
      height: 500,
      child: Column(
        children: [
          SizedBox(
            height: 500 - 40 - 26 - 69,
            width: MediaQuery.of(ctx).size.width,
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                        context, AppRoutes.movieShowtimesByOpsdate,
                        arguments: MovieToBuyArgs(
                          selectedCode: data.code ?? '-',
                          firstDate: '',
                          availableDate: [],
                        ));
                  },
                  child: AspectRatio(
                    aspectRatio: MediaQuery.of(ctx).size.width / (500 - 130),
                    child: CachedNetworkImage(
                      imageUrl: data.child?.first.stills ?? '',
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) {
                        return Image.asset(
                            'assets/images/Default placeholder_app_img.png',
                            fit: BoxFit.fitWidth);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration:
                const BoxDecoration(color: Colors.transparent, boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 20.0,
                spreadRadius: 20.0,
                offset: Offset(0, -1),
              ),
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                data.child!.first.trailerUrl != null
                    ? data.child!.first.trailerUrl! != ""
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MovieDetailsScreen(
                                            parentCode: data.code ?? "",
                                            isAurum: false,
                                            fromMoviePopup: false,
                                          )));
                              // String result =
                              //     data.child!.first.trailerUrl != null
                              //         ? data.child!.first.trailerUrl!.isNotEmpty
                              //             ? data.child!.first.trailerUrl!
                              //             : ""
                              //         : "";

                              // dynamic videoID = result.split("=");
                              // if (videoID.length > 1) {
                              //   _launchUrl(result);
                              // }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Constants.ASSET_IMAGES + 'play-icon.png',
                                  fit: BoxFit.cover,
                                  width: 24,
                                  height: 24,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    Utils.getTranslated(context,
                                            "home_slider_movie_play_btn_text")
                                        .toUpperCase(),
                                    style: AppFont.poppinsBold(8,
                                        color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox(
                            height: 30,
                            width: 30,
                          )
                    : const SizedBox(
                        height: 30,
                        width: 30,
                      ),
                InkWell(
                  onTap: (() {
                    Navigator.pushNamed(
                        context, AppRoutes.movieShowtimesByOpsdate,
                        arguments: MovieToBuyArgs(
                          selectedCode: data.code ?? '-',
                          firstDate: '',
                          availableDate: [],
                        ));
                  }),
                  child: Container(
                    height: 40,
                    width: 151,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.appYellow(),
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          Constants.ASSET_IMAGES + 'buy-ticket-icon.png',
                          fit: BoxFit.cover,
                          width: 18,
                          height: 18,
                        ),
                        Text(
                          Utils.getTranslated(
                              context, "home_slider_movie_buy_btn_text"),
                          style: AppFont.poppinsBold(15,
                              color: AppColor.appYellow()),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MovieDetailsScreen(
                                parentCode: data.code ?? "",
                                isAurum: false,
                                fromMoviePopup: false,
                              ))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Constants.ASSET_IMAGES + 'info-icon.png',
                        fit: BoxFit.cover,
                        width: 24,
                        height: 24,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          Utils.getTranslated(
                                  context, "home_slider_movie_info_btn_text")
                              .toUpperCase(),
                          style: AppFont.poppinsBold(8, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget sliderAdvsUI(int aIndex) {
    WebViewController currentController;
    switch (aIndex) {
      case 0:
        currentController = _controller1;
        break;
      case 1:
        currentController = _controller2;
        break;
      case 2:
        currentController = _controller3;
        break;
      case 3:
        currentController = _controller4;
        break;
      default:
        currentController = _controller1;
        break;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(26, 26, 26, 26),
      child: Stack(
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 135 - 26,
            child: SizedBox(
              height: 378,
              width: 270,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: WebViewWidget(controller: currentController)),
            ),
          ),
          Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text(
                    Utils.getTranslated(context, "ads"),
                    style: AppFont.poppinsRegular(10, color: Colors.white),
                  ))))
        ],
      ),
    );
  }

  Widget _movieWidget(double screenWidth, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      width: screenWidth,
      decoration: BoxDecoration(
        color: AppColor.appSecondaryBlack(),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: TabBar(
              indicatorColor: AppColor.appYellow(),
              unselectedLabelColor: AppColor.cinemaTabUnselectedColor(),
              labelColor: Colors.white,
              isScrollable: true,
              controller: _controllerTab,
              onTap: (value) {
                setState(() {
                  _selectedTabbar = value;
                });
              },
              indicatorPadding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              tabs: [
                Tab(
                  child: Text(
                    Utils.getTranslated(context, "home_now_showing_tab_text"),
                    style: AppFont.montSemibold(
                      14,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    Utils.getTranslated(context, "home_advances_sale_tab_text"),
                    style: AppFont.montSemibold(
                      14,
                    ),
                  ),
                )
              ],
            ),
          ),
          Builder(builder: (_) {
            if (_selectedTabbar == 0) {
              return nowShowing.isNotEmpty
                  ? Center(
                      child: Wrap(
                        spacing: 8,
                        children: nowShowing
                            .map((e) => movieUI(context, e, screenWidth))
                            .toList(),
                      ),
                    )
                  : Container(
                      color: AppColor.appSecondaryBlack(),
                      height: 200,
                      width: screenWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Text(
                                Utils.getTranslated(context, "coming_soon"),
                                style: AppFont.poppinsMedium(14,
                                    color: Colors.white)),
                          )
                        ],
                      ),
                    );
            } else {
              return advanceSale.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        children: advanceSale
                            .map((e) => movieUI(context, e, screenWidth))
                            .toList(),
                      ),
                    )
                  : Container(
                      color: AppColor.appSecondaryBlack(),
                      height: 200,
                      width: screenWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Text(
                                Utils.getTranslated(context, "coming_soon"),
                                style: AppFont.poppinsMedium(14,
                                    color: Colors.white)),
                          )
                        ],
                      ),
                    );
            }
          }),
        ],
      ),
    );
  }

  Widget _homeSlider(
      double screenWidth, double availableHeight, BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, AppColor.homeScreenTopGradient2()],
          stops: const [0.7, 1],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Visibility(
              visible: !refreshData,
              child: SizedBox(
                width: screenWidth,
                height: 431,
                child: PageView(
                    controller: _controllerSlider,
                    pageSnapping: true,
                    allowImplicitScrolling: true,
                    //  itemCount: sliderContent!.length,
                    onPageChanged: (int index) {
                      setState(() {
                        _selectedSliderIndex = index;
                        // _controller1.reload();
                        // _controller2.reload();
                        // _controller3.reload();
                        // _controller4.reload();
                        // if (adsPosition.contains(_selectedSliderIndex)) {
                        //   _controller1.scrollTo(
                        //       0,
                        //       adsPosition.indexOf(_selectedSliderIndex) *
                        //           sliderScrollPixel);
                        // }
                      });
                    },
                    children: [for (var data in sliderContent!) data]),
              ),
            ),
          ),
          Visibility(
            visible: !refreshData,
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sliderContent!.length,
                  (index) => buildDot(index, context),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 34, left: 16),
            width: screenWidth,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const AurumShowtimesScreen(),
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Image.asset(
                                Constants.ASSET_IMAGES + 'aurum-logo.png',
                                fit: BoxFit.cover,
                                height: 73,
                                width: 73,
                              ),
                              Text(
                                Utils.getTranslated(
                                    context, "home_module_icon_text_aurum"),
                                style: AppFont.poppinsRegular(10,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        )),
                    InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const HomeBase(tab: 0),
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          child: Column(
                            children: [
                              //new_movies_icon
                              Image.asset(
                                Constants.ASSET_IMAGES +
                                    'new_movies_icon.png', // 'movie-logo.png',
                                fit: BoxFit.cover,
                                height: 73,
                                width: 73,
                              ),
                              Text(
                                Utils.getTranslated(
                                    context, "home_module_icon_text_movies"),
                                style: AppFont.poppinsRegular(10,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        )),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.fnbRoute,
                            arguments: true);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            Image.asset(
                              Constants.ASSET_IMAGES + 'cinema-logo.png',
                              fit: BoxFit.cover,
                              height: 73,
                              width: 73,
                            ),
                            Text(
                              Utils.getTranslated(
                                  context, "home_module_icon_text_f&b"),
                              style: AppFont.poppinsRegular(10,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebView(
                                    useHtmlString: false,
                                    url: Constants.ESERVICES_MERCHANTDISE,
                                    title: Utils.getTranslated(context,
                                        "home_module_icon_text_merchandise"))));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            Image.asset(
                              Constants.ASSET_IMAGES + 'keepsake_icon.png',
                              fit: BoxFit.cover,
                              height: 73,
                              width: 73,
                            ),
                            Text(
                              Utils.getTranslated(
                                  context, "home_module_icon_text_merchandise"),
                              style: AppFont.poppinsRegular(10,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Utils.launchBrowser(
                          Constants.ESERVICE_JIN_GastroBar,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            Image.asset(
                              Constants.ASSET_IMAGES + 'jinbar_icon.png',
                              fit: BoxFit.cover,
                              height: 73,
                              width: 73,
                            ),
                            Text(
                              Utils.getTranslated(context,
                                  "home_module_icon_text_JIN Gastrobar"),
                              style: AppFont.poppinsRegular(10,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Utils.launchBrowser(
                            Constants.ESERVICE_KEEPSAKE,
                          );
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => WebView(
                          //             useHtmlString: false,
                          //             url: Constants.ESERVICE_KEEPSAKE,
                          //             title: Utils.getTranslated(context,
                          //                 "home_module_icon_text_keepsake"))));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Image.asset(
                                Constants.ASSET_IMAGES + 'movie-logo.png',
                                fit: BoxFit.cover,
                                height: 73,
                                width: 73,
                              ),
                              Text(
                                Utils.getTranslated(
                                    context, "home_module_icon_text_keepsake"),
                                style: AppFont.poppinsRegular(10,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        )),
                    InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => HomeBase(
                                  tab: 3,
                                  hasLogin: widget.isLogin,
                                ),
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Image.asset(
                                Constants.ASSET_IMAGES + 'gsc_rewards_icon.png',
                                fit: BoxFit.cover,
                                height: 73,
                                width: 73,
                              ),
                              Text(
                                Utils.getTranslated(context,
                                    "home_module_icon_text_gsc_rewards"),
                                style: AppFont.poppinsRegular(10,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget movieUI(BuildContext ctx, MovieListingDetails data, double width) {
    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(ctx, AppRoutes.movieShowtimesByOpsdate,
            arguments: MovieToBuyArgs(
              selectedCode: data.ParentCode!,
              movieDetails: data,
              firstDate: '',
              availableDate: [],
            ));
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppColor.lightGrey().withOpacity(0.3),
            ),
            width: (width - 24 - 24) / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: data.Poster!,
                fit: BoxFit.fill,
                errorWidget: (context, error, stackTrace) {
                  return Image.asset(
                      'assets/images/Default placeholder_app_img.png',
                      fit: BoxFit.fitWidth);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 6, bottom: 20),
            width: width / 3 - 30,
            child: Center(
              child: Text(
                data.Title ?? "-",
                style: AppFont.poppinsRegular(10, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _promotionList(double screenWidth, BuildContext context) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: AppColor.appSecondaryBlack(),
        borderRadius: widget.isLogin
            ? const BorderRadius.only(
                topLeft: Radius.circular(26), topRight: Radius.circular(26))
            : BorderRadius.circular(26),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Text(
                Utils.getTranslated(context, "home_promotions_title_text"),
                style: AppFont.montSemibold(14, color: Colors.white),
              ),
            ),
            cmspromotionsList != null
                ? Wrap(spacing: 8, children: [
                    for (var index = 0; index < promotionsListCount; index++)
                      promotionItem(
                          context, cmspromotionsList![index], screenWidth)
                  ])
                : Container(),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.promotionListRoute,
                    arguments: cmspromotionsList),
                child: Container(
                  width: 90,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 2),
                      bottom: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      Utils.getTranslated(context, "view_more_btn"),
                      style: AppFont.poppinsRegular(12, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ]),
    );
  }

  Widget _cinemaExperience(double screenWidth, BuildContext context) {
    return Container(
      width: screenWidth,
      margin: widget.isLogin ? EdgeInsets.zero : const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 50),
      decoration: BoxDecoration(
        color: AppColor.appSecondaryBlack(),
        borderRadius: widget.isLogin
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Text(
                Utils.getTranslated(
                    context, "home_cinema_experiences_title_text"),
                style: AppFont.montSemibold(14, color: Colors.white),
              ),
            ),
            cmsexperienceList != null
                ? Wrap(spacing: 8, children: [
                    for (var index = 0; index < experienceListCount; index++)
                      experienceItem(
                          context, cmsexperienceList![index], screenWidth)
                  ])
                : Container(),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.experienceListRoute,
                    arguments: cmsexperienceList),
                child: Container(
                  width: 90,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 2),
                      bottom: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      Utils.getTranslated(context, "view_more_btn"),
                      style: AppFont.poppinsRegular(12, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ]),
    );
  }

  Widget promotionItem(BuildContext ctx, CMS_PROMOTION e, double width) {
    return InkWell(
      onTap: () {
        if (e.path!.first.alias != null) {
          Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (context) => WebView(
                      useHtmlString: false,
                      url: Constants.ESERVICES_GSC_PROMOTION +
                          e.path!.first.alias!.substring(1) +
                          Constants.ESERVICES_GSC_NO_CTA)));
        }
      },
      child: Container(
        width: (width / 3) - 16,
        height: (width - 24) / 3,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColor.lightGrey(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: e.fieldCoverImage?.first.url ?? '',
              fit: BoxFit.cover,
              errorWidget: (context, error, stackTrace) {
                return Image.asset(
                    'assets/images/Default placeholder_app_img.png',
                    fit: BoxFit.fitWidth);
              },
            )),
      ),
    );
  }

  Widget experienceItem(BuildContext ctx, CMS_EXPERIENCE e, double width) {
    return InkWell(
      onTap: () {
        if (e.path!.first.alias != null) {
          _launchUrl(Constants.ESERVICES_GSC_EXPERIENCE +
              e.path!.first.alias!.substring(1) +
              Constants.ESERVICES_GSC_NO_CTA);
        }
      },
      child: Container(
        width: (width / 3) - 16,
        height: (width - 24) / 3,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: e.fieldLogo!.first.url!,
              fit: BoxFit.contain,
              errorWidget: (context, error, stackTrace) {
                return Image.asset(
                    'assets/images/Default placeholder_app_img.png',
                    fit: BoxFit.fitWidth);
              },
            )),
      ),
    );
  }

  Widget pageViewItem(int i, BuildContext context, double availableHeight) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(19),
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  mergedList[i],
                  fit: BoxFit.fill,
                  height: availableHeight * .5,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/Default placeholder_app_img.png',
                      fit: BoxFit.fill,
                      height: availableHeight * .5,
                    );
                  },
                ),
              ),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(
                        Utils.getTranslated(context, "ads"),
                        style: AppFont.poppinsRegular(10, color: Colors.white),
                      ))))
            ],
          ),
        ),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              sliderContent!.length,
              (index) => buildDot(index, context),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 6,
      width: _selectedSliderIndex == index ? 17 : 6,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
          border: Border.all(
              color: _selectedSliderIndex == index
                  ? AppColor.appYellow()
                  : AppColor.iconGrey()),
          borderRadius: BorderRadius.circular(3),
          color: _selectedSliderIndex == index
              ? AppColor.appYellow()
              : Colors.transparent),
    );
  }

  Widget fastTicketFloatingActionButton(BuildContext context) {
    return Container(
      width: 150,
      height: 50,
      margin: const EdgeInsets.only(bottom: 36),
      child: FloatingActionButton(
        onPressed: () async {
          var hasAccessToken =
              await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
          if (hasAccessToken) {
            Navigator.pushNamed(context, AppRoutes.fastTicketRoute);
          } else {
            Navigator.pushNamed(context, AppRoutes.loginRoute);
          }
        },
        backgroundColor: AppColor.backgroundBlack(),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 13, 18, 13),
          decoration: BoxDecoration(
            color: AppColor.backgroundBlack(),
            border: Border.all(color: AppColor.appYellow()),
            borderRadius: BorderRadius.circular(50.0),
            boxShadow: [
              BoxShadow(
                color: AppColor.appYellow(),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Constants.ASSET_IMAGES + 'fast-ticket-icon.png',
                fit: BoxFit.cover,
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 12),
              Text(
                Utils.getTranslated(context, "fast_ticket"),
                style: AppFont.poppinsSemibold(
                  12,
                  color: AppColor.appYellow(),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageDimensionsDialog extends StatefulWidget {
  const ImageDimensionsDialog({Key? key}) : super(key: key);

  @override
  _ImageDimensionsDialogState createState() => _ImageDimensionsDialogState();
}

class _ImageDimensionsDialogState extends State<ImageDimensionsDialog> {
  Future<Size>? imageSizeFuture;

  @override
  void initState() {
    super.initState();
    imageSizeFuture = getImageSize();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Image Dimensions'),
      content: FutureBuilder(
        future: imageSizeFuture,
        builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            final Size imageSize = snapshot.data!;
            return Text(
              'Width: ${imageSize.width.toStringAsFixed(2)}\n'
              'Height: ${imageSize.height.toStringAsFixed(2)}',
            );
          } else if (snapshot.hasError) {
            return const Text('Error loading image');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<Size> getImageSize() async {
    final Completer<Size> completer = Completer<Size>();
    final ImageStream imageStream =
        Image.network('https://example.com/my_image.jpg')
            .image
            .resolve(ImageConfiguration.empty);
    imageStream.addListener(
      ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          final Size imageSize = Size(
            imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble(),
          );
          completer.complete(imageSize);
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          completer.completeError(error);
        },
      ),
    );
    return completer.future;
  }
}
