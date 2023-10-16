// ignore_for_file: non_constant_identifier_names

class ChangePasswordModel {
  bool? IsValid;
  int? ReturnStatus;
  String? ReturnMessage;
  String? RequestTime;
  String? ResponseTime;

  ChangePasswordModel(
      {this.IsValid,
      this.ReturnStatus,
      this.ReturnMessage,
      this.RequestTime,
      this.ResponseTime});

  ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    IsValid = json['IsValid'];
    ReturnStatus = json['ReturnStatus'];
    ReturnMessage = json['ReturnMessage'];
    RequestTime = json['RequestTime'];
    ResponseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "IsValid": IsValid,
      "ReturnStatus": ReturnStatus,
      "ReturnMessage": ReturnMessage,
      "RequestTime": RequestTime,
      "ResponseTime": ResponseTime,
    };
    return data;
  }
}

class MembershipCancellationModel {
  int? ReturnStatus;
  String? ReturnMessage;
  String? RequestTime;
  String? ResponseTime;

  MembershipCancellationModel(
      {this.ReturnStatus,
      this.ReturnMessage,
      this.RequestTime,
      this.ResponseTime});

  MembershipCancellationModel.fromJson(Map<String, dynamic> json) {
    ReturnStatus = json['ReturnStatus'];
    ReturnMessage = json['ReturnMessage'];
    RequestTime = json['RequestTime'];
    ResponseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "ReturnStatus": ReturnStatus,
      "ReturnMessage": ReturnMessage,
      "RequestTime": RequestTime,
      "ResponseTime": ResponseTime,
    };
    return data;
  }
}
