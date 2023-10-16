class DeleteInAppMessageDTO {
  int? returnStatus;
  String? returnMessage;
  String? requestTime;
  String? responseTime;

  DeleteInAppMessageDTO({
    this.returnStatus,
    this.returnMessage,
    this.requestTime,
    this.responseTime,
  });

  DeleteInAppMessageDTO.fromJson(Map<String, dynamic> json) {
    returnStatus = json['ReturnStatus'];
    returnMessage = json['ReturnMessage'];
    requestTime = json['RequestTime'];
    responseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "ReturnStatus": returnStatus,
      "ReturnMessage": returnMessage,
      "RequestTime": requestTime,
      "ResponseTime": responseTime,
    };

    return data;
  }
}
