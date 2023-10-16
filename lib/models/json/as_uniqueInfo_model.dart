// ignore_for_file: file_names
import 'as_dynamic_field_model.dart';

class UniqueInfoDTO {
  bool? succeeded;
  String? message;
  List<String>? errors;
  int? status;
  UniqueInfoDataDTO? data;

  UniqueInfoDTO({
    this.succeeded,
    this.message,
    this.errors,
    this.status,
    this.data,
  });

  factory UniqueInfoDTO.fromJson(Map<String, dynamic> json) => UniqueInfoDTO(
        succeeded: json["succeeded"],
        message: json["message"],
        errors: json["errors"] == null
            ? []
            : List<String>.from(json["errors"]!.map((x) => x)),
        status: json["status"],
        data: json["data"] == null
            ? null
            : UniqueInfoDataDTO.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "succeeded": succeeded,
        "message": message,
        "errors":
            errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
        "status": status,
        "data": data?.toJson(),
      };
}

class UniqueInfoDataDTO {
  bool? isUnique;
  List<AS_DYNAMIC_MODEL>? dynamicColumnList;
  List<AS_DYNAMIC_MODEL>? dynamicFieldList;

  UniqueInfoDataDTO({
    this.isUnique,
    this.dynamicColumnList,
    this.dynamicFieldList,
  });

  factory UniqueInfoDataDTO.fromJson(Map<String, dynamic> json) =>
      UniqueInfoDataDTO(
        isUnique: json["isUnique"],
        dynamicColumnList: json["dynamicColumnList"] == null
            ? []
            : List<AS_DYNAMIC_MODEL>.from(json["dynamicColumnList"]!
                .map((x) => AS_DYNAMIC_MODEL.fromJson(x))),
        dynamicFieldList: json["dynamicFieldList"] == null
            ? []
            : List<AS_DYNAMIC_MODEL>.from(json["dynamicFieldList"]!
                .map((x) => AS_DYNAMIC_MODEL.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isUnique": isUnique,
        "dynamicColumnList": dynamicColumnList == null
            ? []
            : List<AS_DYNAMIC_MODEL>.from(
                dynamicColumnList!.map((x) => x.toJson())),
        "dynamicFieldList": dynamicFieldList == null
            ? []
            : List<AS_DYNAMIC_MODEL>.from(
                dynamicFieldList!.map((x) => x.toJson())),
      };
}
