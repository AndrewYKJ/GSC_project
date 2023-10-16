// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/user_member_model.dart';

class VouchersDTO {
  VoucherCardInfoDTO? voucherCardInfoDTO;
  UserMemberModel? memberInfoDTO;
  VoucherMembershipInfoDTO? voucherMembershipInfoDTO;
  int? totalActiveVoucherCount;
  List<VoucherItemDTO>? activeVoucherList;
  dynamic voucherCapSettingList;
  List<VoucherSummaryDTO>? voucherSummaryList;
  int? totalSummaryVoucherCount;
  int? totalRedeemedVoucherCount;
  List<VoucherItemDTO>? redeemedVoucherList;
  int? totalExpiredVoucherCount;
  List<VoucherItemDTO>? expiredVoucherList;
  int? totalVoidedVoucherCount;
  List<VoucherItemDTO>? voidedVoucherList;
  int? totalDelayVoucherCount;
  List<VoucherItemDTO>? delayVoucherList;
  int? returnStatus;
  String? returnMessage;
  String? requestTime;
  String? responseTime;

  VouchersDTO(
      {this.voucherCardInfoDTO,
      this.memberInfoDTO,
      this.voucherMembershipInfoDTO,
      this.totalActiveVoucherCount,
      this.activeVoucherList,
      this.voucherCapSettingList,
      this.voucherSummaryList,
      this.totalSummaryVoucherCount,
      this.totalRedeemedVoucherCount,
      this.redeemedVoucherList,
      this.totalExpiredVoucherCount,
      this.expiredVoucherList,
      this.totalVoidedVoucherCount,
      this.voidedVoucherList,
      this.totalDelayVoucherCount,
      this.delayVoucherList,
      this.returnStatus,
      this.returnMessage,
      this.requestTime,
      this.responseTime});

  VouchersDTO.fromJson(Map<String, dynamic> json) {
    voucherCardInfoDTO = VoucherCardInfoDTO.fromJson(json['CardInfo']);
    memberInfoDTO = UserMemberModel.fromJson(json['MemberInfo']);
    voucherMembershipInfoDTO = json['MembershipInfo'];
    totalActiveVoucherCount = json['TotalActiveVoucherCount'];
    activeVoucherList = json["ActiveVoucherLists"] == null
        ? []
        : List<VoucherItemDTO>.from(
            json["ActiveVoucherLists"]!.map((x) => VoucherItemDTO.fromJson(x)));
    voucherCapSettingList = json['VoucherCapSettingList'];
    voucherSummaryList = json["VoucherSummary"] == null
        ? []
        : List<VoucherSummaryDTO>.from(
            json["VoucherSummary"]!.map((x) => VoucherSummaryDTO.fromJson(x)));
    totalSummaryVoucherCount = json['TotalSummaryVoucherCount'];
    totalRedeemedVoucherCount = json['TotalRedeemedVoucherCount'];
    redeemedVoucherList = json['RedeemedVoucherLists'] == null
        ? []
        : List<VoucherItemDTO>.from(json["RedeemedVoucherLists"]!
            .map((x) => VoucherItemDTO.fromJson(x)));
    totalExpiredVoucherCount = json['TotalExpiredVoucherCount'];
    expiredVoucherList = json['ExpiredVoucherLists'] == null
        ? []
        : List<VoucherItemDTO>.from(json["ExpiredVoucherLists"]!
            .map((x) => VoucherItemDTO.fromJson(x)));
    totalVoidedVoucherCount = json['TotalVoidedVoucherCount'];
    voidedVoucherList = json['VoidedVoucherLists'] == null
        ? []
        : List<VoucherItemDTO>.from(
            json["VoidedVoucherLists"]!.map((x) => VoucherItemDTO.fromJson(x)));
    totalDelayVoucherCount = json['TotalDelayVoucherCount'];
    delayVoucherList = json['DelayVoucherLists'] == null
        ? []
        : List<VoucherItemDTO>.from(
            json["DelayVoucherLists"]!.map((x) => VoucherItemDTO.fromJson(x)));
    returnStatus = json['ReturnStatus'];
    returnMessage = json['ReturnMessage'];
    requestTime = json['RequestTime'];
    responseTime = json['ResponseTime'];
  }

