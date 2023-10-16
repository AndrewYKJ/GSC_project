import 'dart:convert';

class InitSalesDTO {
  InitSalesDataDTO? prepareStatus;
  ErrorResponseDTO? error;
  InitSalesDTO({this.prepareStatus, this.error});

  factory InitSalesDTO.fromRawJson(String str) =>
      InitSalesDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InitSalesDTO.fromJson(Map<String, dynamic> json) => InitSalesDTO(
        prepareStatus: json["prepareStatus"] == null
            ? null
            : InitSalesDataDTO.fromJson(json["prepareStatus"]),
        error: json["error"] == null
            ? null
            : ErrorResponseDTO.fromJson(json["error"]),
      );

  Map<String, dynamic> toJson() => {
        "prepareStatus": prepareStatus?.toJson(),
      };
}

class ErrorResponseDTO {
  String? code;
  String? msg;
  String? displayMsg;

  ErrorResponseDTO({
    this.code,
    this.msg,
    this.displayMsg,
  });

  factory ErrorResponseDTO.fromRawJson(String str) =>
      ErrorResponseDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ErrorResponseDTO.fromJson(Map<String, dynamic> json) =>
      ErrorResponseDTO(
        code: json["code"],
        msg: json["msg"],
        displayMsg: json["display_msg"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "display_msg": displayMsg,
      };
}

class InitSalesDataDTO {
  Status? status;

  InitSalesDataDTO({
    this.status,
  });

  factory InitSalesDataDTO.fromRawJson(String str) =>
      InitSalesDataDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InitSalesDataDTO.fromJson(Map<String, dynamic> json) =>
      InitSalesDataDTO(
        status: json["status"] == null ? null : Status.fromJson(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status?.toJson(),
      };
}

class Status {
  Tickets? tickets;
  Econs? econs;
  GcPrivilege? gcPrivilege;
  String? code;
  String? msg;
  String? eonid;
  String? elapsedTime;
  String? tranRef;
  String? tranNo;
  String? tranType;
  String? tranDate;
  String? tranAmt;
  String? movieTag;
  String? ticketTag;
  String? memberId;
  String? icno;
  String? phoneno;
  String? emailaddress;
  String? memberName;
  String? referenceNo;
  String? transactionNo;
  String? transDate;
  String? statusCode;
  String? statusDesc;
  String? ticketQty;
  String? ticketAmt;
  String? ticketDisc;
  String? paypalMerchantEmailId;
  String? surchargeAmt;
  String? transTotalAmt;
  String? bookingFee;
  String? merchantId;
  String? econAmt;
  DateTime? txMovieDate;
  String? txMovieDateDisplay;
  String? sig;

  Status({
    this.tickets,
    this.econs,
    this.gcPrivilege,
    this.code,
    this.msg,
    this.eonid,
    this.elapsedTime,
    this.tranRef,
    this.tranNo,
    this.tranType,
    this.tranDate,
    this.tranAmt,
    this.movieTag,
    this.ticketTag,
    this.memberId,
    this.icno,
    this.phoneno,
    this.emailaddress,
    this.memberName,
    this.referenceNo,
    this.transactionNo,
    this.transDate,
    this.statusCode,
    this.statusDesc,
    this.ticketQty,
    this.ticketAmt,
    this.ticketDisc,
    this.paypalMerchantEmailId,
    this.surchargeAmt,
    this.transTotalAmt,
    this.bookingFee,
    this.merchantId,
    this.econAmt,
    this.txMovieDate,
    this.txMovieDateDisplay,
    this.sig,
  });

