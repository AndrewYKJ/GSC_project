import 'dart:convert';

class CoinTransactionDTO {
  int? totalTransactionCounts;
  List<TransactionList>? transactionLists;
  int? returnStatus;
  String? returnMessage;
  String? requestTime;
  String? responseTime;

  CoinTransactionDTO({
    this.totalTransactionCounts,
    this.transactionLists,
    this.returnStatus,
    this.returnMessage,
    this.requestTime,
    this.responseTime,
  });

  factory CoinTransactionDTO.fromRawJson(String str) =>
      CoinTransactionDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CoinTransactionDTO.fromJson(Map<String, dynamic> json) =>
      CoinTransactionDTO(
        totalTransactionCounts: json["TotalTransactionCounts"],
        transactionLists: json["TransactionLists"] == null
            ? []
            : List<TransactionList>.from(json["TransactionLists"]!
                .map((x) => TransactionList.fromJson(x))),
        returnStatus: json["ReturnStatus"],
        returnMessage: json["ReturnMessage"],
        requestTime: json["RequestTime"],
        responseTime: json["ResponseTime"],
      );

  Map<String, dynamic> toJson() => {
        "TotalTransactionCounts": totalTransactionCounts,
        "TransactionLists": transactionLists == null
            ? []
            : List<dynamic>.from(transactionLists!.map((x) => x.toJson())),
        "ReturnStatus": returnStatus,
        "ReturnMessage": returnMessage,
        "RequestTime": requestTime,
        "ResponseTime": responseTime,
      };
}

class TransactionList {
  String? cardNo;
  int? autoId;
  bool? isGraceTransact;
  String? cycleType;
  String? transactDate;
  String? addedOn;
  String? originalDate;
  String? transactTime;
  String? transactType;
  String? transactOutletCode;
  String? transactOutletName;
  String? receiptNo;
  String? itemCode;
  String? voucherTypeCode;
  String? voucherTypeName;
  String? voucherType;
  String? voucherTypeValue;
  List<dynamic>? issuedVoucherLists;
  double? spendingAmt;
  num? points;
  String? remark;
  num? nettSpent;
  String? cashierId;
  String? posid;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? ref5;
  String? ref6;
  String? ref7;
  int? transactStagingAutoId;
  String? voidBy;
  String? voidReason;
  String? voidOn;
  List<SalesRelatedTransactionList>? salesRelatedTransactionList;
  List<TransactionDetailsList>? transactionDetailsList;
  List<OnlinePaymentList>? onlinePaymentList;
  List<PaymentList>? paymentList;
  String? attachmentUrl;
  String? attachments;
  int? luckyDrawChances;
  num? svAmount;
  num? svBal;
  String? issueByCampaignCode;
  String? issueByCampaignName;
  int? parentTransactAutoId;
  String? status;
  String? confirmationId;
  String? currency;
  String? transactionRefId;
  dynamic baseConversions;
  dynamic bookingDetails;

  TransactionList({
    this.cardNo,
    this.autoId,
    this.isGraceTransact,
    this.cycleType,
    this.transactDate,
    this.addedOn,
    this.originalDate,
    this.transactTime,
    this.transactType,
    this.transactOutletCode,
    this.transactOutletName,
    this.receiptNo,
    this.itemCode,
    this.voucherTypeCode,
    this.voucherTypeName,
    this.voucherType,
    this.voucherTypeValue,
    this.issuedVoucherLists,
    this.spendingAmt,
    this.points,
    this.remark,
    this.nettSpent,
    this.cashierId,
    this.posid,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.ref5,
    this.ref6,
    this.ref7,
    this.transactStagingAutoId,
    this.voidBy,
    this.voidReason,
    this.voidOn,
    this.salesRelatedTransactionList,
    this.transactionDetailsList,
    this.onlinePaymentList,
    this.paymentList,
    this.attachmentUrl,
    this.attachments,
    this.luckyDrawChances,
    this.svAmount,
    this.svBal,
    this.issueByCampaignCode,
    this.issueByCampaignName,
    this.parentTransactAutoId,
    this.status,
    this.confirmationId,
    this.currency,
    this.transactionRefId,
    this.baseConversions,
    this.bookingDetails,
  });