  Map<String, dynamic> toJson() => {
        "CardInfo": voucherCardInfoDTO,
        "MemberInfo": memberInfoDTO,
        "MembershipInfo": voucherMembershipInfoDTO,
        "TotalActiveVoucherCount": totalActiveVoucherCount,
        "ActiveVoucherLists": activeVoucherList,
        "VoucherSummary": voucherSummaryList,
        "TotalSummaryVoucherCount": totalSummaryVoucherCount,
        "TotalRedeemedVoucherCount": totalRedeemedVoucherCount,
        "RedeemedVoucherLists": redeemedVoucherList,
        "TotalExpiredVoucherCount": totalExpiredVoucherCount,
        "ExpiredVoucherLists": expiredVoucherList,
        "TotalVoidedVoucherCount": totalVoidedVoucherCount,
        "VoidedVoucherLists": voidedVoucherList,
        "totalDelayVoucherCount": totalDelayVoucherCount,
        "DelayVoucherLists": delayVoucherList,
        "ReturnStatus": returnStatus,
        "ReturnMessage": returnMessage,
        "RequestTime": requestTime,
        "ResponseTime": responseTime,
      };
}

class VoucherCardInfoDTO {
  String? cardNo;
  String? memberID;
  String? printedName;
  String? membershipTypeCode;
  String? membershipStatusCode;
  String? membershipPhoto;
  String? membershipPhotoLink;
  String? issueDate;
  String? effectiveDate;
  String? expiryDate;
  bool? printed;
  String? printedDate;
  String? renewedDate;
  String? tmpEffectiveDate;
  String? tmpExpiryDate;
  String? tmpMembershipStatusCode;
  double? pointsBAL;
  double? totalPointsBAL;
  num? holdingPoints;
  String? pointsToNextTier;
  String? remarks;
  double? membershipDiscount;
  String? tierCode;
  String? suppCardTierCode;
  String? tierAnniversaryStartDate;
  String? tierAnniversaryEndDate;
  String? loyaltyMessage;
  String? dollarToPointsRatio;
  List<VoucherCardInfoRewardCycleItem>? rewardCycleLists;
  bool? isSupplementary;
  bool? isBurnSupplementaryCard;
  String? relationID;
  String? primaryCardNo;
  String? primaryRelationID;
  String? primaryCardExpiryDate;
  String? primaryCardEffectiveDate;
  int? ptsHoldingDays;
  bool? membershipTypeCCNFeatures;
  String? membershipTypeDefaultCCNValue;
  String? membershipTypeTierDefaultCCNValue;
  double? currentNetSpent;
  String? passcode;
  double? storedValueBalance;
  String? currency;
  String? lastVisitedDate;
  String? lastVisitedOutlet;
  String? nettToNextTier;
  String? luckyDrawConversionPtsUsageType;
  String? luckyDrawConversionRate;
  String? discGroupCode;
  String? spentQuotaIncreasementExpiredOn;
  double? spentQuotaIncreasement;
  String? discountGroupInfo;
  String? pickupDate;
  String? pickupBy;
  double? currentRCNettSpent;
  List<VoucherCardInfoCVCInfoItem>? CVCInfo;
  double? CMCEarnedPoints;
  double? CRCEarnedPoints;
  num? currentTierNett;
  num? currentTierAmt;
  int? bringFwdTierNett;
  int? bringFwdTierAmt;
  String? bringFwdTierExpiry;
  String? bringFwdTierStartDate;
  String? extendedTierAnniversaryEndDate;