  factory Status.fromRawJson(String str) => Status.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        tickets:
            json["TICKETS"] == null ? null : Tickets.fromJson(json["TICKETS"]),
        econs: json["ECONS"] == null ? null : Econs.fromJson(json["ECONS"]),
        gcPrivilege: json["GC_Privilege"] == null
            ? null
            : GcPrivilege.fromJson(json["GC_Privilege"]),
        code: json["code"],
        msg: json["msg"],
        eonid: json["eonid"],
        elapsedTime: json["elapsed_time"],
        tranRef: json["tranRef"],
        tranNo: json["tranNo"],
        tranType: json["tranType"],
        tranDate: json["tranDate"],
        tranAmt: json["tranAmt"],
        movieTag: json["movieTag"],
        ticketTag: json["ticketTag"],
        memberId: json["memberID"],
        icno: json["icno"],
        phoneno: json["phoneno"],
        emailaddress: json["emailaddress"],
        memberName: json["memberName"],
        referenceNo: json["ReferenceNo"],
        transactionNo: json["TransactionNo"],
        transDate: json["TransDate"],
        statusCode: json["StatusCode"],
        statusDesc: json["StatusDesc"],
        ticketQty: json["TicketQty"],
        ticketAmt: json["TicketAmt"],
        ticketDisc: json["TicketDisc"],
        paypalMerchantEmailId: json["PaypalMerchantEmailId"],
        surchargeAmt: json["SurchargeAmt"],
        transTotalAmt: json["TransTotalAmt"],
        bookingFee: json["BookingFee"],
        merchantId: json["merchantID"],
        econAmt: json["EconAmt"],
        txMovieDate: json["tx_movie_date"] == null
            ? null
            : DateTime.parse(json["tx_movie_date"]),
        txMovieDateDisplay: json["tx_movie_date_display"],
        sig: json["sig"],
      );

  Map<String, dynamic> toJson() => {
        "TICKETS": tickets?.toJson(),
        "ECONS": econs,
        "GC_Privilege": gcPrivilege?.toJson(),
        "code": code,
        "msg": msg,
        "eonid": eonid,
        "elapsed_time": elapsedTime,
        "tranRef": tranRef,
        "tranNo": tranNo,
        "tranType": tranType,
        "tranDate": tranDate,
        "tranAmt": tranAmt,
        "movieTag": movieTag,
        "ticketTag": ticketTag,
        "memberID": memberId,
        "icno": icno,
        "phoneno": phoneno,
        "emailaddress": emailaddress,
        "memberName": memberName,
        "ReferenceNo": referenceNo,
        "TransactionNo": transactionNo,
        "TransDate": transDate,
        "StatusCode": statusCode,
        "StatusDesc": statusDesc,
        "TicketQty": ticketQty,
        "TicketAmt": ticketAmt,
        "TicketDisc": ticketDisc,
        "PaypalMerchantEmailId": paypalMerchantEmailId,
        "SurchargeAmt": surchargeAmt,
        "TransTotalAmt": transTotalAmt,
        "BookingFee": bookingFee,
        "merchantID": merchantId,
        "EconAmt": econAmt,
        "tx_movie_date":
            "${txMovieDate!.year.toString().padLeft(4, '0')}-${txMovieDate!.month.toString().padLeft(2, '0')}-${txMovieDate!.day.toString().padLeft(2, '0')}",
        "tx_movie_date_display": txMovieDateDisplay,
        "sig": sig,
      };
}

class Econs {
  List<Econ>? econ;

  Econs({
    this.econ,
  });

  factory Econs.fromRawJson(String str) => Econs.fromJson(json.decode(str));

  Econs.fromJson(Map<String, dynamic> json) {
    if (json['ECON'] != null) {
      econ = [];
      if (json['ECON'] is List<dynamic>) {
        json['ECON'].forEach((v) {
          econ!.add(Econ.fromJson(v));
        });
      } else {
        econ!.add(Econ.fromJson(json['ECON']));
      }
    }
  }
}

class Econ {
  EconTax? taxes;
  String? procCode;
  String? comboDesc;
  String? salesQty;
  String? salesAmt;
  String? txSeq;
  String? hlbDiscFlag;
  String? pkgSeq;
  String? pkgCode;
  String? pkgName;

