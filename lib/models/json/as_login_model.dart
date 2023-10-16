class LoginDTO {
  bool? succeeded;
  String? message;
  List<String>? errors;
  int? status;
  LoginDataDTO? data;

  LoginDTO({
    this.succeeded,
    this.message,
    this.errors,
    this.status,
    this.data,
  });

  factory LoginDTO.fromJson(Map<String, dynamic> json) => LoginDTO(
        succeeded: json["succeeded"],
        message: json["message"],
        errors: json["errors"] == null
            ? []
            : List<String>.from(json["errors"]!.map((x) => x)),
        status: json["status"],
        data: json["data"] == null ? null : LoginDataDTO.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "succeeded": succeeded,
        "message": message,
        "errors":
            errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
        "status": status,
        "data": data?.toJson(),
      };
}

class LoginDataDTO {
  String? id;
  String? name;
  String? fullName;
  String? email;
  String? tokenExpire;
  String? token;
  String? mobileNo;
  bool? isGuest;
  String? cardNo;
  String? tier;
  String? memberType;

  LoginDataDTO({
    this.id,
    this.name,
    this.fullName,
    this.email,
    this.tokenExpire,
    this.token,
    this.mobileNo,
    this.isGuest,
    this.cardNo,
    this.tier,
    this.memberType,
  });

  factory LoginDataDTO.fromJson(Map<String, dynamic> json) => LoginDataDTO(
        id: json["id"],
        name: json["name"],
        fullName: json["fullName"],
        email: json["email"],
        tokenExpire: json["tokenExpire"],
        token: json["token"],
        mobileNo: json["mobileNo"],
        isGuest: json["isGuest"],
        cardNo: json["cardNo"],
        tier: json["tier"],
        memberType: json["memberType"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "fullName": fullName,
        "email": email,
        "tokenExpire": tokenExpire,
        "token": token,
        "mobileNo": mobileNo,
        "isGuest": isGuest,
        "cardNo": cardNo,
        "tier": tier,
        "memberType": memberType,
      };
}
