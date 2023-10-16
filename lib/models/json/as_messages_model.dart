class InAppMessageDTO {
  String? deviceUid;
  String? appName;
  int? totalCount;
  List<InAppMessageInfoDTO>? inAppMessageInfoList;
  int? returnStatus;
  String? returnMessage;
  String? requestTime;
  String? responseTime;

  InAppMessageDTO({
    this.deviceUid,
    this.appName,
    this.totalCount,
    this.inAppMessageInfoList,
    this.returnStatus,
    this.returnMessage,
    this.requestTime,
    this.responseTime,
  });

  InAppMessageDTO.fromJson(Map<String, dynamic> json) {
    deviceUid = json['DeviceUID'];
    appName = json['AppName'];
    totalCount = json['TotalCount'];
    inAppMessageInfoList = json["InAppInfoLists"] == null
        ? []
        : List<InAppMessageInfoDTO>.from(json["InAppInfoLists"]!
            .map((x) => InAppMessageInfoDTO.fromJson(x)));
    returnStatus = json['ReturnStatus'];
    returnMessage = json['ReturnMessage'];
    requestTime = json['RequestTime'];
    responseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "DeviceUID": deviceUid,
      "AppName": appName,
      "TotalCount": totalCount,
      "InAppInfoLists": inAppMessageInfoList == null
          ? []
          : List<dynamic>.from(inAppMessageInfoList!.map((x) => x.toJson())),
      "ReturnStatus": returnStatus,
      "ReturnMessage": returnMessage,
      "RequestTime": requestTime,
      "ResponseTime": responseTime,
    };

    return data;
  }
}

class InAppMessageInfoDTO {
  String? blastHeadId;
  String? blastId;
  String? inAppSubject;
  String? inAppMessage;
  String? inAppImageLink;
  String? inAppDescription;
  bool? readStatus;
  String? sentOn;
  String? viewOn;
  bool? isChecked = false;
  bool? isShowArrowRightIcon = true;

  InAppMessageInfoDTO(
      {this.blastHeadId,
      this.blastId,
      this.inAppSubject,
      this.inAppMessage,
      this.inAppImageLink,
      this.inAppDescription,
      this.readStatus,
      this.sentOn,
      this.viewOn,
      this.isChecked,
      this.isShowArrowRightIcon});

  InAppMessageInfoDTO.fromJson(Map<String, dynamic> json) {
    blastHeadId = json['BlastHeaderID'];
    blastId = json['BlastID'];
    inAppSubject = json['InAppSubject'];
    inAppMessage = json['InAppMessage'];
    inAppImageLink = json['InAppImageLink'];
    inAppDescription = json['InAppDescription'];
    readStatus = json['ReadStatus'];
    sentOn = json['SentOn'];
    viewOn = json['ViewedOn'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "BlastHeaderID": blastHeadId,
      "BlastID": blastId,
      "InAppSubject": inAppSubject,
      "InAppMessage": inAppMessage,
      "InAppImageLink": inAppImageLink,
      "InAppDescription": inAppDescription,
      "ReadStatus": readStatus,
      "SentOn": sentOn,
      "ViewedOn": viewOn,
    };

    return data;
  }
}
