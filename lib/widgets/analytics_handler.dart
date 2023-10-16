import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/widgets/analytics_firebase.dart';
import 'package:gsc_app/widgets/analytics_hms.dart';

class AnalyticsHandler {

  static void setAnalyticsCurrentScreen(String screen){
    if (Constants.IS_HUAWEI){
      AnalyticsHms.initAnalytics().then((value){
        AnalyticsHms.hmsAnalytics = value;
        AnalyticsHms.pageStart(screen);
        AnalyticsHms.pageEnter(screen);
      });
    } else {
      AnalyticsFirebase.setFirebaseAnalyticsCurrentScreen(screen);
    } 
  }
}