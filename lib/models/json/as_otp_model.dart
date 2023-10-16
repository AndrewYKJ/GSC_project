
class OtpDTO {
  String? otp;
  bool? isValid;
  int? returnStatus;
  String? returnMessage;
  String? requestTime;
  String? responseTime;

  OtpDTO({
    this.otp,
    this.isValid,
    this.returnStatus,
    this.returnMessage,
    this.requestTime,
    this.responseTime,
  });

  OtpDTO.fromJson(Map<String, dynamic> json) {
    otp = json['OTPcode'];
    isValid = json['IsValid'];
    returnStatus = json['ReturnStatus'];
    returnMessage = json['ReturnMessage'];
    requestTime = json['RequestTime'];
    responseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "OTPcode": otp,
      "IsValid": isValid,
      "ReturnStatus": returnStatus,
      "ReturnMessage": returnMessage,
      "RequestTime": requestTime,
      "ResponseTime": responseTime,
    };

    return data;
  }
}