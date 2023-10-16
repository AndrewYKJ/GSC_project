
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/widgets/push_notification_firebase.dart';
import 'package:gsc_app/widgets/push_notification_hms.dart';

class PushNotificationHandler {
  static void initialize() {
    Utils.printInfo(">>>>>>> IS HUAWEI: ${Constants.IS_HUAWEI}");
    if (Constants.IS_HUAWEI) {
      PushNotificationHms.initHuaweiPush();
    } else {
      PushNotificationFcm.fcmPushInitialise();
    }
  } 

  static void getToken(){
    if (Constants.IS_HUAWEI){
      Utils.printInfo(">>>>>>> HOMEBASE GET PUSH TOKEN");
      PushNotificationHms.getHMSToken();
    } else {
      PushNotificationFcm.getFcmToken();
    }
  }

  
}