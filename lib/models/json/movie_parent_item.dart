import 'movie_child_item.dart';

class MovieParentItem {
  String? code;
  String? title;
  dynamic child;

  MovieParentItem({this.code, this.title, this.child});

  MovieParentItem.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    title = json['title'];

    var jsonCheck = json['child'].toString();

    if (jsonCheck[0] == "[") {
      dynamic listItem = json['child'] as List;
      if (listItem != null && listItem.length > 0) {
        child = listItem.map((e) => MovieChildItem.fromJson(e)).toList();
      }
    } else {
      child = MovieChildItem.fromJson(json["child"]);
      // List<MovieChildItem> item = [];
      // item.add(MovieChildItem.fromJson(json["child"]));
      // child = item;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['code'] = code;
    data['title'] = title;
    data['child'] = child;

    return data;
  }
}