  VoucherCardInfoDTO(
      {this.cardNo,
      this.memberID,
      this.printedName,
      this.membershipTypeCode,
      this.membershipStatusCode,
      this.membershipPhoto,
      this.membershipPhotoLink,
      this.issueDate,
      this.effectiveDate,
      this.expiryDate,
      this.printed,
      this.printedDate,
      this.renewedDate,
      this.tmpEffectiveDate,
      this.tmpExpiryDate,
      this.tmpMembershipStatusCode,
      this.pointsBAL,
      this.totalPointsBAL,
      this.holdingPoints,
      this.pointsToNextTier,
      this.remarks,
      this.membershipDiscount,
      this.tierCode,
      this.suppCardTierCode,
      this.tierAnniversaryStartDate,
      this.tierAnniversaryEndDate,
      this.loyaltyMessage,
      this.dollarToPointsRatio,
      this.rewardCycleLists,
      this.isSupplementary,
      this.isBurnSupplementaryCard,
      this.relationID,
      this.primaryCardNo,
      this.primaryRelationID,
      this.primaryCardExpiryDate,
      this.primaryCardEffectiveDate,
      this.ptsHoldingDays,
      this.membershipTypeCCNFeatures,
      this.membershipTypeDefaultCCNValue,
      this.membershipTypeTierDefaultCCNValue,
      this.currentNetSpent,
      this.passcode,
      this.storedValueBalance,
      this.currency,
      this.lastVisitedDate,
      this.lastVisitedOutlet,
      this.nettToNextTier,
      this.luckyDrawConversionPtsUsageType,
      this.luckyDrawConversionRate,
      this.discGroupCode,
      this.spentQuotaIncreasementExpiredOn,
      this.spentQuotaIncreasement,
      this.discountGroupInfo,
      this.pickupDate,
      this.pickupBy,
      this.currentRCNettSpent,
      this.CVCInfo,
      this.CMCEarnedPoints,
      this.CRCEarnedPoints,
      this.currentTierNett,
      this.currentTierAmt,
      this.bringFwdTierNett,
      this.bringFwdTierAmt,
      this.bringFwdTierExpiry,
      this.bringFwdTierStartDate,
      this.extendedTierAnniversaryEndDate});

