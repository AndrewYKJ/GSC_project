// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/aurum_ecombo_status.dart';
import 'package:gsc_app/models/json/e_combo_bundle.dart';

class AurumEcomboBody {
  AurumEcomboStatus? Status;
  List<EComboBundle>? Bundles;

  AurumEcomboBody({this.Status, this.Bundles});

  AurumEcomboBody.fromJson(Map<String, dynamic> json) {
    var list = json['Bundles'] as List;

    Status = AurumEcomboStatus.fromJson(json['Status']);

    if (list.isNotEmpty) {
      Bundles = list.map((e) => EComboBundle.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'Status': Status, 'Bundles': Bundles};

    return res;
  }
}
