class MovieListingHeader {
  String? ver;

  MovieListingHeader({this.ver});

  MovieListingHeader.fromJson(Map<String, dynamic> json) {
    ver = json['ver'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};

    json['ver'] = ver;

    return json;
  }
}
