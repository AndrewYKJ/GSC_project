// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';

class ShowtimesByCinemaDTO {
  ShowtimesByCinemaDataDTO? films;
  String? code;
  String? display_msg;
  ShowtimesByCinemaDTO({this.films, this.code, this.display_msg});

  factory ShowtimesByCinemaDTO.fromRawJson(String str) =>
      ShowtimesByCinemaDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShowtimesByCinemaDTO.fromJson(Map<String, dynamic> json) =>
      ShowtimesByCinemaDTO(
          films: json["films"] == null
              ? null
              : ShowtimesByCinemaDataDTO.fromJson(json["films"]),
          code: json['code'],
          display_msg: json['display_msg']);

  Map<String, dynamic> toJson() =>
      {"films": films?.toJson(), "code": code, "display_msg": display_msg};
}

class ShowtimesByCinemaDataDTO {
  Oprn? oprn;
  Filters? filters;

  ShowtimesByCinemaDataDTO({
    this.oprn,
    this.filters,
  });

  factory ShowtimesByCinemaDataDTO.fromRawJson(String str) =>
      ShowtimesByCinemaDataDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  ShowtimesByCinemaDataDTO.fromJson(Map<String, dynamic> json) {
    if (json['oprn'] != null) {
      oprn = Oprn.fromJson(json['oprn']);
    }
    if (json['filters'] != null) {
      filters = Filters.fromJson(json['filters']);
    }
  }

  Map<String, dynamic> toJson() => {
        "oprn": oprn?.toJson(),
        "filters": filters?.toJson(),
      };
}

class Oprn {
  List<Parent>? parent;
  DateTime? date;
  String? display;

  Oprn({
    this.parent,
    this.date,
    this.display,
  });

  factory Oprn.fromRawJson(String str) => Oprn.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Oprn.fromJson(Map<String, dynamic> json) {
    if (json['parent'] != null) {
      parent = [];
      if (json['parent'] is List<dynamic>) {
        json['parent'].forEach((v) {
          parent!.add(Parent.fromJson(v));
        });
      } else {
        parent!.add(Parent.fromJson(json['parent']));
      }
    }
    date = json["_date"] == null ? null : DateTime.parse(json["_date"]);
    display = json["_display"];
  }

  Map<String, dynamic> toJson() => {
        "parent": parent == null
            ? []
            : List<dynamic>.from(parent!.map((x) => x.toJson())),
        "_date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "_display": display,
      };
}
