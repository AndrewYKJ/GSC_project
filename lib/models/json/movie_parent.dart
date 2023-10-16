import 'movie_parent_item.dart';

class MovieParent {
  dynamic parent;

  MovieParent({this.parent});

  MovieParent.fromJson(Map<String, dynamic> json) {
    var jsonCheck = json["parent"].toString();

    if (jsonCheck[0] == "[") {
      var item = json['parent'];

      if (item != null && item.length > 0) {
        parent = item.map((e) => MovieParentItem.fromJson(e)).toList();
      }
    } else {
      parent = MovieParentItem.fromJson(json['parent']);
    }

    // if (listItem[0] == '[') {
    //   parent = item.map((e) => MovieParentItem.fromJson(e)).toList();
    // } else {
    //   parent = [item];
    // }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['parent'] = parent;

    return data;
  }
}
