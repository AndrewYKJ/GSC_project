// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/rewards_center_participating_outlet_info.dart';
import 'package:gsc_app/models/json/rewards_center_ref_info.dart';

class RewardsVoucherTypeList {
  String? Code;
  String? Name;
  String? Description;
  String? Type;
  String? TypeValue;
  String? PromoMsg;
  bool? IsReusable;
  bool? IsCarParkVoucher;
  bool? IsBirthdayVoucher;
  bool? IsCampaignVoucher;
  RewardCenterPartipatingOutletInfo? ParticipatingOutletsInformation;
  bool? IsRedeemable;
  dynamic VoucherRedemptionValue;
  bool? IsMinSpendingReq;
  dynamic MinSpendingValue;
  String? ValidTimeFrom;
  String? ValidTimeTo;
  String? ValidTimeFrom_Sec;
  String? ValidTimeTo_Sec;
  String? FullImageName;
  String? Base64ImageString;
  String? ImageLink;
  String? Remarks;
  String? PointUsageType;
  String? TnC;
  dynamic IssuanceLimit;
  dynamic IssuanceLimitPeriodType;
  dynamic IssuanceMemberLimit;
  String? IssuanceMemberLimitPeriodType;
  dynamic IssuanceCardLimit;
  String? IssuanceCardLimitPeroidType;
  dynamic CurrentIssuedCount;
  dynamic RedemptionLimit;
  String? RedemptionLimitPeriodType;
  dynamic CurrentRedeemedCount;
  RewardCenterRefInfo? RefInfo;
  String? ActiveDaysOfWeek;
  String? StartDate;
  String? EndDate;
  String? MembershipTypeEligibility;
  String? MembershipTierEligibility;
  List<dynamic>? OutletCostsLists;
  String? Category;
  String? SubCategory;
  dynamic LifeTimeIssuanceLimit;
  dynamic LifeTimeRedemptionLimit;
  dynamic LifetimeIssuedCount;
  dynamic LifetimeRedeemedCount;
  bool? IsReserved;
  bool? isPublished;

  RewardsVoucherTypeList(
      {this.Code,
      this.Name,
      this.Description,
      this.Type,
      this.TypeValue,
      this.PromoMsg,
      this.IsReusable,
      this.IsCarParkVoucher,
      this.IsBirthdayVoucher,
      this.IsCampaignVoucher,
      this.ParticipatingOutletsInformation,
      this.IsRedeemable,
      this.VoucherRedemptionValue,
      this.IsMinSpendingReq,
      this.MinSpendingValue,
      this.ValidTimeFrom,
      this.ValidTimeTo,
      this.ValidTimeTo_Sec,
      this.ValidTimeFrom_Sec,
      this.FullImageName,
      this.Base64ImageString,
      this.ImageLink,
      this.Remarks,
      this.PointUsageType,
      this.TnC,
      this.IssuanceCardLimit,
      this.IssuanceLimit,
      this.IssuanceLimitPeriodType,
      this.IssuanceMemberLimit,
      this.IssuanceMemberLimitPeriodType,
      this.IssuanceCardLimitPeroidType,
      this.CurrentIssuedCount,
      this.RedemptionLimit,
      this.RedemptionLimitPeriodType,
      this.CurrentRedeemedCount,
      this.RefInfo,
      this.ActiveDaysOfWeek,
      this.StartDate,
      this.EndDate,
      this.MembershipTierEligibility,
      this.MembershipTypeEligibility,
      this.OutletCostsLists,
      this.Category,
      this.SubCategory,
      this.LifeTimeIssuanceLimit,
      this.LifeTimeRedemptionLimit,
      this.LifetimeIssuedCount,
      this.LifetimeRedeemedCount,
      this.isPublished,
      this.IsReserved});

