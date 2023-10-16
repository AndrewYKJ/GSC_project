// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/bundle_code.dart';

class TicketItemModel {
  String? id;
  String? type;
  String? price;
  String? tax;
  String? surcharge;
  String? seatcategory;
  String? seats_taken;
  String? loyalty_discount;
  String? surcharge_discount;
  String? hide_epay;
  String? selected;
  BundleCodeBody? bundle;

  TicketItemModel(
      {this.id,
      this.type,
      this.price,
      this.tax,
      this.surcharge,
      this.seatcategory,
      this.seats_taken,
      this.loyalty_discount,
      this.surcharge_discount,
      this.hide_epay,
      this.selected,
      this.bundle});

  TicketItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    price = json['price'];
    tax = json['tax'];
    surcharge = json['surcharge'];
    seatcategory = json['seatcategory'];
    seats_taken = json['seats_taken'];
    loyalty_discount = json['loyalty_discount'];
    surcharge_discount = json['surcharge_discount'];
    hide_epay = json['hide_epay'];
    selected = json['selected'];
    bundle =
        json['bundle'] != null ? BundleCodeBody.fromJson(json['bundle']) : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "id": id,
      "type": type,
      "price": price,
      "tax": tax,
      "surcharge": surcharge,
      "seatcategory": seatcategory,
      "seats_taken": seats_taken,
      "loyalty_discount": loyalty_discount,
      "surcharge_discount": surcharge_discount,
      "hide_epay": hide_epay,
      "selected": selected,
      "bundle": bundle,
    };

    return data;
  }
}

class ComboItemModel {
  ComboTaxModel? TAXES;
  ComboChildModel? CHILD;
  String? PARENT_ID;
  String? Combo_Desc;
  String? Price;
  String? HLB_DISC_FLAG;
  String? ImageUrl;
  dynamic ImageData;
  dynamic Detail_Desc;
  String? SOLD_OUT_FLAG;
  String? SOLD_OUT_MSG;
  String? Combo_Category;
  String? Limit_By_Tkt_Qty;
  String? Price_Description;
  dynamic ProdLastUpdated;
  dynamic ProdImgLastUpdated;

  ComboItemModel(
      {this.TAXES,
      this.CHILD,
      this.PARENT_ID,
      this.Combo_Desc,
      this.Price,
      this.HLB_DISC_FLAG,
      this.ImageUrl,
      this.ImageData,
      this.Detail_Desc,
      this.SOLD_OUT_FLAG,
      this.SOLD_OUT_MSG,
      this.Combo_Category,
      this.Limit_By_Tkt_Qty,
      this.Price_Description,
      this.ProdImgLastUpdated,
      this.ProdLastUpdated});

  ComboItemModel.fromJson(Map<String, dynamic> json) {
    TAXES =  json['TAXES'] != null ? ComboTaxModel.fromJson(json["TAXES"]) : json['TAXES'];
    CHILD = ComboChildModel.fromJson(json["CHILD"]);
    PARENT_ID = json['PARENT_ID'];
    Combo_Desc = json['Combo_Desc'];
    Price = json['Price'];
    HLB_DISC_FLAG = json['HLB_DISC_FLAG'];
    ImageUrl = json['ImageUrl'];
    ImageData = json['ImageData'];
    Detail_Desc = json['Detail_Desc'];
    SOLD_OUT_FLAG = json['SOLD_OUT_FLAG'];
    SOLD_OUT_MSG = json['SOLD_OUT_MSG'];
    Combo_Category = json['Combo_Category'];
    Limit_By_Tkt_Qty = json['Limit_By_Tkt_Qty'];
    Price_Description = json['Price_Description'];
    ProdImgLastUpdated = json['ProdImgLastUpdated'];
    ProdLastUpdated = json['ProdLastUpdated'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "TAXES": TAXES,
      "CHILD": CHILD,
      "PARENT_ID": PARENT_ID,
      "Combo_Desc": Combo_Desc,
      "Price": Price,
      "HLB_DISC_FLAG": HLB_DISC_FLAG,
      "ImageUrl": ImageUrl,
      "ImageData": ImageData,
      "Detail_Desc": Detail_Desc,
      "SOLD_OUT_FLAG": SOLD_OUT_FLAG,
      "SOLD_OUT_MSG": SOLD_OUT_MSG,
      "Combo_Category": Combo_Category,
      "Limit_By_Tkt_Qty": Limit_By_Tkt_Qty,
      "Price_Description": Price_Description,
      "ProdImgLastUpdated": ProdImgLastUpdated,
      "ProdLastUpdated": ProdLastUpdated,
    };

    return data;
  }
}

