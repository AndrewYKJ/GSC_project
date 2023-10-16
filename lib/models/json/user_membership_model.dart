// ignore_for_file: non_constant_identifier_names

class UserMembershipModel {
  String? CardNo;
  String? MemberID;
  String? PrintedName;
  String? MembershipTypeCode;
  String? MembershipStatusCode;
  String? MembershipPhoto;
  String? IssueDate;
  String? EffectiveDate;
  String? ExpiryDate;
  bool? Printed;
  String? PrintedDate;
  String? RenewedDate;
  String? tmpEffectiveDate;
  String? tmpExpiryDate;
  String? tmpMembershipStatusCode;
  double? PointsBAL;
  double? TotalPointsBAL;
  String? PointsToNextTier;
  String? Remarks;
  double? MembershipDiscount;
  String? TierCode;
  dynamic TotalSpending;
  dynamic TotalNettSpending;
  dynamic TotalPoints;
  dynamic TotalVisits;
  String? LastVisitedOutletCode;
  String? MostCycleVisitedOutletCode;
  dynamic TotalCycleVisits;
  dynamic TotalCycleSpending;
  dynamic TotalCycleNettSpending;
  dynamic TotalCyclePoints;
  dynamic TotalBalPoints;
  dynamic CurrentMonthSpending;
  dynamic CurrentMonth_1Spending;
  dynamic CurrentMonth_2Spending;
  dynamic CurrentMonthNettSpending;
  dynamic CurrentMonth_1NettSpending;
  dynamic CurrentMonth_2NettSpending;
  String? TierAnniversaryStartDate;
  String? TierAnniversaryEndDate;

  UserMembershipModel({
    this.CardNo,
    this.MemberID,
    this.PrintedName,
    this.MembershipTypeCode,
    this.MembershipStatusCode,
    this.MembershipPhoto,
    this.IssueDate,
    this.EffectiveDate,
    this.Printed,
    this.PrintedDate,
    this.RenewedDate,
    this.tmpEffectiveDate,
    this.tmpExpiryDate,
    this.tmpMembershipStatusCode,
    this.PointsBAL,
    this.TotalPointsBAL,
    this.PointsToNextTier,
    this.Remarks,
    this.MembershipDiscount,
    this.TierCode,
    this.TotalSpending,
    this.TotalNettSpending,
    this.TotalPoints,
    this.TotalVisits,
    this.LastVisitedOutletCode,
    this.MostCycleVisitedOutletCode,
    this.TotalCycleVisits,
    this.TotalCycleSpending,
    this.TotalCycleNettSpending,
    this.TotalCyclePoints,
    this.TotalBalPoints,
    this.CurrentMonthSpending,
    this.CurrentMonth_1Spending,
    this.CurrentMonth_2Spending,
    this.CurrentMonthNettSpending,
    this.CurrentMonth_1NettSpending,
    this.CurrentMonth_2NettSpending,
    this.TierAnniversaryStartDate,
    this.TierAnniversaryEndDate,
  });

  UserMembershipModel.fromJson(Map<String, dynamic> json) {
    CardNo = json['CardNo'];
    MemberID = json['MemberID'];
    PrintedName = json['PrintedName'];
    MembershipTypeCode = json['MembershipTypeCode'];
    MembershipStatusCode = json['MembershipStatusCode'];
    MembershipPhoto = json['MembershipPhoto'];
    IssueDate = json['IssueDate'];
    EffectiveDate = json['EffectiveDate'];

    ExpiryDate = json['ExpiryDate'];
    Printed = json['Printed'];
    PrintedDate = json['PrintedDate'];
    RenewedDate = json['RenewedDate'];
    tmpEffectiveDate = json['tmpEffectiveDate'];
    tmpExpiryDate = json['tmpExpiryDate'];
    tmpMembershipStatusCode = json['tmpMembershipStatusCode'];
    PointsBAL = json['PointsBAL'];
    TotalPointsBAL = json["TotalPointsBAL"];
    PointsToNextTier = json["PointsToNextTier"];
    Remarks = json['Remarks'];
    MembershipDiscount = json['MembershipDiscount'];
    TierCode = json['TierCode'];
    TotalSpending = json['TotalSpending'];
    TotalNettSpending = json['TotalNettSpending'];
    TotalPoints = json['TotalPoints'];
    TotalVisits = json['TotalVisits'];
    LastVisitedOutletCode = json['LastVisitedOutletCode'];
    MostCycleVisitedOutletCode = json['MostCycleVisitedOutletCode'];
    TotalCycleVisits = json['TotalCycleVisits'];
    TotalCycleSpending = json['TotalCycleSpending'];
    TotalCycleNettSpending = json['TotalCycleNettSpending'];
    TotalCyclePoints = json['TotalCyclePoints'];
    TotalBalPoints = json['TotalBalPoints'];
    CurrentMonthSpending = json['CurrentMonthSpending'];
    CurrentMonth_1Spending = json['CurrentMonth_1Spending'];
    CurrentMonth_2Spending = json['CurrentMonth_2Spending'];
    CurrentMonthNettSpending = json['CurrentMonthNettSpending'];
    CurrentMonth_1NettSpending = json['CurrentMonth_1NettSpending'];
    CurrentMonth_2NettSpending = json['CurrentMonth_2NettSpending'];
    TierAnniversaryStartDate = json['TierAnniversaryStartDate'];
    TierAnniversaryEndDate = json['TierAnniversaryEndDate'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "CardNo": CardNo,
      "MemberID": MemberID,
      "PrintedName": PrintedName,
      "MembershipTypeCode": MembershipTypeCode,
      "MembershipStatusCode": MembershipStatusCode,
      "MembershipPhoto": MembershipPhoto,
      "IssueDate": IssueDate,
      "EffectiveDate": EffectiveDate,
      "ExpiryDate": ExpiryDate,
      "Printed": Printed,
      "PrintedDate": PrintedDate,
      "RenewedDate": RenewedDate,
      "tmpEffectiveDate": tmpEffectiveDate,
      "tmpExpiryDate": tmpExpiryDate,
      "tmpMembershipStatusCode": tmpMembershipStatusCode,
      "PointsBAL": PointsBAL,
      "TotalPointsBAL": TotalPointsBAL,
      "PointsToNextTier": PointsToNextTier,
      "Remarks": Remarks,
      "MembershipDiscount": MembershipDiscount,
      "TierCode": TierCode,
      "TotalSpending": TotalSpending,
      "TotalNettSpending": TotalNettSpending,
      "TotalPoints": TotalPoints,
      "TotalVisits": TotalVisits,
      "LastVisitedOutletCode": LastVisitedOutletCode,
      "MostCycleVisitedOutletCode": MostCycleVisitedOutletCode,
      "TotalCycleVisits": TotalCycleVisits,
      "TotalCycleSpending": TotalCycleSpending,
      "TotalCycleNettSpending": TotalCycleNettSpending,
      "TotalCyclePoints": TotalCyclePoints,
      "TotalBalPoints": TotalBalPoints,
      "CurrentMonthSpending": CurrentMonthSpending,
      "CurrentMonth_1Spending": CurrentMonth_1Spending,
      "CurrentMonth_2Spending": CurrentMonth_2Spending,
      "CurrentMonthNettSpending": CurrentMonthNettSpending,
      "CurrentMonth_1NettSpending": CurrentMonth_1NettSpending,
      "CurrentMonth_2NettSpending": CurrentMonth_2NettSpending,
      "TierAnniversaryStartDate": TierAnniversaryStartDate,
      "TierAnniversaryEndDate": TierAnniversaryEndDate
    };

    return data;
  }
}
