import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/models/json/aurum_ecombo_selection_option_model.dart';
import 'package:gsc_app/models/json/check_booking_status_response.dart';
import 'package:gsc_app/models/json/init_sales_trans_reponse.dart';
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

import '../../const/utils.dart';
import '../dio_repo.dart';

class TransactionsApi extends DioRepo {
  TransactionsApi(BuildContext context) {
    dioContext = context;
  }

  final myTransformer = Xml2Json();

  Future<InitSalesDTO> initSalesTransaction(
      String locationid,
      String showid,
      List seat,
      String ticketType,
      String econ,
      String seattype,
      String selectedecon,
      String selectedtkt,
      String userEmail,
      String userIC,
      String userPhoneno,
      String token,
      String? version,
      String platform,
      String entryPoint,
      List<AurumEComboSelectedOption>? selectedOptions) async {
    var headers = {
      "Ver": '1.0.0.1',
      "Req": 'initSalesTranscationEpayV4',
      "ReqDt": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };

    var bodyItem = {
      "locationid": locationid,
      "showid": showid,
      "numseats": seat.length.toString(),
      "seats": seat.join(','),
      "seattype": seattype,
      "tickettype": ticketType,
      "icno": '',
      "memberid": AppCache.me?.MemberLists?.first.MemberID ?? "",
      "email": AppCache.me?.MemberLists?.first.Email ?? "",
      "phoneno": AppCache.me?.MemberLists?.first.MobileNo ?? "",
      "voucher_channel": '',
      "member_name": AppCache.me?.MemberLists?.first.Name ?? "",
      "econ": econ,
      "selectedtkt": selectedtkt,
      "selectedecon": selectedecon,
      "payment_channel": 'E-Payment',
      "promo_flag": 'N', // need to confirm this
      "isLoggedIn": true,
      "source": '',
      "appVersion": '3.2.7', //ToDo :change appVersion
      "platform": platform,
      "entryPoint": entryPoint,
      "SelectedOptions": selectedOptions,
    };

    const signature = '';

    var initSalesBody = {
      "Request": {"Header": headers, "Body": bodyItem},
      "Signature": signature
    };

    try {
      Response response = await mDio.post(
        '/transactionws/service.asmx/initSalesTransactionEpayV4',
        options: Options(
          headers: {
            'Accept': 'text/plain, */*',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          responseType: ResponseType.json,
        ),
        data: json.encode(initSalesBody),
      );
      // Utils.printWrapped(response.data.toString());
      myTransformer.parse(response.data);

      var data = myTransformer.toGData();

      var jsonData = json.decode(data);

      return InitSalesDTO.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingResponseDTO> checkTransactionStatus(String bookingId) async {
    var params = {"bookingid": bookingId};

    try {
      Response response = await mDio.get(
        '/transactionws/service.asmx/checkTransactionStatusV2',
        options: Options(
          headers: {
            'Accept': 'text/plain, */*',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          responseType: ResponseType.json,
        ),
        queryParameters: params,
      );

      Utils.printInfo(response.data.toString());
      myTransformer.parse(response.data);

      var data = myTransformer.toGData();

      var jsonData = json.decode(data);

      return BookingResponseDTO.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingResponseDTO> cancelTransaction(
      String bookingId, String locationId) async {
    var params = {"bookingid": bookingId, "locationid": locationId};

    try {
      Response response = await mDio.get(
        '/transactionws/service.asmx/cancelTransactions',
        queryParameters: params,
      );

      Utils.printInfo(response.data.toString());

      myTransformer.parse(response.data);

      var data = myTransformer.toGData();

      var jsonData = json.decode(data);

      return BookingResponseDTO.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }
}
