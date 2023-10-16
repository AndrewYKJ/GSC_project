// ignore_for_file: non_constant_identifier_names

class VoucherIssuanceModel {
  int? ReturnStatus;
  String? ReturnMessage;
  String? RequestTime;
  String? ResponseTime;

  VoucherIssuanceModel(
      {this.ReturnStatus,
      this.ReturnMessage,
      this.RequestTime,
      this.ResponseTime});

  VoucherIssuanceModel.fromJson(Map<String, dynamic> json) {
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
