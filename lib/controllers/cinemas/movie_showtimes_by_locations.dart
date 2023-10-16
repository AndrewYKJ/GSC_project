import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/cinema_api.dart';
import 'package:gsc_app/models/arguments/custom_seat_selection_arguments.dart';
import 'package:gsc_app/models/arguments/custom_selection_model.dart';
import 'package:gsc_app/models/arguments/custom_show_model.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:gsc_app/models/json/nearby_location_model.dart';
import 'package:gsc_app/models/json/showtimes_by_cinema_model.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/custom_rating_popup.dart';
import 'package:intl/intl.dart';

import '../../const/analytics_constant.dart';
import '../../widgets/custom_favourite_button.dart';

class MovieShowtimesByCinema extends StatefulWidget {
  final MovieToBuyArgs data;
  const MovieShowtimesByCinema({Key? key, required this.data})
      : super(key: key);

  @override
  State<MovieShowtimesByCinema> createState() => _MovieShowtimesByCinemaState();
}

class _MovieShowtimesByCinemaState extends State<MovieShowtimesByCinema> {
  ShowtimesByCinemaDTO? showtimesByCinemaDTO;
  int maxCount = 8;
  bool isAurum = false;
  dynamic isSelectedData;
  List<Parent>? movieList;
  String? previousSelectedShow;
  var isLogin = false;
  bool offFilter = true;
  bool isLoading = true;
  List<bool> keyCap = [];
  List<CustomSelector> experienceSelectionList = [];
  List<String> preferredExpList = [];

  List<String> opsdateList = [];
  String? selectedOpsdate;
  Parent? selectedMovie;

  Future<ShowtimesByCinemaDTO> getMovieShowtimesByCinema(BuildContext context,
      String opsdate, String locationId, String? hallGroup) async {
    CinemaApi showtimesApi = CinemaApi(context);
    return showtimesApi.getShowtimesByLocation(opsdate, locationId, hallGroup);
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SELECT_MOVIES_BY_CINEMA_SCREEN);
    checkLocationData();

    _checkLoginState();

