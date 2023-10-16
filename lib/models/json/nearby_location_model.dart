import 'dart:convert';

class NearbyLocationDTO {
  NearbyLocationResponse? response;

  NearbyLocationDTO({
    this.response,
  });

  factory NearbyLocationDTO.fromRawJson(String str) =>
      NearbyLocationDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NearbyLocationDTO.fromJson(Map<String, dynamic> json) =>
      NearbyLocationDTO(
        response: json["Response"] == null
            ? null
            : NearbyLocationResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class NearbyLocationResponse {
  NearbyLocationHeader? header;
  NearbyLocationBody? body;

  NearbyLocationResponse({
    this.header,
    this.body,
  });

  factory NearbyLocationResponse.fromRawJson(String str) =>
      NearbyLocationResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NearbyLocationResponse.fromJson(Map<String, dynamic> json) =>
      NearbyLocationResponse(
        header: json["Header"] == null
            ? null
            : NearbyLocationHeader.fromJson(json["Header"]),
        body: json["Body"] == null
            ? null
            : NearbyLocationBody.fromJson(json["Body"]),
      );

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Body": body?.toJson(),
      };
}

class NearbyLocationBody {
  NearbyLocationBodyStatus? status;
  List<SwaggerLocation>? topFive;
  List<SwaggerLocation>? locations;

  NearbyLocationBody({
    this.status,
    this.topFive,
    this.locations,
  });

  factory NearbyLocationBody.fromRawJson(String str) =>
      NearbyLocationBody.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NearbyLocationBody.fromJson(Map<String, dynamic> json) =>
      NearbyLocationBody(
        status: json["s"] == null
            ? null
            : NearbyLocationBodyStatus.fromJson(json["Status"]),
        topFive: json["TopFive"] == null
            ? []
            : List<SwaggerLocation>.from(
                json["TopFive"]!.map((x) => SwaggerLocation.fromJson(x))),
        locations: json["Locations"] == null
            ? []
            : List<SwaggerLocation>.from(
                json["Locations"]!.map((x) => SwaggerLocation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status": status?.toJson(),
        "TopFive":
            topFive == null ? [] : List<dynamic>.from(topFive!.map((x) => x)),
        "Locations": locations == null
            ? []
            : List<dynamic>.from(locations!.map((x) => x.toJson())),
      };
}

class SwaggerLocation {
  int? sequence;
  int? cinemaCode;
  String? cinemaName;
  String? epaymentName;
  String? hallGroup;
  int? sort;
  String? longitude;
  String? latitude;
  String? thumb;
  String? thumbSmall;
  String? thumbMedium;
  String? thumbLarge;
  String? address;
  String? region;
  bool? isEpayEnabled;
  bool? isEpayHidden;
  List<ShowDate>? showDate;

  SwaggerLocation({
    this.sequence,
    this.cinemaCode,
    this.cinemaName,
    this.epaymentName,
    this.hallGroup,
    this.sort,
    this.longitude,
    this.latitude,
    this.thumb,
    this.thumbSmall,
    this.thumbMedium,
    this.thumbLarge,
    this.address,
    this.region,
    this.isEpayEnabled,
    this.isEpayHidden,
    this.showDate,
  });

  factory SwaggerLocation.fromRawJson(String str) =>
      SwaggerLocation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SwaggerLocation.fromJson(Map<String, dynamic> json) =>
      SwaggerLocation(
        sequence: json["Sequence"],
        cinemaCode: json["CinemaCode"],
        cinemaName: json["CinemaName"],
        epaymentName: json["EpaymentName"],
        hallGroup: json["HallGroup"],
        sort: json["Sort"],
        longitude: json["Longitude"],
        latitude: json["Latitude"],
        thumb: json["Thumb"],
        thumbSmall: json["ThumbSmall"],
        thumbMedium: json["ThumbMedium"],
        thumbLarge: json["ThumbLarge"],
        address: json["Address"],
        region: json["Region"],
        isEpayEnabled: json["IsEpayEnabled"],
        isEpayHidden: json["IsEpayHidden"],
        showDate: json["ShowDate"] == null
            ? []
            : List<ShowDate>.from(
                json["ShowDate"]!.map((x) => ShowDate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Sequence": sequence,
        "CinemaCode": cinemaCode,
        "CinemaName": cinemaName,
        "EpaymentName": epaymentName,
        "HallGroup": hallGroup,
        "Sort": sort,
        "Longitude": longitude,
        "Latitude": latitude,
        "Thumb": thumb,
        "ThumbSmall": thumbSmall,
        "ThumbMedium": thumbMedium,
        "ThumbLarge": thumbLarge,
        "Address": address,
        "Region": region,
        "IsEpayEnabled": isEpayEnabled,
        "IsEpayHidden": isEpayHidden,
        "ShowDate": showDate == null
            ? []
            : List<dynamic>.from(showDate!.map((x) => x.toJson())),
      };
}

class CheckBoxSwaggerLocation {
  SwaggerLocation? location;
  bool? isChecked;

  CheckBoxSwaggerLocation({
    this.location,
    this.isChecked,
  });
}

class ShowDate {
  DateTime? operationDate;
  String? displayDate;

  ShowDate({
    this.operationDate,
    this.displayDate,
  });

  factory ShowDate.fromRawJson(String str) =>
      ShowDate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShowDate.fromJson(Map<String, dynamic> json) => ShowDate(
        operationDate: json["OperationDate"] == null
            ? null
            : DateTime.parse(json["OperationDate"]),
        displayDate: json["DisplayDate"],
      );

  Map<String, dynamic> toJson() => {
        "OperationDate":
            "${operationDate!.year.toString().padLeft(4, '0')}-${operationDate!.month.toString().padLeft(2, '0')}-${operationDate!.day.toString().padLeft(2, '0')}",
        "DisplayDate": displayDate,
      };
}

class NearbyLocationBodyStatus {
  String? respNearbyLocationBodyStatus;
  String? respDesc;
  DateTime? respDateTime;

  NearbyLocationBodyStatus({
    this.respNearbyLocationBodyStatus,
    this.respDesc,
    this.respDateTime,
  });

  factory NearbyLocationBodyStatus.fromRawJson(String str) =>
      NearbyLocationBodyStatus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NearbyLocationBodyStatus.fromJson(Map<String, dynamic> json) =>
      NearbyLocationBodyStatus(
        respNearbyLocationBodyStatus: json["RespNearbyLocationBodyStatus"],
        respDesc: json["RespDesc"],
        respDateTime: json["RespDateTime"] == null
            ? null
            : DateTime.parse(json["RespDateTime"]),
      );

  Map<String, dynamic> toJson() => {
        "RespNearbyLocationBodyStatus": respNearbyLocationBodyStatus,
        "RespDesc": respDesc,
        "RespDateTime": respDateTime?.toIso8601String(),
      };
}

class NearbyLocationHeader {
  String? ver;

  NearbyLocationHeader({
    this.ver,
  });

  factory NearbyLocationHeader.fromRawJson(String str) =>
      NearbyLocationHeader.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NearbyLocationHeader.fromJson(Map<String, dynamic> json) =>
      NearbyLocationHeader(
        ver: json["Ver"],
      );

  Map<String, dynamic> toJson() => {
        "Ver": ver,
      };
}