  factory TransactionList.fromRawJson(String str) =>
      TransactionList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TransactionList.fromJson(Map<String, dynamic> json) =>
      TransactionList(
        cardNo: json["CardNo"],
        autoId: json["AutoID"],
        isGraceTransact: json["IsGraceTransact"],
        cycleType: json["CycleType"],
        transactDate: json["TransactDate"],
        addedOn: json["AddedOn"],
        originalDate: json["OriginalDate"],
        transactTime: json["TransactTime"],
        transactType: json["TransactType"],
        transactOutletCode: json["TransactOutletCode"],
        transactOutletName: json["TransactOutletName"],
        receiptNo: json["ReceiptNo"],
        itemCode: json["ItemCode"],
        voucherTypeCode: json["VoucherTypeCode"],
        voucherTypeName: json["VoucherTypeName"],
        voucherType: json["VoucherType"],
        voucherTypeValue: json["VoucherTypeValue"],
        issuedVoucherLists: json["IssuedVoucherLists"] == null
            ? []
            : List<dynamic>.from(json["IssuedVoucherLists"]!.map((x) => x)),
        spendingAmt: json["SpendingAmt"]?.toDouble(),
        points: json["Points"],
        remark: json["Remark"],
        nettSpent: json["NettSpent"],
        cashierId: json["CashierID"],
        posid: json["POSID"],
        ref1: json["Ref1"],
        ref2: json["Ref2"],
        ref3: json["Ref3"],
        ref4: json["Ref4"],
        ref5: json["Ref5"],
        ref6: json["Ref6"],
        ref7: json["Ref7"],
        transactStagingAutoId: json["Transact_Staging_AutoID"],
        voidBy: json["VoidBy"],
        voidReason: json["VoidReason"],
        voidOn: json["VoidOn"],
        salesRelatedTransactionList: json["SalesRelatedTransactionList"] == null
            ? []
            : List<SalesRelatedTransactionList>.from(
                json["SalesRelatedTransactionList"]!
                    .map((x) => SalesRelatedTransactionList.fromJson(x))),
        transactionDetailsList: json["TransactionDetailsList"] == null
            ? []
            : List<TransactionDetailsList>.from(json["TransactionDetailsList"]!
                .map((x) => TransactionDetailsList.fromJson(x))),
        onlinePaymentList: json["OnlinePaymentList"] == null
            ? []
            : List<OnlinePaymentList>.from(json["OnlinePaymentList"]!
                .map((x) => OnlinePaymentList.fromJson(x))),
        paymentList: json["PaymentList"] == null
            ? []
            : List<PaymentList>.from(
                json["PaymentList"]!.map((x) => PaymentList.fromJson(x))),
        attachmentUrl: json["AttachmentURL"],
        attachments: json["Attachments"],
        luckyDrawChances: json["LuckyDrawChances"],
        svAmount: json["SVAmount"],
        svBal: json["SVBal"],
        issueByCampaignCode: json["IssueByCampaignCode"],
        issueByCampaignName: json["IssueByCampaignName"],
        parentTransactAutoId: json["ParentTransactAutoID"],
        status: json["Status"],
        confirmationId: json["ConfirmationID"],
        currency: json["Currency"],
        transactionRefId: json["TransactionRefID"],
        baseConversions: json["BaseConversions"],
        bookingDetails: json["BookingDetails"],
      );

