// ignore_for_file: non_constant_identifier_names

class RewardCenterPartipatingOutletInfo {
  List<dynamic>? ParticipatingOutlets;
  List<dynamic>? ParticipatingOutletsByType;
  List<dynamic>? ParticipatingOutletsCategoryType1;
  List<dynamic>? ParticipatingOutletsCategoryType2;
  List<dynamic>? ParticipatingOutletsCategoryType3;
  List<dynamic>? ParticipatingOutletsCategoryType4;
  List<dynamic>? ParticipatingOutletsCategoryType5;

  RewardCenterPartipatingOutletInfo(
      {this.ParticipatingOutlets,
      this.ParticipatingOutletsByType,
      this.ParticipatingOutletsCategoryType1,
      this.ParticipatingOutletsCategoryType2,
      this.ParticipatingOutletsCategoryType3,
      this.ParticipatingOutletsCategoryType4,
      this.ParticipatingOutletsCategoryType5});

  RewardCenterPartipatingOutletInfo.fromJson(Map<String, dynamic> json) {
    ParticipatingOutlets = json['ParticipatingOutlets'];
    ParticipatingOutletsByType = json['ParticipatingOutletsByType'];
    ParticipatingOutletsCategoryType1 =
        json['ParticipatingOutletsCategoryType1'];
    ParticipatingOutletsCategoryType2 =
        json['ParticipatingOutletsCategoryType2'];
    ParticipatingOutletsCategoryType3 =
        json['ParticipatingOutletsCategoryType3'];
    ParticipatingOutletsCategoryType4 =
        json['ParticipatingOutletsCategoryType4'];
    ParticipatingOutletsCategoryType5 =
        json['ParticipatingOutletsCategoryType5'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'ParticipatingOutlets': ParticipatingOutlets,
      'ParticipatingOutletsByType': ParticipatingOutletsByType,
      'ParticipatingOutletsCategoryType1': ParticipatingOutletsCategoryType1,
      'ParticipatingOutletsCategoryType2': ParticipatingOutletsCategoryType2,
      'ParticipatingOutletsCategoryType3': ParticipatingOutletsCategoryType3,
      'ParticipatingOutletsCategoryType4': ParticipatingOutletsCategoryType4,
      'ParticipatingOutletsCategoryType5': ParticipatingOutletsCategoryType5
    };

    return data;
  }
}
