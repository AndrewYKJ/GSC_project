import 'package:gsc_app/models/json/splash_popup_model.dart';

class SplashScreenImageModel {
  SplashImage? data;
  String? record;

  SplashScreenImageModel({
    this.data,
    this.record,
  });

  SplashScreenImageModel.fromJson(Map<String, dynamic> json) {
    data = SplashImage.fromJson(json['data']);
    record = json['record'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'data': data,
      'record': record,
    };

    return res;
  }
}