  Map<String, dynamic> toJson() => {
        "CardNo": cardNo,
        "AutoID": autoId,
        "IsGraceTransact": isGraceTransact,
        "CycleType": cycleType,
        "TransactDate": transactDate,
        "AddedOn": addedOn,
        "OriginalDate": originalDate,
        "TransactTime": transactTime,
        "TransactType": transactType,
        "TransactOutletCode": transactOutletCode,
        "TransactOutletName": transactOutletName,
        "ReceiptNo": receiptNo,
        "ItemCode": itemCode,
        "VoucherTypeCode": voucherTypeCode,
        "VoucherTypeName": voucherTypeName,
        "VoucherType": voucherType,
        "VoucherTypeValue": voucherTypeValue,
        "IssuedVoucherLists": issuedVoucherLists == null
            ? []
            : List<dynamic>.from(issuedVoucherLists!.map((x) => x)),
        "SpendingAmt": spendingAmt,
        "Points": points,
        "Remark": remark,
        "NettSpent": nettSpent,
        "CashierID": cashierId,
        "POSID": posid,
        "Ref1": ref1,
        "Ref2": ref2,
        "Ref3": ref3,
        "Ref4": ref4,
        "Ref5": ref5,
        "Ref6": ref6,
        "Ref7": ref7,
        "Transact_Staging_AutoID": transactStagingAutoId,
        "VoidBy": voidBy,
        "VoidReason": voidReason,
        "VoidOn": voidOn,
        "SalesRelatedTransactionList": salesRelatedTransactionList == null
            ? []
            : List<dynamic>.from(
                salesRelatedTransactionList!.map((x) => x.toJson())),
        "TransactionDetailsList": transactionDetailsList == null
            ? []
            : List<dynamic>.from(
                transactionDetailsList!.map((x) => x.toJson())),
        "OnlinePaymentList": onlinePaymentList == null
            ? []
            : List<dynamic>.from(onlinePaymentList!.map((x) => x.toJson())),
        "PaymentList": paymentList == null
            ? []
            : List<dynamic>.from(paymentList!.map((x) => x.toJson())),
        "AttachmentURL": attachmentUrl,
        "Attachments": attachments,
        "LuckyDrawChances": luckyDrawChances,
        "SVAmount": svAmount,
        "SVBal": svBal,
        "IssueByCampaignCode": issueByCampaignCode,
        "IssueByCampaignName": issueByCampaignName,
        "ParentTransactAutoID": parentTransactAutoId,
        "Status": status,
        "ConfirmationID": confirmationId,
        "Currency": currency,
        "TransactionRefID": transactionRefId,
        "BaseConversions": baseConversions,
        "BookingDetails": bookingDetails,
      };
}

class OnlinePaymentList {
  String? orderNo;
  String? orderDate;
  String? transactId;
  String? paymentType;
  String? paymentMode;
  num? paymentAmount;
  String? currency;
  String? memberId;
  String? cardName;
  String? buyerName;
  String? buyerEmail;
  String? recipientName;
  String? recipientEmail;
  String? messageForRecipient;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? ref5;
  String? ref6;
  String? ref7;
  String? remarks;

  OnlinePaymentList({
    this.orderNo,
    this.orderDate,
    this.transactId,
    this.paymentType,
    this.paymentMode,
    this.paymentAmount,
    this.currency,
    this.memberId,
    this.cardName,
    this.buyerName,
    this.buyerEmail,
    this.recipientName,
    this.recipientEmail,
    this.messageForRecipient,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.ref5,
    this.ref6,
    this.ref7,
    this.remarks,
  });

  factory OnlinePaymentList.fromRawJson(String str) =>
      OnlinePaymentList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OnlinePaymentList.fromJson(Map<String, dynamic> json) =>
      OnlinePaymentList(
        orderNo: json["OrderNo"],
        orderDate: json["OrderDate"],
        transactId: json["TransactID"],
        paymentType: json["PaymentType"],
        paymentMode: json["PaymentMode"],
        paymentAmount: json["PaymentAmount"],
        currency: json["Currency"],
        memberId: json["MemberID"],
        cardName: json["CardName"],
        buyerName: json["BuyerName"],
        buyerEmail: json["BuyerEmail"],
        recipientName: json["RecipientName"],
        recipientEmail: json["RecipientEmail"],
        messageForRecipient: json["MessageForRecipient"],
        ref1: json["Ref1"],
        ref2: json["Ref2"],
        ref3: json["Ref3"],
        ref4: json["Ref4"],
        ref5: json["Ref5"],
        ref6: json["Ref6"],
        ref7: json["Ref7"],
        remarks: json["Remarks"],
      );

