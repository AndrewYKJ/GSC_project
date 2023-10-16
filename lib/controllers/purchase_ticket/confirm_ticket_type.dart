import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/analytics_constant.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/dio/api/transactions_api.dart';
import 'package:gsc_app/models/arguments/aurum_ecombo_selection_arguments.dart';
import 'package:gsc_app/models/arguments/buy_ticket_type_arguments.dart';
import 'package:gsc_app/models/arguments/combo_selection_arguments.dart';
import 'package:gsc_app/models/json/ticket_item_wrapper.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/custom_quantity_stepper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../../dio/api/movie_showtimes.dart';
import '../../models/arguments/init_transaction_arguments.dart';
import '../../models/json/init_sales_trans_reponse.dart';
import '../../models/json/ticket_item_model.dart';
import '../../widgets/custom_dialog.dart';

class ConfirmTicketTypeScreen extends StatefulWidget {
  final BuyTicketTypeArgs data;

  const ConfirmTicketTypeScreen({Key? key, required this.data})
      : super(key: key);

  @override
  _ConfirmTicketTypeScreen createState() => _ConfirmTicketTypeScreen();
}

class _ConfirmTicketTypeScreen extends State<ConfirmTicketTypeScreen>
    with WidgetsBindingObserver {
  List<TicketModel> ticketType = [];
  List<TicketModel> selectedType = [];
  List<ComboItemModel> combo = [];
  int currentQty = 0;
  bool bundleCodeExist = false;
  bool isLoading = false;
  var bottomDisplayKey = GlobalKey<ScaffoldState>();
  var topDisplayKey = GlobalKey<ScaffoldState>();
  double? fillUpEmtpySpace;
  bool isSaving = false;
  InitSalesDTO? initSalesDTO;
  String? appVersion;
  String? appPlatform;
  bool absorb = false;
  bool isCheckOutDisabled = false;
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_TICKET_SELECTION_SCREEN);
    super.initState();
    currentQty = widget.data.ticketQty;
    _getTicketInfo();
    _checkPlatform();
  }

  Future<void> _checkPlatform() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.version.isNotEmpty) {
      appVersion = packageInfo.version;
      appPlatform = Platform.isAndroid
          ? Constants.IS_HUAWEI
              ? 'Huawei'
              : 'Android'
          : 'iOS';
    }
  }

  Future<TicketWrapper> getTicketType(BuildContext context) async {
    MovieShowtimes itm = MovieShowtimes(context);
    return itm.getTicketComboDetailsByShowtime(
        widget.data.locationId,
        widget.data.hallId,
        widget.data.filmId,
        widget.data.showDate,
        widget.data.showTime);
  }

  Future<dynamic> initTransactionApi(BuildContext context) async {
    List ticketType = [];
    List econ = [];
    List selectedecon = [];
    List selecttkt = [];
    List seatType = [];
    for (var data in selectedType) {
      if (data.qty! > 0) {
        for (var i = 0; i < data.qty!; i++) {
          ticketType.add(data.type);
        }
      }
    }

    widget.data.seatTypeMap!.forEach((key, value) {
      if (value['qty'] > 0) {
        selecttkt.add("$key: ${value['qty']}");
        for (var i = 0; i < value['qty']; i++) {
          seatType.add(key);
        }
      }
    });

    TransactionsApi itm = TransactionsApi(context);
    return itm.initSalesTransaction(
        widget.data.locationId,
        widget.data.showId,
        widget.data.seats,
        ticketType.join(',').toString(),
        econ.join(',').toString(),
        seatType.join(',').toString(),
        selectedecon.join(', ').toString(),
        selecttkt.join(', ').toString(),
        "userEmail",
        "userIC",
        "userPhoneno",
        "token",
        appVersion,
        appPlatform!,
        widget.data.fromWher, []);
  }

  _getInitSaleApi(BuildContext context) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await initTransactionApi(context).then((value) {
      EasyLoading.dismiss();
      setState(() {
        initSalesDTO = value;

        if (initSalesDTO!.error != null) {
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              initSalesDTO!.error!.displayMsg!,
              true,
              null,
              () => Navigator.of(context).pop());
        } else {
          Navigator.pushNamed(context, AppRoutes.reviewSummaryRoute,
              arguments: InitSalesTransactionArg(
                  locationId: widget.data.locationId,
                  hallId: widget.data.hallId,
                  showId: widget.data.showId,
                  cinemaName: widget.data.cinemaName,
                  filmId: widget.data.filmId,
                  initSalesDTO: initSalesDTO,
                  opsDate: widget.data.opsDate,
                  showDate: widget.data.showDate,
                  showTime: widget.data.showTime,
                  movieTitle: widget.data.movieTitle,
                  selectedCombo: [],
                  selectedTicket: selectedType,
                  seats: widget.data.seats,
                  ticketQty: widget.data.ticketQty,
                  seatTypeMap: widget.data.seatTypeMap,
                  isAurum: widget.data.isAurum));
        }
      });
    }, onError: (error) {
      EasyLoading.dismiss();
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          error != null
              ? error.toString().isNotEmpty
                  ? error.toString()
                  : Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          null, () {
        Navigator.of(context).pop();
      });
    }).whenComplete(() => setState(
          () {
            absorb = false;
          },
        ));
  }

  _getTicketInfo() async {
    EasyLoading.show();
    await getTicketType(context)
        .then((data) {
          setState(() {
            if (data.code != null && data.code == "-1") {
              Utils.showAlertDialog(
                  context,
                  Utils.getTranslated(context, "error_title"),
                  data.display_msg != null
                      ? data.display_msg ??
                          Utils.getTranslated(context, "general_error")
                      : Utils.getTranslated(context, "general_error"),
                  true,
                  widget.data.isAurum, () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            } else {
              if (data.ticketdata?.ticket != null) {
                if (data.ticketdata!.ticket!.isNotEmpty) {
                  data.ticketdata?.ticket?.first.bundle != null
                      ? bundleCodeExist = true
                      : null;
                  List category = [];
                  List ticketCat = [];
                  // List<TicketItemModel> ticketDTO =
                  //     data.ticketdata?.ticket ?? [];
                  // if(ticketDTO.isNotEmpty){

                  //   ticketDTO.removeWhere((element) => false)
                  // }
                  for (var element in data.ticketdata!.ticket!) {
                    ticketCat.add(element.seatcategory);
                    ticketType.add(TicketModel(
                      id: element.id,
                      qty: 0,
                      type: element.type,
                      price: element.price,
                      bundleCode:
                          element.bundle != null ? element.bundle!.code : null,
                      category: element.seatcategory,
                    ));
                  }
                  if (ticketType.isNotEmpty) {
                    widget.data.seatTypeMap!.forEach((key, value) {
                      if (value['qty'] > 0) {
                        category.add(value['category']);
                      }
                    });

                    ticketType.removeWhere(
                        (element) => !category.contains(element.category));
                  }
                  if (widget.data.seatTypeMap!.isNotEmpty) {
                    //   " Unable to find available ticket type. Please reselect your seat again."

                    widget.data.seatTypeMap!.forEach((key, value) {
                      if (value['qty'] > 0) {
                        if (!ticketCat.contains(value['category'])) {
                          Utils.showAlertDialog(
                              context,
                              Utils.getTranslated(context, "error_title"),
                              Utils.getTranslated(
                                  context, "mismatch_ticket_error"),
                              true,
                              widget.data.isAurum, () {
                            Navigator.of(context).pop();
                          });
                          isCheckOutDisabled = true;
                        } else {
                          var item = ticketType.firstWhere((element) =>
                              element.category == value['category']);

                          selectedType.add(TicketModel(
                              id: item.id,
                              qty: value['qty'],
                              type: item.type,
                              price: item.price,
                              bundleCode: item.bundleCode != null
                                  ? item.bundleCode!
                                  : null,
                              category: value['category']));
                        }
                      }
                    });
                  } else {
                    selectedType.add(TicketModel(
                        id: ticketType.first.id,
                        qty: widget.data.ticketQty,
                        type: ticketType.first.type,
                        price: ticketType.first.price,
                        bundleCode: ticketType.first.bundleCode,
                        category: ticketType.first.category));
                  }
                }
              } else {
                Utils.showAlertDialog(
                    context,
                    Utils.getTranslated(context, "error_title"),
                    Utils.getTranslated(context, "general_error"),
                    true,
                    widget.data.isAurum, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
              }

              if (data.econdata != null) {
                if (data.econdata!.status_code != 0) {
                  combo = data.econdata!.Product!.Combo!.toList();
                }
              }
            }
          });
        })
        .whenComplete(() => {EasyLoading.dismiss(), isLoading = true})
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              e != null
                  ? e.message ?? Utils.getTranslated(context, "general_error")
                  : Utils.getTranslated(context, "general_error"),
              true,
              widget.data.isAurum, () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
        });
  }

  String _formatPrice(double price) {
    var pricing = price.toStringAsFixed(2);
    return "RM " + pricing;
  }

  void postFrameCallback(_) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final double? _heightBtm = bottomDisplayKey.currentContext?.size?.height;
    final double? _heightUppr = topDisplayKey.currentContext?.size?.height;
    fillUpEmtpySpace = _heightBtm! + _heightUppr!;
    if (availableHeight > fillUpEmtpySpace!) {
      fillUpEmtpySpace = availableHeight;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 60,
          centerTitle: true,
          title: Text(Utils.getTranslated(context, 'confirm_ticket_type_title'),
              style: AppFont.montRegular(18, color: Colors.white)),
          leading: InkWell(
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child:
                  Image.asset(Constants.ASSET_IMAGES + 'white-left-icon.png')),
          backgroundColor: Colors.black,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: screenWidth,
          color: Colors.black,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: fillUpEmtpySpace ?? availableHeight,
                width: screenWidth,
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _upperDisplay(context, screenWidth),
                    _bottomDisplay(context, screenWidth)
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _upperDisplay(BuildContext context, double screenWidth) {
    return Container(
      key: topDisplayKey,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _seatDisplay(context, screenWidth),
          const SizedBox(
            height: 16,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: widget.data.isAurum != null
                ? widget.data.isAurum!
                    ? AppColor.aurumDay()
                    : AppColor.dividerColor()
                : AppColor.dividerColor(),
          ),
          const SizedBox(
            height: 16,
          ),
          _ticketDisplay(context, screenWidth)
        ],
      ),
    );
  }

  Widget _seatDisplay(BuildContext context, double screenWidth) {
    return SizedBox(
      width: screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.getTranslated(context, 'confirm_ticket_type_seat'),
              style: AppFont.montRegular(
                14,
                color: AppColor.greyWording(),
              )),
          const SizedBox(
            height: 6,
          ),
          Text(
            widget.data.seats.join(", "),
            style: AppFont.poppinsMedium(14,
                color: widget.data.isAurum != null
                    ? widget.data.isAurum!
                        ? AppColor.aurumGold()
                        : Colors.white
                    : Colors.white),
          )
        ],
      ),
    );
  }

  Widget _ticketDisplay(BuildContext context, double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.getTranslated(context, 'confirm_ticket_type_ticket'),
              style: AppFont.montRegular(
                14,
                color: AppColor.greyWording(),
              )),
          const SizedBox(
            height: 6,
          ),
          checkSelectedTicketData(context),
        ],
      ),
    );
  }

  Widget checkSelectedTicketData(
    BuildContext context,
  ) {
    bool isEmtpy = true;
    if (selectedType.isNotEmpty) {
      var totalSelectedQty = 0;
      for (var item in selectedType) {
        totalSelectedQty += item.qty ?? 0;
      }
      isEmtpy = totalSelectedQty != 0 ? false : true;
    }
    if (isEmtpy) {
      return Text(
          "N / A", // Utils.getTranslated(context, 'profile_value_ticket'),
          style: AppFont.poppinsMedium(14, color: Colors.white));
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var item in selectedType) _ticketDataDisplay(context, item)
        ],
      );
    }
  }

  Widget _ticketDataDisplay(BuildContext context, TicketModel item) {
    if (item.qty != 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.type! + " x " + item.qty.toString(),
            style: AppFont.poppinsMedium(14,
                color: widget.data.isAurum != null
                    ? widget.data.isAurum!
                        ? AppColor.aurumGold()
                        : Colors.white
                    : Colors.white),
          ),
          Text(
            _formatPrice(
                double.parse(item.price!) * double.parse(item.qty.toString())),
            style: AppFont.poppinsMedium(14,
                color: widget.data.isAurum != null
                    ? widget.data.isAurum!
                        ? AppColor.aurumGold()
                        : Colors.white
                    : Colors.white),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _bottomDisplay(BuildContext context, double screenWidth) {
    return Container(
        key: bottomDisplayKey,
        width: screenWidth,
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            color: AppColor.appSecondaryBlack()),
        child: Column(children: [
          for (int i = 0; i < ticketType.length; i++)
            _ticketType(context, ticketType[i], i),
          ticketType.isNotEmpty
              ? Divider(
                  thickness: 1,
                  height: 1,
                  color: widget.data.isAurum != null
                      ? widget.data.isAurum!
                          ? AppColor.aurumDay()
                          : AppColor.greyWording()
                      : AppColor.greyWording(),
                )
              : const SizedBox(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(top: 18.5),
            width: screenWidth,
            height: 50,
            child: AbsorbPointer(
              absorbing: absorb,
              child: TextButton(
                  onPressed: () async {
                    if (!isCheckOutDisabled) {
                      selectedType =
                          selectedType.where((map) => map.qty! > 0).toList();

                      bool isValid = await validationTicketType();
                      Utils.printInfo("IS AURUM: ${widget.data.isAurum}");
                      isValid
                          ? combo.isNotEmpty || bundleCodeExist
                              ? (widget.data.isAurum == true || bundleCodeExist)
                                  ? goAurum()
                                  : goEcombo()
                              : {
                                  setState(
                                    () {
                                      absorb = true;
                                    },
                                  ),
                                  _getInitSaleApi(context)
                                }
                          : null;
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isCheckOutDisabled
                        ? AppColor.checkOutDisabled()
                        : widget.data.isAurum != null
                            ? widget.data.isAurum!
                                ? AppColor.aurumGold()
                                : AppColor.appYellow()
                            : AppColor.appYellow(),
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    Utils.getTranslated(context, "confirm_btn"),
                    style: AppFont.montSemibold(14, color: Colors.black),
                  )),
            ),
          )
        ]));
  }

  goEcombo() {
    return Navigator.pushNamed(context, AppRoutes.comboSelectionScreen,
        arguments: ComboSelectionArguments(
            locationId: widget.data.locationId,
            showId: widget.data.showId,
            cinemaName: widget.data.cinemaName,
            hallId: widget.data.hallId,
            filmId: widget.data.filmId,
            opsDate: widget.data.opsDate,
            showDate: widget.data.showDate,
            showTime: widget.data.showTime,
            movieTitle: widget.data.movieTitle,
            comboList: combo,
            seats: widget.data.seats,
            ticketQty: widget.data.ticketQty,
            seatTypeMap: widget.data.seatTypeMap,
            selectedTicket: selectedType,
            fromWher: widget.data.fromWher,
            isAurum: widget.data.isAurum));
  }

  goAurum() {
    return Navigator.pushNamed(context, AppRoutes.aurumEcomboRoute,
        arguments: AurumEComboArgs(
            locationId: widget.data.locationId,
            showId: widget.data.showId,
            cinemaName: widget.data.cinemaName,
            hallId: widget.data.hallId,
            filmId: widget.data.filmId,
            opsDate: widget.data.opsDate,
            showDate: widget.data.showDate,
            showTime: widget.data.showTime,
            movieTitle: widget.data.movieTitle,
            comboList: combo,
            seats: widget.data.seats,
            ticketQty: widget.data.ticketQty,
            seatTypeMap: widget.data.seatTypeMap,
            selectedTicket: selectedType,
            fromWher: widget.data.fromWher,
            isAurum: widget.data.isAurum));
  }

  validationTicketType() {
    String errMsg = '';

    if (currentQty < widget.data.ticketQty) {
      errMsg = Utils.getTranslated(context, "confirm_ticket_insufficient_info")
          .replaceAll(RegExp(r'\<maxQty>'), widget.data.ticketQty.toString())
          .replaceAll(RegExp(r'\<totalTix>'), currentQty.toString());
    } else {
      widget.data.seatTypeMap!.forEach((key, value) {
        if (value['qty'] != 0) {
          if (value['category'] != "1") {
            TicketModel data = TicketModel();
            selectedType.any((e) => e.category == value['category'])
                ? data = selectedType
                    .firstWhere((e) => e.category == value['category'])
                : data = ticketType
                    .firstWhere((e) => e.category == value['category']);
            if (data.qty != value['qty']) {
              errMsg = Utils.getTranslated(
                      context, "confirm_ticket_insufficient_info_type")
                  .replaceAll(RegExp(r'\<maxQty>'), "${value['qty']}")
                  .replaceAll('<type>', "${data.type}")
                  .replaceAll(RegExp(r'\<totalTix>'), "${data.qty}");
            }
          } else {
            var totalCount = 0;
            for (var element in selectedType) {
              if (element.category == "1") {
                totalCount += element.qty ?? 0;
              }
            }
            if (totalCount != value['qty']) {
              errMsg = Utils.getTranslated(
                      context, "confirm_ticket_insufficient_info_type")
                  .replaceAll(RegExp(r'\<maxQty>'), "${value['qty']}")
                  .replaceAll('<type>', "Normal")
                  .replaceAll(RegExp(r'\<totalTix>'), totalCount.toString());
            }
          }
        }
      });
    }

    return errMsg.isEmpty
        ? true
        : showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "",
                message: errMsg,
                img: "attention-icon.png",
                showButton: false,
              );
            });
  }

  Widget _ticketType(BuildContext context, TicketModel ticketData, int idx) {
    int indexMatching = selectedType.indexWhere((e) => e.id == ticketData.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            ticketData.type != null ? ticketData.type! : "",
            style: AppFont.poppinsRegular(14, color: Colors.white),
          ),
          QuantityButton(
              isAurum:
                  widget.data.isAurum != null ? widget.data.isAurum! : false,
              initialQuantity: selectedType.isNotEmpty
                  ? indexMatching != -1
                      ? indexMatching <= selectedType.length - 1
                          ? selectedType[indexMatching].qty != null
                              ? selectedType[indexMatching].qty!
                              : 0
                          : 0
                      : 0
                  : 0,
              maxQuantity: widget.data.ticketQty,
              hasVariation: false,
              currentQuantity: currentQty,
              onQuantityChange: (qty) {
                setState(() {
                  ticketData.qty = qty;
                  if (selectedType
                      .where((element) => element.type == ticketData.type)
                      .isEmpty) {
                    selectedType.add(ticketData);
                  }

                  currentQty = 0;
                  for (var element in selectedType) {
                    if (element.type == ticketData.type) {
                      element.qty = qty;
                    }
                    currentQty += element.qty!;
                  }
                });
                return null;
              })
        ],
      ),
    );
  }
}
