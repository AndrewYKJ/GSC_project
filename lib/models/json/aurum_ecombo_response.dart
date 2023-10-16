// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/aurum_ecombo_body.dart';
import 'package:gsc_app/models/json/aurum_ecombo_header.dart';

class AurumEcomboResponse {
  AurumEcomboHeader? Header;
  AurumEcomboBody? Body;
  String? Signature;

  AurumEcomboResponse({this.Header, this.Body, this.Signature});

  AurumEcomboResponse.fromJson(Map<String, dynamic> json) {
    Header = AurumEcomboHeader.fromJson(json['Header']);
    Body = AurumEcomboBody.fromJson(json['Body']);
    Signature = json['Signature'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'Header': Header,
      'Body': Body,
      'Signature': Signature
    };

    return res;
  }
}
