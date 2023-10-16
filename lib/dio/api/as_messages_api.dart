import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/models/json/as_messages_delete_model.dart';
import 'package:gsc_app/models/json/as_messages_model.dart';

import '../../const/constants.dart';
import '../as_dio_repo.dart';

class AsMessagesApi extends AsDioRepo {
  AsMessagesApi(BuildContext context) {
    dioContext = context;
  }

  Future<InAppMessageDTO> getInAppMessagesList(BuildContext context,
      String appName, String memberId, String deviceUID, int page, int size) async {
    var params = {
      "Command": Constants.ASCENTIS_COMMAND_RETRIEVE_IN_APP_MESSAGES,
      "EnquiryCode": Constants.ASCENTIS_CRM_ENQUIRY_CODE,
      "OutletCode": Constants.ASCENTIS_CRM_OUTLET_CODE,
      "PosID": Constants.ASCENTIS_CRM_POST_ID,
      "CashierID": Constants.ASCENTIS_CRM_CASHIER_ID,
      "IgnoreCCNchecking": Constants.ASCENTIS_CRM_IGNORE_CNN_CHECKING,
      "AppName": appName,
      "MemberID": memberId,
      "PageNumber": page,
      "PageCount": size,
      "DeviceUID": deviceUID,
      // "BlastID": "",
      // "BlastHeaderID": "",
      // "FilterBy_DateFrom": "",
      // "FilterBy_DateTo": ""
    };

    try {
      Response response = await asDio.post('', data: params);
      return InAppMessageDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<InAppMessageDTO> getInAppMessagesDetails(BuildContext context,
      String appName, String memberId, String blastHeaderId, String deviceUUID) async {
    var params = {
      "Command": Constants.ASCENTIS_COMMAND_RETRIEVE_IN_APP_MESSAGES,
      "EnquiryCode": Constants.ASCENTIS_CRM_ENQUIRY_CODE,
      "OutletCode": Constants.ASCENTIS_CRM_OUTLET_CODE,
      "PosID": Constants.ASCENTIS_CRM_POST_ID,
      "CashierID": Constants.ASCENTIS_CRM_CASHIER_ID,
      "IgnoreCCNchecking": Constants.ASCENTIS_CRM_IGNORE_CNN_CHECKING,
      "AppName": appName,
      "MemberID": memberId,
      "DeviceUID": deviceUUID,
      // "BlastID": "",
      "BlastHeaderID": blastHeaderId,
      // "FilterBy_DateFrom": "",
      // "FilterBy_DateTo": ""
    };

    try {
      Response response = await asDio.post('', data: params);
      return InAppMessageDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<DeleteInAppMessageDTO> deleteInAppMessages(
      BuildContext context, String blastId) async {
    var params = {
      "Command": Constants.ASCENTIS_COMMAND_DELETE_IN_APP_MESSAGE,
      "EnquiryCode": Constants.ASCENTIS_CRM_ENQUIRY_CODE,
      "OutletCode": Constants.ASCENTIS_CRM_OUTLET_CODE,
      "PosID": Constants.ASCENTIS_CRM_POST_ID,
      "CashierID": Constants.ASCENTIS_CRM_CASHIER_ID,
      "IgnoreCCNchecking": Constants.ASCENTIS_CRM_IGNORE_CNN_CHECKING,
      "BlastID": blastId
    };

    try {
      Response response = await asDio.post('', data: params);
      return DeleteInAppMessageDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