    super.initState();
  }

  checkLocationData() {
    if (widget.data.location != null) {
      getOpsdate(widget.data.location!, null);
      selectedOpsdate = widget.data.firstDate.isNotEmpty
          ? opsdateList.firstWhere(
              (element) => element == widget.data.firstDate,
              orElse: () => widget.data.location!.show!.first.opsdate!)
          : widget.data.location!.show!.first.opsdate!;
      getMovie(widget.data.location!.show!.first.opsdate!,
          widget.data.location!.value!, widget.data.location!.hallGroup);
    } else {
      getOpsdate(null, widget.data.swaggerLocation!);
      selectedOpsdate = widget.data.firstDate.isNotEmpty
          ? opsdateList.firstWhere(
              (element) => element == widget.data.firstDate,
              orElse: () => widget
                  .data.swaggerLocation!.showDate!.first.operationDate!
                  .toString())
          : widget.data.swaggerLocation!.showDate!.first.operationDate!
              .toString();

      getMovie(
          selectedOpsdate!,
          widget.data.swaggerLocation!.cinemaCode!.toString(),
          widget.data.swaggerLocation!.hallGroup);
    }
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken && AppCache.me != null) {
      setState(() {
        isLogin = true;
      });
    }
  }

  checkShowList(Parent parent) {
    List<CustomShowModel> tempList = [];
    if (parent.child != null && parent.child!.isNotEmpty) {
      for (var childs in parent.child!) {
        for (var shows in childs.show!) {
          if (preferredExpList.isEmpty) {
            tempList.add(CustomShowModel(
                childID: childs.code,
                locationDisplayName: widget.data.location != null
                    ? widget.data.location!.epaymentName
                    : widget.data.swaggerLocation!.epaymentName,
                locationID: widget.data.location != null
                    ? widget.data.location!.value
                    : widget.data.swaggerLocation!.cinemaCode.toString(),
                rating: childs.rating,
                id: shows.id,
                date: shows.date,
                time: shows.time,
                timestr: shows.timestr,
                hid: shows.hid,
                hallgroup: widget.data.location?.hallGroup,
                hname: shows.hname,
                hallfull: shows.hallfull,
                hallorder: shows.hallorder,
                barcodeEnabled: shows.barcodeEnabled,
                displayDate: shows.displayDate,
                hasGscPrivilege: shows.hasGscPrivilege,
                type: shows.type,
                filmType: childs.filmType,
                typeDesc: shows.typeDesc,
                freelist: shows.freelist));
          } else {
            var showsType = shows.type!.split(" ");

            if (preferredExpList
                .any((element) => showsType.contains(element))) {
              tempList.add(CustomShowModel(
                  childID: childs.code,
                  locationDisplayName: widget.data.location != null
                      ? widget.data.location!.epaymentName
                      : widget.data.swaggerLocation!.epaymentName,
                  locationID: widget.data.location != null
                      ? widget.data.location!.value
                      : widget.data.swaggerLocation!.cinemaCode.toString(),
                  rating: childs.rating,
                  id: shows.id,
                  date: shows.date,
                  time: shows.time,
                  timestr: shows.timestr,
                  hid: shows.hid,
                  filmType: childs.filmType,
                  hname: shows.hname,
                  hallgroup: widget.data.location?.hallGroup,
                  hallfull: shows.hallfull,
                  hallorder: shows.hallorder,
                  barcodeEnabled: shows.barcodeEnabled,
                  displayDate: shows.displayDate,
                  hasGscPrivilege: shows.hasGscPrivilege,
                  type: shows.type,
                  typeDesc: shows.typeDesc,
                  freelist: shows.freelist));
            }
          }
        }
      }
    }
    tempList.sort(((a, b) {
      return Utils.compareAndArrangeTimes(a.time!, b.time!);
    }));
    return tempList;
  }

  getMovie(String opsdate, String locationId, String? hallGroup) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    await getMovieShowtimesByCinema(
            context, selectedOpsdate!, locationId, hallGroup)
        .then((value) {
      if (value.code != null && value.code == '-1') {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.display_msg != null
                ? value.display_msg ??
                    Utils.getTranslated(context, "general_error")
                : Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } else {
        if (value.films?.oprn?.parent != null) {
          setState(() {
            showtimesByCinemaDTO = value;
            movieList = value.films!.oprn!.parent;
            keyCap = List<bool>.generate(movieList!.length, (index) => (false),
                growable: false);
          });
        }
      }

      return null;
    }).whenComplete(() {
      isSelectedData != null ? isSelectedData = null : null;
      EasyLoading.dismiss();
      getAllFilterParams();
    }).catchError((e) {
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

  dismissScreen() {
    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (selectedMovie == null) {
        EasyLoading.dismiss();
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "info_title"),
            Utils.getTranslated(context, "general_error"),
            false,
            false, () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      }
    });
  }

  getOpsdate(Location? cinemaData, SwaggerLocation? swaggerLocation) async {
    setState(() {
      if (cinemaData != null) {
        for (var value in cinemaData.show!) {
          if (!(opsdateList.toString().contains(value.opsdate!))) {
            opsdateList.add(value.opsdate!);
          }
        }
      } else {
        for (var value in swaggerLocation!.showDate!) {
          if (!(opsdateList
              .toString()
              .contains(value.operationDate!.toString()))) {
            opsdateList.add(value.operationDate!.toString());
          }
        }
      }
      opsdateList.sort((a, b) {
        DateTime timeA = DateFormat('yyyy-MM-dd').parse(a);
        DateTime timeB = DateFormat('yyyy-MM-dd').parse(b);
        return timeA.compareTo(timeB);
      });
    });
  }

  checkShowtimes(List<Parent>? loc) {
    return loc != null
        ? preferredExpList.isNotEmpty
            ? loc.any((a) {
                return (a.child ?? []).any((c) {
                  return (c.show ?? []).any((element) {
                    return preferredExpList.any((g) =>
                        (element.type ?? '').split(' ').any((t) => t == g));
                  });
                });
              })
            : loc.any((element) =>
                element.child != null &&
                (element.child ?? [])
                    .any((e) => e.show != null && e.show!.isNotEmpty))
        : false;
  }

  getAllFilterParams() {
    preferredExpList.clear();

    experienceSelectionList.clear();

    showtimesByCinemaDTO != null
        ? {
            for (var value in showtimesByCinemaDTO!.films!.filters!.group!)
              {
                if (value.name!.toLowerCase().contains('experience'))
                  {
                    for (var element in value.type!)
                      {
                        experienceSelectionList.add(CustomSelector(
                            displayName:
                                element.name!.replaceAll(' ', '').toUpperCase(),
                            code: element.code,
                            isSelected: false))
                      }
                  }
              }
          }
        : null;

    EasyLoading.dismiss();
    setState(() {
      isLoading = false;
    });
  }

  returnButton() {
    return Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : WillPopScope(
            onWillPop: () => returnButton(),
            child: Container(
              color: Colors.black,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                child: Stack(
                  children: [
                    _cinemaImage(context),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appBar(context),
                        _emtpySpace(),
                        _showtimesModule(context),
                      ],
                    ),
                    !offFilter
                        ? BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.transparent),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          );
  }

  Container _emtpySpace() {
    return Container(
      height: 132 - MediaQuery.of(context).viewPadding.top / 2,
      decoration: const BoxDecoration(color: Colors.transparent),
    );
  }

  Widget _cinemaImage(BuildContext context) {
    String url;
    url = widget.data.location != null
        ? widget.data.location!.thumbBig!
        : widget.data.swaggerLocation!.thumbLarge!;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage(
        imageUrl: url,
        height: 200 + MediaQuery.of(context).viewPadding.top,
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        errorWidget: (context, error, stackTrace) {
          return Image.asset('assets/images/Default placeholder_app_img.png',
              fit: BoxFit.cover);
        },
      ),
    );
  }

  Widget selectedShowtimesCancelButton(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, right: 16),
            child: SizedBox(
              height: 36,
              width: 36,
              child: Image.asset(
                Constants.ASSET_IMAGES + "close-icon.png",
                height: 14,
                width: 14,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }

  turnOnPopUp(CustomShowModel showtimes) async {
    offFilter = false;
    final result = await moviePopUpModule(showtimes);

    if (result == null || result != null) {
      setState(() {
        offFilter = true;
      });
    }
  }

  moviePopUpModule(CustomShowModel showtimes) {
    String hallDisplayName = '';
    var ratingAssetName = MovieClassification.movieRating[showtimes.rating];
    double physicalSizeheight =
        WidgetsBinding.instance.window.physicalSize.height;

    var typeList = showtimes.typeDesc!.replaceAll(";", ", ").split(",");

    final itmDate = DateTime.parse(showtimes.date!);
    final opsDate = DateTime.parse(selectedOpsdate!);
    final difference = itmDate.difference(opsDate).inDays;

    if (showtimes.hname != null) {
      if (int.tryParse(showtimes.hname!) != null) {
        showtimes.hname!.toLowerCase().contains('hall')
            ? hallDisplayName = showtimes.hname!
            : hallDisplayName = "Hall ${showtimes.hname}";
      } else {
        hallDisplayName = showtimes.hname!;
      }
    }
    setState(() {
      previousSelectedShow = showtimes.id;
    });
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withOpacity(0.2),
      context: context,
      builder: (ctx) => SingleChildScrollView(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: physicalSizeheight > 2000 ? 90 : 80,
                ),
                padding: EdgeInsets.only(
                    top: 0, bottom: MediaQuery.of(context).viewPadding.bottom),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.black),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          selectedShowtimesCancelButton(ctx),
                          SizedBox(
                            height: physicalSizeheight > 2000 ? 98 : 88,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .9,
                            child: Center(
                              child: Text(
                                selectedMovie!.title!,
                                style:
                                    AppFont.montBold(16, color: Colors.white),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Utils.formatDuration(
                                      selectedMovie!.child!.first.duration!),
                                  style: AppFont.poppinsRegular(
                                    10,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(6),
                                  width: 2,
                                  height: 2,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(2)),
                                ),
                                Text(
                                  Utils.getLanguageName(
                                      selectedMovie!.child!.first.lang!),
                                  style: AppFont.poppinsRegular(10,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: physicalSizeheight > 2000 ? 18 : 14,
                          ),
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${showtimes.typeDesc?.replaceAll(";", ", ")}",
                                  style: AppFont.poppinsRegular(12,
                                      color: AppColor.lightGrey()),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    for (var type in typeList)
                                      MapCinemaExperiences.experiencesFilter[
                                                  type
                                                      .split("-")
                                                      .last
                                                      .replaceAll(' ', '')
                                                      .toUpperCase()] !=
                                              null
                                          ? Image.asset(
                                              MapCinemaExperiences
                                                      .experiencesFilter[
                                                  type
                                                      .split("-")
                                                      .last
                                                      .replaceAll(' ', '')
                                                      .toUpperCase()],
                                              height: 20,
                                              width: 40,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const SizedBox();
                                              },
                                            )
                                          : const SizedBox()
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: physicalSizeheight > 2000 ? 18 : 14,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        color: AppColor.dividerColor(),
                        thickness: 1,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.all(physicalSizeheight > 2000 ? 16.0 : 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Utils.getTranslated(context, "cinema"),
                              style: AppFont.montRegular(14,
                                  color: AppColor.greyWording())),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            '${showtimes.locationDisplayName}',
                            style: AppFont.poppinsMedium(14,
                                color: isAurum
                                    ? AppColor.aurumGold()
                                    : AppColor.yellow()),
                          ),
                          SizedBox(
                            height: physicalSizeheight > 2000 ? 19 : 14,
                          ),
                          Text(Utils.getTranslated(context, "hall"),
                              style: AppFont.montRegular(14,
                                  color: AppColor.greyWording())),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            hallDisplayName,
                            style: AppFont.poppinsMedium(14,
                                color: isAurum
                                    ? AppColor.aurumGold()
                                    : AppColor.yellow()),
                          ),
                          SizedBox(
                            height: physicalSizeheight > 2000 ? 19 : 14,
                          ),
                          Text(Utils.getTranslated(context, "time_and_date"),
                              style: AppFont.montRegular(14,
                                  color: AppColor.greyWording())),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            difference > 0
                                ? "${DateFormat('E dd MMM').format(opsDate)}, ${showtimes.timestr} (${showtimes.displayDate})"
                                : "${showtimes.displayDate}, ${showtimes.timestr}",
                            style: AppFont.poppinsMedium(14,
                                color: isAurum
                                    ? AppColor.aurumGold()
                                    : AppColor.yellow()),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        late Child selectedChild = Child();
                        if (movieList != null && movieList!.isNotEmpty) {
                          for (var element in movieList!) {
                            if (element.child != null &&
                                element.child!.isNotEmpty) {
                              for (var e in element.child!) {
                                if (e.code == showtimes.childID) {
                                  selectedChild = e;

                                  continue;
                                }
                              }
                            }
                          }
                        }

                        if (showtimes.rating == '18') {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return CustomRatingPopup(
                                  title: Utils.getTranslated(
                                      context, "rating_18_title"),
                                  message: Utils.getTranslated(
                                      context, "rating_18_content"),
                                  rating: showtimes.rating!,
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                    onConfirm(
                                        context, showtimes, selectedChild);
                                  },
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              });
                          return;
                        }

                        if (showtimes.rating == '16') {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return CustomRatingPopup(
                                  title: Utils.getTranslated(
                                      context, "rating_16_title"),
                                  message: Utils.getTranslated(
                                      context, "rating_16_content"),
                                  rating: showtimes.rating!,
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                    onConfirm(
                                        context, showtimes, selectedChild);
                                  },
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              });
                          return;
                        }

                        onConfirm(context, showtimes, selectedChild);
                      },
                      child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          child: Center(
                              child: Text(
                                  Utils.getTranslated(context, 'select_seats'),
                                  style: AppFont.montSemibold(14,
                                      color: Colors.black))),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: isAurum
                                  ? AppColor.aurumGold()
                                  : AppColor.yellow(),
                              borderRadius: BorderRadius.circular(6))),
                    ),
                    SizedBox(
                      height: physicalSizeheight > 2000 ? 20 : 14,
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 42),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: isAurum
                                  ? AppColor.aurumGold()
                                  : AppColor.yellow(),
                              width: 2),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.movieDetailsRoute,
                            arguments: [selectedMovie?.code, false, true]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: selectedMovie!.child!.first.thumbBig!,
                            fit: BoxFit.fill,
                            width: 148,
                            height: physicalSizeheight > 2000 ? 220 : 200,
                            errorWidget: (context, error, stackTrace) {
                              return Image.asset(
                                  'assets/images/Default placeholder_app_img.png',
                                  width: 148,
                                  height: physicalSizeheight > 2000 ? 220 : 200,
                                  fit: BoxFit.cover);
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: physicalSizeheight > 2000 ? 195 : 170, left: 12),
                      child: ratingAssetName != null
                          ? Image.asset(
                              ratingAssetName,
                              height: 30,
                              width: 30,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 30,
                                  width: 30,
                                );
                              },
                            )
                          : const SizedBox(
                              height: 30,
                              width: 30,
                            ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showtimesModule(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.black),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
                left: 16.0, top: 14, bottom: 8, right: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/location-solid-icon.png',
                  fit: BoxFit.cover,
                  height: 26,
                  width: 26,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4),
                  width: MediaQuery.of(context).size.width - 32 - 26 - 10,
                  child: Text(
                    widget.data.location != null
                        ? widget.data.location!.epaymentName!
                        : widget.data.swaggerLocation!.epaymentName!,
                    style: AppFont.montBold(16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
            child: Text(
              widget.data.location != null
                  ? widget.data.location!.address!.replaceAll(r'\\n', ", ")
                  : widget.data.swaggerLocation!.address!
                      .replaceAll('\n', ", "),
              style: AppFont.poppinsRegular(12, color: AppColor.greyWording()),
            ),
          ),
          Divider(
            color: AppColor.dividerColor(),
          ),
          dateSelectionSlider(context, opsdateList),
          experienceSelectionList.isNotEmpty
              ? experienceSelectionSection(context, experienceSelectionList)
              : const SizedBox(),
          movieList != null
              ? checkShowtimes(movieList)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (var i = 0; i < movieList!.length; i++)
                          _movieListUI(i, context, keyCap[i])
                      ],
                    )
                  : Container(
                      margin: const EdgeInsets.only(top: 30, bottom: 30),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Constants.ASSET_IMAGES +
                              'Movie showtime error_icon.png'),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: MediaQuery.of(context).size.width * .8,
                            child: Text(
                              Utils.getTranslated(context, "no_cinema_msg"),
                              style: AppFont.poppinsSemibold(12,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    )
              : Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(Constants.ASSET_IMAGES +
                          'Movie showtime error_icon.png'),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: MediaQuery.of(context).size.width * .8,
                        child: Text(
                          Utils.getTranslated(context, "showtimes_emtpy_error"),
                          style:
                              AppFont.poppinsSemibold(12, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Container _movieListUI(int i, BuildContext context, bool view) {
    int currentCount = 0;
    bool viewMore = view;
    List<CustomShowModel> customShowModelList = checkShowList(movieList![i]);

    return customShowModelList.isNotEmpty
        ? Container(
            padding: const EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width,
            color: AppColor.appSecondaryBlack(),
            child: Column(
              children: [
                _movieDetails(i, context),
                Builder(builder: (BuildContext context) {
                  viewMore
                      ? currentCount = customShowModelList.length
                      : customShowModelList.length - 1 >= maxCount
                          ? currentCount = maxCount
                          : currentCount = customShowModelList.length;

                  _handleButtonPress() {
                    setState(() {
                      keyCap[i] = true;
                      currentCount = customShowModelList.length;
                    });
                  }

                  return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 23),
                      width: MediaQuery.of(context).size.width,
                      child: _showList(
                          context,
                          movieList![i],
                          currentCount,
                          viewMore,
                          customShowModelList,
                          setState,
                          _handleButtonPress));
                }),
                const SizedBox(
                  height: 7,
                ),
                i != movieList!.length - 1
                    ? Divider(
                        color: AppColor.dividerColor(),
                      )
                    : const SizedBox(),
                i != movieList!.length - 1
                    ? const SizedBox()
                    : const SizedBox(
                        height: 20,
                      )
              ],
            ),
          )
        : Container();
  }

  Container _movieDetails(int i, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: movieList![i].child!.first.thumbBig!,
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width * 0.4 - 32,
            errorWidget: (context, error, stackTrace) {
              return Image.asset(
                  'assets/images/Default placeholder_app_img.png',
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: MediaQuery.of(context).size.width * 0.4 - 32,
                  fit: BoxFit.cover);
            },
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MovieClassification.movieRating[
                                  movieList![i].child?.first.rating] !=
                              null
                          ? Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Image.asset(
                                MovieClassification.movieRating[
                                    movieList![i].child?.first.rating],
                                height: 24,
                                width: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox();
                                },
                              ),
                            )
                          : const SizedBox(),
                      InkWell(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.movieDetailsRoute,
                            arguments: [movieList![i].code, false, true]),
                        child: Image.asset(
                          Constants.ASSET_IMAGES + 'info-icon.png',
                          fit: BoxFit.cover,
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6 - 32 - 16,
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Text(
                    movieList![i].title!,
                    style: AppFont.montBold(14, color: Colors.white),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6 - 32 - 16,
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Text(
                    movieList![i].child!.first.genre!,
                    style: AppFont.poppinsRegular(14,
                        color: AppColor.greyWording()),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6 - 32 - 16,
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        Constants.ASSET_IMAGES + 'grey-time-icon.png',
                        fit: BoxFit.cover,
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        Utils.formatDuration(
                            movieList![i].child!.first.duration!),
                        style: AppFont.poppinsRegular(14,
                            color: AppColor.greyWording()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _showList(
      BuildContext context,
      Parent parent,
      int currentCount,
      bool viewMore,
      List<CustomShowModel> customShowModelList,
      StateSetter setState,
      void Function() handleButtonPress) {
    return Wrap(spacing: 8, runSpacing: 10, children: [
      for (var i = 0; i < currentCount; i++)
        showtimesItems(
            context,
            i,
            customShowModelList[i],
            viewMore,
            customShowModelList.length,
            currentCount,
            handleButtonPress,
            setState,
            parent)
    ]);
  }

  Widget showtimesItems(
      BuildContext context,
      var currentIndex,
      CustomShowModel time,
      bool viewMore,
      int length,
      int currentCount,
      void Function() handleButtonPress,
      StateSetter setState,
      Parent parent) {
    String time24 = time.time!;
    String hour = time24.substring(0, 2);
    String minute = time24.substring(2);
    DateTime currentDate = DateTime.now();

    DateTime dateTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      int.parse(hour),
      int.parse(minute),
    );

    String displayTime = DateFormat('h:mm a').format(dateTime);

    if (currentIndex == 7 && !viewMore && length - 1 != 7) {
      return InkWell(
        onTap: () {
          handleButtonPress();
        },
        child: Container(
          width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
          height: 65,
          decoration: BoxDecoration(
              border: Border.all(
                  color: isAurum ? AppColor.aurumGold() : AppColor.yellow()),
              borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(
              Utils.getTranslated(context, "more_btn"),
              textAlign: TextAlign.center,
              style: AppFont.poppinsRegular(12,
                  color: isAurum ? AppColor.aurumGold() : AppColor.yellow()),
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          isSelectedData = time.id;
          selectedMovie = parent;

          turnOnPopUp(time);
        },
        child: Container(
          width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
          height: 65,
          decoration: BoxDecoration(
              color: isSelectedData == time.id
                  ? isAurum
                      ? AppColor.aurumGold()
                      : AppColor.appYellow()
                  : Colors.transparent,
              border: Border.all(
                  color: isAurum
                      ? AppColor.aurumGold()
                      : isSelectedData == time.id
                          ? AppColor.appYellow()
                          : Colors.white),
              borderRadius: BorderRadius.circular(6)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
                width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    displayTime,
                    textAlign: TextAlign.center,
                    style: AppFont.poppinsRegular(12,
                        color: isSelectedData == time.id
                            ? isAurum
                                ? AppColor.aurumBase()
                                : Colors.black
                            : Colors.white),
                  ),
                ),
              ),
              Container(
                height: 1,
                margin:
                    const EdgeInsets.only(left: 6, right: 6, top: 5, bottom: 2),
                color: AppColor.dividerColor(),
              ),
              Container(
                height: 35 - 9,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
                child: Center(
                  child: Text(
                    time.type ?? '',
                    textAlign: TextAlign.center,
                    style: AppFont.poppinsRegular(12,
                        color: isSelectedData == time.id
                            ? isAurum
                                ? AppColor.aurumBase()
                                : Colors.black
                            : Colors.white,
                        height: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget experienceSelectionSection(
      BuildContext ctx, List<CustomSelector> expList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(Utils.getTranslated(context, "select_experience"),
                style: AppFont.montMedium(14, color: AppColor.greyWording())),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: expList.map((e) => expItem(context, e)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget expItem(BuildContext ctx, CustomSelector item) {
    return MapCinemaExperiences.experiences[item.displayName] != null
        ? InkWell(
            onTap: (() {
              item.isSelected = !item.isSelected!;

              setState(() {
                filterShowTimesFunction();
              });
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: (MediaQuery.of(context).size.width - 30 - 32) / 4,
              child: MapCinemaExperiences.experiences[item.displayName] != null
                  ? Image.asset(
                      item.isSelected!
                          ? MapCinemaExperiences
                              .experiencesSelected[item.displayName]
                          : MapCinemaExperiences.experiences[item.displayName],
                      fit: BoxFit.cover,
                      width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
                    )
                  : Center(
                      child: Text(
                        '${item.code}',
                        textAlign: TextAlign.center,
                        style: AppFont.poppinsSemibold(18,
                            color: AppColor.appYellow()),
                      ),
                    ),
            ),
          )
        : const SizedBox();
  }

  Widget dateSelectionSlider(BuildContext ctx, List<String> dateList) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(Utils.getTranslated(context, "select_date"),
                style: AppFont.montMedium(14, color: AppColor.greyWording())),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dateList.map((e) => dateItem(context, e)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget dateItem(BuildContext context, String date) {
    return InkWell(
      onTap: () {
        if (selectedOpsdate != date) {
          setState(() {
            selectedOpsdate = date;
          });

          getMovie(
              selectedOpsdate!.split(' ')[0],
              widget.data.swaggerLocation!.cinemaCode!.toString(),
              widget.data.swaggerLocation!.hallGroup);
        }
      },
      child: Container(
        width: 48,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: date == selectedOpsdate
                    ? AppColor.appYellow()
                    : Colors.white),
            color: date == selectedOpsdate
                ? isAurum
                    ? AppColor.aurumGold()
                    : AppColor.yellow()
                : Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.E()
                  .format(DateFormat('yyyy-MM-dd').parse(date))
                  .toUpperCase(),
              style: AppFont.poppinsRegular(12,
                  color: AppColor.lightGrey(), height: 1),
            ),
            Text(
              DateFormat.d().format(DateFormat('yyyy-MM-dd').parse(date)),
              style: AppFont.poppinsSemibold(
                18,
                color: date == selectedOpsdate ? Colors.black : Colors.white,
              ),
            ),
            Text(
              DateFormat.MMM().format(DateFormat('yyyy-MM-dd').parse(date)),
              style: AppFont.poppinsRegular(10,
                  color: date == selectedOpsdate
                      ? Colors.black
                      : AppColor.appYellow(),
                  height: 1),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        width: MediaQuery.of(context).size.width,
        decoration:
            const BoxDecoration(color: Colors.transparent, boxShadow: []),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Image.asset(
                Constants.ASSET_IMAGES + 'white-left-icon.png',
                fit: BoxFit.cover,
                height: 28,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: FavouriteButton(
              isAurum: false,
              isReload: () {},
              isFavourite: false,
              hallGroup: widget.data.swaggerLocation!.hallGroup ?? '',
              cinemaId: widget.data.swaggerLocation!.cinemaCode ?? 0,
            ),
          ),
        ]),
      ),
    );
  }

  filterShowTimesFunction() {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    preferredExpList.clear();

    for (var element in experienceSelectionList) {
      element.isSelected!
          ? !preferredExpList.contains(element.code!)
              ? preferredExpList.add(element.code!)
              : null
          : null;
    }

    setState(() {});
    EasyLoading.dismiss();
  }

  onConfirm(BuildContext context, CustomShowModel showtimes,
      Child? selectedChild) async {
    if (isLogin) {
      Navigator.pushNamed(context, AppRoutes.movieSeatSelection,
          arguments: CustomSeatSelectionArg(
            opsdate: selectedOpsdate!,
            selectedShowtimesData: showtimes,
            title: selectedMovie!.title!,
            movieDetails: selectedChild,
            fromWher: Constants.GSC_INIT_ENTRYPOINT_BYCINEMA,
          ));
    } else {
      await Navigator.pushNamed(context, AppRoutes.loginRoute).then((value) {
        if (value != null) {
          if (value == true) {
            setState(() {
              isLogin = true;
            });
          }
        }
      });
    }
  }
}
