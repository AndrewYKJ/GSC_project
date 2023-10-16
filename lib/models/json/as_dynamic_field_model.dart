// ignore: camel_case_types
class AS_DYNAMIC_MODEL {
  String? name;
  String? colValue;
  String? type;

  AS_DYNAMIC_MODEL({
    this.name,
    this.colValue,
    this.type,
  });
  AS_DYNAMIC_MODEL.fromJson(Map<String, dynamic> json) {
    json['Name'] != null ? name = json['Name'] : null;
    json['ColValue'] != null ? colValue = json["ColValue"] : null;
    json['Type'] != null ? type = json['Type'] : null;
  }

  Map<String, dynamic> toJson() => {
        "Name": name,
        "ColValue": colValue,
        "Type": type,
      };
}
