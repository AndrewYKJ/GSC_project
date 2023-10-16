// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/user_member_model.dart';
import 'package:gsc_app/models/json/user_membership_model.dart';

class UserModel {
  bool? IsValid;
  String? MemberToken;
  UserMemberModel? MemberInfo;
  List<UserMembershipModel>? MembershipCardLists;
  int? ReturnStatus;
  String? ReturnMessage;
  String? RequestTime;
  String? ResponseTime;
  List<UserMemberModel>? MemberLists;
  List<UserMembershipModel>? CardLists;
  dynamic JournalLists;
  dynamic MembershipMovementHistory;

  UserModel(
      {this.IsValid,
      this.MemberToken,
      this.MemberInfo,
      this.MembershipCardLists,
      this.ReturnStatus,
      this.ReturnMessage,
      this.RequestTime,
      this.ResponseTime});

  UserModel.fromJson(Map<String, dynamic> json) {
    IsValid = json['IsValid'];
    MemberToken = json['MemberToken'];
    if (json['MemberInfo'] != null) {
      MemberInfo = UserMemberModel.fromJson(json["MemberInfo"]);
    }
    if (json['MembershipCardLists'] != null) {
      MembershipCardLists = [];
      if (json['MembershipCardLists'] is List<dynamic>) {
        json['MembershipCardLists'].forEach((v) {
          MembershipCardLists!.add(UserMembershipModel.fromJson(v));
        });
      } else {
        MembershipCardLists!
            .add(UserMembershipModel.fromJson(json['MembershipCardLists']));
      }
    }
    ReturnStatus = json['ReturnStatus'];
    ReturnMessage = json['ReturnMessage'];
    RequestTime = json['RequestTime'];
    ResponseTime = json['ResponseTime'];
    if (json['MemberLists'] != null) {
      MemberLists = [];
      if (json['MemberLists'] is List<dynamic>) {
        json['MemberLists'].forEach((v) {
          MemberLists!.add(UserMemberModel.fromJson(v));
        });
      } else {
        MemberLists!.add(UserMemberModel.fromJson(json['MemberLists']));
      }
    }
    if (json['CardLists'] != null) {
      CardLists = [];
      if (json['CardLists'] is List<dynamic>) {
        json['CardLists'].forEach((v) {
          CardLists!.add(UserMembershipModel.fromJson(v));
        });
      } else {
        CardLists!.add(UserMembershipModel.fromJson(json['CardLists']));
      }
    }
    if (json['JournalLists'] != null) {
      JournalLists = json['JournalLists'];
    }
    MembershipMovementHistory = json['MembershipMovementHistory'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "IsValid": IsValid,
      "MemberToken": MemberToken,
      "MemberInfo": MemberInfo,
      "MembershipCardLists":
          MembershipCardLists?.map((e) => e.toJson()).toList(),
      "ReturnStatus": ReturnStatus,
      "ReturnMessage": ReturnMessage,
      "RequestTime": RequestTime,
      "ResponseTime": ResponseTime,
      "MemberLists": MemberLists?.map((e) => e.toJson()).toList(),
      "CardLists": CardLists?.map((e) => e.toJson()).toList(),
      "JournalLists": JournalLists,
      "MembershipMovementHistory": MembershipMovementHistory,
    };
    return data;
  }
}
