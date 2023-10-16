// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/e_combo_bundle_option.dart';

class EComboBundle {
  String? Code;
  String? Name;
  int? Sequence;
  List<EComboBundleOption>? Options;

  EComboBundle({this.Code, this.Name, this.Sequence, this.Options});

  EComboBundle.fromJson(Map<String, dynamic> json) {
    Code = json['Code'];
    Name = json['Name'];
    Sequence = json['Sequence'];

    var list = json['Options'] as List;

    if (list.isNotEmpty) {
      Options = list.map((e) => EComboBundleOption.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'Code': Code,
      'Name': Name,
      'Sequence': Sequence,
      'Options': Options
    };

    return res;
  }
}
