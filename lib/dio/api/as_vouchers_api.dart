import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/models/json/as_vouchers_model.dart';

import '../../const/constants.dart';
import '../as_dio_repo.dart';

class AsVouchersApi extends AsDioRepo {
  AsVouchersApi(BuildContext context) {
    dioContext = context;
  }

  Future<VouchersDTO> getVouchersList(
      BuildContext context,
      String cardNo,
      int page,
      int size,
      bool active,
      bool redeem,
      bool expired,
      int pastSize,
      int pastPage) async {
    var params = {
      "Command": Constants.ASCENTIS_COMMAND_GET_VOUCHERS,
      "EnquiryCode": Constants.ASCENTIS_CRM_ENQUIRY_CODE,
      "OutletCode": Constants.ASCENTIS_CRM_OUTLET_CODE,
      "PosID": Constants.ASCENTIS_CRM_POST_ID,
      "CashierID": Constants.ASCENTIS_CRM_CASHIER_ID,
      "IgnoreCCNchecking": Constants.ASCENTIS_CRM_IGNORE_CNN_CHECKING,
      "CardNo": cardNo,
      "RetrieveMembershipInfo": false,
      "SortOrder": "DESC",
      "SortBy_VoucherNo": false,
      "SortBy_VoucherType": false,
      "SortBy_ValidFrom": false,
      "SortBy_ValidTo": false,
      "SortBy_RedeemedDate": false,
      "RetrieveVoucherCap": false,
      "RetrieveEligibleFlag": false,
      "RetrieveVoucherSummary": false,
      "RetrieveActiveVouchers": active,
      "PageNumber_ActiveVouchers": page,
      "PageCount_ActiveVouchers": size,
      "RetrieveRedeemedVouchers": redeem,
      "RetrieveExpiredVouchers": expired,
      "RetrieveVoidedVouchers": false,
      "RetrieveDelayVouchers": false,
      // "FilterBy_VoucherNo": "",
      // "FilterBy_VoucherType": "",
      // "FilterBy_VoucherTypeType": "",
      // "FilterBy_TypeValue": "",
      // "FilterBy_ValidFrom": "",
      // "FilterBy_ValidTo": "",
      // "FilterBy_TriggerSource": "",
      // "FilterBy_TransactID": "",
      "PageNumber_RedeemedVouchers": pastPage,
      "PageCount_RedeemedVouchers": pastSize,
      "PageNumber_ExpiredVouchers": pastPage,
      "PageCount_ExpiredVouchers": pastSize,
      "PageNumber_VoidedVouchers": 1,
      "PageCount_VoidedVouchers": 99,
      "PageNumber_DelayVouchers": 1,
      "PageCount_DelayVouchers": 99
    };

    try {
      Response response = await asDio.post('', data: params);
      return VouchersDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
