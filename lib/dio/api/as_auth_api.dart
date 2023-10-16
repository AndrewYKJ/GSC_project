import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/dio/as_dio_repo.dart';
import 'package:gsc_app/models/arguments/sign_up_arguments.dart';
import 'package:gsc_app/models/json/as_dynamic_field_model.dart';
import 'package:gsc_app/models/json/as_otp_model.dart';
import 'package:gsc_app/models/json/settings_model.dart';
import 'package:gsc_app/models/json/as_gscoin_transaction_model.dart';
import 'package:gsc_app/models/json/user_model.dart';

import '../../const/utils.dart';
import '../../models/json/as_update_device_model.dart';
import '../../models/json/as_vouchers_model.dart';

class AsAuthApi extends AsDioRepo {
  AsAuthApi(BuildContext context) {
    dioContext = context;
  }

  Future generateASApiToken() async {
    var body =
        "grant_type=${Constants.ASCENTIS_CRM_GRANT_TYPE}&scope=${Constants.ASCENTIS_CRM_SCOPE}&client_id=${Constants.ASCENTIS_CRM_CLIENT_ID}&client_secret=${Constants.ASCENTIS_CRM_CLIENT_SECRET}";
    asDio.options.headers['Accept'] = "application/json";
    asDio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    asDio.options.baseUrl = Constants.ASCENTIS_CRM_TOKEN_URL;
    try {
      Response response = await asDio.post(
        '',
        data: body,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> login(
      BuildContext context, String mobile, String password) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_LOGIN);
    params["UserIDisCardNo"] = false;
    params["UserID"] = mobile;
    params["Password"] = password;

    try {
      Response response = await asDio.post('', data: params);
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> signUp(
      BuildContext context, SignUpArguments signUpArguments) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_SIGN_UP);
    params["MembershipTypeCode"] = "GSCRewards";
    params["TierCode"] = "Member";
    params["MembershipStatusCode"] = "ACTIVE";
    params["RegistrationDate"] = "";
    params["PickPreloadCard"] = false;
    params["CardNo"] = "";
    params["PrintedName"] = signUpArguments.name;
    params["Name"] = signUpArguments.name;
    params["DOB"] = signUpArguments.dob;
    params["Nationality"] = signUpArguments.nationality;
    params["Email"] = signUpArguments.email;
    params["MobileNo"] = signUpArguments.mobile;
    params["Password"] = signUpArguments.password;
    params["MailingLists"] = [
      {"Name": "GSC Rewards"}
    ];
    params["DynamicColumnLists"] = [
      {
        "Name": Constants.ASCENTIS_DYNAMIC_GENDER_CODE,
        "ColValue": signUpArguments.gender,
        "Type": "nvarchar(1)"
      },
      {
        "Name": Constants.ASCENTIS_DYNAMIC_COUNTRY_CODE,
        "ColValue": signUpArguments.countryCode,
        "Type": "nvarchar(10)"
      },
      {
        "Name": Constants.ASCENTIS_DYNAMIC_RACE_CODE,
        "ColValue": signUpArguments.race,
        "Type": "nvarchar(50)"
      },
      {
        "Name": Constants.ASCENTIS_DYNAMIC_OCCUPATION_CODE,
        "ColValue": signUpArguments.profession,
        "Type": "nvarchar(50)"
      },
      {
        "Name": Constants.ASCENTIS_DYNAMIC_NOTIFY_POST,
        "ColValue": signUpArguments.isVerifyPromo == 1 ? 'True' : 'False',
        "Type": "nvarchar(50)"
      },
      {
        "Name": Constants.ASCENTIS_DYNAMIC_NOTIFY_SMS,
        "ColValue": signUpArguments.isVerifyPromo == 1 ? 'True' : 'False',
        "Type": "nvarchar(50)"
      }
    ];
    params["DynamicFieldLists"] = [
      {
        "Name": Constants.ASCENTIS_DYNAMIC_STATE_CODE,
        "ColValue": signUpArguments.location,
        "Type": "PlainText"
      },
      {
        "Name": Constants.ASCENTIS_DYNAMIC_MARKETING_CODE,
        "ColValue": signUpArguments.isVerifyPromo,
        "Type": "bit"
      }
    ];

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '>>>>>>>>> [SIGN UP API] response DATA: ${response.toString()}');
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getProfile(
      String member, String? mobile, String? email) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_USER_PROFILE);
    params["MobileNo"] = mobile;
    params["Email"] = email;
    params["MemberID"] = member;
    params["FilterCardsByStatus"] = "ACTIVE";
    params["MobileNoExactSearch"] = false;
    params["RetrievePtsToNextTier"] = true;
    params["RetrieveNettToNextTier"] = true;
    params["RetrieveJournalList"] = false;
    params["RequestDynamicColumnLists"] = [
      {"Name": Constants.ASCENTIS_DYNAMIC_COUNTRY_CODE},
      {"Name": Constants.ASCENTIS_DYNAMIC_GENDER_CODE},
      {"Name": Constants.ASCENTIS_DYNAMIC_RACE_CODE},
      {"Name": Constants.ASCENTIS_DYNAMIC_OCCUPATION_CODE}
    ];
    params["RequestDynamicFieldLists"] = [
      {"Name": Constants.ASCENTIS_DYNAMIC_STATE_CODE},
      {"Name": Constants.ASCENTIS_DYNAMIC_MARKETING_CODE},
      {"Name": Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE},
      {"Name": Constants.ASCENTIS_DYNAMIC_MIGRATED_MEMBER},
    ];
    params["CardLists_PageNumber"] = 1;
    params["CardLists_PageCount"] = "99";

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '>>>>>>>>> [USER PROFILE API] response DATA: ${response.toString()}');
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<VouchersDTO> getCard(
    String cardNo,
  ) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_CARD_ENQUIRY);
    params["CardNo"] = cardNo;
    params['CVC'] = '';
    params["RetrieveCVCInfo"] = false;
    params["RetrieveMembershipInfo"] = false;
    params["RetrieveActiveVouchersList"] = true;

    params["RetrieveJournalList"] = false;
    params["RetrieveCarparkInfo"] = false;
    params["RetrieveReceiptMessage"] = true;

    params["RetrievePtsToNextTier"] = true;
    params["RetrieveNettToNextTier"] = true;
    params["RetrieveEligibleFlag"] = true;

    params["RetrieveRedeemableVoucher"] = false;
    params["RetrieveVoucherSummary"] = false;
    params["RetrieveVoucherCap"] = false;

    params["SortBy_ValidTo"] = false;
    params["SortBy_ValidFrom"] = false;

    params["SortOrder"] = "ASC";
    params["SortBy_VoucherNo"] = false;
    params["SortBy_VoucherType"] = false;

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '>>>>>>>>> [USER CARD API] response DATA: ${response.toString()}');
      }
      return VouchersDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> verifyEmail(String email) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_USER_PROFILE);

    params["Email"] = email;
    params["FilterCardsByStatus"] = "ACTIVE";
    params["MobileNoExactSearch"] = false;
    params["RetrieveJournalList"] = false;
    params["RequestDynamicColumnLists"] = [];
    params["RequestDynamicFieldLists"] = [];
    params["CardLists_PageNumber"] = 1;
    params["CardLists_PageCount"] = "99";

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '>>>>>>>>> [CHECK EMAIL API] response DATA: ${response.toString()}');
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> verifyMobile(String mobile) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_USER_PROFILE);

    params["MobileNo"] = mobile;
    params["FilterCardsByStatus"] = "ACTIVE";
    params["MobileNoExactSearch"] = true;
    params["RetrieveJournalList"] = false;
    params["RequestDynamicColumnLists"] = [];
    params["RequestDynamicFieldLists"] = [
      {"Name": Constants.ASCENTIS_DYNAMIC_MIGRATED_MEMBER}
    ];
    params["CardLists_PageNumber"] = 1;
    params["CardLists_PageCount"] = "99";

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '>>>>>>>>> [CHECK MOBILE API] response DATA: ${response.toString()}');
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<OtpDTO> getOTP(String mobile, String smsMessage) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_GET_OTP);
    params["OTPType"] = "SMS";
    params["MobileNo"] = mobile;
    params["SMSMaskName"] = "Matrix";
    params["SMSMessage"] = smsMessage;
    params["Options"] = "X";
    params["CharLen"] = 4;

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '>>>>>>>>> [GET OTP API] response DATA: ${response.toString()}');
      }
      return OtpDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<OtpDTO> verifyOTP(String mobile, String otp) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_VALIDATE_OTP);
    params["OTPType"] = "SMS";
    params["MobileNo"] = mobile;
    params["OTP"] = otp;
    params["IgnoreCase"] = false;
    params["TimeIntervalType"] = "Minute";
    params["TimeIntervalValue"] = 3;

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '>>>>>>>>> [VALIDATE OTP API] response DATA: ${response.toString()}');
      }
      return OtpDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ChangePasswordModel> changePassword(
      String mobileNo, String oldPass, String newPass) async {
    var params = {
      "Command": Constants.ASCENTIS_COMMAND_CHANGE_PASSWORD,
      "EnquiryCode": Constants.ASCENTIS_CRM_ENQUIRY_CODE,
      "OutletCode": Constants.ASCENTIS_CRM_OUTLET_CODE,
      "PosID": Constants.ASCENTIS_CRM_POST_ID,
      "CashierID": Constants.ASCENTIS_CRM_CASHIER_ID,
      "IgnoreCCNchecking": Constants.ASCENTIS_CRM_IGNORE_CNN_CHECKING,
      "UserID": mobileNo,
      "OldPassword": oldPass,
      "NewPassword": newPass
    };

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[CHNAGE PASSWORD API] response DATA: ${response.toString()}');
      }
      return ChangePasswordModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<MembershipCancellationModel> membershipCancellation(
      String memberId) async {
    var params = {
      "Command": Constants.ASCENTIS_COMMAND_MEMBERSHIP_CANCELLATION,
      "EnquiryCode": Constants.ASCENTIS_CRM_ENQUIRY_CODE,
      "OutletCode": Constants.ASCENTIS_CRM_OUTLET_CODE,
      "PosID": Constants.ASCENTIS_CRM_POST_ID,
      "CashierID": Constants.ASCENTIS_CRM_CASHIER_ID,
      "IgnoreCCNchecking": Constants.ASCENTIS_CRM_IGNORE_CNN_CHECKING,
      "MemberID": memberId
      /*"SendNotification": true,
      "NotificationType": "Email",
      "SMSMaskedName": "Test Member Cancellation",
      "SMSMessage": "Test Member Cancellation Msg",
      "EmailTemplateName": "Custom Membership Cancellation Template",
      "AdditionalDynamicFieldLists": []*/
    };

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[MEMBERSHIP CANCELLATION API] response DATA: ${response.toString()}');
      }
      return MembershipCancellationModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> forgetPassword(String? mobile, String? password,
      List<AS_DYNAMIC_MODEL>? fieldList) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_UPDATE_PROFILE_3);
    params["FilterbyMobileNo"] = mobile;
    params["MobileNo"] = mobile;
    params["Password"] = password;
    if (fieldList != null) {
      params["DynamicFieldLists"] = (fieldList);
    }

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[UPDATE PROFILE API] response DATA: ${response.toString()}');
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateProfileV3(
      String member,
      String? fullName,
      String? mobile,
      String? gender,
      String? email,
      String? isVerifyPromo,
      List<AS_DYNAMIC_MODEL>? columnList,
      List<AS_DYNAMIC_MODEL>? fieldList) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_UPDATE_PROFILE_3);
    params["FilterByMemberID"] = member;
    params["Name"] = fullName;
    params["Email"] = email;
    params["Gender"] = gender;
    params["MailingLists"] = [
      {"Name": isVerifyPromo}
    ];
    params["DynamicColumnLists"] = (columnList);
    params["DynamicFieldLists"] = (fieldList);

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[UPDATE PROFILE API] response DATA: ${response.toString()}');
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateCinemaFavourite(
      String member, List<AS_DYNAMIC_MODEL>? fieldList) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_UPDATE_PROFILE_3);
    params["FilterByMemberID"] = member;
    params["DynamicFieldLists"] = (fieldList);
    params["AcceptEmptyString"] = true;

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[UPDATE PROFILE API] response DATA: ${response.toString()}');
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<CoinTransactionDTO> getCoinTransactionList(
    String member,
    String card,
    int page,
  ) async {
    var params =
        baseParam(Constants.ASCENTIS_COMMAND_GET_COIN_TRANSACTION_HISTORY);
    params["CardNo"] = card;
    params["MemberID"] = member;
    params["RewardsCycleLog_AutoID"] = 0;
    params["RetrieveTransactDetailInfo"] = true;
    params["RetrieveOnlinepaymentInfo"] = true;
    params["RetrievePaymentInfo"] = true;
    params["RetrieveVoidedTransactions"] = true;
    params["SortOrder"] = "DESC";
    params["FilterBy_Mode"] = Constants.ASCENTIS_COIN_TRANSACTION_MODE;
    params["SortByCycle"] = false;
    params["SortByProgramYear"] = false;
    params["SortByTransactDate"] = true;
    params["SortByTransactTime"] = true;
    params["SortByModeNameShort"] = false;
    params["SortByMode"] = false;
    params["SortByOutlet"] = false;
    params["SortByReceiptNo"] = false;
    params["SortByAmountSpent"] = false;
    params["SortByTransactPoints"] = false;
    params["SortByVoidBy"] = false;
    params["SortByVoidOn"] = false;
    params["SortByRemarks"] = false;
    params["SortByAddedOn"] = false;
    params["PageNumber"] = page;
    params["PageCount"] = 20;

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[GSC COIN TRANSACTION API] response DATA: ${response.toString()}');
      }
      return CoinTransactionDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateDeviceDTO> updateMemberDevice(
    String member,
    String appVersion,
    String deviceUID,
    String deviceToken,
    String deviceName,
    String deviceModel,
    String deviceVersion,
  ) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_UPDATE_DEVICE);
    params["MemberID"] = member;
    params["AppName"] = 'GSC';
    params["AppVersion"] = appVersion;
    params["DeviceUID"] = deviceUID;
    params["DeviceToken"] = deviceToken;
    params['DeviceModel'] = deviceModel;
    params["DeviceName"] = deviceName;
    params["DeviceVersion"] = deviceVersion;
    params["PushBadge"] = true;
    params["PushAlert"] = true;
    params["PushSound"] = true;
    params["IsDevelopment"] = true;
    params["App_Status"] = "ACTIVE";
// {

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[UPDATE DEVICE API] response DATA: ${response.toString()}');
      }
      return UpdateDeviceDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateDeviceDTO> removeDeviceToken(
    String member,
    String appVersion,
    String deviceUID,
    String deviceToken,
    String deviceModel,
  ) async {
    var params = baseParam(Constants.ASCENTIS_COMMAND_UPDATE_DEVICE);
    params["MemberID"] = member;
    params["AppName"] = 'GSC';
    params["AppVersion"] = appVersion;
    params["DeviceUID"] = deviceUID;
    params["DeviceToken"] = deviceToken;
    params["DeviceModel"] = deviceModel;
    params["App_Status"] = "INACTIVE";

// {

    try {
      Response response = await asDio.post('', data: params);
      if (response.data != null) {
        Utils.printInfo(
            '[UPDATE DEVICE API] response DATA: ${response.toString()}');
      }
      return UpdateDeviceDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