  Econ({
    this.taxes,
    this.procCode,
    this.comboDesc,
    this.salesQty,
    this.salesAmt,
    this.txSeq,
    this.hlbDiscFlag,
    this.pkgSeq,
    this.pkgCode,
    this.pkgName,
  });

  factory Econ.fromRawJson(String str) => Econ.fromJson(json.decode(str));

  factory Econ.fromJson(Map<String, dynamic> json) => Econ(
        taxes: json["TAXES"] == null ? null : EconTax.fromJson(json["TAXES"]),
        procCode: json["PROC_CODE"],
        comboDesc: json["COMBO_DESC"],
        salesQty: json["SALES_QTY"],
        salesAmt: json["SALES_AMT"],
        txSeq: json["TX_SEQ"],
        hlbDiscFlag: json["HLB_DISC_FLAG"],
        pkgSeq: json["PKG_SEQ"],
        pkgCode: json["PKG_CODE"],
        pkgName: json["PKG_NAME"],
      );
}

class Taxes {
  List<Tax>? tax;

  Taxes({
    this.tax,
  });

  factory Taxes.fromRawJson(String str) => Taxes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Taxes.fromJson(Map<String, dynamic> json) {
    if (json['TAX'] != null) {
      tax = [];
      if (json['TAX'] is List<dynamic>) {
        json['TAX'].forEach((v) {
          tax!.add(Tax.fromJson(v));
        });
      } else {
        tax!.add(Tax.fromJson(json['TAX']));
      }
    }
  }

  Map<String, dynamic> toJson() => {
        "TAX":
            tax == null ? [] : List<dynamic>.from(tax!.map((x) => x.toJson())),
      };
}

class EconTax {
  Tax? tax;

  EconTax({
    this.tax,
  });

  factory EconTax.fromRawJson(String str) => EconTax.fromJson(json.decode(str));

  factory EconTax.fromJson(Map<String, dynamic> json) =>
      EconTax(tax: json["TAX"] == null ? null : Tax.fromJson(json["TAX"]));
}

class Tax {
  String? type;
  String? code;
  String? id;
  String? ratep;
  String? enb;
  String? incl;

  Tax({
    this.type,
    this.code,
    this.id,
    this.ratep,
    this.enb,
    this.incl,
  });

  factory Tax.fromRawJson(String str) => Tax.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
        type: json["TYPE"],
        code: json["CODE"],
        id: json["ID"],
        ratep: json["RATEP"],
        enb: json["ENB"],
        incl: json["INCL"],
      );

  Map<String, dynamic> toJson() => {
        "TYPE": type,
        "CODE": code,
        "ID": id,
        "RATEP": ratep,
        "ENB": enb,
        "INCL": incl,
      };
}

class GcPrivilege {
  String? epayRemark1;
  String? epayRemark2;
  String? mobileRemark1;
  String? mobileRemark2;
  String? hasGscPrivilege;

  GcPrivilege({
    this.epayRemark1,
    this.epayRemark2,
    this.mobileRemark1,
    this.mobileRemark2,
    this.hasGscPrivilege,
  });

  factory GcPrivilege.fromRawJson(String str) =>
      GcPrivilege.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GcPrivilege.fromJson(Map<String, dynamic> json) => GcPrivilege(
        epayRemark1: json["epay_remark_1"],
        epayRemark2: json["epay_remark_2"],
        mobileRemark1: json["mobile_remark_1"],
        mobileRemark2: json["mobile_remark_2"],
        hasGscPrivilege: json["has_gsc_privilege"],
      );

  Map<String, dynamic> toJson() => {
        "epay_remark_1": epayRemark1,
        "epay_remark_2": epayRemark2,
        "mobile_remark_1": mobileRemark1,
        "mobile_remark_2": mobileRemark2,
        "has_gsc_privilege": hasGscPrivilege,
      };
}

class Tickets {
  List<Ticket>? ticket;

