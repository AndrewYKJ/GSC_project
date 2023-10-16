class BundleCodeBody {
  String? code;

  BundleCodeBody({this.code});

  BundleCodeBody.fromJson(Map<String, dynamic> json) {
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'code': code};

    return res;
  }
}
