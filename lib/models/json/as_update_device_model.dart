class UpdateDeviceDTO {
  int? returnStatus;
  String? returnMessage;
  String? requestTime;
  String? responseTime;

  UpdateDeviceDTO({
    this.returnStatus,
    this.returnMessage,
    this.requestTime,
    this.responseTime,
  });

  UpdateDeviceDTO.fromJson(Map<String, dynamic> json) {
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
