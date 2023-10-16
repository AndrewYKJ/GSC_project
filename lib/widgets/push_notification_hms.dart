import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huawei_push/huawei_push.dart' as hpush;

import '../cache/app_cache.dart';
import '../const/utils.dart';
import '../controllers/tab/homebase.dart';

class PushNotificationHms {


  static void initHuaweiPush() async {

    await hpush.Push.setAutoInitEnabled(true);

    hpush.Push.getIntentStream.listen(
      _onNewIntent,
      onError: _onIntentError,
    );

    hpush.Push.onNotificationOpenedApp.listen(
      _onNotificationOpenedApp,
    );

    // final dynamic initialNotification = await hpush.Push.getInitialNotification();
    // _onNotificationOpenedApp(initialNotification);

    final String? intent = await hpush.Push.getInitialIntent();
    _onNewIntent(intent);

    hpush.Push.onMessageReceivedStream.listen(
      _onMessageReceived,
      onError: _onMessageReceiveError,
    );
    hpush.Push.getRemoteMsgSendStatusStream.listen(
      _onRemoteMessageSendStatus,
      onError: _onRemoteMessageSendError,
    );

    bool backgroundMessageHandler = await hpush.Push.registerBackgroundMessageHandler(
      backgroundMessageCallback,
    );
    debugPrint(
      'backgroundMessageHandler registered: $backgroundMessageHandler',
    );
  }

  static void getHMSToken() async {
    await hpush.Push.setAutoInitEnabled(true);

    hpush.Push.getToken('');
    hpush.Push.getTokenStream.listen((event) {
      AppCache.fcmToken = event;
      Utils.printInfo("HMS TOKEN: $event");
    }, onError: (err){
      PlatformException e = err as PlatformException;
      Utils.printInfo("HMS TOKEN: ${e.message}");
    });
  }

  static void backgroundMessageCallback(hpush.RemoteMessage remoteMessage) async {
    String? data = remoteMessage.data;
    if (data != null) {
      debugPrint(
        'Background message is received, sending local notification.',
      );
      hpush.Push.localNotification(
        <String, String>{
          hpush.HMSLocalNotificationAttr.TITLE: '[Headless] DataMessage Received',
          hpush.HMSLocalNotificationAttr.MESSAGE: data,
        },
      );
    } else {
      debugPrint(
        'Background message is received. There is no data in the message.',
      );
    }
  }

  static void removeBackgroundMessageHandler() async {
    await hpush.Push.removeBackgroundMessageHandler();
  }

  static void _onNotificationOpenedApp(dynamic initialNotification) {
    showResult('_onNotificationOpenedApp');
    if (initialNotification != null) {
      if (initialNotification['extras'] != null){
        AppCache.payload = initialNotification['extras'];
        HomeBase.homeKey.currentState?.checkPush();
      }
    }
  }

  static void showResult(
    String name, [
    String? msg = 'Button pressed.',
  ]) {
    msg ??= '';
    debugPrint('[$name]: $msg');
    hpush.Push.showToast('[$name]: $msg');
  }

  static void _onMessageReceived(hpush.RemoteMessage remoteMessage) {
    showResult('onMessageReceived');
    Utils.printInfo("HUA WEI MESG RECEIVED");

    String? data = remoteMessage.data;
    if (data != null) {
      hpush.Push.localNotification(
        <String, String>{
          hpush.HMSLocalNotificationAttr.TITLE: 'DataMessage Received',
          hpush.HMSLocalNotificationAttr.MESSAGE: data,
        },
      );
      showResult('onMessageReceived', 'Data: $data');
    } else {
      showResult('onMessageReceived', 'No data is present.');
    }
  }

  static void _onMessageReceiveError(Object error) {
    showResult('onMessageReceiveError', error.toString());
  }

  static void _onRemoteMessageSendStatus(String event) {
    showResult('RemoteMessageSendStatus', 'Status: $event');
  }

  static void _onRemoteMessageSendError(Object error) {
    PlatformException e = error as PlatformException;
    showResult('RemoteMessageSendError', 'Error: $e');
  }

  static void _onNewIntent(String? intentString) {
    // For navigating to the custom intent page (deep link) the custom
    // intent that sent from the push kit console is:
    // app://app2
    intentString = intentString ?? '';
    if (intentString != '') {
      showResult('CustomIntentEvent: ', intentString);
      // List<String> parsedString = intentString.split('://');
      // if (parsedString[1] == 'app2') {
      //   SchedulerBinding.instance.addPostFrameCallback(
      //     (Duration timeStamp) {
      //       Navigator.of(context).push(
      //         MaterialPageRoute<dynamic>(
      //           builder: (BuildContext context) => const CustomIntentPage(),
      //         ),
      //       );
      //     },
      //   );
      // }
    }
  }

  static void _onIntentError(Object err) {
    PlatformException e = err as PlatformException;
    debugPrint('Error on intent stream: $e');
  }

}