  Map<String, dynamic> toJson() => {
        "OrderNo": orderNo,
        "OrderDate": orderDate,
        "TransactID": transactId,
        "PaymentType": paymentType,
        "PaymentMode": paymentMode,
        "PaymentAmount": paymentAmount,
        "Currency": currency,
        "MemberID": memberId,
        "CardName": cardName,
        "BuyerName": buyerName,
        "BuyerEmail": buyerEmail,
        "RecipientName": recipientName,
        "RecipientEmail": recipientEmail,
        "MessageForRecipient": messageForRecipient,
        "Ref1": ref1,
        "Ref2": ref2,
        "Ref3": ref3,
        "Ref4": ref4,
        "Ref5": ref5,
        "Ref6": ref6,
        "Ref7": ref7,
        "Remarks": remarks,
      };
}

class PaymentList {
  String? type;
  String? mode;
  dynamic value;
  String? currency;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? ref5;
  String? ref6;
  String? ref7;
  int? lineNo;
  num? curRate;
  String? foreignCurrency;
  num? foreignCurrencyValue;
  String? cardName;

  PaymentList({
    this.type,
    this.mode,
    this.value,
    this.currency,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.ref5,
    this.ref6,
    this.ref7,
    this.lineNo,
    this.curRate,
    this.foreignCurrency,
    this.foreignCurrencyValue,
    this.cardName,
  });

  factory PaymentList.fromRawJson(String str) =>
      PaymentList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentList.fromJson(Map<String, dynamic> json) => PaymentList(
        type: json["Type"],
        mode: json["Mode"],
        value: json["Value"],
        currency: json["Currency"],
        ref1: json["Ref1"],
        ref2: json["Ref2"],
        ref3: json["Ref3"],
        ref4: json["Ref4"],
        ref5: json["Ref5"],
        ref6: json["Ref6"],
        ref7: json["Ref7"],
        lineNo: json["LineNo"],
        curRate: json["CurRate"],
        foreignCurrency: json["ForeignCurrency"],
        foreignCurrencyValue: json["ForeignCurrencyValue"],
        cardName: json["CardName"],
      );

  Map<String, dynamic> toJson() => {
        "Type": type,
        "Mode": mode,
        "Value": value,
        "Currency": currency,
        "Ref1": ref1,
        "Ref2": ref2,
        "Ref3": ref3,
        "Ref4": ref4,
        "Ref5": ref5,
        "Ref6": ref6,
        "Ref7": ref7,
        "LineNo": lineNo,
        "CurRate": curRate,
        "ForeignCurrency": foreignCurrency,
        "ForeignCurrencyValue": foreignCurrencyValue,
        "CardName": cardName,
      };
}

class SalesRelatedTransactionList {
  int? autoId;
  String? transactDate;
  dynamic transactTime;
  String? transactType;
  String? transactOutletCode;
  String? transactOutletName;
  String? receiptNo;
  String? itemCode;
  String? voucherTypeCode;
  String? voucherTypeName;
  String? voucherType;
  String? voucherTypeValue;
  num? spendingAmt;
  num? points;
  String? remark;
  num? nettSpent;
  String? cashierId;
  String? posid;
  dynamic voidOn;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? ref5;
  String? ref6;
  String? ref7;

  SalesRelatedTransactionList({
    this.autoId,
    this.transactDate,
    this.transactTime,
    this.transactType,
    this.transactOutletCode,
    this.transactOutletName,
    this.receiptNo,
    this.itemCode,
    this.voucherTypeCode,
    this.voucherTypeName,
    this.voucherType,
    this.voucherTypeValue,
    this.spendingAmt,
    this.points,
    this.remark,
    this.nettSpent,
    this.cashierId,
    this.posid,
    this.voidOn,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.ref5,
    this.ref6,
    this.ref7,
  });

