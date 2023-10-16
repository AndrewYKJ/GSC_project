// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/as_dynamic_field_model.dart';

class UserMemberModel {
  String? MemberAutoID;
  String? MemberID;
  String? Salutation;
  String? Name;
  String? NRIC;
  String? Passport;
  String? Email;
  String? Gender;
  String? DOB;
  String? Nationality;
  String? Block;
  String? Level;
  String? Unit;
  String? Street;
  String? Building;
  String? PostalCode;
  String? Country;
  String? Address1;
  String? Address2;
  String? Address3;
  String? ContactNo;
  String? MobileNo;
  String? FaxNo;
  String? ReferrerCode;
  String? FacebookID;
  String? FacebookName;
  String? FacebookPhotoLink;
  String? FacebookToken;
  String? FacebookTokenExpiry;
  String? FullPhotoName;
  String? Base64PhotoString;
  String? PhotoLink;
  dynamic InterestGroupLists;
  List<dynamic>? MailingLists;
  List<AS_DYNAMIC_MODEL>? DynamicColumnLists;
  List<AS_DYNAMIC_MODEL>? DynamicFieldLists;
  String? JoinDate;
  String? LastLoginDateTime;
  String? FirstLoginDateTime;
  List<dynamic>? ActiveTagList;
  String? IU;

  UserMemberModel({
    this.MemberAutoID,
    this.MemberID,
    this.Salutation,
    this.Name,
    this.NRIC,
    this.Passport,
    this.Email,
    this.Gender,
    this.DOB,
    this.Nationality,
    this.Block,
    this.Level,
    this.Unit,
    this.Street,
    this.Building,
    this.PostalCode,
    this.Country,
    this.Address1,
    this.Address2,
    this.Address3,
    this.ContactNo,
    this.MobileNo,
    this.FaxNo,
    this.ReferrerCode,
    this.FacebookID,
    this.FacebookName,
    this.FacebookPhotoLink,
    this.FacebookToken,
    this.FacebookTokenExpiry,
    this.FullPhotoName,
    this.Base64PhotoString,
    this.PhotoLink,
    this.InterestGroupLists,
    this.MailingLists,
    this.DynamicColumnLists,
    this.DynamicFieldLists,
    this.JoinDate,
    this.FirstLoginDateTime,
    this.LastLoginDateTime,
    this.ActiveTagList,
    this.IU,
  });

  UserMemberModel.fromJson(Map<String, dynamic> json) {
    MemberAutoID = json['MemberAutoID'];
    MemberID = json['MemberID'];
    Salutation = json['Salutation'];
    Name = json['Name'];
    NRIC = json['NRIC'];
    Passport = json['Passport'];
    Email = json['Email'];
    Gender = json['Gender'];
    DOB = json['DOB'];
    Nationality = json['Nationality'];
    Block = json['Block'];
    Level = json['Level'];
    Unit = json['Unit'];
    Street = json['Street'];
    Building = json['Building'];
    PostalCode = json['PostalCode'];
    Country = json['Country'];
    Address1 = json['Address1'];
    Address2 = json['Address2'];
    Address3 = json['Address3'];
    ContactNo = json['ContactNo'];
    MobileNo = json['MobileNo'];
    FaxNo = json['FaxNo'];
    ReferrerCode = json['ReferrerCode'];
    FacebookID = json['FacebookID'];
    FacebookName = json['FacebookName'];
    FacebookPhotoLink = json['FacebookPhotoLink'];
    FacebookToken = json['FacebookToken'];
    FacebookTokenExpiry = json['FacebookTokenExpiry'];
    FullPhotoName = json['FullPhotoName'];
    Base64PhotoString = json['Base64PhotoString'];
    PhotoLink = json['PhotoLink'];
    InterestGroupLists = json['InterestGroupLists'];
    MailingLists = json['MailingLists'];
    if (json['DynamicColumnLists'] != null) {
      var colList = json['DynamicColumnLists'] as List;

      if (colList.isNotEmpty) {
        DynamicColumnLists =
            colList.map((e) => AS_DYNAMIC_MODEL.fromJson(e)).toList();
      }
    } else {
      DynamicColumnLists = null;
    }
    if (json['DynamicFieldLists'] != null) {
      var fieldList = json['DynamicFieldLists'] as List;

      if (fieldList.isNotEmpty) {
        DynamicFieldLists =
            fieldList.map((e) => AS_DYNAMIC_MODEL.fromJson(e)).toList();
      }
    } else {
      DynamicFieldLists = null;
    }

    JoinDate = json['JoinDate'];
    FirstLoginDateTime = json['FirstLoginDateTime'];
    LastLoginDateTime = json['LastLoginDateTime'];
    ActiveTagList = json['ActiveTagList'];
    IU = json['IU'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "MemberAutoID": MemberAutoID,
      "MemberID": MemberID,
      "Salutation": Salutation,
      "Name": Name,
      "NRIC": NRIC,
      "Passport": Passport,
      "Email": Email,
      "Gender": Gender,
      "DOB": DOB,
      "Nationality": Nationality,
      "Block": Block,
      "Level": Level,
      "Unit": Unit,
      "Street": Street,
      "Building": Building,
      "PostalCode": PostalCode,
      "Country": Country,
      "Address1": Address1,
      "Address2": Address2,
      "Address3": Address3,
      "ContactNo": ContactNo,
      "MobileNo": MobileNo,
      "FaxNo": FaxNo,
      "ReferrerCode": ReferrerCode,
      "FacebookID": FacebookID,
      "FacebookName": FacebookName,
      "FacebookPhotoLink": FacebookPhotoLink,
      "FacebookToken": FacebookToken,
      "FacebookTokenExpiry": FacebookTokenExpiry,
      "FullPhotoName": FullPhotoName,
      "Base64PhotoString": Base64PhotoString,
      "PhotoLink": PhotoLink,
      "InterestGroupLists": InterestGroupLists,
      "MailingLists": MailingLists,
      "DynamicColumnLists": DynamicColumnLists,
      "DynamicFieldLists": DynamicFieldLists,
      "JoinDate": JoinDate,
      "FirstLoginDateTime": FirstLoginDateTime,
      "LastLoginDateTime": LastLoginDateTime,
      "ActiveTagList": ActiveTagList,
      "IU": IU,
    };

    return data;
  }
}