  VoucherCardInfoDTO.fromJson(Map<String, dynamic> json) {
    cardNo = json['CardNo'];
    memberID = json['MemberID'];
    printedName = json['PrintedName'];
    membershipTypeCode = json['MembershipTypeCode'];
    membershipStatusCode = json['MembershipStatusCode'];
    membershipPhoto = json['MembershipPhoto'];
    membershipPhotoLink = json['MembershipPhotoLink'];
    issueDate = json['IssueDate'];
    effectiveDate = json['EffectiveDate'];
    expiryDate = json['ExpiryDate'];
    printed = json['Printed'];
    printedDate = json['PrintedDate'];
    renewedDate = json['RenewedDate'];
    tmpEffectiveDate = json['tmpEffectiveDate'];
    tmpExpiryDate = json['tmpExpiryDate'];
    tmpMembershipStatusCode = json['tmpMembershipStatusCode'];
    pointsBAL = json['PointsBAL'];
    totalPointsBAL = json['TotalPointsBAL'];
    holdingPoints = json['HoldingPoints'];
    pointsToNextTier = json['PointsToNextTier'];
    remarks = json['Remarks'];
    membershipDiscount = json['MembershipDiscount'];
    tierCode = json['TierCode'];
    suppCardTierCode = json['SuppCardTierCode'];
    tierAnniversaryStartDate = json['TierAnniversaryStartDate'];
    tierAnniversaryEndDate = json['TierAnniversaryEndDate'];
    loyaltyMessage = json['LoyaltyMessage'];
    dollarToPointsRatio = json['DollarToPointsRatio'];
    if (json['RewardCycleLists'] != null) {
      rewardCycleLists = [];
      if (json['RewardCycleLists'] is List<dynamic>) {
        json['RewardCycleLists'].forEach((v) {
          rewardCycleLists!.add(VoucherCardInfoRewardCycleItem.fromJson(v));
        });
      } else {
        rewardCycleLists!.add(
            VoucherCardInfoRewardCycleItem.fromJson(json['RewardCycleLists']));
      }
    }
    isSupplementary = json['IsSupplementary'];
    isBurnSupplementaryCard = json['isBurnSupplementaryCard'];
    relationID = json['RelationID'];
    primaryCardNo = json['PrimaryCardNo'];
    primaryRelationID = json['PrimaryRelationID'];
    primaryCardExpiryDate = json['PrimaryCardExpiryDate'];
    primaryCardEffectiveDate = json['PrimaryCardEffectiveDate'];
    ptsHoldingDays = json['PtsHoldingDays'];
    membershipTypeCCNFeatures = json['MembershipTypeCCNFeatures'];
    membershipTypeDefaultCCNValue = json['MembershipTypeDefaultCCNValue'];
    membershipTypeTierDefaultCCNValue =
        json['MembershipTypeTierDefaultCCNValue'];
    currentNetSpent = json['CurrentNetSpent'];
    passcode = json['Passcode'];
    storedValueBalance = json['StoredValueBalance'];
    currency = json['Currency'];
    lastVisitedDate = json['LastVisitedDate'];
    lastVisitedOutlet = json['LastVisitedOutlet'];
    nettToNextTier = json['NettToNextTier'];
    luckyDrawConversionPtsUsageType = json['LuckyDrawConversionPtsUsageType'];
    luckyDrawConversionRate = json['LuckyDrawConversionRate'];
    discGroupCode = json['DiscGroupCode'];
    spentQuotaIncreasementExpiredOn = json['SpentQuotaIncreasementExpiredOn'];
    spentQuotaIncreasement = json['SpentQuotaIncreasement'];
    discountGroupInfo = json['DiscountGroupInfo'];
    pickupDate = json['PickupDate'];
    pickupBy = json['PickupBy'];
    currentRCNettSpent = json['CurrentRCNettSpent'];

    CMCEarnedPoints = json['CMCEarnedPoints'];
    CRCEarnedPoints = json['CRCEarnedPoints'];
    currentTierNett = json['CurrentTierNett'];
    currentTierAmt = json['CurrentTierAmt'];
    bringFwdTierNett = json['BringFwdTierNett'];
    bringFwdTierAmt = json['BringFwdTierAmt'];
    bringFwdTierExpiry = json['BringFwdTierExpiry'];
    bringFwdTierStartDate = json['BringFwdTierStartDate'];
    extendedTierAnniversaryEndDate = json['ExtendedTierAnniversaryEndDate'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "CardNo": cardNo,
      "MemberID": memberID,
      "PrintedName": printedName,
      "MembershipTypeCode": membershipTypeCode,
      "MembershipStatusCode": membershipStatusCode,
      "MembershipPhoto": membershipPhoto,
      "MembershipPhotoLink": membershipPhotoLink,
      "IssueDate": issueDate,
      "EffectiveDate": effectiveDate,
      "ExpiryDate": expiryDate,
      "Printed": printed,
      "PrintedDate": printedDate,
      "RenewedDate": renewedDate,
      "tmpEffectiveDate": tmpEffectiveDate,
      "tmpExpiryDate": tmpExpiryDate,
      "tmpMembershipStatusCode": tmpMembershipStatusCode,
      "PointsBAL": pointsBAL,
      "TotalPointsBAL": totalPointsBAL,
      "HoldingPoints": holdingPoints,
      "Remarks": remarks,
      "MembershipDiscount": membershipDiscount,
      "TierCode": tierCode,
      "SuppCardTierCode": suppCardTierCode,
      "TierAnniversaryStartDate": tierAnniversaryStartDate,
      "TierAnniversaryEndDate": tierAnniversaryEndDate,
      "LoyaltyMessage": loyaltyMessage,
      "DollarToPointsRatio": dollarToPointsRatio,
      "RewardCycleLists": rewardCycleLists,
      "IsSupplementary": isSupplementary,
      "isBurnSupplementaryCard": isBurnSupplementaryCard,
      "RelationID": relationID,
      "PrimaryCardNo": primaryCardNo,
      "PrimaryRelationID": primaryRelationID,
      "PrimaryCardExpiryDate": primaryCardExpiryDate,
      "PrimaryCardEffectiveDate": primaryCardEffectiveDate,
      "PtsHoldingDays": ptsHoldingDays,
      "MembershipTypeCCNFeatures": membershipTypeCCNFeatures,
      "MembershipTypeDefaultCCNValue": membershipTypeDefaultCCNValue,
      "MembershipTypeTierDefaultCCNValue": membershipTypeTierDefaultCCNValue,
      "CurrentNetSpent": currentNetSpent,
      "Passcode": passcode,
      "StoredValueBalance": storedValueBalance,
      "Currency": currency,
      "LastVisitedDate": lastVisitedDate,
      "LastVisitedOutlet": lastVisitedOutlet,
      "PointsToNextTier": pointsToNextTier,
      "NettToNextTier": nettToNextTier,
      "LuckyDrawConversionPtsUsageType": luckyDrawConversionPtsUsageType,
      "LuckyDrawConversionRate": luckyDrawConversionRate,
      "DiscGroupCode": discGroupCode,
      "SpentQuotaIncreasementExpiredOn": spentQuotaIncreasementExpiredOn,
      "SpentQuotaIncreasement": spentQuotaIncreasement,
      "DiscountGroupInfo": discountGroupInfo,
      "PickupDate": pickupDate,
      "PickupBy": pickupBy,
      "CurrentRCNettSpent": currentRCNettSpent,
      "CVCInfo": CVCInfo,
      "CMCEarnedPoints": CMCEarnedPoints,
      "CRCEarnedPoints": CRCEarnedPoints,
      "CurrentTierNett": currentTierNett,
      "CurrentTierAmt": currentTierAmt,
      "BringFwdTierNett": bringFwdTierNett,
      "BringFwdTierAmt": bringFwdTierAmt,
      "BringFwdTierExpiry": bringFwdTierExpiry,
      "BringFwdTierStartDate": bringFwdTierStartDate,
      "ExtendedTierAnniversaryEndDate": extendedTierAnniversaryEndDate
    };

    return data;
  }
}

