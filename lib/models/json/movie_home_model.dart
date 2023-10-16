import 'dart:convert';

class MovieEpaymentDTO {
  MovieEpaymentDTO({
    this.films,
  });

  Films? films;

  factory MovieEpaymentDTO.fromRawJson(String str) =>
      MovieEpaymentDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  MovieEpaymentDTO.fromJson(Map<String, dynamic> json) {
    if (json['films'] != null) {
      films = Films.fromJson(json['films']);
    }
  }
  Map<String, dynamic> toJson() => {
        "films": films?.toJson(),
      };
}

class ClassName {
  Films? films;

  ClassName({
    this.films,
  });

  ClassName.fromJson(Map<String, dynamic> json)
      : films = (json['films'] as Map<String, dynamic>?) != null
            ? Films.fromJson(json['films'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {'films': films?.toJson()};
}

class Films {
  List<Parent>? parent;

  Films({
    this.parent,
  });

  Films.fromJson(Map<String, dynamic> json) {
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
  }

  Map<String, dynamic> toJson() =>
      {'parent': parent?.map((e) => e.toJson()).toList()};
}

class Parent {
  List<Child>? child;
  String? code;
  String? title;

  Parent({
    this.child,
    this.code,
    this.title,
  });

  Parent.fromJson(Map<String, dynamic> json) {
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
    code = json['code'];
    title = json['title'];
  }
  Map<String, dynamic> toJson() => {
        'child': child?.map((e) => e.toJson()).toList(),
        'code': code,
        'title': title
      };
}

class Child {
  List<Show>? show;
  String? code;
  String? title;
  String? duration;
  String? lang;
  String? rating;
  String? freelist;
  String? thumbBig;
  String? stills;
  String? thumbMedium;
  String? thumbSmall;
  String? filmType;
  String? trailerUrl;
  String? genre;

  Child({
    this.show,
    this.code,
    this.title,
    this.duration,
    this.lang,
    this.stills,
    this.rating,
    this.freelist,
    this.thumbBig,
    this.thumbMedium,
    this.thumbSmall,
    this.filmType,
    this.trailerUrl,
    this.genre,
  });

  Child.fromJson(Map<String, dynamic> json) {
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

    code = json["code"];
    title = json["title"];
    duration = json["duration"];
    lang = json["lang"];
    rating = json["rating"];
    freelist = json["freelist"];
    thumbBig = json["thumb_big"];
    thumbMedium = json["thumb_medium"];
    stills = json["stills"];
    thumbSmall = json["thumb_small"];
    filmType = json["film_type"];
    trailerUrl = json["trailer_url"];
    genre = json["genre"];
  }

  Map<String, dynamic> toJson() => {
        'show': show?.map((e) => e.toJson()).toList(),
        'code': code,
        'title': title,
        'duration': duration,
        'lang': lang,
        'rating': rating,
        'freelist': freelist,
        "stills": stills,
        'thumb_big': thumbBig,
        'thumb_medium': thumbMedium,
        'thumb_small': thumbSmall,
        'film_type': filmType,
        'trailer_url': trailerUrl,
        'genre': genre
      };
}

class Show {
  String? opsdate;
  String? display;
  String? id;
  String? date;
  String? time;
  String? timestr;
  String? hid;
  String? hname;
  String? hallfull;
  String? hallorder;
  String? barcodeEnabled;
  String? displayDate;
  String? hasGscPrivilege;
  String? type;
  String? typeDesc;
  String? freelist;

  Show({
    this.opsdate,
    this.display,
    this.id,
    this.date,
    this.time,
    this.timestr,
    this.hid,
    this.hname,
    this.hallfull,
    this.hallorder,
    this.barcodeEnabled,
    this.displayDate,
    this.hasGscPrivilege,
    this.type,
    this.typeDesc,
    this.freelist,
  });

  Show.fromJson(Map<String, dynamic> json)
      : opsdate = json['opsdate'] as String?,
        display = json['display'] as String?,
        id = json['id'] as String?,
        date = json['date'] as String?,
        time = json['time'] as String?,
        timestr = json['timestr'] as String?,
        hid = json['hid'] as String?,
        hname = json['hname'] as String?,
        hallfull = json['hallfull'] as String?,
        hallorder = json['hallorder'] as String?,
        barcodeEnabled = json['barcode_enabled'] as String?,
        displayDate = json['display_date'] as String?,
        hasGscPrivilege = json['has_gsc_privilege'] as String?,
        type = json['type'] as String?,
        typeDesc = json['type_desc'] as String?,
        freelist = json['freelist'] as String?;

  Map<String, dynamic> toJson() => {'opsdate': opsdate, 'display': display};
}
