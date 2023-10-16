import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsFirebase {

  static void setFirebaseAnalyticsCurrentScreen(String screen){
    FirebaseAnalytics.instance.setCurrentScreen(screenName: screen);
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': screen,
        'firebase_screen_class': screen,
      },
    );
  }
}