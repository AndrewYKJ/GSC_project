// ignore_for_file: non_constant_identifier_names

class AurumEComboSelectedOption {
  String? TicketType;
  String? BundleCode;
  List<String>? ItemCode;

  AurumEComboSelectedOption(this.TicketType, this.BundleCode, this.ItemCode);

  AurumEComboSelectedOption.fromJson(Map<String, dynamic> json) {
    TicketType = json['TicketType'];
    BundleCode = json['BundleCode'];
    ItemCode = json['ItemCode'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'TicketType': TicketType,
      'BundleCode': BundleCode,
      'ItemCodes': ItemCode,
    };

    return res;
  }
}