  factory SalesRelatedTransactionList.fromRawJson(String str) =>
      SalesRelatedTransactionList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SalesRelatedTransactionList.fromJson(Map<String, dynamic> json) =>
      SalesRelatedTransactionList(
        autoId: json["AutoID"],
        transactDate: json["TransactDate"],
        transactTime: json["TransactTime"],
        transactType: json["TransactType"],
        transactOutletCode: json["TransactOutletCode"],
        transactOutletName: json["TransactOutletName"],
        receiptNo: json["ReceiptNo"],
        itemCode: json["ItemCode"],
        voucherTypeCode: json["VoucherTypeCode"],
        voucherTypeName: json["VoucherTypeName"],
        voucherType: json["VoucherType"],
        voucherTypeValue: json["VoucherTypeValue"],
        spendingAmt: json["SpendingAmt"],
        points: json["Points"],
        remark: json["Remark"],
        nettSpent: json["NettSpent"],
        cashierId: json["CashierID"],
        posid: json["POSID"],
        voidOn: json["VoidOn"],
        ref1: json["Ref1"],
        ref2: json["Ref2"],
        ref3: json["Ref3"],
        ref4: json["Ref4"],
        ref5: json["Ref5"],
        ref6: json["Ref6"],
        ref7: json["Ref7"],
      );

  Map<String, dynamic> toJson() => {
        "AutoID": autoId,
        "TransactDate": transactDate,
        "TransactTime": transactTime,
        "TransactType": transactType,
        "TransactOutletCode": transactOutletCode,
        "TransactOutletName": transactOutletName,
        "ReceiptNo": receiptNo,
        "ItemCode": itemCode,
        "VoucherTypeCode": voucherTypeCode,
        "VoucherTypeName": voucherTypeName,
        "VoucherType": voucherType,
        "VoucherTypeValue": voucherTypeValue,
        "SpendingAmt": spendingAmt,
        "Points": points,
        "Remark": remark,
        "NettSpent": nettSpent,
        "CashierID": cashierId,
        "POSID": posid,
        "VoidOn": voidOn,
        "Ref1": ref1,
        "Ref2": ref2,
        "Ref3": ref3,
        "Ref4": ref4,
        "Ref5": ref5,
        "Ref6": ref6,
        "Ref7": ref7,
      };
}

class TransactionDetailsList {
  String? itemCode;
  String? description;
  double? quantity;
  double? price;
  num? discount;
  double? net;
  num? points;
  int? lineNo;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? ref5;
  String? ref6;
  String? ref7;

  TransactionDetailsList({
    this.itemCode,
    this.description,
    this.quantity,
    this.price,
    this.discount,
    this.net,
    this.points,
    this.lineNo,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.ref5,
    this.ref6,
    this.ref7,
  });

  factory TransactionDetailsList.fromRawJson(String str) =>
      TransactionDetailsList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TransactionDetailsList.fromJson(Map<String, dynamic> json) =>
      TransactionDetailsList(
        itemCode: json["ItemCode"],
        description: json["Description"],
        quantity: json["Quantity"],
        price: json["Price"]?.toDouble(),
        discount: json["Discount"],
        net: json["Net"]?.toDouble(),
        points: json["Points"],
        lineNo: json["LineNo"],
        ref1: json["Ref1"],
        ref2: json["Ref2"],
        ref3: json["Ref3"],
        ref4: json["Ref4"],
        ref5: json["Ref5"],
        ref6: json["Ref6"],
        ref7: json["Ref7"],
      );

  Map<String, dynamic> toJson() => {
        "ItemCode": itemCode,
        "Description": description,
        "Quantity": quantity,
        "Price": price,
        "Discount": discount,
        "Net": net,
        "Points": points,
        "LineNo": lineNo,
        "Ref1": ref1,
        "Ref2": ref2,
        "Ref3": ref3,
        "Ref4": ref4,
        "Ref5": ref5,
        "Ref6": ref6,
        "Ref7": ref7,
      };
}
