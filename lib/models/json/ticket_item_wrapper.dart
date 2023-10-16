// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/ticket_item_model.dart';

class TicketItemWrapper {
  List<TicketItemModel>? ticket;
  String? code;
  String? msg;
  String? oprndate;

  TicketItemWrapper({this.ticket, this.code, this.msg, this.oprndate});

  TicketItemWrapper.fromJson(Map<String, dynamic> json) {
    if (json['ticket'] != null) {
      ticket = [];
      if (json['ticket'] is List<dynamic>) {
        json['ticket'].forEach((v) {
          ticket!.add(TicketItemModel.fromJson(v));
        });
      } else {
        ticket!.add(TicketItemModel.fromJson(json['ticket']));
      }
    }

    code = json['code'];
    msg = json['msg'];
    oprndate = json['oprndate'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "ticket": ticket,
      "code": code,
      "msg": msg,
      "oprndate": oprndate,
    };

    return data;
  }
}

class ComboItemWrapper {
  ProductItemWrapper? Product;
  dynamic status_code;

  ComboItemWrapper({this.Product, this.status_code});

  ComboItemWrapper.fromJson(Map<String, dynamic> json) {
    Product = ProductItemWrapper.fromJson(json['Product']);
    status_code = json['status_code'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "Product": Product,
      "status_code": status_code
    };

    return data;
  }
}

class ProductItemWrapper {
  List<ComboItemModel>? Combo;

  ProductItemWrapper({this.Combo});

  ProductItemWrapper.fromJson(Map<String, dynamic> json) {
    if (json["Combo"] != null) {
      var jsonCheck = json["Combo"].toString();
      if (jsonCheck[0] == "[") {
        var itemsList = json["Combo"] as List;
        if (itemsList.isNotEmpty) {
          Combo = itemsList.map((e) => ComboItemModel.fromJson(e)).toList();
        }
      } else {
        Combo = ComboItemModel.fromJson(json["Combo"]) as List<ComboItemModel>?;
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "Combo": Combo,
    };

    return data;
  }
}

class TicketWrapper {
  TicketItemWrapper? ticketdata;
  ComboItemWrapper? econdata;
  dynamic status;
  String? code;
  String? display_msg;

  TicketWrapper(
      {this.ticketdata,
      this.econdata,
      this.status,
      this.code,
      this.display_msg});

  TicketWrapper.fromJson(Map<String, dynamic> json) {
    ticketdata = json['ticketdata'] != null
        ? TicketItemWrapper.fromJson(json['ticketdata'])
        : null;
    econdata = json['econdata'] != null
        ? ComboItemWrapper.fromJson(json['econdata'])
        : null;
    status = json['status'];
    code = json['code'];
    display_msg = json['display_msg'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "ticketdata": ticketdata,
      "econdata": econdata,
      "status": status,
      "code": code,
      "display_msg": display_msg
    };

    return data;
  }
}
