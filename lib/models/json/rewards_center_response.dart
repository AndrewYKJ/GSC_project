// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/rewards_voucher_type_list.dart';

class RewardsCenterResponse {
  int? TotalResults;
  List<RewardsVoucherTypeList>? VoucherTypeLists;
  int? ReturnStatus;
  String? ReturnMessage;
  String? RequestTime;
  String? ResponseTime;

  RewardsCenterResponse(
      {this.TotalResults,
      this.VoucherTypeLists,
      this.ReturnStatus,
      this.ReturnMessage,
      this.RequestTime,
      this.ResponseTime});

  RewardsCenterResponse.fromJson(Map<String, dynamic> json) {
    TotalResults = json['TotalResults'];

    var list = json['VoucherTypeLists'] as List;

    if (list.isNotEmpty) {
      VoucherTypeLists =
          list.map((e) => RewardsVoucherTypeList.fromJson(e)).toList();
    }

    ReturnStatus = json['ReturnStatus'];
    ReturnMessage = json['ReturnMessage'];
    RequestTime = json['RequestTime'];
    ResponseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'TotalResults': TotalResults,
      'VoucherTypeLists': VoucherTypeLists,
      'ReturnStatus': ReturnStatus,
      'ReturnMessage': ReturnMessage,
      'RequestTime': RequestTime,
      'ResponseTime': ResponseTime
    };

    return data;
  }
}