class VoucherCardInfoRewardCycleItem {
  String? pointsType;
  double? pointsBALValue;
  String? pointsExpiringDate;
  String? cycEndDate;

  VoucherCardInfoRewardCycleItem(
      {this.pointsType,
      this.pointsBALValue,
      this.pointsExpiringDate,
      this.cycEndDate});

  VoucherCardInfoRewardCycleItem.fromJson(Map<String, dynamic> json) {
    pointsType = json['PointsType'];
    pointsBALValue = json['PointsBALValue'];
    pointsExpiringDate = json['PointsExpiringDate'];
    cycEndDate = json['CycEndDate'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "PointsType": pointsType,
      "PointsBALValue": pointsBALValue,
      "PointsExpiringDate": pointsExpiringDate,
      "CycEndDate": cycEndDate
    };
    return data;
  }
}

class VoucherCardInfoCVCInfoItem {
  String? CNO;
  String? CCN;
  String? CVC;

  VoucherCardInfoCVCInfoItem({this.CNO, this.CCN, this.CVC});

  VoucherCardInfoCVCInfoItem.fromJson(Map<String, dynamic> json) {
    CNO = json['CNO'];
    CCN = json['CCN'];
    CVC = json['CVC'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "CNO": CNO,
      "CCN": CCN,
      "CVC": CVC,
    };
    return data;
  }
}

