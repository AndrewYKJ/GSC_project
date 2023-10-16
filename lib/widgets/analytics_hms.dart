import 'package:huawei_analytics/huawei_analytics.dart';

class AnalyticsHms {
  static late HMSAnalytics hmsAnalytics;
 
  static Future<HMSAnalytics> initAnalytics() async {
    hmsAnalytics = await HMSAnalytics.getInstance();
    return hmsAnalytics;
  }

  static Future<void> enableLog() async {
    await hmsAnalytics.enableLog();
  }

  static Future<void> enableAnalytics() async {
    await hmsAnalytics.setAnalyticsEnabled(true);
  }

  static Future<void> pageStart(String screen) async {
    await hmsAnalytics.pageStart(screen, screen);
  }

  static Future<void> pageEnter(String screen) async {
    await hmsAnalytics.onEvent("Page Visit", {
      "page_name": screen
    });
  }
}