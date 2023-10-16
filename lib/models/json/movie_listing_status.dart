// ignore_for_file: non_constant_identifier_names

class MovieListingStatus {
  String? RespStatus;
  String? RespDesc;
  String? RespDateTime;

  MovieListingStatus({this.RespDateTime, this.RespDesc, this.RespStatus});

  MovieListingStatus.fromJson(Map<String, dynamic> json) {
    RespStatus = json['RespStatus'];
    RespDesc = json["RespDesc"];
    RespDateTime = json["RespDateTime"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['RespStatus'] = RespStatus;
    data['RespDesc'] = RespDesc;
    data['RespDateTime'] = RespDateTime;

    return data;
  }
}