class VoucherMembershipInfoDTO {
  double? totalSpending;
  double? totalPoints;
  int? totalVisits;
  String? lastVisitedOutletCode;
  String? mostCycleVisitedOutletCode;
  int? totalCycleVisits;
  double? totalCycleSpending;
  double? totalCyclePoints;
  double? totalBalPoints;
  double? currentMonthSpending;
  double? currentMonth1Spending;
  double? currentMonth2Spending;
  double? totalNettSpending;
  double? totalCycleNettSpending;
  double? currentMonthNettSpending;
  double? currentMonth1NettSpending;
  double? currentMonth2NettSpending;

  VoucherMembershipInfoDTO({
    this.totalSpending,
    this.totalPoints,
    this.totalVisits,
    this.lastVisitedOutletCode,
    this.mostCycleVisitedOutletCode,
    this.totalCycleVisits,
    this.totalCycleSpending,
    this.totalCyclePoints,
    this.totalBalPoints,
    this.currentMonthSpending,
    this.currentMonth1Spending,
    this.currentMonth2Spending,
    this.totalNettSpending,
    this.totalCycleNettSpending,
    this.currentMonthNettSpending,
    this.currentMonth1NettSpending,
    this.currentMonth2NettSpending,
  });

  VoucherMembershipInfoDTO.fromJson(Map<String, dynamic> json) {
    totalSpending = json['TotalSpending'];
    totalPoints = json['TotalPoints'];
    totalVisits = json['TotalVisits'];
    lastVisitedOutletCode = json['LastVisitedOutletCode'];
    mostCycleVisitedOutletCode = json['MostCycleVisitedOutletCode'];
    totalCycleVisits = json['TotalCycleVisits'];
    totalCycleSpending = json['TotalCycleSpending'];
    totalCyclePoints = json['TotalCyclePoints'];
    totalBalPoints = json['TotalBalPoints'];
    currentMonthSpending = json['CurrentMonthSpending'];
    currentMonth1Spending = json['CurrentMonth_1Spending'];
    currentMonth2Spending = json['CurrentMonth_2Spending'];
    totalNettSpending = json['TotalNettSpending'];
    totalCycleNettSpending = json['TotalCycleNettSpending'];
    currentMonthNettSpending = json['CurrentMonthNettSpending'];
    currentMonth1NettSpending = json['CurrentMonth_1NettSpending'];
    currentMonth2NettSpending = json['CurrentMonth_2NettSpending'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "TotalSpending": totalSpending,
      "TotalPoints": totalPoints,
      "TotalVisits": totalVisits,
      "LastVisitedOutletCode": lastVisitedOutletCode,
      "MostCycleVisitedOutletCode": mostCycleVisitedOutletCode,
      "TotalCycleVisits": totalCycleVisits,
      "TotalCycleSpending": totalCycleSpending,
      "TotalCyclePoints": totalCyclePoints,
      "TotalBalPoints": totalBalPoints,
      "CurrentMonthSpending": currentMonthSpending,
      "CurrentMonth_1Spending": currentMonth1Spending,
      "CurrentMonth_2Spending": currentMonth2Spending,
      "TotalNettSpending": totalNettSpending,
      "TotalCycleNettSpending": totalCycleNettSpending,
      "CurrentMonthNettSpending": currentMonthNettSpending,
      "CurrentMonth_1NettSpending": currentMonth1NettSpending,
      "CurrentMonth_2NettSpending": currentMonth2NettSpending
    };

    return data;
  }
}

class VoucherItemDTO {
  String? voucherNo;
  String? voucherTypeCode;
  String? voucherTypeName;
  String? voucherTypeDescription;
  String? type;
  String? typeValue;
  String? refundValue;
  String? validFrom;
  String? validTo;
  String? validTimeFrom;
  String? validTimeTo;
  String? validTimeFromSec;
  String? validTimeToSec;
  bool? isRedeemable;
  num? voucherRedemptionValue;
  String? voucherUsedOn;
  bool? isMinSpendingReq;
  int? minSpendingValue;
  String? remarks;
  String? entityCode;
  String? tenderMode;
  String? voucherIssuedOn;
  String? issuedOutletCode;
  String? issuedOutletName;
  String? redeemedOutletCode;
  String? redeemedOutletName;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? ref5;
  String? ref6;
  String? ref7;
  String? activeDaysOfWeek;
  String? taggingRef1;
  String? taggingRef2;
  String? taggingRef3;
  String? taggingRef4;
  String? taggingRef5;
  String? taggingRef6;
  String? taggingRef7;
  bool? eligibleFlag;
  String? vouRemarks;
  String? voucherUrl;
  String? expiryExtensionReason;
  String? voucherImageLink;
  String? voucherTnc;

