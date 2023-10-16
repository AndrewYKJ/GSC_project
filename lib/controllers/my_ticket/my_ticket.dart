import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/controllers/my_ticket/my_ticket_details.dart';
import 'package:gsc_app/controllers/my_ticket/ticket_qr.dart';
import 'package:gsc_app/dio/api/booking_api.dart';
import 'package:gsc_app/models/arguments/appcache_profile_model.dart';
import 'package:gsc_app/models/json/booking_model.dart';
import 'package:gsc_app/widgets/custom_no_val_screen.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../../models/arguments/appcache_object_model.dart';

class MyTicketScreen extends StatefulWidget {
  final bool? afterPurchase;
  const MyTicketScreen({Key? key, this.afterPurchase}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyTicketScreen();
  }
}

class _MyTicketScreen extends State<MyTicketScreen> {
  var isLogin = false;
  dynamic dateSec;
  // dynamic currentDateSec;
  List<BookingModel> tickets = [];
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? ticketDetailsHtml;
  Map<String, List<BookingModel>>? ticketGroup;
  AppCacheObjectModel? storedData;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_TICKET_LIST_SCREEN);
    super.initState();
    _checkLoginState();
    _checkRefresh();
  }

  Future<BookingWrapper> getMyTickets(BuildContext context, String currentDate,
      String memberId, String email, String phoneno, String token) async {
    BookingApi bookingApi = BookingApi(context);
    return bookingApi.getTickets(currentDate, memberId, email, phoneno, token);
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken && AppCache.me != null) {
      setState(() {
        isLogin = true;
      });
    }

    if (isLogin) {
      if (AppCache.tickets != null) {
        if (AppCache.tickets!.isNotEmpty) {
          Utils.printInfo(">>>>> AppCache.tickets != null");
          tickets = AppCache.tickets!;
          ticketGroup = tickets.groupBy((m) => DateFormat('MMMM yyyy')
              .format(DateTime.parse(m.showdate!).toLocal()));
        } else {
          Utils.printInfo(">>>>> AppCache.tickets == null");
          _getTicketInfo();
        }
      } else {
        var hasData = await AppCache.containValue(AppCache.SPLASH_SCREEN_REF);
        if (hasData) {
          AppCache.getStringValue(AppCache.SPLASH_SCREEN_REF).then((value) {
            storedData = AppCacheObjectModel.fromJson(jsonDecode(value));
            if (storedData != null) {
              if (storedData!.ticket != null) {
                if (storedData!.ticket!.cacheDate != null) {
                  var myCacheDate =
                      DateTime.parse(storedData!.ticket!.cacheDate!);
                  if (DateTime.now().difference(myCacheDate).inDays > 0) {
                    Utils.printInfo(">>>>> StoredData.date > 1");
                    _getTicketInfo();
                  } else {
                    if (storedData!.ticket!.cacheData != null) {
                      Utils.printInfo(">>>>> StoredData.tickets != null");
                      AppCache.tickets =
                          toResponseList(storedData!.ticket!.cacheData);
                      tickets = toResponseList(storedData!.ticket!.cacheData);
                      // Utils.printWrapped(">>>>> StoredData.tickets ${tickets}");

                      ticketGroup = tickets.groupBy((m) =>
                          DateFormat('MMMM yyyy')
                              .format(DateTime.parse(m.showdate!).toLocal()));
                    } else {
                      Utils.printInfo(">>>>> StoredData.tickets == null");
                      _getTicketInfo();
                    }
                  }
                } else {
                  Utils.printInfo(">>>>> StoredData.tickets == null - 1");

                  _getTicketInfo();
                }
              } else {
                Utils.printInfo(">>>>> StoredData.tickets == null - 2");
                _getTicketInfo();
              }
            } else {
              Utils.printInfo(">>>>> StoredData.tickets == null - 3");
              _getTicketInfo();
            }
          });
        } else {
          Utils.printInfo(">>>>> StoredData.tickets == null - 4");
          _getTicketInfo();
        }
      }
    }
  }

  _checkRefresh() {
    if (widget.afterPurchase != null && widget.afterPurchase!) {
      _getTicketInfo();
    }
  }

  _getTicketInfo() async {
    EasyLoading.show();

    await getMyTickets(
            context,
            currentDate,
            AppCache.me?.MemberLists?.first.MemberID ?? "",
            AppCache.me?.MemberLists?.first.Email ?? "",
            AppCache.me?.MemberLists?.first.MobileNo ?? "",
            '1')
        .then((data) {
          setState(() {
            if (data.code != null && data.code == '-1') {
              Utils.showAlertDialog(
                  context,
                  Utils.getTranslated(context, "error_title"),
                  data.display_msg != null
                      ? data.display_msg ??
                          Utils.getTranslated(context, "general_error")
                      : Utils.getTranslated(context, "general_error"),
                  true,
                  false, () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            } else {
              if (data.success?.booking != null) {
                if (data.success!.booking!.isNotEmpty) {
                  if (storedData != null) {
                    if (storedData!.ticket != null) {
                      // Utils.printWrapped(
                      //     ">>>>>>>>>>> storedData.ticket is not empty");
                      storedData!.ticket!.cacheDate =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      storedData!.ticket!.cacheData = data.success!.booking!;
                    } else {
                      // Utils.printWrapped(
                      //     ">>>>>>>>>>> storedData.ticket is empty");
                      var ticketObj = AppCacheProfileModel();
                      ticketObj.cacheDate =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      ticketObj.cacheData = data.success!.booking!;
                      storedData!.ticket = ticketObj;
                    }

                    // Utils.printWrapped(
                    //     ">>>>>>>>>>> storedData?.ticket?.cacheDate : ${storedData?.ticket?.cacheDate}");
                    // Utils.printWrapped(
                    //     ">>>>>>>>>>>> storedData?.ticket?.cacheData : ${storedData?.ticket?.cacheData}");
                    AppCache.setString(
                        AppCache.SPLASH_SCREEN_REF, json.encode(storedData));
                  } else {
                    // Utils.printWrapped(">>>>>>>>>>> storedData? null");
                  }
                  AppCache.tickets = data.success!.booking!;
                  tickets = data.success!.booking!;
                  ticketGroup = tickets.groupBy((m) => DateFormat('MMMM yyyy')
                      .format(DateTime.parse(m.showdate!).toLocal()));
                }
              }
            }
          });
        })
        .whenComplete(() => {EasyLoading.dismiss()})
        .catchError((e) {
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              e != null
                  ? e.toString().isNotEmpty
                      ? e.toString()
                      : Utils.getTranslated(context, "general_error")
                  : Utils.getTranslated(context, "general_error"),
              true,
              null, () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
        });
  }

  List<BookingModel> toResponseList(List<dynamic> data) {
    List<BookingModel> value = <BookingModel>[];
    for (var element in data) {
      value.add(BookingModel.fromJson(element));
    }
    return value;
  }

  Future<void> callRefreshData(BuildContext ctx) async {
    Utils.printInfo("pull refresh");
    tickets.clear();
    ticketGroup?.clear();
    _getTicketInfo();
  }

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? tickets.isNotEmpty
            ? _loggedInContent()
            : NoValScreen(title: 'profile_value_ticket')
        : NoValScreen(title: 'profile_value_ticket');
  }

  Widget _loggedInContent() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 60,
          title: Text(Utils.getTranslated(context, 'profile_value_ticket'),
              textAlign: TextAlign.center,
              style: AppFont.montRegular(18, color: Colors.white)),
          leading: InkWell(
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Image.asset(
                  'assets/images/white-left-icon.png') // child: Image.asset('assets/images/white-left-icon.png')
              ),
          backgroundColor: AppColor.backgroundBlack(),
        ),
        body: Container(
            height: height,
            width: width,
            color: Colors.black,
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SafeArea(
                child: RefreshIndicator(
                    backgroundColor: Colors.transparent,
                    color: AppColor.appYellow(),
                    onRefresh: () => callRefreshData(context),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: ticketGroup?.length,
                        itemBuilder: (context, index) {
                          dynamic key = ticketGroup?.keys.elementAt(index);
                          var items = ticketGroup?[key];
                          return SizedBox(
                              width: width,
                              child: Column(children: [
                                headerItem(context, key),
                                for (var i = 0; i < items!.length; i++)
                                  _items(context, i, items[i]),
                              ]));
                          // var item = tickets[index];
                          // return _items(context, index, item);
                        })))));
  }

  Widget headerItem(BuildContext context, String title) {
    double screenWidth = MediaQuery.of(context).size.width;
    var today = DateFormat('MMMM yyyy').format(DateTime.now().toLocal());
    var isSame = today == title;
    return Transform.translate(
        offset: const Offset(0, 16),
        child: Container(
            width: screenWidth,
            color: Colors.black,
            margin: const EdgeInsets.only(top: 8, left: 8),
            child: Text(isSame ? '' : title,
                style: AppFont.montSemibold(18, color: Colors.white))));
  }

  Widget _items(BuildContext context, int index, BookingModel ticket) {
    final itmDate = DateTime.parse(ticket.showdate!);
    final today = DateTime.now();
    final difference = itmDate.difference(today).inDays;

    if (index >= 1) {
      dateSec = DateFormat.yMMM().format(DateTime.parse(ticket.showdate!));
    }

    return Container(
        padding: index == 0
            ? const EdgeInsets.all(0)
            : const EdgeInsets.only(
                top: 20,
              ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Material(),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      TicketDetailsScreen(
                                          url: Constants.ESERVICES_STG +
                                              '/eticketws/ticket.cshtml?value=${ticket.enc ?? ""}'),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  }));
                        },
                        child: Text(
                            Utils.getTranslated(context, "more_details"),
                            style: AppFont.montRegular(12,
                                color: AppColor.yellow(),
                                decoration: TextDecoration.underline)))
                  ])),
          Container(
              margin: const EdgeInsets.only(bottom: 17.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: (difference >= 0) ? Colors.white : AppColor.greyTicket(),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 23.5, left: 20, right: 17),
                        child: _movieTitle(context, index, difference, ticket)),
                    Padding(
                        padding: const EdgeInsets.only(left: 20, right: 17),
                        child: _subTitle(context, index, ticket)),
                    Padding(
                        padding: const EdgeInsets.only(left: 20, right: 17),
                        child: _qrCode(context, index, difference, ticket)),
                    _divider(),
                    Padding(
                        padding: const EdgeInsets.only(left: 20, right: 17),
                        child: _cinemaTitle()),
                    Padding(
                        padding: const EdgeInsets.only(left: 20, right: 17),
                        child: _cinema(context, index, difference, ticket)),
                    Container(
                        padding: const EdgeInsets.only(
                            top: 14, bottom: 14, left: 20, right: 17),
                        child: Row(children: [
                          _date(context, index, difference, ticket),
                          Padding(
                              padding: const EdgeInsets.only(left: 72),
                              child: _time(context, index, difference, ticket))
                        ])),
                    Padding(
                        padding: const EdgeInsets.only(left: 20, right: 17),
                        child: _hall(context, index, difference, ticket)),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 14.0, 17.0, 0),
                        child: _ticketType(context, index, difference, ticket)),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 14.0, 17.0, 0),
                        child: _seats(context, index, difference, ticket)),
                    Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 14.0, 17.0, 14.0),
                        child: _eCombo(context, index, difference, ticket)),
                  ])),
          const Padding(
              padding: EdgeInsets.only(top: 15),
              child: Divider(color: Colors.white))
        ]));
  }

  Widget _movieTitle(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Text(ticket.title ?? '-',
        style: AppFont.montSemibold(14,
            color: (difference >= 0) ? Colors.black : Colors.white));
  }

  Widget _subTitle(BuildContext context, int index, BookingModel ticket) {
    return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 14.5),
        child: Row(children: [
          Text(ticket.rating ?? '-',
              style: AppFont.poppinsRegular(12, color: AppColor.lightGrey())),
        ]));
  }

  Widget _qrCode(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      InkWell(
          onTap: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        TicketQrScreen(
                            id: ticket.bookingId != null
                                ? ticket.bookingId!.isNotEmpty
                                    ? ticket.bookingId!
                                        .substring(ticket.bookingId!.length - 5)
                                    : '-'
                                : '-',
                            qrID: ticket.barcode_string ?? '-'),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    }));
          },
          child: SizedBox(
              width: 126,
              height: 126,
              child: Stack(alignment: Alignment.center, children: [
                Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColor.qrBorderGrey())),
                    // padding: EdgeInsets.only(top: 5.3),
                    child: QrImage(
                      data: ticket.barcode_string ?? '-',
                      version: QrVersions.auto,
                      gapless: false,
                      // embeddedImage: AssetImage('assets/images/logo.png'),
                      // embeddedImageStyle: QrEmbeddedImageStyle(
                      //   size: Size(106, 106),
                      // )
                    )),
                Stack(children: [
                  Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                          width: 106,
                          height: 106,
                          alignment: Alignment.topLeft,
                          child: Container(
                              alignment: Alignment.center,
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20)),
                              child:
                                  Image.asset('assets/images/zoom-icon.png')))),
                ])
              ]))),
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
              Utils.getTranslated(context, "confirmation_id") +
                  " " +
                  (ticket.bookingId != null
                      ? ticket.bookingId!.isNotEmpty
                          ? ticket.bookingId!
                              .substring(ticket.bookingId!.length - 5)
                          : '-'
                      : '-'),
              style: AppFont.poppinsRegular(10,
                  color: (difference >= 0) ? Colors.black : Colors.white)))
    ]));
  }

  Widget _divider() {
    return Image.asset('assets/images/ticket-divided.png',
        fit: BoxFit.cover, width: MediaQuery.of(context).size.width);
  }

  Widget _cinemaTitle() {
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(Utils.getTranslated(context, 'ticket_cinema'),
            style: AppFont.montRegular(14, color: AppColor.lightGrey())));
  }

  Widget _cinema(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Text(ticket.cinema ?? '-',
        style: AppFont.poppinsRegular(14,
            color: (difference >= 0) ? Colors.black : Colors.white));
  }

  Widget _date(
      BuildContext context, int index, int difference, BookingModel ticket) {
    final oprnDate = DateTime.parse(ticket.oprndate!);
    final showDate = DateTime.parse(ticket.showdate!);
    final diff = oprnDate.difference(showDate).inDays;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(Utils.getTranslated(context, 'date'),
          style: AppFont.montRegular(14, color: AppColor.lightGrey())),
      diff > 0
          ? Text('${ticket.oprndate_display} (${ticket.showdate_display})',
              style: AppFont.poppinsRegular(14,
                  color: (difference >= 0) ? Colors.black : Colors.white))
          : Text(ticket.oprndate_display ?? '-',
              style: AppFont.poppinsRegular(14,
                  color: (difference >= 0) ? Colors.black : Colors.white))
    ]);
  }

  Widget _time(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(Utils.getTranslated(context, 'time'),
          style: AppFont.montRegular(14, color: AppColor.lightGrey())),
      Row(children: [
        Text(ticket.showtime ?? '-',
            style: AppFont.poppinsRegular(14,
                color: (difference >= 0) ? Colors.black : Colors.white)),
        // (DateFormat.jm().format(DateTime.parse(sampleData[index]['date'])) ==
        //         "12:00 AM")
        //     ? Text(
        //         " (" +
        //             DateFormat('E d MMM').format(
        //                 DateTime.parse(sampleData[index]['date'])
        //                     .add(Duration(days: 1))) +
        //             ")",
        //         style: AppFont.poppinsRegular(14,
        //             color: (difference >= 0) ? Colors.black : Colors.white))
        //     : Container()
      ])
    ]);
  }

  Widget _hall(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(Utils.getTranslated(context, 'hall'),
          style: AppFont.montRegular(14, color: AppColor.lightGrey())),
      Text(ticket.hall ?? '-',
          style: AppFont.poppinsRegular(14,
              color: (difference >= 0) ? Colors.black : Colors.white))
    ]);
  }

  Widget _ticketType(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(Utils.getTranslated(context, 'ticket_type'),
          style: AppFont.montRegular(14, color: AppColor.lightGrey())),
      Text(ticket.tktstr ?? '-',
          style: AppFont.poppinsRegular(14,
              color: (difference >= 0) ? Colors.black : Colors.white))
    ]);
  }

  Widget _seats(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(Utils.getTranslated(context, 'seats'),
          style: AppFont.montRegular(14, color: AppColor.lightGrey())),
      Text(ticket.seats ?? '-',
          style: AppFont.poppinsRegular(14,
              color: (difference >= 0) ? Colors.black : Colors.white))
    ]);
  }

  Widget _eCombo(
      BuildContext context, int index, int difference, BookingModel ticket) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(Utils.getTranslated(context, 'e_combo'),
          style: AppFont.montRegular(14, color: AppColor.lightGrey())),
      Text(
          ticket.econstr != null
              ? ticket.econstr!.isNotEmpty
                  ? ticket.econstr!
                  : 'N / A'
              : 'N / A',
          style: AppFont.poppinsRegular(14,
              color: (difference >= 0) ? Colors.black : Colors.white))
    ]);
  }

  String formatRunningTime(String time) {
    int value = int.parse(time);
    final int hour = value ~/ 60;
    final int minutes = value % 60;
    return '$hour hr $minutes mins';
  }

  Future<bool> internetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('gsc.com.my');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

extension GetByKeyIndex on Map {
  elementAt(int index) => values.elementAt(index);
}
