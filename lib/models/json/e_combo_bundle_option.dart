// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/e_combo_bundle_option_items.dart';

class EComboBundleOption {
  int? OptionNo;
  List<EComboBundleItems>? Items;

  EComboBundleOption({this.OptionNo, this.Items});

  EComboBundleOption.fromJson(Map<String, dynamic> json) {
    OptionNo = json['OptionNo'];

    var list = json['Items'] as List;

    if (list.isNotEmpty) {
      Items = list.map((e) => EComboBundleItems.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'OptionNo': OptionNo, 'Items': Items};

    return res;
  }
}
