// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class SeatSelectionDTO {
  SeatSelectionDTO({this.hall, this.code, this.display_msg});

  Hall? hall;
  String? code;
  String? display_msg;

  factory SeatSelectionDTO.fromRawJson(String str) =>
      SeatSelectionDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SeatSelectionDTO.fromJson(Map<String, dynamic> json) =>
      SeatSelectionDTO(
          hall: json["hall"] == null ? null : Hall.fromJson(json["hall"]),
          code: json['code'],
          display_msg: json['display_msg']);

  Map<String, dynamic> toJson() =>
      {"hall": hall?.toJson(), "code": code, "display_msg": display_msg};
}

class Hall {
  Hall({
    this.section,
    this.mappings,
    this.no,
    this.hsereleased,
    this.resvreleased,
    this.maximumseats,
    this.sponsorship,
  });

  Sections? section;
  Mappings? mappings;
  Sponsorship? sponsorship;
  String? no;
  String? hsereleased;
  String? resvreleased;
  String? maximumseats;

  factory Hall.fromRawJson(String str) => Hall.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Hall.fromJson(Map<String, dynamic> json) => Hall(
        section:
            json["section"] == null ? null : Sections.fromJson(json["section"]),
        mappings: json["mappings"] == null
            ? null
            : Mappings.fromJson(json["mappings"]),
        sponsorship: json["sponsorship"] == null
            ? null
            : Sponsorship.fromJson(json["sponsorship"]),
        no: json["no"],
        hsereleased: json["hsereleased"],
        resvreleased: json["resvreleased"],
        maximumseats: json["maximumseats"],
      );

  Map<String, dynamic> toJson() => {
        "section": section?.toJson(),
        "mappings": mappings?.toJson(),
        "no": no,
        "hsereleased": hsereleased,
        "resvreleased": resvreleased,
        "maximumseats": maximumseats,
      };
}

class Sponsorship {
  Sponsor? kioskSponsor;
  Sponsor? webSponsor;
  Sponsor? appSponsor;

  Sponsorship({
    this.kioskSponsor,
    this.webSponsor,
    this.appSponsor,
  });

  factory Sponsorship.fromRawJson(String str) =>
      Sponsorship.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sponsorship.fromJson(Map<String, dynamic> json) => Sponsorship(
        kioskSponsor: json["kiosk_sponsor"] == null
            ? null
            : Sponsor.fromJson(json["kiosk_sponsor"]),
        webSponsor: json["web_sponsor"] == null
            ? null
            : Sponsor.fromJson(json["web_sponsor"]),
        appSponsor: json["app_sponsor"] == null
            ? null
            : Sponsor.fromJson(json["app_sponsor"]),
      );

  Map<String, dynamic> toJson() => {
        "kiosk_sponsor": kioskSponsor?.toJson(),
        "web_sponsor": webSponsor?.toJson(),
        "app_sponsor": appSponsor?.toJson(),
      };
}

class Sponsor {
  String? imagepath;

  Sponsor({
    this.imagepath,
  });

  factory Sponsor.fromRawJson(String str) => Sponsor.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sponsor.fromJson(Map<String, dynamic> json) => Sponsor(
        imagepath: json["imagepath"],
      );

  Map<String, dynamic> toJson() => {
        "imagepath": imagepath,
      };
}

class Mappings {
  Mappings({
    this.category,
  });

  List<Category>? category;

  factory Mappings.fromRawJson(String str) =>
      Mappings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Mappings.fromJson(Map<String, dynamic> json) {
    if (json['category'] != null) {
      category = [];
      if (json['category'] is List<dynamic>) {
        json['category'].forEach((v) {
          category!.add(Category.fromJson(v));
        });
      } else {
        category!.add(Category.fromJson(json['category']));
      }
    }
  }

  Map<String, dynamic> toJson() => {
        "category": category == null
            ? []
            : List<dynamic>.from(category!.map((x) => x.toJson())),
      };
}

class Category {
  Category({
    this.seat,
    this.id,
    this.name,
    this.seatsTaken,
  });

  Seat? seat;
  String? id;
  String? name;
  String? seatsTaken;

  factory Category.fromRawJson(String str) =>
      Category.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        seat: json["seat"] == null ? null : Seat.fromJson(json["seat"]),
        id: json["id"],
        name: json["name"],
        seatsTaken: json["seats_taken"],
      );

  Map<String, dynamic> toJson() => {
        "seat": seat?.toJson(),
        "id": id,
        "name": name,
        "seats_taken": seatsTaken,
      };
}

class Seat {
  Seat({
    this.type,
  });

  String? type;

  factory Seat.fromRawJson(String str) => Seat.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Seat.fromJson(Map<String, dynamic> json) => Seat(
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
      };
}

class Sections {
  Sections({
    this.row,
    this.value,
    this.flipped,
  });

  List<Rows>? row;
  String? value;
  String? flipped;

  factory Sections.fromRawJson(String str) =>
      Sections.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Sections.fromJson(Map<String, dynamic> json) {
    value = json["value"];
    flipped = json["flipped"];

    if (json['row'] != null) {
      row = [];
      if (json['row'] is List<dynamic>) {
        json['row'].forEach((v) {
          row!.add(Rows.fromJson(v));
        });
      } else {
        row!.add(Rows.fromJson(json['row']));
      }
    }
  }

  Map<String, dynamic> toJson() => {
        "row":
            row == null ? [] : List<dynamic>.from(row!.map((x) => x.toJson())),
        "value": value,
        "flipped": flipped,
      };
}

class Rows {
  Rows({
    this.col,
    this.value,
    this.y,
  });

  List<Cols>? col;
  String? value;
  String? y;

  factory Rows.fromRawJson(String str) => Rows.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Rows.fromJson(Map<String, dynamic> json) {
    if (json['col'] != null) {
      col = [];
      if (json['col'] is List<dynamic>) {
        json['col'].forEach((v) {
          col!.add(Cols.fromJson(v));
        });
      } else {
        col!.add(Cols.fromJson(json['col']));
      }
    }

    value = json["value"];
    y = json["y"];
  }
  Map<String, dynamic> toJson() => {
        "col":
            col == null ? [] : List<dynamic>.from(col!.map((x) => x.toJson())),
        "value": value,
        "y": y,
      };
}

class Cols {
  Cols({
    this.value,
    this.x,
    this.type,
    this.priority,
    this.status,
    this.seatcategory,
    this.id,
  });

  String? value;
  String? x;
  String? type;
  String? priority;
  String? status;
  String? seatcategory;
  String? id;

  factory Cols.fromRawJson(String str) => Cols.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Cols.fromJson(Map<String, dynamic> json) => Cols(
        value: json["value"],
        x: json["x"],
        type: json["type"],
        priority: json["priority"],
        status: json["status"],
        seatcategory: json["seatcategory"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "x": x,
        "type": type,
        "priority": priority,
        "status": status,
        "seatcategory": seatcategory,
        "id": id,
      };
}
