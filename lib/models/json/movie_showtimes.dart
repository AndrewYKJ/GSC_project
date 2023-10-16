// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:gsc_app/models/json/movie_home_model.dart';

class MovieShowtimesDTO {
  Locations? locations;
  String? code;
  String? display_msg;

  MovieShowtimesDTO({this.locations, this.code, this.display_msg});

  factory MovieShowtimesDTO.fromRawJson(String str) =>
      MovieShowtimesDTO.fromJson(json.decode(str));

  MovieShowtimesDTO.fromJson(Map<String, dynamic> json) {
    if (json['locations'] != null) {
      locations = Locations.fromJson(json['locations']);
    }
    code = json['code'];
    display_msg = json['display_msg'];
  }

  Map<String, dynamic> toJson() => {
        "locations": locations?.toJson(),
        "code": code,
        "display_msg": display_msg
      };
}

class CinemaDTO {
  Locations? locations;
  String? code;
  String? display_msg;
  CinemaDTO({this.locations, this.code, this.display_msg});

  factory CinemaDTO.fromRawJson(String str) =>
      CinemaDTO.fromJson(json.decode(str));

  CinemaDTO.fromJson(Map<String, dynamic> json) {
    if (json['locations'] != null) {
      locations = Locations.fromJson(json['locations']);
    }
    code = json['code'];
    display_msg = json['display_msg'];
  }

  Map<String, dynamic> toJson() => {
        "locations": locations?.toJson(),
        "code": code,
        "display_msg": display_msg
      };
}

class Locations {
  List<Location>? location;
  Filters? filters;
  String? parentCode;
  String? parentTitle;

  Locations({
    this.location,
    this.filters,
    this.parentCode,
    this.parentTitle,
  });

  Locations.fromJson(Map<String, dynamic> json) {
    if (json['location'] != null) {
      location = [];
      if (json['location'] is List<dynamic>) {
        json['location'].forEach((v) {
          location!.add(Location.fromJson(v));
        });
      } else {
        location!.add(Location.fromJson(json['location']));
      }
    }

    if (json['filters'] != null) {
      filters = Filters.fromJson(json['filters']);
    }
    parentCode = json['parent_code'];
    parentTitle = json['parent_title'];
  }
  Map<String, dynamic> toJson() => {
        'location': location?.map((e) => e.toJson()).toList(),
        'filters': filters?.toJson(),
        'parent_code': parentCode,
        'parent_title': parentTitle
      };
}

class Location {
  List<Child>? child;
  List<Show>? show;
  String? id;
  String? name;
  String? barcodeEnabled;
  String? address;
  String? thumb;
  String? isEpayment;
  String? epaymentName;
  String? sort;
  String? info;
  String? regionsCode;
  String? value;
  String? hallGroup;
  String? longitude;
  String? latitude;
  String? thumbSmall;
  String? thumbMedium;
  String? thumbBig;
  String? isEpayEnabled;
  String? isEpayHidden;
  Location(
      {this.child,
      this.show,
      this.id,
      this.name,
      this.barcodeEnabled,
      this.address,
      this.thumb,
      this.isEpayment,
      this.epaymentName,
      this.sort,
      this.regionsCode,
      this.info,
      this.hallGroup,
      this.isEpayEnabled,
      this.isEpayHidden,
      this.latitude,
      this.longitude,
      this.thumbBig,
      this.thumbMedium,
      this.thumbSmall,
      this.value});

  Location.fromJson(Map<String, dynamic> json) {
    if (json['child'] != null) {
      child = [];
      if (json['child'] is List<dynamic>) {
        json['child'].forEach((v) {
          child!.add(Child.fromJson(v));
        });
      } else {
        child!.add(Child.fromJson(json['child']));
      }
    }
    if (json['show'] != null) {
      show = [];
      if (json['show'] is List<dynamic>) {
        json['show'].forEach((v) {
          show!.add(Show.fromJson(v));
        });
      } else {
        show!.add(Show.fromJson(json['show']));
      }
    }
    id = json['id'];
    name = json['name'];
    regionsCode = json['region'];
    barcodeEnabled = json['barcode_enabled'];
    address = json['address'];
    thumb = json['thumb'];
    isEpayment = json['is_epayment'];
    epaymentName = json['epayment_name'];
    sort = json['sort'];
    info = json['info'];
    value = json['value'];
    hallGroup = json["hallgroup"];
    longitude = json["longitude"];
    latitude = json["latitude"];
    thumbSmall = json["thumb_small"];
    thumbMedium = json["thumb_medium"];
    thumbBig = json["thumb_big"];
    isEpayEnabled = json["is_epay_enabled"];
    isEpayHidden = json["is_epay_hidden"];
  }

  Map<String, dynamic> toJson() => {
        'child': child?.map((e) => e.toJson()).toList(),
        'id': id,
        'name': name,
        'barcode_enabled': barcodeEnabled,
        'address': address,
        'thumb': thumb,
        'is_epayment': isEpayment,
        'epayment_name': epaymentName,
        'sort': sort,
        'info': info
      };
}

class Filters {
  List<Group>? group;

  Filters({
    this.group,
  });

  Filters.fromJson(Map<String, dynamic> json) {
    if (json['group'] != null) {
      group = [];
      if (json['group'] is List<dynamic>) {
        json['group'].forEach((v) {
          group!.add(Group.fromJson(v));
        });
      } else {
        group!.add(Group.fromJson(json['group']));
      }
    }
  }

  Map<String, dynamic> toJson() =>
      {'group': group?.map((e) => e.toJson()).toList()};
}

class Group {
  List<Type>? type;
  String? name;

  Group({
    this.type,
    this.name,
  });

  Group.fromJson(Map<String, dynamic> json) {
    if (json['type'] != null) {
      type = [];
      if (json['type'] is List<dynamic>) {
        json['type'].forEach((v) {
          type!.add(Type.fromJson(v));
        });
      } else {
        type!.add(Type.fromJson(json['type']));
      }
    }
    name = json['name'];
  }
  Map<String, dynamic> toJson() =>
      {'type': type?.map((e) => e.toJson()).toList(), 'name': name};
}

class Type {
  String? code;
  String? name;

  Type({
    this.code,
    this.name,
  });

  Type.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }
  Map<String, dynamic> toJson() => {'code': code, 'name': name};
}
