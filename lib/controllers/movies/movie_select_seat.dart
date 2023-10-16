import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/seat_constant.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/movie_showtimes.dart';
import 'package:gsc_app/models/arguments/custom_show_model.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_seat_selection_model.dart';
import 'package:gsc_app/widgets/custom_dialog.dart';
import 'package:intl/intl.dart';

import '../../const/analytics_constant.dart';
import '../../models/arguments/buy_ticket_type_arguments.dart';
import '../../routes/approutes.dart';

class MovieHallSelectSeat extends StatefulWidget {
  final CustomShowModel data;
  final String title;
  final Child? movieChild;
  final String opsdate;
  final bool? isAurum;
  final String fromWher;
  const MovieHallSelectSeat(
      {Key? key,
      required this.data,
      required this.title,
      this.movieChild,
      required this.opsdate,
      required this.fromWher,
      this.isAurum})
      : super(key: key);

  @override
  State<MovieHallSelectSeat> createState() => _MovieHallSelectSeatState();
}

class _MovieHallSelectSeatState extends State<MovieHallSelectSeat> {
  var colDataPointer = -1;
  int maxColumnCount = 0;
  int? maxSeatCount;
  final zoomTransformationController = TransformationController();
  GlobalKey titleBarKey = GlobalKey();
  GlobalKey movieTitleNDetailsKey = GlobalKey();
  GlobalKey cinemaDetailsKey = GlobalKey();
  GlobalKey seatKey = GlobalKey();
  GlobalKey seatSelectedNLabelKey = GlobalKey();

  GlobalKey cinemaSeatingKey = GlobalKey();
  double? cinemaViewerHeight;
  Map<String, Map<String, dynamic>> seatTypeMap = {};
  double? seatWidgetHeight;
  List<String> selectedSeat = [];
  SeatSelectionDTO? seat;
  double currentZoomFactor = 100;
  dynamic movieDetails;
  List<List<String>> groupSeat = [];
  Sections? data;
  bool showGuideLines = false;
  bool isInit = false;
  dynamic guideLinesType;
  List existSeatStatus = [];

  List existSeatType = [];
  List<Category> category = [];

  Future<SeatSelectionDTO> getHallSeatDTO(
      BuildContext context,
      String locationID,
      String hallID,
      String showDate,
      String showTime) async {
    MovieShowtimes hallSeat = MovieShowtimes(context);
    return hallSeat.getHallSeating(locationID, hallID, showDate, showTime);
  }

  getHallSeating() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getHallSeatDTO(context, widget.data.locationID!, widget.data.hid!,
            widget.data.date!, widget.data.time!)
        .then((value) async {
      if (value.code != null && value.code == '-1') {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.display_msg != null
                ? value.display_msg ??
                    Utils.getTranslated(context, "general_error")
                : Utils.getTranslated(context, "general_error"),
            true,
            widget.isAurum, () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } else {
        seat = value;

        maxSeatCount = seat?.hall?.maximumseats != null
            ? int.parse(seat!.hall!.maximumseats!)
            : 0;

        data = seat?.hall?.section;
      }
    }).onError((error, stackTrace) {
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          Utils.getTranslated(context, "general_error"),
          true,
          widget.isAurum, () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    }).whenComplete(() async {
      EasyLoading.dismiss();
      // checkMaxSeat();
      await getColCaculation();
      setState(() {
        isInit = true;
      });
    });