class ComboChildModel {
  List<ComboChildItemModel>? CHILD;

  ComboChildModel({this.CHILD});

  ComboChildModel.fromJson(Map<String, dynamic> json) {
    if (json['CHILD'] != null) {
      CHILD = [];
      if (json['CHILD'] is List<dynamic>) {
        json['CHILD'].forEach((v) {
          CHILD!.add(ComboChildItemModel.fromJson(v));
        });
      } else {
        CHILD!.add(ComboChildItemModel.fromJson(json['CHILD']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "CHILD": CHILD?.map((e) => e.toJson()).toList(),
    };

    return data;
  }
}

class ComboChildItemModel {
  ComboTaxModel? TAXES;
  String? SEQ;
  String? CODE;
  String? DESC;
  String? QUANTITY;
  String? AMOUNT;
  String? HLB_DISC_FLAG;
  String? ImageUrl;
  String? Detail_Desc;
  String? SOLD_OUT_FLAG;
  String? Limit_By_Tkt_Qty;

  ComboChildItemModel(
      {this.TAXES,
      this.SEQ,
      this.CODE,
      this.DESC,
      this.QUANTITY,
      this.AMOUNT,
      this.HLB_DISC_FLAG,
      this.ImageUrl,
      this.Detail_Desc,
      this.SOLD_OUT_FLAG,
      this.Limit_By_Tkt_Qty});

  ComboChildItemModel.fromJson(Map<String, dynamic> json) {
    TAXES = json["TAXES"] != null ? ComboTaxModel.fromJson(json["TAXES"]) : json['TAXES'];
    SEQ = json['SEQ'];
    CODE = json['CODE'];
    DESC = json['DESC'];
    QUANTITY = json['QUANTITY'];
    AMOUNT = json['AMOUNT'];
    HLB_DISC_FLAG = json['HLB_DISC_FLAG'];
    ImageUrl = json['ImageUrl'];
    Detail_Desc = json['Detail_Desc'];
    SOLD_OUT_FLAG = json['SOLD_OUT_FLAG'];
    Limit_By_Tkt_Qty = json['Limit_By_Tkt_Qty'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "TAXES": TAXES,
      "SEQ": SEQ,
      "CODE": CODE,
      "DESC": DESC,
      "QUANTITY": QUANTITY,
      "AMOUNT": AMOUNT,
      "HLB_DISC_FLAG": HLB_DISC_FLAG,
      "ImageUrl": ImageUrl,
      "Detail_Desc": Detail_Desc,
      "SOLD_OUT_FLAG": SOLD_OUT_FLAG,
      "Limit_By_Tkt_Qty": Limit_By_Tkt_Qty
    };

    return data;
  }
}

class TicketModel {
  String? id;
  int? qty;
  String? type;
  String? price;
  String? bundleCode;
  String? category;

  TicketModel({this.id, this.qty, this.type, this.price, this.bundleCode, this.category});
}

class ComboModel {
  String? id;
  int? qty;
  String? desc;
  String? price;

  ComboModel({this.id, this.qty, this.desc, this.price});
}

class ComboTaxModel {
  List<ComboTaxItemModel>? TAX;

  ComboTaxModel({this.TAX});

  ComboTaxModel.fromJson(Map<String, dynamic> json) {
    if (json['TAX'] != null) {
      TAX = [];
      if (json['TAX'] is List<dynamic>) {
        json['TAX'].forEach((v) {
          TAX!.add(ComboTaxItemModel.fromJson(v));
        });
      } else {
        TAX!.add(ComboTaxItemModel.fromJson(json['TAX']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "TAX": TAX?.map((e) => e.toJson()).toList(),
    };

    return data;
  }
}

class ComboTaxItemModel{
  String? TYPE;
  String? CODE;
  String? ID;
  String? RATEP;
  String? ENB;
  String? INCL;


  ComboTaxItemModel({this.TYPE, this.CODE, this.ID, this.RATEP, this.ENB, this.INCL});

  ComboTaxItemModel.fromJson(Map<String, dynamic> json) {
    TYPE = json['TYPE'];
    ID = json['ID'];
    CODE = json['CODE'];
    RATEP = json['RATEP'];
    ENB = json['ENB'];
    INCL = json['INCL'];
  }

  Map<String, dynamic> toJson() {
 Map<String, dynamic> data = {
      "TYPE": TYPE,
      "ID": ID,
      "CODE": CODE,
      "RATEP": RATEP,
      "ENB": ENB,
      "INCL": INCL
    };
    return data;
  }

}