  VoucherItemDTO(
      {this.voucherNo,
      this.voucherTypeCode,
      this.voucherTypeName,
      this.voucherTypeDescription,
      this.type,
      this.typeValue,
      this.refundValue,
      this.validFrom,
      this.validTo,
      this.validTimeFrom,
      this.validTimeTo,
      this.validTimeFromSec,
      this.validTimeToSec,
      this.isRedeemable,
      this.voucherRedemptionValue,
      this.voucherUsedOn,
      this.isMinSpendingReq,
      this.minSpendingValue,
      this.remarks,
      this.entityCode,
      this.tenderMode,
      this.voucherIssuedOn,
      this.issuedOutletCode,
      this.issuedOutletName,
      this.redeemedOutletCode,
      this.redeemedOutletName,
      this.ref1,
      this.ref2,
      this.ref3,
      this.ref4,
      this.ref5,
      this.ref6,
      this.ref7,
      this.activeDaysOfWeek,
      this.taggingRef1,
      this.taggingRef2,
      this.taggingRef3,
      this.taggingRef4,
      this.taggingRef5,
      this.taggingRef6,
      this.taggingRef7,
      this.eligibleFlag,
      this.vouRemarks,
      this.voucherUrl,
      this.expiryExtensionReason,
      this.voucherImageLink,
      this.voucherTnc});

