// ignore_for_file: non_constant_identifier_names

class AurumEcomboStatus {
  String? RespStatus;
  String? RespDesc;
  String? RespDateTime;

  AurumEcomboStatus({this.RespStatus, this.RespDesc, this.RespDateTime});

  AurumEcomboStatus.fromJson(Map<String, dynamic> json) {
    RespStatus = json['RespStatus'];
    RespDesc = json['RespDesc'];
    RespDateTime = json['RespDateTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'RespStatus': RespStatus,
      'RespDesc': RespDesc,
      'RespDateTime': RespDateTime
    };

    return res;
  }
}
