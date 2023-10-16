class AppCacheProfileModel {
  String? cacheDate;
  dynamic cacheData;

  AppCacheProfileModel(
      {this.cacheDate,
      this.cacheData});

  AppCacheProfileModel.fromJson(Map<String, dynamic> json) {
    cacheDate = json['cacheDate'];
    cacheData = json['cacheData'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'cacheDate': cacheDate,
      'cacheData': cacheData
    };

    return res;
  }
}