  RewardsVoucherTypeList.fromJson(Map<String, dynamic> json) {
    Code = json['Code'];
    Name = json['Name'];
    Description = json['Description'];
    Type = json['Type'];
    TypeValue = json['TypeValue'];
    PromoMsg = json['PromoMsg'];
    IsReusable = json['IsReusable'];
    IsCarParkVoucher = json['IsCarParkVoucher'];
    IsBirthdayVoucher = json['IsBirthdayVoucher'];
    IsCampaignVoucher = json['IsCampaignVoucher'];
    ParticipatingOutletsInformation =
        RewardCenterPartipatingOutletInfo.fromJson(
            json['ParticipatingOutletsInformation']);
    IsRedeemable = json['IsRedeemable'];
    VoucherRedemptionValue = json['VoucherRedemptionValue'];
    IsMinSpendingReq = json['IsMinSpendingReq'];
    MinSpendingValue = json['MinSpendingValue'];
    ValidTimeFrom = json['ValidTimeFrom'];
    ValidTimeTo = json['ValidTimeTo'];
    ValidTimeTo_Sec = json['ValidTimeTo_Sec'];
    ValidTimeFrom_Sec = json['ValidTimeFrom_Sec'];
    FullImageName = json['FullImageName'];
    Base64ImageString = json['Base64ImageString'];
    ImageLink = json['ImageLink'];
    Remarks = json['Remarks'];
    PointUsageType = json['PointUsageType'];
    TnC = json['TnC'];
    IssuanceCardLimit = json['IssuanceCardLimit'];
    IssuanceLimit = json['IssuanceLimit'];
    IssuanceLimitPeriodType = json['IssuanceLimitPeriodType'];
    IssuanceMemberLimit = json['IssuanceMemberLimit'];
    IssuanceMemberLimitPeriodType = json['IssuanceMemberLimitPeriodType'];
    IssuanceCardLimitPeroidType = json['IssuanceCardLimitPeroidType'];
    CurrentIssuedCount = json['CurrentIssuedCount'];
    RedemptionLimit = json['RedemptionLimit'];
    RedemptionLimitPeriodType = json['RedemptionLimitPeriodType'];
    CurrentRedeemedCount = json['CurrentRedeemedCount'];
    RefInfo = RewardCenterRefInfo.fromJson(json['RefInfo']);
    ActiveDaysOfWeek = json['ActiveDaysOfWeek'];
    StartDate = json['StartDate'];
    EndDate = json['EndDate'];
    MembershipTierEligibility = json['MembershipTierEligibility'];
    MembershipTypeEligibility = json['MembershipTypeEligibility'];
    OutletCostsLists = json['OutletCostsLists'];
    Category = json['Category'];
    SubCategory = json['SubCategory'];
    LifeTimeIssuanceLimit = json['LifeTimeIssuanceLimit'];
    LifeTimeRedemptionLimit = json['LifeTimeRedemptionLimit'];
    LifetimeIssuedCount = json['LifetimeIssuedCount'];
    LifetimeRedeemedCount = json['LifetimeRedeemedCount'];
    isPublished = json['isPublished'];
    IsReserved = json['IsReserved'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'Code': Code,
      'Name': Name,
      'Description': Description,
      'Type': Type,
      'TypeValue': TypeValue,
      'PromoMsg': PromoMsg,
      'IsReusable': IsReusable,
      'IsCarParkVoucher': IsCarParkVoucher,
      'IsBirthdayVoucher': IsBirthdayVoucher,
      'IsCampaignVoucher': IsCampaignVoucher,
      'ParticipatingOutletsInformation': ParticipatingOutletsInformation,
      'IsRedeemable': IsRedeemable,
      'VoucherRedemptionValue': VoucherRedemptionValue,
      'IsMinSpendingReq': IsMinSpendingReq,
      'MinSpendingValue': MinSpendingValue,
      'ValidTimeFrom': ValidTimeFrom,
      'ValidTimeTo': ValidTimeTo,
      'ValidTimeTo_Sec': ValidTimeTo_Sec,
      'ValidTimeFrom_Sec': ValidTimeFrom_Sec,
      'FullImageName': FullImageName,
      'Base64ImageString': Base64ImageString,
      'ImageLink': ImageLink,
      'Remarks': Remarks,
      'PointUsageType': PointUsageType,
      'TnC': TnC,
      'IssuanceCardLimit': IssuanceCardLimit,
      'IssuanceLimit': IssuanceLimit,
      'IssuanceLimitPeriodType': IssuanceLimitPeriodType,
      'IssuanceMemberLimit': IssuanceMemberLimit,
      'IssuanceMemberLimitPeriodType': IssuanceMemberLimitPeriodType,
      'IssuanceCardLimitPeroidType': IssuanceCardLimitPeroidType,
      'CurrentIssuedCount': CurrentIssuedCount,
      'RedemptionLimit': RedemptionLimit,
      'RedemptionLimitPeriodType': RedemptionLimitPeriodType,
      'CurrentRedeemedCount': CurrentRedeemedCount,
      'RefInfo': RefInfo,
      'ActiveDaysOfWeek': ActiveDaysOfWeek,
      'StartDate': StartDate,
      'EndDate': EndDate,
      'MembershipTierEligibility': MembershipTierEligibility,
      'MembershipTypeEligibility': MembershipTypeEligibility,
      'OutletCostsLists': OutletCostsLists,
      'Category': Category,
      'SubCategory': SubCategory,
      'LifeTimeIssuanceLimit': LifeTimeIssuanceLimit,
      'LifeTimeRedemptionLimit': LifeTimeRedemptionLimit,
      'LifetimeIssuedCount': LifetimeIssuedCount,
      'LifetimeRedeemedCount': LifetimeRedeemedCount,
      'isPublished': isPublished,
      'IsReserved': IsReserved
    };

    return data;
  }
}
