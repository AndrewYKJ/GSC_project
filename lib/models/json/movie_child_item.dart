// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/show_item.dart';

class MovieChildItem {
  String? code;
  String? title;
  String? duration;
  String? lang;
  String? rating;
  String? freelist;
  String? thumb_big;
  String? thumb_medium;
  String? thumb_small;
  String? film_type;
  String? genre;
  dynamic show;

  MovieChildItem(
      {this.code,
      this.title,
      this.duration,
      this.lang,
      this.rating,
      this.freelist,
      this.thumb_big,
      this.thumb_medium,
      this.thumb_small,
      this.film_type,
      this.genre,
      this.show});

  MovieChildItem.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    title = json['title'];
    duration = json['duration'];
    lang = json['lang'];
    rating = json['rating'];
    freelist = json['freelist'];
    thumb_big = json['thumb_big'];
    thumb_medium = json['thumb_medium'];
    thumb_small = json['thumb_small'];
    film_type = json['film_type'];
    genre = json['genre'];

    var jsonCheck = json["show"].toString();

    if (jsonCheck[0] == "[") {
      var itemsList = json["show"] as List;
      if (itemsList.isNotEmpty) {
        show = itemsList.map((e) => ShowItem.fromJson(e)).toList();
      }
    } else {
      show = ShowItem.fromJson(json["show"]);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['code'] = code;
    data['title'] = title;
    data['duration'] = duration;
    data['lang'] = lang;
    data['rating'] = rating;
    data['freelist'] = freelist;
    data['thumb_big'] = thumb_big;
    data['thumb_medium'] = thumb_medium;
    data['thumb_small'] = thumb_small;
    data['film_type'] = film_type;
    data['genre'] = genre;
    data['show'] = show;

    return data;
  }
}
