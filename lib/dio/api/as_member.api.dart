import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/json/as_qr_token_model.dart';
import 'package:gsc_app/models/json/rewards_center_response.dart';
import 'package:gsc_app/models/json/voucher_issuance_model.dart';

import '../../const/constants.dart';
import '../as_dio_repo.dart';

class AsMemberApi extends AsDioRepo {
  AsMemberApi(BuildContext context) {
    dioContext = context;
  }

  Future<QrTokenDTO> memberQrToken(BuildContext context, String cardNo) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_GET_TOKEN);
    params["CardNo"] = cardNo;

    try {
      Response response = await asDio.post('', data: params);
      return QrTokenDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<RewardsCenterResponse> getRewardsCenterListing(BuildContext context,
      bool includeExpired, int pageNo, int pageCount) async {
    var params = {
      ...baseParam(Constants.ASCENTIS_COMMAND_GET_VOUCHER_TYPE),
      "OnlyOutletVoucherType": false,
      "RetrieveTnC": true,
      "RetrievePromoMsgBy_VoucherTypeCodes": "",
      "RetrievePromoMsgBy_PrefixVoucherTypeCode": "",
      "RetrieveParticipatingOutletInformation": true,
      "RetrieveBase64ImageString": false,
      "FilterBy_VoucherTypeName": "",
      "FilterBy_VoucherTypeType": "",
      "FilterBy_IsRedeemable": true,
      "FilterBy_PointUsageType": "",
      "FilterBy_Category": "",
      "FilterBy_SubCategory": "",
      "FilterBy_IncludeExpired": includeExpired,
      "FilterBy_ParticipatingEntities": "",
      "FilterBy_ParticipatingOutlets": "",
      "FilterBy_isPublished": true,
      "SortOrder": "",
      "SortByVoucherTypeCode": false,
      "SortByVoucherTypeName": false,
      "SortByVoucherTypeType": false,
      "SortByVoucherTypeStartDate": false,
      "SortByVoucherTypeEndDate": false,
      "FilterBy_VoucherTypeCode": "",
      "PageNumber": pageNo,
      "PageCount": pageCount,
    };

    try {
      Response response = await asDio.post('', data: params);
      return RewardsCenterResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<VoucherIssuanceModel> redeemRewardCentreVoucher(
      BuildContext context, String cardNo, String itmCode, int quantity) async {
    var params = {
      ...baseParam(Constants.VOUCHER_ISSUANCE_WITH_POINTS),
      "CardNo": cardNo,
      "VoucherTypeLists": [
        {"VoucherTypeCode": itmCode, "VoucherQty": quantity}
      ],
      "CheckOutletCodeDuplication": false,
      "CheckOriginalDateDuplication": false,
      "CheckPOSIDDuplication": false,
      "PointsUsage": "COMBINE",
    };

    try {
      Response response = await asDio.post('', data: params);
      Utils.printInfo(response.data);
      return VoucherIssuanceModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
