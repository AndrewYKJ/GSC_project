// ignore_for_file: non_constant_identifier_names

class RewardCenterRefInfo {
  String? Ref1;
  String? Ref2;
  String? Ref3;
  String? Ref4;
  String? Ref5;
  String? Ref6;

  RewardCenterRefInfo(
      {this.Ref1, this.Ref2, this.Ref3, this.Ref4, this.Ref5, this.Ref6});

  RewardCenterRefInfo.fromJson(Map<String, dynamic> json) {
    Ref1 = json['Ref1'];
    Ref2 = json['Ref2'];
    Ref3 = json['Ref3'];
    Ref4 = json['Ref4'];
    Ref5 = json['Ref5'];
    Ref6 = json['Ref6'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'Ref1': Ref1,
      'Ref2': Ref2,
      'Ref3': Ref3,
      'Ref4': Ref4,
      'Ref5': Ref5,
      'Ref6': Ref6,
    };
    return data;
  }
}