    EasyLoading.dismiss();
  }

  checkMaxSeat() {
    if (maxSeatCount != null) {
      if (maxSeatCount == 0) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: Utils.getTranslated(context, 'error_title'),
                message: Utils.getTranslated(context, 'general_error'),
                img: widget.isAurum != null && widget.isAurum!
                    ? "aurum-attention.png"
                    : "attention-icon.png",
                showConfirm: true,
                showButton: true,
                isAurum: widget.isAurum,
                confirmStr: Utils.getTranslated(context, 'ok_btn'),
                onConfirm: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            });
      }
    } else {}
  }

  checkGuideLines() {
    if ((widget.data.typeDesc != null) ||
        widget.data.typeDesc!.contains("4DX") ||
        widget.data.typeDesc!.contains("DBOX") ||
        widget.data.typeDesc!.contains("PLAYPLUS")) {
      // var typeList =
      //     widget.data.typeDesc!.split("-").last.replaceAll(";", ",").split(',');
      var typeList = widget.data.typeDesc!.split(';');
      for (var i = 0; i < typeList.length; i++) {
        typeList[i] = typeList[i].split("-").last;
      }
      for (var d in typeList) {
        if (d.replaceAll(" ", "").toUpperCase() == "DBOX") {
          setState(() {
            showGuideLines = true;
            guideLinesType = d;
          });
        } else if (d.replaceAll(" ", "").toUpperCase() == "PLAYPLUS") {
          setState(() {
            showGuideLines = true;
            guideLinesType = d;
          });
        } else if (d.replaceAll(" ", "").toUpperCase() == "4D" ||
            d.replaceAll(" ", "").toUpperCase() == "EXTREME4DX" ||
            d.replaceAll(" ", "").toUpperCase() == "4DX" ||
            d.replaceAll(" ", "").toUpperCase() == "MX4D") {
          setState(() {
            showGuideLines = true;
            guideLinesType = d;
          });
        }
      }
    }
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SELECT_SEAT_SCREEN);

    super.initState();

    getHallSeating();
    checkGuideLines();
  }

  void increasePointer(List<Cols> data) {
    if (colDataPointer + 1 < data.length) {
      colDataPointer++;
    }
  }

  void resetPointer() {
    setState(() {
      colDataPointer = 0;
    });
  }

  void postFrameCallback(_) {
    setState(() {
      cinemaViewerHeight = cinemaSeatingKey.currentContext?.size?.height;

      isInit = false;
    });
  }

  void showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4,
              sigmaY: 4,
            ),
            child: CustomDialogBox(
              isAurum: widget.isAurum,
              title: "",
              message: Utils.getTranslated(context, "leave_gap_error_msg"),
              img: widget.isAurum != null && widget.isAurum!
                  ? "aurum-attention.png"
                  : "attention-icon.png",
            ),
          );
        });
  }

  void showAlertDialogMaxSeatSelection() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4,
              sigmaY: 4,
            ),
            child: CustomDialogBox(
              title: "",
              isAurum: widget.isAurum,
              message:
                  Utils.getTranslated(context, "max_seat_count_hit_error_msg")
                      .replaceAll("<number>", '${maxSeatCount ?? 0}'),
              img: widget.isAurum != null && widget.isAurum!
                  ? "aurum-attention.png"
                  : "attention-icon.png",
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    isInit
        ? SchedulerBinding.instance.addPostFrameCallback(postFrameCallback)
        : null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 0,
      ),
      body: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height + 500,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBar(context),
            movieTitleNDetails(context),
            cinemaDetails(context),
            seat != null && !isInit ? hallSeating(context) : Container(),
            seat != null ? seatSelectedNLabel(context) : Container(),
          ],
        ),
      ),
    );
  }

  Widget hallSeating(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: InteractiveViewer(
              key: seatKey,
              transformationController: zoomTransformationController,
              onInteractionEnd: (details) {
                setState(() {
                  currentZoomFactor =
                      zoomTransformationController.value.getMaxScaleOnAxis() *
                          100;
                  currentZoomFactor.roundToDouble();
                });
              },
              constrained: false,
              scaleFactor: 2,
              maxScale: 2,
              minScale: 1,
              child: Container(
                height: cinemaViewerHeight != null
                    ? cinemaViewerHeight! + 40
                    : cinemaViewerHeight,

                //  BoxConstraints.loose(Size(
                //   MediaQuery.of(context).size.width,
                //   500,
                // )),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Center(
                  child: Column(
                    key: cinemaSeatingKey,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      seat!.hall!.sponsorship!.appSponsor != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.53, 7, 8.53, 5.2),
                              child: Image.network(
                                seat!.hall!.sponsorship!.appSponsor!.imagepath!,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              ),
                            )
                          : SizedBox(
                              width: MediaQuery.of(context).size.width,
                            ),
                      for (var row = 0; row < data!.row!.length; row++)
                        getRow(context, data!.row![row], row),
                      Row(
                        children: [
                          for (var col = -1; col <= maxColumnCount; col++)
                            getColBtmNumbering(context, maxColumnCount, col)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          helperButton(),
        ],
      ),
    );
  }

  Widget getColBtmNumbering(BuildContext ctx, int colLength, int index) {
    double size = (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3;
    if (index != -1 && index++ != colLength) {
      return Container(
        margin: EdgeInsets.symmetric(
            horizontal: 1.5,
            vertical: (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
        height: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
        width: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
        child: Text(
          "${index++}",
          maxLines: 1,
          textAlign: TextAlign.center,
          style:
              AppFont.poppinsRegular(size * 0.6, color: AppColor.lightGrey()),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(
            horizontal: 1.5,
            vertical: (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
        height: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
        width: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
      );
    }
  }

  Widget helperButton() {
    return Positioned(
      top: 0,
      right: 16,
      child: Row(
        children: [
          resetButton(),
          const SizedBox(
            width: 20,
          ),
          zoomButton(),
        ],
      ),
    );
  }

  Widget resetButton() {
    return InkWell(
      onTap: () {
        setState(() {
          selectedSeat = [];
          seatTypeMap = {};
        });
      },
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + "info-icon.png",
              height: 10,
              width: 10,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              Utils.getTranslated(context, "reset"),
              style: AppFont.poppinsRegular(10, color: AppColor.greyWording()),
            ),
          ]),
    );
  }

  Widget zoomButton() {
    return InkWell(
      onTap: () {
        var isZoom = currentZoomFactor =
            zoomTransformationController.value.getMaxScaleOnAxis();
        if (isZoom >= 2 || isZoom + 1 > 2) {
          zoomTransformationController.value = Matrix4.identity();
        } else {
          zoomTransformationController.value = Matrix4.identity()
            ..setTranslationRaw(-seatKey.currentContext!.size!.width / 2,
                -seatKey.currentContext!.size!.height / 2, 0)
            ..scale(isZoom + 1);
        }
        currentZoomFactor =
            zoomTransformationController.value.getMaxScaleOnAxis() * 100;
        currentZoomFactor.roundToDouble();
        setState(() {});
      },
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + "zoom-icon.png",
              height: 10,
              width: 10,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              "${currentZoomFactor.toInt() - 100}%",
              style: AppFont.poppinsRegular(10, color: AppColor.greyWording()),
            ),
          ]),
    );
  }

  Widget displaySelectedSeat() {
    selectedSeat = Utils.sortAlphanumericSeat(selectedSeat);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        selectedSeat.isNotEmpty ? selectedSeat.join(", ") : '-',
        style: AppFont.montMedium(15,
            color: selectedSeat.isNotEmpty
                ? widget.isAurum != null
                    ? widget.isAurum!
                        ? AppColor.aurumGold()
                        : AppColor.appYellow()
                    : AppColor.appYellow()
                : AppColor.appYellow()),
      ),
    );
  }

  Widget seatSelectedNLabel(BuildContext context) {
    return Container(
      key: seatSelectedNLabelKey,
      decoration: BoxDecoration(
          color: AppColor.appSecondaryBlack(),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [for (var item in category) seatLabelItem(item)],
              ),
            ),
            const SizedBox(
              height: 18.5,
            ),
            Text(
              Utils.getTranslated(context, "seat_selection_text"),
              style: AppFont.montRegular(12, color: AppColor.greyWording()),
            ),
            displaySelectedSeat(),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: widget.isAurum != null
                        ? widget.isAurum!
                            ? AppColor.aurumDay()
                            : AppColor.greyWording()
                        : AppColor.greyWording(),
                  ),
                  InkWell(
                    onTap: () {
                      Utils.printInfo("SEAT TYPE MAP: $seatTypeMap");

                      showGuideLines
                          ? selectedSeat.isNotEmpty
                              ? {guideLineDialog(context)}
                              : null
                          : selectedSeat.isNotEmpty
                              ? Navigator.pushNamed(
                                  context, AppRoutes.buyMovieTicketTypeRoute,
                                  arguments: BuyTicketTypeArgs(
                                      opsDate: widget.opsdate,
                                      cinemaName:
                                          widget.data.locationDisplayName!,
                                      showId: widget.data.id!,
                                      movieTitle: widget.title,
                                      locationId: widget.data.locationID!,
                                      hallId: widget.data.hid!,
                                      filmId: widget.data.childID!,
                                      showDate: widget.data.date!,
                                      showTime: widget.data.time!,
                                      seats: selectedSeat,
                                      ticketQty: selectedSeat.length,
                                      fromWher: widget.fromWher,
                                      seatTypeMap: seatTypeMap,
                                      isAurum: widget.isAurum))
                              : null;
                    },
                    child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 20, top: 20),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(Utils.getTranslated(context, "confirm_btn"),
                                style: AppFont.montSemibold(14,
                                    color: Colors.black)),
                            Text(
                                ' - ${selectedSeat.length} ${Utils.getTranslated(context, "ticket_text")}',
                                style: AppFont.montRegular(14,
                                    color: Colors.black)),
                          ],
                        )),
                        decoration: BoxDecoration(
                            color: selectedSeat.isNotEmpty
                                ? widget.isAurum != null
                                    ? widget.isAurum!
                                        ? AppColor.aurumGold()
                                        : AppColor.appYellow()
                                    : AppColor.appYellow()
                                : AppColor.checkOutDisabled(),
                            borderRadius: BorderRadius.circular(6))),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  Widget seatLabelItem(Category item) {
    return SeatConstants.seatImage(
                SeatConstants.seatName[item.name?.toUpperCase()] ?? '',
                widget.isAurum != null
                    ? widget.isAurum!
                        ? true
                        : false
                    : false) !=
            ''
        ? Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14.5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: SeatConstants.seatLableColor(
                      SeatConstants.seatName[item.name!.toUpperCase()]!,
                      widget.isAurum != null
                          ? widget.isAurum!
                              ? true
                              : false
                          : false),
                )),
            child: Row(children: [
              Image.asset(
                SeatConstants.seatImage(
                    SeatConstants.seatName[item.name!.toUpperCase()]!,
                    widget.isAurum != null
                        ? widget.isAurum!
                            ? true
                            : false
                        : false),
                height: 18,
              ),
              const SizedBox(
                width: 7,
              ),
              Text(
                SeatConstants.showBooked.contains(item.name!.toUpperCase())
                    ? Utils.capitalizeEveryWord(
                        Utils.getTranslated(context, "occupied"))
                    : Utils.capitalizeEveryWord(item.name!),
                style:
                    AppFont.poppinsRegular(10, color: AppColor.greyWording()),
              ),
            ]),
          )
        : Container();
  }

  Container cinemaDetails(BuildContext context) {
    String? hallDisplayName;
    String displayDateTIme = '';

    if (widget.data.date == widget.opsdate) {
      displayDateTIme = "${widget.data.displayDate}, ${widget.data.timestr}";
    } else {
      var oprnDate =
          DateTime.parse(widget.data.date!).subtract(const Duration(days: 1));

      displayDateTIme =
          "${DateFormat("E d MMM").format(oprnDate)}, ${widget.data.timestr} (${widget.data.displayDate})";
    }
    if (widget.data.hname != null) {
      if (int.tryParse(widget.data.hname!) != null) {
        widget.data.hname!.toLowerCase().contains('hall')
            ? hallDisplayName = widget.data.hname!
            : hallDisplayName = "Hall ${widget.data.hname}";
      } else {
        hallDisplayName = widget.data.hname!;
      }
    }

    return Container(
      key: cinemaDetailsKey,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Image.asset(
                  Constants.ASSET_IMAGES + "location-icon.png",
                  height: 18,
                  width: 18,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  "${widget.data.locationDisplayName}",
                  style: AppFont.poppinsRegular(12, color: Colors.white),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Image.asset(
                  Constants.ASSET_IMAGES + "hall-icon.png",
                  height: 18,
                  width: 18,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  "$hallDisplayName",
                  style: AppFont.poppinsRegular(12, color: Colors.white),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Image.asset(
                  Constants.ASSET_IMAGES + "booking-time-icon.png",
                  height: 18,
                  width: 18,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  displayDateTIme,
                  style: AppFont.poppinsRegular(12, color: Colors.white),
                ),
              ]),
            ),
            Divider(
              thickness: 1,
              color: widget.isAurum != null
                  ? widget.isAurum!
                      ? AppColor.aurumDay()
                      : AppColor.greyWording()
                  : AppColor.greyWording(),
            )
          ]),
    );
  }

  Container movieTitleNDetails(BuildContext context) {
    return Container(
      key: movieTitleNDetailsKey,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      width: MediaQuery.of(context).size.width,
      color: widget.isAurum != null
          ? widget.isAurum!
              ? AppColor.aurumGold()
              : AppColor.appYellow()
          : AppColor.appYellow(),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Center(
                child: Text(
                  widget.title,
                  style: AppFont.montBold(14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.movieChild!.rating != "NA"
                      ? Text(
                          "${widget.movieChild!.rating}",
                          style:
                              AppFont.poppinsRegular(12, color: Colors.black),
                        )
                      : Container(),
                  widget.movieChild!.rating != "NA"
                      ? Text(
                          "  |  ",
                          style:
                              AppFont.poppinsRegular(12, color: Colors.black),
                        )
                      : Container(),
                  Text(
                    Utils.formatDuration(widget.movieChild!.duration!),
                    style: AppFont.poppinsRegular(12, color: Colors.black),
                  ),
                  Text(
                    "  |  ",
                    style: AppFont.poppinsRegular(12, color: Colors.black),
                  ),
                  Text(
                    "${widget.data.type}",
                    style: AppFont.poppinsRegular(12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  Container titleBar(BuildContext context) {
    return Container(
      key: titleBarKey,
      width: MediaQuery.of(context).size.width,
      height: kToolbarHeight,
      color: Colors.black,
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16),
          child: InkWell(
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Image.asset('assets/images/white-left-icon.png')),
        ),
        Center(
          child: Text(
            Utils.getTranslated(context, "select_seats"),
            style: AppFont.montRegular(18, color: Colors.white),
          ),
        ),
      ]),
    );
  }

  getRow(BuildContext ctx, Rows data, int rowIndex) {
    resetPointer();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var col = -1; col <= maxColumnCount; col++)
          getColumns(ctx, col, rowIndex, data.col!, maxColumnCount,
              colDataPointer, data.value!)
      ],
    );
  }

  getColCaculation() {
    var typeList = [];
    var statusList = [];
    for (var data in data!.row!) {
      for (var col in data.col!) {
        if (int.parse(col.x!) > maxColumnCount) {
          maxColumnCount = int.parse(col.x!);
        }
        !statusList.contains(col.status) ? statusList.add(col.status) : null;
        !typeList.contains(col.type) ? typeList.add(col.type) : null;
      }
    }

    statusList.forEach((e) {
      if (SeatConstants.seatStatus[e] != SeatConstants.NORMAL) {
        !existSeatStatus.contains(SeatConstants.seatStatus[e])
            ? existSeatStatus.add(SeatConstants.seatStatus[e])
            : null;
      }
    });
    typeList.add("S"); //to show selected seat label
    typeList.forEach((e) {
      !existSeatType.contains(SeatConstants.seatCode[e])
          ? existSeatType.add(SeatConstants.seatCode[e])
          : null;
    });

    for (var element in seat!.hall!.mappings!.category!) {
      if (existSeatStatus.contains((element.name ?? '').toUpperCase())) {
        if (!category
            .any((e) => e.name == (element.name ?? '').toUpperCase())) {
          category.add(element);
        }
      }
      if (existSeatType.contains((element.name ?? '').toUpperCase())) {
        if (!category
            .any((e) => e.name == (element.name ?? '').toUpperCase())) {
          category.add(element);
        }
      }
    }

    if (category
            .where((element) => SeatConstants.showBooked
                .contains((element.name ?? '').toUpperCase()))
            .length >
        1) {
      Category stored = category.firstWhere((element) => SeatConstants
          .showBooked
          .contains((element.name ?? '').toUpperCase()));

      category.removeWhere((element) => SeatConstants.showBooked
          .contains((element.name ?? '').toUpperCase()));

      category.add(stored);
    }

    maxColumnCount++;
  }

  getColumns(BuildContext ctx, int index, int rowIndex, List<Cols> colData,
      int colLength, int pointer, String key) {
    double size = (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3;
    bool isSeat =
        (int.parse(colData[pointer].x!) == index) && (pointer < colData.length);
    if (isSeat) {
      increasePointer(colData);
      return getSeatByStatus(
          key, index, colData, rowIndex, pointer, ctx, colLength, size);
    } else if (index == -1 || index == maxColumnCount) {
      return Container(
        margin: EdgeInsets.symmetric(
            horizontal: 1.5,
            vertical: (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
        height: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
        width: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
        child: Text(
          key,
          maxLines: 1,
          textAlign: TextAlign.center,
          style:
              AppFont.poppinsRegular(size * 0.6, color: AppColor.lightGrey()),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(
            horizontal: 1.5,
            vertical: (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
        height: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
        decoration: const BoxDecoration(color: Colors.black),
        width: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
      );
    }
  }

  Widget getSeatByStatus(String key, int colIndex, List<Cols> colData,
      int rowIndex, int pointer, BuildContext ctx, int colLength, double size) {
    String seatStatus =
        SeatConstants.seatStatus[colData[pointer].status?.toUpperCase()] ??
            SeatConstants.NORMAL;
    //  seat!.hall!.mappings!.category!;
    switch (seatStatus) {
      case SeatConstants.OCCUPIED:
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: 1.5,
              vertical:
                  (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
          child: Image.asset(
            Constants.ASSET_IMAGES + "booked-icon.png",
            width: size,
            height: size,
            scale: 0.55,
          ),
        );
      case SeatConstants.LOCKSEATS:
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: 1.5,
              vertical:
                  (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
          child: Image.asset(
            Constants.ASSET_IMAGES + "booked-icon.png",
            width: size,
            height: size,
            scale: 0.55,
          ),
        );

      case SeatConstants.REPAIR:
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: 1.5,
              vertical:
                  (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
          child: Image.asset(
            Constants.ASSET_IMAGES + "aurum_seat_underepair_icon.png",
            width: size,
            height: size,
            scale: 0.55,
          ),
        );
      case SeatConstants.BLOCKSEAT:
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: 1.5,
              vertical:
                  (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
          child: Image.asset(
            Constants.ASSET_IMAGES + "blocked-seat-icon.png",
            width: size,
            height: size,
            scale: 0.55,
          ),
        );
      default:
        return getSeatByType(
            key, colData, rowIndex, colIndex, pointer, ctx, colLength, size);
    }
  }

  Widget getSeatByType(String key, List<Cols> colData, int rowIndex,
      int colIndex, int pointer, BuildContext ctx, int colLength, double size) {
    List<String> includedSeat = [];
    bool isConnected = false;

    int seatTaken = 1;

    String seatName = seat!.hall!.mappings!.category!
            .any((element) => colData[pointer].seatcategory == element.id)
        ? SeatConstants.seatName[seat!.hall!.mappings!.category!
                .firstWhere(
                    (element) => colData[pointer].seatcategory == element.id)
                .name
                ?.toUpperCase()] ??
            SeatConstants.NORMAL
        : SeatConstants.NORMAL;

    seatName != SeatConstants.BEANBAG
        ? seat!.hall!.mappings!.category!.any((element) =>
                SeatConstants.seatMap[element.id] == seatName ||
                SeatConstants.seatCode[element.seat!.type] == seatName)
            ? seatTaken = int.parse(seat?.hall?.mappings?.category
                    ?.firstWhere((element) =>
                        element.id == colData[pointer].seatcategory)
                    .seatsTaken ??
                seat?.hall?.mappings?.category
                    ?.firstWhere((element) =>
                        element.seat!.type == colData[pointer].type)
                    .seatsTaken ??
                '1')
            : null
        : 1;

    if (seatTaken != 1) {
      if (!groupSeat.any((element) =>
          element.contains("$key${colData[pointer].value.toString()}"))) {
        List<String> temp = [];
        temp.add("$key${data!.row![rowIndex].col![pointer].value}");
        for (var x = 0; x < seatTaken; x++) {
          if (!temp.contains(
              "$key${data!.row![rowIndex].col![pointer + x].value}")) {
            temp.add("$key${data!.row![rowIndex].col![pointer + x].value}");
          }
        }

        groupSeat.add(temp);
      }
      includedSeat = groupSeat.firstWhere((element) =>
          element.contains("$key${colData[pointer].value.toString()}"));

      if (includedSeat.any((element) =>
              element.contains("$key${colData[pointer].value.toString()}")) &&
          pointer > 0) {
        var index =
            includedSeat.indexOf("$key${colData[pointer].value.toString()}");

        if (index != 0 ||
            ("$key${colData[pointer].value.toString()}" ==
                "$key${colData[pointer - 1].value.toString()}")) {
          isConnected = true;
        }
      }
    }

    // print(includedSeat);

    // return !isConnected
    //     ? GestureDetector(
    //         onTap: () async {
    //           if (seatTaken == 1) {
    //             if (selectedSeat.length > maxSeatCount! ||
    //                 selectedSeat.length + 1 > maxSeatCount!) {
    //               if (!selectedSeat
    //                   .contains("$key${colData[pointer].value.toString()}")) {
    //                 showAlertDialogMaxSeatSelection();
    //               } else {
    //                 final gotGap = await checkGapForRemoveSeat(
    //                   colData,
    //                   pointer,
    //                   key,
    //                 );

    //                 if (gotGap is bool && gotGap) {
    //                   showAlertDialog();
    //                 } else {
    //                   seatTypeMap.update(
    //                       colData[pointer].type!,
    //                       (value) => {
    //                             "category": colData[pointer].seatcategory!,
    //                             "qty": value['qty'] - 1,
    //                           },
    //                       ifAbsent: () => {
    //                             "category": colData[pointer].seatcategory!,
    //                             "qty": 0,
    //                           });
    //                   selectedSeat.removeWhere((element) =>
    //                       element ==
    //                       "$key${colData[pointer].value.toString()}");
    //                 }
    //               }
    //             } else {
    //               if (!selectedSeat
    //                   .contains("$key${colData[pointer].value.toString()}")) {
    //                 final gotGap = await checkGap(colData, pointer, key);

    //                 if (gotGap is bool && gotGap) {
    //                   showAlertDialog();
    //                 } else {
    //                   seatTypeMap.update(
    //                       colData[pointer].type!,
    //                       (value) => {
    //                             "category": colData[pointer].seatcategory!,
    //                             "qty": value['qty'] + 1,
    //                           },
    //                       ifAbsent: () => {
    //                             "category": colData[pointer].seatcategory!,
    //                             "qty": 1,
    //                           });
    //                   selectedSeat
    //                       .add("$key${colData[pointer].value.toString()}");
    //                 }
    //               } else {
    //                 final gotGap = await checkGapForRemoveSeat(
    //                   colData,
    //                   pointer,
    //                   key,
    //                 );

    //                 if (gotGap is bool && gotGap) {
    //                   showAlertDialog();
    //                 } else {
    //                   seatTypeMap.update(
    //                       colData[pointer].type!,
    //                       (value) => {
    //                             "category": colData[pointer].seatcategory!,
    //                             "qty": value['qty'] - 1,
    //                           },
    //                       ifAbsent: () => {
    //                             "category": colData[pointer].seatcategory!,
    //                             "qty": 0,
    //                           });
    //                   selectedSeat.removeWhere((element) =>
    //                       element ==
    //                       "$key${colData[pointer].value.toString()}");
    //                 }
    //               }
    //             }
    //           } else {
    //             if (selectedSeat.length > maxSeatCount! ||
    //                 selectedSeat.length + seatTaken > maxSeatCount!) {
    //               if (selectedSeat
    //                   .contains("$key${colData[pointer].value.toString()}")) {
    //                 selectedSeat.removeWhere(
    //                     (element) => includedSeat.contains(element));

    //                 seatTypeMap.update(
    //                     colData[pointer].type!,
    //                     (value) => {
    //                           "category": colData[pointer].seatcategory!,
    //                           "qty": value['qty'] - seatTaken,
    //                         },
    //                     ifAbsent: () => {
    //                           "category": colData[pointer].seatcategory!,
    //                           "qty": 0,
    //                         });
    //               } else {
    //                 showAlertDialogMaxSeatSelection();
    //               }
    //             } else {
    //               if (!selectedSeat
    //                   .contains("$key${colData[pointer].value.toString()}")) {
    //                 selectedSeat.addAll(includedSeat);
    //                 seatTypeMap.update(
    //                     colData[pointer].type!,
    //                     (value) => {
    //                           "category": colData[pointer].seatcategory!,
    //                           "qty": value['qty'] + seatTaken,
    //                         },
    //                     ifAbsent: () => {
    //                           "category": colData[pointer].seatcategory!,
    //                           "qty": seatTaken,
    //                         });
    //               } else {
    //                 selectedSeat.removeWhere(
    //                     (element) => includedSeat.contains(element));
    //                 seatTypeMap.update(
    //                     colData[pointer].type!,
    //                     (value) => {
    //                           "category": colData[pointer].seatcategory!,
    //                           "qty": value['qty'] - seatTaken,
    //                         },
    //                     ifAbsent: () => {
    //                           "category": colData[pointer].seatcategory!,
    //                           "qty": 0,
    //                         });
    //               }
    //             }
    //           }
    //           setState(() {});
    //         },
    //         child: Container(
    //           margin: EdgeInsets.symmetric(
    //               horizontal: 1.5,
    //               vertical:
    //                   (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
    //           child: Image.asset(
    //               selectedSeat
    //                       .contains("$key${colData[pointer].value.toString()}")
    //                   ? widget.isAurum != null
    //                       ? widget.isAurum!
    //                           ? Constants.ASSET_IMAGES +
    //                               "Aurum Selected 4 Seater_icon_active.png"
    //                           : Constants.ASSET_IMAGES +
    //                               "4 Seater Selected_icon.png"
    //                       : Constants.ASSET_IMAGES +
    //                           "4 Seater Selected_icon.png"
    //                   : SeatConstants.seatImage(
    //                       seatCat, widget.isAurum ?? false),
    //               width: MediaQuery.of(ctx).size.width /
    //                       (colLength + 2) *
    //                       seatTaken -
    //                   3,
    //               height: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
    //               fit: BoxFit.fill),
    //         ),
    //       )
    //     : Container();
    switch (seatName) {
      case SeatConstants.RECLINER:
        return GestureDetector(
          onTap: () async {
            if (selectedSeat.length > maxSeatCount! ||
                selectedSeat.length + 1 > maxSeatCount!) {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                showAlertDialogMaxSeatSelection();
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            } else {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                final gotGap = await checkGap(colData, pointer, key);

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] + 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 1,
                          });
                  selectedSeat.add("$key${colData[pointer].value.toString()}");
                }
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            }

            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            child: Image.asset(
              selectedSeat.contains("$key${colData[pointer].value.toString()}")
                  ? widget.isAurum != null
                      ? widget.isAurum!
                          ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
                          : Constants.ASSET_IMAGES +
                              "selected_yellow_seat_icon.png"
                      : Constants.ASSET_IMAGES + "selected_yellow_seat_icon.png"
                  : Constants.ASSET_IMAGES + "aurum-seat-icon.png",
              width: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
              height: size,
              fit: BoxFit.fill,
            ),
          ),
        );

      case SeatConstants.CHAISE:
        return GestureDetector(
          onTap: () async {
            if (selectedSeat.length > maxSeatCount! ||
                selectedSeat.length + 1 > maxSeatCount!) {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                showAlertDialogMaxSeatSelection();
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            } else {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                final gotGap = await checkGap(colData, pointer, key);

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] + 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 1,
                          });
                  selectedSeat.add("$key${colData[pointer].value.toString()}");
                }
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            }

            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            child: Image.asset(
              selectedSeat.contains("$key${colData[pointer].value.toString()}")
                  ? widget.isAurum != null
                      ? widget.isAurum!
                          ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
                          : Constants.ASSET_IMAGES +
                              "selected_yellow_seat_icon.png"
                      : Constants.ASSET_IMAGES + "selected_yellow_seat_icon.png"
                  : Constants.ASSET_IMAGES + "aurum_ps_seat_icon.png",
              width: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
              height: size,
              fit: BoxFit.fill,
            ),
          ),
        );

      case SeatConstants.SUITE:
        return GestureDetector(
          onTap: () async {
            if (selectedSeat.length > maxSeatCount! ||
                selectedSeat.length + 1 > maxSeatCount!) {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                showAlertDialogMaxSeatSelection();
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            } else {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                final gotGap = await checkGap(colData, pointer, key);

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] + 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 1,
                          });
                  selectedSeat.add("$key${colData[pointer].value.toString()}");
                }
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            }

            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            child: Image.asset(
              selectedSeat.contains("$key${colData[pointer].value.toString()}")
                  ? widget.isAurum != null
                      ? widget.isAurum!
                          ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
                          : Constants.ASSET_IMAGES +
                              "selected_yellow_seat_icon.png"
                      : Constants.ASSET_IMAGES + "selected_yellow_seat_icon.png"
                  : Constants.ASSET_IMAGES + "aurum_getha_seat_icon.png",
              width: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
              height: size,
              fit: BoxFit.fill,
            ),
          ),
        );
      case SeatConstants.BEANBAG:
        return GestureDetector(
          onTap: () async {
            if (selectedSeat.length > maxSeatCount! ||
                selectedSeat.length + 1 > maxSeatCount!) {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                showAlertDialogMaxSeatSelection();
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            } else {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                final gotGap = await checkGap(colData, pointer, key);

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] + 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 1,
                          });
                  selectedSeat.add("$key${colData[pointer].value.toString()}");
                }
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            }

            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            child: Image.asset(
              selectedSeat.contains("$key${colData[pointer].value.toString()}")
                  ? widget.isAurum != null
                      ? widget.isAurum!
                          ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
                          : Constants.ASSET_IMAGES +
                              "selected_yellow_seat_icon.png"
                      : Constants.ASSET_IMAGES + "selected_yellow_seat_icon.png"
                  : Constants.ASSET_IMAGES + "beanbag_icon.png",
              width: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
              height: size,
              fit: BoxFit.fill,
            ),
          ),
        );

      case SeatConstants.CABIN:
        return GestureDetector(
          onTap: () async {
            if (selectedSeat.length > maxSeatCount! ||
                selectedSeat.length + 1 > maxSeatCount!) {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                showAlertDialogMaxSeatSelection();
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            } else {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                final gotGap = await checkGap(colData, pointer, key);

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] + 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 1,
                          });
                  selectedSeat.add("$key${colData[pointer].value.toString()}");
                }
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            }

            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            child: Image.asset(
              selectedSeat.contains("$key${colData[pointer].value.toString()}")
                  ? widget.isAurum != null
                      ? widget.isAurum!
                          ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
                          : Constants.ASSET_IMAGES +
                              "selected_yellow_seat_icon.png"
                      : Constants.ASSET_IMAGES + "selected_yellow_seat_icon.png"
                  : Constants.ASSET_IMAGES + "aurum_cabin_seat_icon.png",
              width: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
              height: size,
              fit: BoxFit.fill,
            ),
          ),
        );
      case SeatConstants.LOUNGER:
        return GestureDetector(
          onTap: () async {
            if (selectedSeat.length > maxSeatCount! ||
                selectedSeat.length + 1 > maxSeatCount!) {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                showAlertDialogMaxSeatSelection();
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            } else {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                final gotGap = await checkGap(colData, pointer, key);

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] + 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 1,
                          });
                  selectedSeat.add("$key${colData[pointer].value.toString()}");
                }
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            }

            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            child: Image.asset(
              selectedSeat.contains("$key${colData[pointer].value.toString()}")
                  ? widget.isAurum != null
                      ? widget.isAurum!
                          ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
                          : Constants.ASSET_IMAGES +
                              "selected_yellow_seat_icon.png"
                      : Constants.ASSET_IMAGES + "selected_yellow_seat_icon.png"
                  : Constants.ASSET_IMAGES + "lounger_icon.png",
              width: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
              height: size,
              fit: BoxFit.fill,
            ),
          ),
        );
      case SeatConstants.FOURSEATER:
        return !isConnected
            ? GestureDetector(
                onTap: () {
                  if (selectedSeat.length > maxSeatCount! ||
                      selectedSeat.length + includedSeat.length >
                          maxSeatCount!) {
                    if (selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));

                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - seatTaken,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    } else {
                      showAlertDialogMaxSeatSelection();
                    }
                  } else {
                    if (!selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.addAll(includedSeat);

                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] + seatTaken,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": seatTaken,
                              });
                    } else {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));
                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - seatTaken,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    }
                  }

                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical:
                          (MediaQuery.of(ctx).size.width / (colLength + 2)) *
                              0.1),
                  child: Image.asset(
                    selectedSeat.contains(
                            "$key${colData[pointer].value.toString()}")
                        ? widget.isAurum != null
                            ? widget.isAurum!
                                ? Constants.ASSET_IMAGES +
                                    "Aurum Selected 4 Seater_icon_active.png"
                                : Constants.ASSET_IMAGES +
                                    "4 Seater Selected_icon.png"
                            : Constants.ASSET_IMAGES +
                                "4 Seater Selected_icon.png"
                        : Constants.ASSET_IMAGES + "aurum-4seats.png",
                    width: MediaQuery.of(ctx).size.width /
                            (colLength + 2) *
                            seatTaken -
                        3,
                    height: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
                    fit: BoxFit.fill,
                  ),
                ),
              )
            : Container();
      case SeatConstants.CUDDLECOUCH:
        return !isConnected
            ? GestureDetector(
                onTap: () {
                  if (selectedSeat.length > maxSeatCount! ||
                      selectedSeat.length + includedSeat.length >
                          maxSeatCount!) {
                    if (selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));

                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - seatTaken,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    } else {
                      showAlertDialogMaxSeatSelection();
                    }
                  } else {
                    if (!selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.addAll(includedSeat);
                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] + seatTaken,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": seatTaken,
                              });
                    } else {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));

                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - seatTaken,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    }
                  }

                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical:
                          (MediaQuery.of(ctx).size.width / (colLength + 2)) *
                              0.1),
                  child: Image.asset(
                    selectedSeat.contains(
                            "$key${colData[pointer].value.toString()}")
                        ? widget.isAurum != null
                            ? widget.isAurum!
                                ? Constants.ASSET_IMAGES +
                                    "Aurum Selected 4 Seater_icon_active.png"
                                : Constants.ASSET_IMAGES +
                                    "4 Seater Selected_icon.png"
                            : Constants.ASSET_IMAGES +
                                "4 Seater Selected_icon.png"
                        : Constants.ASSET_IMAGES + "cuddlecouch_icon.png",
                    width: MediaQuery.of(ctx).size.width /
                            (colLength + 2) *
                            seatTaken -
                        3,
                    height: MediaQuery.of(ctx).size.width / (colLength + 2) - 3,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
            : Container();
      case SeatConstants.TWINSOFA:
        return !isConnected
            ? GestureDetector(
                onTap: () {
                  if (selectedSeat.length > maxSeatCount! ||
                      selectedSeat.length + 2 > maxSeatCount!) {
                    if (selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));

                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - 2,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    } else {
                      showAlertDialogMaxSeatSelection();
                    }
                  } else {
                    if (!selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.addAll(includedSeat);
                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] + 2,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 2,
                              });
                    } else {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));
                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - 2,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    }
                  }

                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical:
                          (MediaQuery.of(ctx).size.width / (colLength + 2)) *
                              0.1),
                  child: Image.asset(
                    selectedSeat.contains(
                            "$key${colData[pointer].value.toString()}")
                        ? Constants.ASSET_IMAGES + "selected_twin_seat_icon.png"
                        : Constants.ASSET_IMAGES + "aurum-recliner-seat.png",
                    width:
                        MediaQuery.of(ctx).size.width / (colLength + 2) * 2 - 3,
                    height: size,
                    fit: BoxFit.fill,
                  ),
                ),
              )
            : Container();

      case SeatConstants.TWIN:
        return !isConnected
            ? GestureDetector(
                onTap: () {
                  if (selectedSeat.length > maxSeatCount! ||
                      selectedSeat.length + 2 > maxSeatCount!) {
                    if (selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));
                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - 2,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    } else {
                      showAlertDialogMaxSeatSelection();
                    }
                  } else {
                    if (!selectedSeat
                        .contains("$key${colData[pointer].value.toString()}")) {
                      selectedSeat.addAll(includedSeat);
                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] + 2,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 2,
                              });
                    } else {
                      selectedSeat.removeWhere(
                          (element) => includedSeat.contains(element));
                      seatTypeMap.update(
                          colData[pointer].type!,
                          (value) => {
                                "category": colData[pointer].seatcategory!,
                                "qty": value['qty'] - 2,
                              },
                          ifAbsent: () => {
                                "category": colData[pointer].seatcategory!,
                                "qty": 0,
                              });
                    }
                  }

                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical:
                          (MediaQuery.of(ctx).size.width / (colLength + 2)) *
                              0.1),
                  child: Image.asset(
                    selectedSeat.contains(
                            "$key${colData[pointer].value.toString()}")
                        ? Constants.ASSET_IMAGES + "selected_twin_seat_icon.png"
                        : Constants.ASSET_IMAGES + "twin-seat-icon.png",
                    width:
                        MediaQuery.of(ctx).size.width / (colLength + 2) * 2 - 3,
                    height: size,
                    fit: BoxFit.fill,
                  ),
                ),
              )
            : Container();
      case SeatConstants.RESERVATION:
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: 1.5,
              vertical:
                  (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
          child: Image.asset(
            Constants.ASSET_IMAGES + "booked-icon.png",
            width: size,
            height: size,
            scale: 0.55,
          ),
        );
      case SeatConstants.BLOCKSEAT:
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: 1.5,
              vertical:
                  (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
          child: Image.asset(
            Constants.ASSET_IMAGES + "blocked-seat-icon.png",
            width: size,
            height: size,
            scale: 0.55,
          ),
        );
      case SeatConstants.VIP:
        return InkWell(
          onTap: () async {
            if (!selectedSeat
                .contains("$key${colData[pointer].value.toString()}")) {
              final gotGap = await checkGap(colData, pointer, key);

              if (gotGap is bool && gotGap) {
                showAlertDialog();
              } else {
                seatTypeMap.update(
                    colData[pointer].type!,
                    (value) => {
                          "category": colData[pointer].seatcategory!,
                          "qty": value['qty'] + 1,
                        },
                    ifAbsent: () => {
                          "category": colData[pointer].seatcategory!,
                          "qty": 1,
                        });
                selectedSeat.add("$key${colData[pointer].value.toString()}");
              }
            } else {
              final gotGap = await checkGapForRemoveSeat(
                colData,
                pointer,
                key,
              );

              if (gotGap is bool && gotGap) {
                showAlertDialog();
              } else {
                seatTypeMap.update(
                    colData[pointer].type!,
                    (value) => {
                          "category": colData[pointer].seatcategory!,
                          "qty": value['qty'] - 1,
                        },
                    ifAbsent: () => {
                          "category": colData[pointer].seatcategory!,
                          "qty": 0,
                        });
                selectedSeat.removeWhere((element) =>
                    element == "$key${colData[pointer].value.toString()}");
              }
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            child: Image.asset(
              Constants.ASSET_IMAGES + "VIP seat_icon.png",
              width: size,
              height: size,
              scale: 0.55,
            ),
          ),
        );
      case SeatConstants.HOUSESEAT:
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: 1.5,
              vertical:
                  (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
          child: Image.asset(
            Constants.ASSET_IMAGES + "booked-icon.png",
            width: size,
            height: size,
            scale: 0.55,
          ),
        );
      case SeatConstants.WHEELCHAIR:
        return GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            height: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
            width: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
            child: Image.asset(Constants.ASSET_IMAGES + "oku-seat-icon.png",
                width: size, height: size, scale: 0.55, fit: BoxFit.fill),
          ),
        );

      default:
        return GestureDetector(
          onTap: () async {
            if (selectedSeat.length > maxSeatCount! ||
                selectedSeat.length + 1 > maxSeatCount!) {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                showAlertDialogMaxSeatSelection();
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            } else {
              if (!selectedSeat
                  .contains("$key${colData[pointer].value.toString()}")) {
                final gotGap = await checkGap(colData, pointer, key);

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] + 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 1,
                          });
                  selectedSeat.add("$key${colData[pointer].value.toString()}");
                }
              } else {
                final gotGap = await checkGapForRemoveSeat(
                  colData,
                  pointer,
                  key,
                );

                if (gotGap is bool && gotGap) {
                  showAlertDialog();
                } else {
                  seatTypeMap.update(
                      colData[pointer].type!,
                      (value) => {
                            "category": colData[pointer].seatcategory!,
                            "qty": value['qty'] - 1,
                          },
                      ifAbsent: () => {
                            "category": colData[pointer].seatcategory!,
                            "qty": 0,
                          });
                  selectedSeat.removeWhere((element) =>
                      element == "$key${colData[pointer].value.toString()}");
                }
              }
            }

            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical:
                    (MediaQuery.of(ctx).size.width / (colLength + 2)) * 0.1),
            height: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
            width: (MediaQuery.of(ctx).size.width / (colLength + 2)) - 3,
            decoration: BoxDecoration(
              color: selectedSeat
                      .contains("$key${colData[pointer].value.toString()}")
                  ? widget.isAurum != null
                      ? widget.isAurum!
                          ? AppColor.aurumGold()
                          : AppColor.appYellow()
                      : AppColor.appYellow()
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(
              '$key${colData[pointer].value}',
              style: AppFont.poppinsRegular(size * 0.40, color: Colors.black),
              maxLines: 1,
            )),
          ),
        );
    }
  }

  checkGapForRemoveSeat(List<Cols> data, int index, String seatRow) {
    List invalidSeatStatus = ["B", "T", "D", "X"];
    List invalidSeatType = ["W", "R", "H", "X"];
    bool left1 = data.asMap().containsKey(index - 1);
    bool right1 = data.asMap().containsKey(index + 1);
    bool isConnectedLeft1 = left1
        ? (int.parse(data[index].x!) - 1 == int.parse(data[index - 1].x!))
        : false;
    bool isConnectedRight1 = right1
        ? (int.parse(data[index].x!) + 1 == int.parse(data[index + 1].x!))
        : false;

    bool isLeft1Valid = left1 && isConnectedLeft1
        ? !(invalidSeatType.contains(data[index - 1].type!) ||
            invalidSeatStatus.contains(data[index - 1].status!))
        : false;
    bool isRight1Valid = right1 && isConnectedRight1
        ? !(invalidSeatType.contains(data[index + 1].type!) ||
            invalidSeatStatus.contains(data[index + 1].status!))
        : false;

    bool containsLeft1 = isLeft1Valid
        ? selectedSeat.contains("$seatRow${data[index - 1].value}")
        : false;
    bool containsRight1 = isRight1Valid
        ? selectedSeat.contains("$seatRow${data[index + 1].value}")
        : false;

    if (isRight1Valid) {
      if (containsRight1) {
        if (isLeft1Valid) {
          if (containsLeft1) {
            return true;
          } else {
            return false;
          }
        } else {
          return isConnectedLeft1 ? true : false;
        }
      } else {
        return false;
      }
    } else {
      if (isLeft1Valid) {
        if (containsLeft1) {
          if (isRight1Valid) {
            if (containsRight1) {
              return true;
            } else {
              return false;
            }
          } else {
            return isConnectedRight1 ? true : false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  checkGap(List<Cols> data, int index, String seatRow) {
    List invalidSeatStatus = ["B", "T", "D", "X"];

    List invalidSeatType = ["W", "R", "H", "X", "T", "TS", "4S"];

    bool left1 = data.asMap().containsKey(index - 1);
    bool left2 = data.asMap().containsKey(index - 2);
    bool right1 = data.asMap().containsKey(index + 1);
    bool right2 = data.asMap().containsKey(index + 2);
    bool isConnectedLeft1 = left1
        ? (int.parse(data[index].x!) - 1 == int.parse(data[index - 1].x!))
        : false;
    bool isConnectedRight1 = right1
        ? (int.parse(data[index].x!) + 1 == int.parse(data[index + 1].x!))
        : false;
    bool isConnectedLeft2 = left2
        ? (int.parse(data[index].x!) - 2 == int.parse(data[index - 2].x!))
        : false;
    bool isConnectedRight2 = right2
        ? (int.parse(data[index].x!) + 2 == int.parse(data[index + 2].x!))
        : false;
    bool isLeft1Valid = left1 && isConnectedLeft1
        ? !(invalidSeatType.contains(data[index - 1].type!) ||
            invalidSeatStatus.contains(data[index - 1].status!))
        : false;
    bool isRight1Valid = right1 && isConnectedRight1
        ? !(invalidSeatType.contains(data[index + 1].type!) ||
            invalidSeatStatus.contains(data[index + 1].status!))
        : false;
    bool isLeft2Valid = left2 && isConnectedLeft2
        ? !(invalidSeatType.contains(data[index - 2].type!) ||
            invalidSeatStatus.contains(data[index - 2].status!))
        : false;
    bool isRight2Valid = right2 && isConnectedRight2
        ? !(invalidSeatType.contains(data[index + 2].type!) ||
            invalidSeatStatus.contains(data[index + 2].status!))
        : false;
    bool containsLeft2 = isLeft2Valid
        ? selectedSeat.contains("$seatRow${data[index - 2].value}")
        : false;
    bool containsRight2 = isRight2Valid
        ? selectedSeat.contains("$seatRow${data[index + 2].value}")
        : false;
    bool containsLeft1 = isLeft1Valid
        ? selectedSeat.contains("$seatRow${data[index - 1].value}")
        : false;
    bool containsRight1 = isRight1Valid
        ? selectedSeat.contains("$seatRow${data[index + 1].value}")
        : false;

    // if (isLeft1Valid) {
    //   if (containsLeft1) {
    //     return false;
    //   } else {
    //     if (isLeft2Valid) {
    //       if (containsLeft2) {
    //         if (isRight1Valid) {
    //           return true;
    //         } else {
    //           return false;
    //         }
    //       } else {
    //         return false;
    //       }
    //     } else {
    //       if (isConnectedLeft2) {
    //         return true;
    //       } else {
    //         return false;
    //       }
    //     }
    //   }
    // } else if (isRight1Valid) {
    //   if (containsRight1) {
    //     return false;
    //   } else {
    //     if (isRight2Valid) {
    //       if (containsRight2) {
    //         if (isLeft1Valid) {
    //           return true;
    //         } else {
    //           return false;
    //         }
    //       } else {
    //         return false;
    //       }
    //     } else {
    //       if (isConnectedRight2) {
    //         return true;
    //       } else {
    //         return false;
    //       }
    //     }
    //   }
    // }

//START of 2nd set logic
    if (isLeft1Valid) {
      if (containsLeft1) {
        if (isRight1Valid) {
          if (containsRight1) {
            return false;
          } else {
            if (isRight2Valid) {
              if (containsRight2) {
                return true;
              } else {
                if (isLeft1Valid) {
                  if (containsLeft1) {
                    return false;
                  } else {
                    if (isLeft2Valid) {
                      if (containsLeft2) {
                        return true;
                      }
                      return false;
                    }

                    return true;
                  }
                }
              }
            }
          }
        }
        return false;
      } else {
        if (isLeft2Valid) {
          if (containsLeft2) {
            if (isConnectedRight1) {
              return true;
            }
            return false;
          } else {
            if (isRight1Valid) {
              if (containsRight1) {
                return false;
              } else {
                if (isRight2Valid) {
                  if (containsRight2) {
                    return true;
                  }
                  return false;
                }

                return true;
              }
            }
          }
        } else {
          if (isRight1Valid) {
            if (containsRight1) {
              return false;
            } else {
              return true;
            }
          }
          return false;
        }
      }
    } else {
      if (isRight1Valid) {
        if (containsRight1) {
          return false;
        } else {
          if (isRight2Valid) {
            if (containsRight2) {
              if (isConnectedLeft1) {
                return true;
              }
              return false;
            } else {
              if (isLeft1Valid) {
                if (containsLeft1) {
                  return false;
                } else {
                  if (isLeft2Valid) {
                    if (containsLeft2) {
                      return true;
                    }
                    return false;
                  }
                  return true;
                }
              }
            }
          }
        }
      }
      return false;
    }
//END of 2nd set logic

//START of 1nd set logic
    // if (isRight1Valid) {
    //   if (isLeft1Valid) {
    //     if (containsLeft1) {
    //       if (isRight2Valid) {
    //         if (containsRight2) {

    //           return true;
    //         } else {
    //           return false;
    //         }
    //       } else {
    //         if (containsLeft1) {
    //           return connectedFromLeftEnd(data, index - 1, seatRow);

    //         }
    //         return true;
    //       }
    //     } else {
    //       if (isLeft2Valid) {
    //         if (containsLeft2) {
    //           return true;
    //         } else {
    //           if (isRight2Valid) {
    //             if (containsRight2 && !containsRight1) {
    //               return true;
    //             } else {
    //               return false;
    //             }
    //           } else {
    //             if (containsRight1) {
    //               return connectedFromRightEnd(data, index + 1, seatRow);
    //             }
    //             return true;
    //           }
    //         }
    //       } else {
    //         if (containsRight1) {
    //           return connectedFromRightEnd(data, index + 1, seatRow);
    //         }
    //         return true;
    //       }
    //     }
    //   } else {
    //     if (containsRight1) {
    //       return false;
    //     } else {
    //       if (isRight2Valid) {
    //         if (containsRight2) {
    //           return true;
    //         } else {
    //           return false;
    //         }
    //       } else {
    //         return false;
    //       }
    //     }
    //   }
    // } else if (isLeft1Valid) {
    //   if (isRight1Valid) {
    //     if (containsRight1) {
    //       if (isLeft2Valid) {
    //         if (containsLeft2) {
    //           return true;
    //         } else {
    //           return false;
    //         }
    //       } else {
    //         return true;
    //       }
    //     } else {
    //       if (isRight2Valid) {
    //         if (containsRight2) {
    //           return true;
    //         } else {
    //           if (isLeft2Valid) {
    //             if (containsLeft2 && !containsLeft1) {
    //               return true;
    //             } else {
    //               return false;
    //             }
    //           } else {
    //             if (containsLeft1) {
    //               return false;
    //             }
    //             return true;
    //           }
    //         }
    //       } else {
    //         return true;
    //       }
    //     }
    //   } else {
    //     if (containsLeft1) {
    //       return false;
    //     } else {
    //       if (isLeft2Valid) {
    //         if (containsLeft2) {
    //           return true;
    //         } else {
    //           return false;
    //         }
    //       } else {
    //         return false;
    //       }
    //     }
    //   }
    // }
//END of 1nd set logic
    return false;
  }

  connectedFromRightEnd(List<Cols> data, int index, String seatRow) {
    List invalidSeatStatus = ["B", "T", "D", "X"];
    List invalidSeatType = ["W", "R", "H", "X"];

    bool right1 = data.asMap().containsKey(index + 1);

    bool isConnectedRight1 = right1
        ? (int.parse(data[index].x!) + 1 == int.parse(data[index + 1].x!))
        : false;

    bool isRight1Valid = right1 && isConnectedRight1
        ? !(invalidSeatType.contains(data[index + 1].type!) ||
            invalidSeatStatus.contains(data[index + 1].status!))
        : false;
    bool containsRight1 = isRight1Valid
        ? selectedSeat.contains("$seatRow${data[index + 1].value}")
        : false;
    if (isRight1Valid) {
      if (containsRight1) {
        return connectedFromRightEnd(data, index + 1, seatRow);
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  connectedFromLeftEnd(List<Cols> data, int index, String seatRow) {
    List invalidSeatStatus = ["B", "T", "D", "X"];
    List invalidSeatType = ["W", "R", "H", "X"];
    bool left1 = data.asMap().containsKey(index - 1);

    bool isConnectedLeft1 = left1
        ? (int.parse(data[index].x!) - 1 == int.parse(data[index - 1].x!))
        : false;

    bool isLeft1Valid = left1 && isConnectedLeft1
        ? !(invalidSeatType.contains(data[index - 1].type!) ||
            invalidSeatStatus.contains(data[index - 1].status!))
        : false;
    bool containsLeft1 = isLeft1Valid
        ? selectedSeat.contains("$seatRow${data[index - 1].value}")
        : false;

    if (isLeft1Valid) {
      if (containsLeft1) {
        return connectedFromLeftEnd(data, index - 1, seatRow);
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  Future<dynamic> guideLineDialog(BuildContext context) {
    var typeList = widget.data.typeDesc!.split(';');
    for (var element in typeList) {
      element = element.split("-").last;
    }

    if (guideLinesType.replaceAll(' ', '').toUpperCase() == "PLAYPLUS") {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0, right: 16, top: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getTranslated(context, "PP_popup_title")
                              .replaceAll("<title>", guideLinesType),
                          style: AppFont.poppinsRegular(16),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          Utils.getTranslated(context, "PP_popup_subtitle"),
                          style: AppFont.poppinsRegular(12,
                              color: AppColor.greyWording()),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            primary: true,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_1"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.errorRed()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_2"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.errorRed()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_3"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_4"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_5"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_6"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_7"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_8"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_9"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_10"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "PP_popup_content_11"),
                                  style: AppFont.poppinsRegular(
                                    12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                            height: 50,
                            decoration: BoxDecoration(
                                color: AppColor.greyWording(),
                                borderRadius: BorderRadius.circular(
                                  6,
                                )),
                            child: Center(
                              child: Text(
                                Utils.getTranslated(context, "cancel_btn"),
                                style: AppFont.poppinsRegular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Utils.printInfo("SEAT TYPE MAP: $seatTypeMap");

                            Navigator.of(context).pop();
                            Navigator.pushNamed(
                                context, AppRoutes.buyMovieTicketTypeRoute,
                                arguments: BuyTicketTypeArgs(
                                    showId: widget.data.id!,
                                    opsDate: widget.opsdate,
                                    cinemaName:
                                        widget.data.locationDisplayName!,
                                    movieTitle: widget.title,
                                    locationId: widget.data.locationID!,
                                    hallId: widget.data.hid!,
                                    filmId: widget.data.childID!,
                                    showDate: widget.data.date!,
                                    showTime: widget.data.time!,
                                    seats: selectedSeat,
                                    fromWher: widget.fromWher,
                                    ticketQty: selectedSeat.length,
                                    seatTypeMap: seatTypeMap,
                                    isAurum: widget.isAurum));
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                            height: 50,
                            decoration: BoxDecoration(
                                color: AppColor.appYellow(),
                                borderRadius: BorderRadius.circular(
                                  6,
                                )),
                            child: Center(
                              child: Text(
                                Utils.getTranslated(context, "proceed_btn"),
                                style: AppFont.poppinsRegular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (guideLinesType.replaceAll(' ', '').toUpperCase() == "DBOX") {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0, right: 16, top: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getTranslated(context, "dbox_popup_title")
                              .replaceAll("<title>", guideLinesType),
                          style: AppFont.poppinsRegular(
                            16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            primary: true,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Utils.getTranslated(
                                      context, "hall_popup_important_text"),
                                  style: AppFont.poppinsRegular(14,
                                      color: AppColor.errorRed()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1a"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1b"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1c"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1d"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1e"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1f"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_1g"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_2"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_3"),
                                  style: AppFont.poppinsRegular(12),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_4"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_5"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_6"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_7"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_content_8"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "hall_popup_disclaimer_text"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "dbox_popup_disclaimer_content"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                            height: 50,
                            decoration: BoxDecoration(
                                color: AppColor.greyWording(),
                                borderRadius: BorderRadius.circular(
                                  6,
                                )),
                            child: Center(
                              child: Text(
                                Utils.getTranslated(context, "cancel_btn"),
                                style: AppFont.poppinsRegular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Utils.printInfo("SEAT TYPE MAP: $seatTypeMap");

                            Navigator.of(context).pop();
                            Navigator.pushNamed(
                                context, AppRoutes.buyMovieTicketTypeRoute,
                                arguments: BuyTicketTypeArgs(
                                    showId: widget.data.id!,
                                    opsDate: widget.opsdate,
                                    cinemaName:
                                        widget.data.locationDisplayName!,
                                    movieTitle: widget.title,
                                    locationId: widget.data.locationID!,
                                    hallId: widget.data.hid!,
                                    filmId: widget.data.childID!,
                                    fromWher: widget.fromWher,
                                    showDate: widget.data.date!,
                                    showTime: widget.data.time!,
                                    seats: selectedSeat,
                                    ticketQty: selectedSeat.length,
                                    seatTypeMap: seatTypeMap,
                                    isAurum: widget.isAurum));
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                            height: 50,
                            decoration: BoxDecoration(
                                color: AppColor.appYellow(),
                                borderRadius: BorderRadius.circular(
                                  6,
                                )),
                            child: Center(
                              child: Text(
                                Utils.getTranslated(context, "proceed_btn"),
                                style: AppFont.poppinsRegular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0, right: 16, top: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getTranslated(context, "4dx_popup_title")
                              .replaceAll("<title>", guideLinesType),
                          style: AppFont.poppinsRegular(
                            16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            primary: true,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Utils.getTranslated(
                                      context, "hall_popup_important_text"),
                                  style: AppFont.poppinsRegular(14,
                                      color: AppColor.errorRed()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_subtitle"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1a"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1b"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1c"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1d"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1e"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1f"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1g"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_1h"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_2"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_3"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_4"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_5"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_6"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_7"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_8"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_9"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_content_10"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "hall_popup_disclaimer_text"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Utils.getTranslated(
                                      context, "4dx_popup_disclaimer_content"),
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.greyWording()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                            height: 50,
                            decoration: BoxDecoration(
                                color: AppColor.greyWording(),
                                borderRadius: BorderRadius.circular(
                                  6,
                                )),
                            child: Center(
                              child: Text(
                                Utils.getTranslated(context, "cancel_btn"),
                                style: AppFont.poppinsRegular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                          height: 50,
                          decoration: BoxDecoration(
                              color: AppColor.appYellow(),
                              borderRadius: BorderRadius.circular(
                                6,
                              )),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              Utils.printInfo("SEAT TYPE MAP: $seatTypeMap");
                              Navigator.pushNamed(
                                  context, AppRoutes.buyMovieTicketTypeRoute,
                                  arguments: BuyTicketTypeArgs(
                                      showId: widget.data.id!,
                                      movieTitle: widget.title,
                                      opsDate: widget.opsdate,
                                      cinemaName:
                                          widget.data.locationDisplayName!,
                                      locationId: widget.data.locationID!,
                                      hallId: widget.data.hid!,
                                      filmId: widget.data.childID!,
                                      showDate: widget.data.date!,
                                      fromWher: widget.fromWher,
                                      showTime: widget.data.time!,
                                      seats: selectedSeat,
                                      ticketQty: selectedSeat.length,
                                      seatTypeMap: seatTypeMap,
                                      isAurum: widget.isAurum));
                            },
                            child: Center(
                              child: Text(
                                Utils.getTranslated(context, "proceed_btn"),
                                style: AppFont.poppinsRegular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
