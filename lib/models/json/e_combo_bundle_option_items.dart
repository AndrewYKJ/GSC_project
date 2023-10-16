// ignore_for_file: non_constant_identifier_names

class EComboBundleItems {
  String? Code;
  String? Name;
  String? Description;
  String? Category;
  String? ImageUrl;
  int itmQuantity = 0;

  EComboBundleItems(
      {this.Code, this.Name, this.Description, this.Category, this.ImageUrl});

  EComboBundleItems.fromJson(Map<String, dynamic> json) {
    Code = json['Code'];
    Name = json['Name'];
    Description = json['Description'];
    Category = json['Category'];
    ImageUrl = json['ImageUrl'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'Code': Code,
      'Name': Name,
      'Description': Description,
      'Category': Category,
      'ImageUrl': ImageUrl,
    };

    return res;
  }
}
