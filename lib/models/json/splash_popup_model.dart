import 'dart:convert';

class SplashPopUpDTO {
  SplashPopUpData? response;

  SplashPopUpDTO({
    this.response,
  });

  factory SplashPopUpDTO.fromRawJson(String str) =>
      SplashPopUpDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SplashPopUpDTO.fromJson(Map<String, dynamic> json) => SplashPopUpDTO(
        response: json["Response"] == null
            ? null
            : SplashPopUpData.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class SplashPopUpData {
  Header? header;
  Body? body;

  SplashPopUpData({
    this.header,
    this.body,
  });

  factory SplashPopUpData.fromRawJson(String str) =>
      SplashPopUpData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SplashPopUpData.fromJson(Map<String, dynamic> json) =>
      SplashPopUpData(
        header: json["Header"] == null ? null : Header.fromJson(json["Header"]),
        body: json["Body"] == null ? null : Body.fromJson(json["Body"]),
      );

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Body": body?.toJson(),
      };
}

class Body {
  Status? status;
  List<SplashImage>? images;

  Body({
    this.status,
    this.images,
  });

  factory Body.fromRawJson(String str) => Body.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        status: json["Status"] == null ? null : Status.fromJson(json["Status"]),
        images: json["Images"] == null
            ? []
            : List<SplashImage>.from(
                json["Images"]!.map((x) => SplashImage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status": status?.toJson(),
        "Images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
      };
}

class SplashImage {
  int? sequence;
  String? imageName;
  String? imageLink;
  bool? isAsset;

  SplashImage({
    this.sequence,
    this.imageName,
    this.imageLink,
    this.isAsset,
  });

  factory SplashImage.fromRawJson(String str) =>
      SplashImage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SplashImage.fromJson(Map<String, dynamic> json) => SplashImage(
        sequence: json["Sequence"],
        imageName: json["ImageName"],
        imageLink: json["ImageLink"],
        isAsset: false,
      );

  Map<String, dynamic> toJson() => {
        "Sequence": sequence,
        "ImageName": imageName,
        "ImageLink": imageLink,
      };
}

class Status {
  String? respStatus;
  String? respDesc;
  DateTime? respDateTime;

  Status({
    this.respStatus,
    this.respDesc,
    this.respDateTime,
  });

  factory Status.fromRawJson(String str) => Status.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        respStatus: json["RespStatus"],
        respDesc: json["RespDesc"],
        respDateTime: json["RespDateTime"] == null
            ? null
            : DateTime.parse(json["RespDateTime"]),
      );

  Map<String, dynamic> toJson() => {
        "RespStatus": respStatus,
        "RespDesc": respDesc,
        "RespDateTime": respDateTime?.toIso8601String(),
      };
}

class Header {
  String? ver;

  Header({
    this.ver,
  });

  factory Header.fromRawJson(String str) => Header.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        ver: json["Ver"],
      );

  Map<String, dynamic> toJson() => {
        "Ver": ver,
      };
}
