
class QrTokenDTO {
  String? token;
  String? expiryDateTime;
  int? returnStatus;
  String? returnMessage;
  String? requestTime;
  String? responseTime;

  QrTokenDTO({
    this.token,
    this.expiryDateTime,
    this.returnStatus,
    this.returnMessage,
    this.requestTime,
    this.responseTime,
  });

  QrTokenDTO.fromJson(Map<String, dynamic> json) {
    token = json['Token'];
    expiryDateTime = json['ExpiryDateTime'];
    returnStatus = json['ReturnStatus'];
    returnMessage = json['ReturnMessage'];
    requestTime = json['RequestTime'];
    responseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "Token": token,
      "ExpiryDateTime": expiryDateTime,
      "ReturnStatus": returnStatus,
      "ReturnMessage": returnMessage,
      "RequestTime": requestTime,
      "ResponseTime": responseTime,
    };

    return data;
  }
}