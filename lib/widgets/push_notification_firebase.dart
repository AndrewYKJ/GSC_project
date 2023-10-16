import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../cache/app_cache.dart';
import '../const/utils.dart';
import '../controllers/tab/homebase.dart';

class PushNotificationFcm {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  static Future<void> fcmPushInitialise() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    initialiseLocalNotifcation();

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        Utils.printInfo("FCM Listen onMessage: ${message.notification?.title}");
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: android.smallIcon,
                ),
              ),
              payload: json.encode(message.data));
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        Utils.printInfo("****** ON MESSAGE OPENED APP ******");

        Utils.printInfo("*** Message Data: ${message.data}");
        Utils.printInfo("*** Message Title : ${message.notification?.title}");
        Utils.printInfo("*** Message Body : ${message.notification?.body}");

        AppCache.payload = message.data;
        HomeBase.homeKey.currentState?.checkPush();
      },
    );

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        Utils.printInfo("****** ON GET INITIAL MESSAGE ******");
        if (message != null) {
          AppCache.payload = message.data;
        }
      },
    );
  }

  static void initialiseLocalNotifcation() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((message) {
      Utils.printInfo("LOCAL NOTIFICATION: $message");
      if (message != null) {
        if (message.didNotificationLaunchApp) {
          if (message.payload != null) {
            AppCache.payload = json.decode(message.payload!);
          }
        }
      }
    });

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    void selectNotification(String? payload) {
      Utils.printInfo("*** onTap Notification Bar: $payload");
      if (payload != null) {
        var data = json.decode(payload);
        Utils.printInfo("*** payloadData: $data");

        AppCache.payload = data;
        HomeBase.homeKey.currentState?.checkPush();
      }
    }

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    Utils.printInfo("*** Background Message : ${message.data}");
    Utils.printInfo(
        "*** Background Message Title : ${message.notification!.title}");
    Utils.printInfo(
        "*** Background Message Body : ${message.notification!.body}");
  }

  static void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    Utils.printInfo("*** iOS onTap LocalNotification Bar| Title: $title");
    Utils.printInfo("*** iOS onTap LocalNotification Bar| Body: $body");
    Utils.printInfo("*** iOS onTap LocalNotification Bar| Payload: $payload");
    if (payload != null) {
      AppCache.payload = json.decode(payload);
    }
  }

  static Future<void> preinitFirebaseMessaging() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  static void getFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    AppCache.fcmToken = token;
    Utils.printInfo("FCM TOKEN: $token");
  }
}
