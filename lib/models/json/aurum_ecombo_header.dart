// ignore_for_file: non_constant_identifier_names

class AurumEcomboHeader {
  String? Ver;

  AurumEcomboHeader({this.Ver});

  AurumEcomboHeader.fromJson(Map<String, dynamic> json) {
    Ver = json['Ver'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'Ver': Ver};

    return res;
  }
}
