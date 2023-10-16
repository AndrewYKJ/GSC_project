// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/aurum_ecombo_response.dart';

class AurumEcomboMain {
  AurumEcomboResponse? Response;

  AurumEcomboMain({this.Response});

  AurumEcomboMain.fromJson(Map<String, dynamic> json) {
    Response = AurumEcomboResponse.fromJson(json['Response']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'Response': Response};

    return res;
  }
}