  VoucherItemDTO.fromJson(Map<String, dynamic> json) {
    voucherNo = json['VoucherNo'];
    voucherTypeCode = json['VoucherTypeCode'];
    voucherTypeName = json['VoucherTypeName'];
    voucherTypeDescription = json['VoucherTypeDescription'];
    type = json['Type'];
    typeValue = json['TypeValue'];
    refundValue = json['RefundValue'];
    validFrom = json['ValidFrom'];
    validTo = json['ValidTo'];
    validTimeFrom = json['ValidTimeFrom'];
    validTimeTo = json['ValidTimeTo'];
    validTimeFromSec = json['ValidTimeFrom_Sec'];
    validTimeToSec = json['ValidTimeTo_Sec'];
    isRedeemable = json['IsRedeemable'];
    voucherRedemptionValue = json['VoucherRedemptionValue'];
    voucherUsedOn = json['VoucherUsedOn'];
    isMinSpendingReq = json['IsMinSpendingReq'];
    minSpendingValue = json['MinSpendingValue'];
    remarks = json['Remarks'];
    entityCode = json['EntityCode'];
    tenderMode = json['TenderMode'];
    voucherIssuedOn = json['VoucherIssuedOn'];
    issuedOutletCode = json['IssuedOutletCode'];
    issuedOutletName = json['IssuedOutletName'];
    redeemedOutletCode = json['RedeemedOutletCode'];
    redeemedOutletName = json['RedeemedOutletName'];
    ref1 = json['Ref1'];
    ref2 = json['Ref2'];
    ref3 = json['Ref3'];
    ref4 = json['Ref4'];
    ref5 = json['Ref5'];
    ref6 = json['Ref6'];
    ref7 = json['Ref7'];
    activeDaysOfWeek = json['ActiveDaysOfWeek'];
    taggingRef1 = json['TaggingRef1'];
    taggingRef2 = json['TaggingRef2'];
    taggingRef3 = json['TaggingRef3'];
    taggingRef4 = json['TaggingRef4'];
    taggingRef5 = json['TaggingRef5'];
    taggingRef6 = json['TaggingRef6'];
    taggingRef7 = json['TaggingRef7'];
    eligibleFlag = json['EligibleFlag'];
    vouRemarks = json['VouRemarks'];
    voucherUrl = json['VoucherUrl'];
    expiryExtensionReason = json['ExpiryExtensionReason'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "VoucherNo": voucherNo,
      "VoucherTypeCode": voucherTypeCode,
      "VoucherTypeName": voucherTypeName,
      "VoucherTypeDescription": voucherTypeDescription,
      "Type": type,
      "TypeValue": typeValue,
      "RefundValue": refundValue,
      "ValidFrom": validFrom,
      "ValidTo": validTo,
      "ValidTimeFrom": validTimeFrom,
      "ValidTimeTo": validTimeTo,
      "ValidTimeFrom_Sec": validTimeFromSec,
      "ValidTimeTo_Sec": validTimeToSec,
      "IsRedeemable": isRedeemable,
      "VoucherRedemptionValue": voucherRedemptionValue,
      "VoucherUsedOn": voucherUsedOn,
      "IsMinSpendingReq": isMinSpendingReq,
      "MinSpendingValue": minSpendingValue,
      "Remarks": remarks,
      "EntityCode": entityCode,
      "TenderMode": tenderMode,
      "VoucherIssuedOn": voucherIssuedOn,
      "IssuedOutletCode": issuedOutletCode,
      "IssuedOutletName": issuedOutletName,
      "RedeemedOutletCode": redeemedOutletCode,
      "RedeemedOutletName": redeemedOutletName,
      "Ref1": ref1,
      "Ref2": ref2,
      "Ref3": ref3,
      "Ref4": ref4,
      "Ref5": ref5,
      "Ref6": ref6,
      "Ref7": ref7,
      "ActiveDaysOfWeek": activeDaysOfWeek,
      "TaggingRef1": taggingRef1,
      "TaggingRef2": taggingRef2,
      "TaggingRef3": taggingRef3,
      "TaggingRef4": taggingRef4,
      "TaggingRef5": taggingRef5,
      "TaggingRef6": taggingRef6,
      "TaggingRef7": taggingRef7,
      "EligibleFlag": eligibleFlag,
      "VouRemarks": vouRemarks,
      "VoucherUrl": voucherUrl,
      "ExpiryExtensionReason": expiryExtensionReason
    };

    return data;
  }
}

class VoucherSummaryDTO {
  String? voucherTypeCode;
  String? voucherTypeName;
  String? voucherTypeDesc;
  String? voucherValidFrom;
  String? voucherValidTo;
  int? qty;
  int? pointsRedeemed;
  String? voucherTypeImgLink;

  VoucherSummaryDTO(
      {this.voucherTypeCode,
      this.voucherTypeName,
      this.voucherTypeDesc,
      this.voucherValidFrom,
      this.voucherValidTo,
      this.qty,
      this.pointsRedeemed,
      this.voucherTypeImgLink});

  VoucherSummaryDTO.fromJson(Map<String, dynamic> json) {
    voucherTypeCode = json['VoucherTypeCode'];
    voucherTypeName = json['VoucherTypeName'];
    voucherTypeDesc = json['VoucherTypeDesc'];
    voucherValidFrom = json['VoucherValidFrom'];
    voucherValidTo = json['VoucherValidTo'];
    qty = json['Qty'];
    pointsRedeemed = json['PointsRedeemed'];
    voucherTypeImgLink = json['VoucherTypeImgLink'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "VoucherTypeCode": voucherTypeCode,
      "VoucherTypeName": voucherTypeName,
      "VoucherTypeDesc": voucherTypeDesc,
      "VoucherValidFrom": voucherValidFrom,
      "VoucherValidTo": voucherValidTo,
      "Qty": qty,
      "PointsRedeemed": pointsRedeemed,
      "VoucherTypeImgLink": voucherTypeImgLink
    };

    return data;
  }
}
