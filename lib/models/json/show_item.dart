class ShowItem {
  String? opsdate;
  String? display;

  ShowItem({this.opsdate, this.display});

  ShowItem.fromJson(Map<String, dynamic> json) {
    opsdate = json['opsdate'];
    display = json['display'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {"opsdate": opsdate, "display": display};

    return data;
  }
}