  Tickets({
    this.ticket,
  });

  factory Tickets.fromRawJson(String str) => Tickets.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Tickets.fromJson(Map<String, dynamic> json) {
    if (json['TICKET'] != null) {
      ticket = [];
      if (json['TICKET'] is List<dynamic>) {
        json['TICKET'].forEach((v) {
          ticket!.add(Ticket.fromJson(v));
        });
      } else {
        ticket!.add(Ticket.fromJson(json['TICKET']));
      }
    }
  }

  Map<String, dynamic> toJson() => {
        "TICKET": ticket == null
            ? []
            : List<dynamic>.from(ticket!.map((x) => x.toJson())),
      };
}

class SURCHARGES {
  String? code;
  String? grp;
  String? amt;
  String? discAmt;

  SURCHARGES({this.code, this.grp, this.amt, this.discAmt});
  factory SURCHARGES.fromRawJson(String str) =>
      SURCHARGES.fromJson(json.decode(str));

  factory SURCHARGES.fromJson(Map<String, dynamic> json) => SURCHARGES(
        code: json["CODE"],
        grp: json["GRP"],
        amt: json["AMT"],
        discAmt: json["DISC_AMT"],
      );
}

class Ticket {
  SURCHARGES? surcharges;
  Taxes? taxes;
  String? num;
  String? seatType;
  String? rowId;
  String? colId;
  String? tktType;
  String? tktAmt;
  String? tktDiscAmt;
  String? tktSurgAmt;
  String? tktSurgDisc;
  String? tktResvFee;
  String? tktResvFeeDisc;
  String? pkgCode;
  String? pkgName;
  String? pkgSeq;

  Ticket({
    this.surcharges,
    this.taxes,
    this.num,
    this.seatType,
    this.rowId,
    this.colId,
    this.tktType,
    this.tktAmt,
    this.tktDiscAmt,
    this.tktSurgAmt,
    this.tktSurgDisc,
    this.tktResvFee,
    this.tktResvFeeDisc,
    this.pkgCode,
    this.pkgName,
    this.pkgSeq,
  });

  factory Ticket.fromRawJson(String str) => Ticket.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        surcharges: json["SURCHARGES"] == null
            ? null
            : SURCHARGES.fromJson(json["SURCHARGES"]),
        taxes: json["TAXES"] == null ? null : Taxes.fromJson(json["TAXES"]),
        num: json["NUM"],
        seatType: json["SEAT_TYPE"],
        rowId: json["ROW_ID"],
        colId: json["COL_ID"],
        tktType: json["TKT_TYPE"],
        tktAmt: json["TKT_AMT"],
        tktDiscAmt: json["TKT_DISC_AMT"],
        tktSurgAmt: json["TKT_SURG_AMT"],
        tktSurgDisc: json["TKT_SURG_DISC"],
        tktResvFee: json["TKT_RESV_FEE"],
        tktResvFeeDisc: json["TKT_RESV_FEE_DISC"],
        pkgCode: json["PKG_CODE"],
        pkgName: json["PKG_NAME"],
        pkgSeq: json["PKG_SEQ"],
      );

  Map<String, dynamic> toJson() => {
        "SURCHARGES": surcharges,
        "TAXES": taxes?.toJson(),
        "NUM": num,
        "SEAT_TYPE": seatType,
        "ROW_ID": rowId,
        "COL_ID": colId,
        "TKT_TYPE": tktType,
        "TKT_AMT": tktAmt,
        "TKT_DISC_AMT": tktDiscAmt,
        "TKT_SURG_AMT": tktSurgAmt,
        "TKT_SURG_DISC": tktSurgDisc,
        "TKT_RESV_FEE": tktResvFee,
        "TKT_RESV_FEE_DISC": tktResvFeeDisc,
        "PKG_CODE": pkgCode,
        "PKG_NAME": pkgName,
        "PKG_SEQ": pkgSeq,
      };
}
