// ignore_for_file: prefer_typing_uninitialized_variables, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gsc_app/dio/api/auth_api.dart';
import 'package:gsc_app/provider/home_provider.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/analytics_hms.dart';
import 'package:gsc_app/widgets/push_notification_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'cache/app_cache.dart';
import 'const/constants.dart';
import 'const/localization.dart';
import 'const/utils.dart';
// import 'package:facebook_app_events/facebook_app_events.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Utils.isHuawei().then(
    (value) async {
      if (!value) {
        await Firebase.initializeApp();
      }

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DrawerState()),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyApp? state = context.findAncestorStateOfType<_MyApp>();
    state!.setLocale(newLocale);
  }

  void callStartTimer(BuildContext context, int expiredIn) {
    Duration diff = Duration(seconds: expiredIn);
    const oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (timer.tick == (diff.inSeconds - 100)) {
          timer.cancel();
          await refreshAuth(context);
        }
      },
    );
  }

  Future refreshAuth(BuildContext context) async {
    AuthApi _appAuth = AuthApi(context);
    _appAuth.generateToken().then((value) async {
      if (value != null) {
        AppCache.accessToken = value["access_token"];
        AppCache.tokenType = value["token_type"];
        callStartTimer(context, value["expires_in"]);
      }
    });
  }

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'main_navigator');
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  late Locale _locale;
  // static final facebookAppEvents = FacebookAppEvents();

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    Utils.isHuawei().then(
      (value) async {
        if (value) {
          AnalyticsHms.initAnalytics().then((value) {
            AnalyticsHms.hmsAnalytics = value;
            AnalyticsHms.enableLog();
            AnalyticsHms.enableAnalytics();
          });
        }
        getAllInfo();
        configEasyLoading();
        // facebookAppEvents.setAutoLogAppEventsEnabled(true);
        setState(() {
          _locale = Utils.myLocale(Constants.ENGLISH);
        });
        PushNotificationHandler.initialize();
      },
    );
  }

  Future getAllInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var version = packageInfo.version;
    var deviceUUID;
    var deviceModel;
    var deviceName;
    var deviceVersion;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceUUID = androidInfo.id;
      deviceModel = 'Android';
      deviceName = '${androidInfo.brand} ${androidInfo.model}';
      deviceVersion =
          'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceUUID = iosInfo.identifierForVendor ?? '';

      deviceModel = iosInfo.systemName ?? 'iOS';
      deviceName = iosInfo.name ?? '';
      deviceVersion = iosInfo.systemVersion ?? '';
    }

    AppCache.setString(
        AppCache.DEVICE_INFO,
        json.encode({
          "appVersion": version,
          "deviceUUID": deviceUUID,
          "deviceModel": deviceModel,
          "deviceName": deviceName,
          "deviceVersion": deviceVersion
        }));
  }

  @override
  void didChangeDependencies() {
    setState(() {
      _locale = Utils.myLocale(Constants.ENGLISH);
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GSC (Dev)',
      theme: ThemeData(
          backgroundColor: Colors.black,
          primarySwatch: Colors.blue,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          unselectedWidgetColor: Colors.white60),
      onGenerateRoute: AppRoutes.generatedRoute,
      initialRoute: AppRoutes.splashScreenRoute,
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[routeObserver],
      locale: _locale,
      supportedLocales: const [Locale("en"), Locale("zh")],
      localizationsDelegates: const [
        MyLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      builder: (context, child) {
        return MediaQuery(
          child: FlutterEasyLoading(child: child),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
    );
  }
}

void configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.grey
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.grey
    ..textColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}
