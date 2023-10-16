import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/movies/widget/movie_slider.dart';
import 'package:gsc_app/controllers/movies/widget/showtime_accordion.dart';
import 'package:gsc_app/controllers/tab/homebase.dart';
import 'package:gsc_app/dio/api/movie_api.dart';
import 'package:gsc_app/dio/api/movie_showtimes.dart';
import 'package:gsc_app/models/arguments/custom_seat_selection_arguments.dart';
import 'package:gsc_app/models/arguments/custom_selection_model.dart';
import 'package:gsc_app/models/arguments/custom_show_model.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/custom_rating_popup.dart';
import 'package:intl/intl.dart';

import '../../const/analytics_constant.dart';
import '../../models/json/as_list_favourite_cinema_model.dart';

class MovieShowtimesByOpsdate extends StatefulWidget {
  final MovieToBuyArgs data;
  const MovieShowtimesByOpsdate({Key? key, required this.data})
      : super(key: key);

  @override
  State<MovieShowtimesByOpsdate> createState() =>
      _MovieShowtimesByOpsdateState();
}

class _MovieShowtimesByOpsdateState extends State<MovieShowtimesByOpsdate> {
  MovieEpaymentDTO? movieDTO;
  MovieShowtimesDTO? showtimesDTO;
  List<Parent>? movieList;
  List<Location>? locationDTO;
  List<Location>? locationList;
  String? previousSelectedShow;
  var isLogin = false;
  bool offFilter = true;
  bool resetAccordion = false;
  bool isLoading = true;
  List<String> keyCap = [];
  List<AS_FAVOURITE_CINEMA> selectedFavourite = [];
  List<CustomSelector> experienceSelectionList = [];
  List<CustomSelector> experienceFilterList = [];
  List<CustomSelector> hallTypeListFilter = [];
  List<CustomSelector> regionFilterList = [];
  List<String> preferredExpList = [];
  List<String> preferredRegionList = [];
  List<String> opsdateList = [];
  String? selectedOpsdate;
  Parent? selectedMovie;

  Future<MovieEpaymentDTO> getMovieDTO(
    BuildContext context,
  ) async {
    MovieApi movieApi = MovieApi(context);
    return movieApi.getMovie();
  }

  Future<MovieShowtimesDTO> getMovieShowtimes(
      BuildContext context, String opsdate, String parentId) async {
    MovieShowtimes showtimesApi = MovieShowtimes(context);
    return showtimesApi.getShowtimesByOpsdate(opsdate, parentId);
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SELECT_MOVIES_BY_OPSDATE_SCREEN);
    getMovie();
    _checkLoginState();

    super.initState();
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

  Future<void> reloadLocation(Parent newSelectedMovie) async {
    setState(() {
      selectedMovie = newSelectedMovie;
    });
    getOpsdate(selectedMovie!);
  }

  getMovie() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    AppCache.movieEpaymentList == null
        ? await getMovieDTO(context)
            .then((value) {
              movieList = value.films!.parent!;

              for (var data in value.films!.parent!) {
                if (widget.data.selectedCode == data.code) {
                  setState(() {
                    selectedMovie = data;
                  });
                }
              }
              getOpsdate(selectedMovie!);
              return null;
            })
            .whenComplete(() => EasyLoading.dismiss())
            .onError((error, stackTrace) => dismissScreen())
        : setState(() {
            if (AppCache.movieEpaymentList?.films?.parent != null) {
              movieList = AppCache.movieEpaymentList!.films!.parent!;

              for (var data in movieList!) {
                if (widget.data.selectedCode == data.code) {
                  selectedMovie = data;
                }
              }
              selectedMovie != null
                  ? getOpsdate(selectedMovie!)
                  : dismissScreen();
              EasyLoading.dismiss();
            }
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
            null, () {
          Navigator.of(context).pop();
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return const HomeBase();
          }), (route) => false);
        });
      }
    });
  }

  getOpsdate(Parent movieData) async {
    opsdateList.clear();
    keyCap.clear();
    setState(() {
      for (var element in movieData.child!) {
        for (var value in element.show!) {
          if (!(opsdateList.toString().contains(value.opsdate!))) {
            opsdateList.add(value.opsdate!);
          }
        }
      }
      DateTime now = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      opsdateList.sort((a, b) {
        DateTime timeA = DateFormat('yyyy-MM-dd').parse(a);
        DateTime timeB = DateFormat('yyyy-MM-dd').parse(b);
        return timeA.compareTo(timeB);
      });
      selectedOpsdate = widget.data.firstDate.isNotEmpty
          ? opsdateList.firstWhere(
              (element) => element == widget.data.firstDate,
              orElse: () => opsdateList.first.toString())
          : opsdateList.firstWhere((element) =>
              DateTime.parse(element).isAfter(now) ||
              DateTime.parse(element).isAtSameMomentAs(now));
    });

    await getMovieShowtimes(context, selectedOpsdate!, movieData.code!)
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
        });
      } else {
        locationList = null;
        setState(() {
          showtimesDTO = value;
          locationDTO = value.locations!.location;
        });
        getAllFilterParams();
      }
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
  }

  reloadLocationNewDate(String? oldDate) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getMovieShowtimes(context, selectedOpsdate!, selectedMovie!.code!)
        .then((value) {
          // ignore: unnecessary_null_comparison
          if (value != null) {
            setState(() {
              showtimesDTO = value;
              locationDTO = value.locations!.location;
            });
            getAllFilterParams();
            keyCap = [];
          }
        })
        .whenComplete(() => EasyLoading.dismiss())
        .catchError((error) {
          setState(() {
            showtimesDTO = null;

            locationDTO = null;
            locationList = null;
            experienceFilterList.clear();
            experienceSelectionList.clear();
            regionFilterList.clear();
            hallTypeListFilter.clear();
          });
        });
  }

  getAllFilterParams() {
    preferredExpList.clear();
    experienceFilterList.clear();
    experienceSelectionList.clear();
    regionFilterList.clear();
    hallTypeListFilter.clear();
    rearrangeDataList();

    if (showtimesDTO?.locations?.filters != null) {
      for (var value in showtimesDTO!.locations!.filters!.group!) {
        if (value.name!.toLowerCase().contains('experience')) {
          for (var element in value.type!) {
            experienceFilterList.add(CustomSelector(
                displayName: element.name!.replaceAll(' ', '').toUpperCase(),
                code: element.code,
                isSelected: false));
            experienceSelectionList.add(CustomSelector(
                displayName: element.name!.replaceAll(' ', '').toUpperCase(),
                code: element.code,
                isSelected: false));
          }
        }
        if (value.name!.toLowerCase().contains('regions')) {
          for (var element in value.type!) {
            regionFilterList.add(CustomSelector(
                displayName: element.name,
                code: element.code,
                isSelected: false));
          }
        }
        if (value.name!.toLowerCase().contains('hall types')) {
          for (var element in value.type!) {
            hallTypeListFilter.add(CustomSelector(
                displayName: element.name,
                code: element.code,
                isSelected: false));
          }
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          bottom: MediaQuery.of(context).viewPadding.bottom),
      child: isLoading
          ? Container()
          : Stack(
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appBar(context),
                      CarouselMovieSlider(
                          data: widget.data,
                          height: (double height) {},
                          allMovie: movieList!,
                          changeMovie: reloadLocation),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              AppColor.homeScreenTopGradient2()
                            ],
                            stops: const [0, .8],
                          ),
                        ),
                        child: Column(
                          children: [
                            dateSelectionSlider(context, opsdateList),
                            experienceSelectionList.isNotEmpty
                                ? experienceSelectionSection(
                                    context, experienceSelectionList)
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      _showtimesModule(context),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
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
                              style: AppFont.montBold(16, color: Colors.white),
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
                                style: AppFont.poppinsRegular(10,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
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
                              SizedBox(
                                  height: physicalSizeheight > 2000 ? 10 : 6),
                              Wrap(
                                spacing: 6,
                                children: [
                                  for (var type in typeList)
                                    MapCinemaExperiences.experiencesFilter[type
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
                              color: AppColor.appYellow()),
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
                              color: AppColor.appYellow()),
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
                              color: AppColor.appYellow()),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Location s = locationDTO!.firstWhere((element) =>
                          element.id == showtimes.locationID &&
                          element.hallGroup == showtimes.hallgroup);

                      Child? selectedChild = s.child?.firstWhere(
                          (element) => element.code == showtimes.childID);
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
                                  onConfirm(context, showtimes, selectedChild);
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
                                  onConfirm(context, showtimes, selectedChild);
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
                            color: AppColor.appYellow(),
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
                        border:
                            Border.all(color: AppColor.appYellow(), width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.movieDetailsRoute,
                          arguments: [selectedMovie?.code, false, true]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          selectedMovie!.child!.first.thumbBig!,
                          fit: BoxFit.fill,
                          width: 148,
                          height: physicalSizeheight > 2000 ? 220 : 200,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                                'assets/images/Default placeholder_app_img.png',
                                fit: BoxFit.fitWidth);
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
    );
  }

  getFavouriteData() {
    selectedFavourite.clear();
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any((element) =>
            element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
          List<AS_FAVOURITE_CINEMA> favCinemaList = Utils.setASFavCinemaToList(
              AppCache.me!.MemberLists!.first.DynamicFieldLists!
                  .firstWhere((element) =>
                      element.name ==
                      Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                  .colValue);
          setState(() {
            for (var element in favCinemaList) {
              selectedFavourite
                  .add(AS_FAVOURITE_CINEMA(element.id, element.hallGroup));
            }
          });
        }
      }
    }
    return true;
  }

  rearrangeDataList() async {
    List<Location> preferredLoc = [];
    List<Location> othersLoc = [];
    locationList = [];
    final data = await getFavouriteData();
    if (data) {
      if (locationDTO != null) {
        for (var element in locationDTO!) {
          if (selectedFavourite.any((e) =>
              e.id == int.parse(element.id!) &&
              e.hallGroup == element.hallGroup)) {
            preferredLoc.add(element);
          } else {
            othersLoc.add(element);
          }
        }
        locationList = [...preferredLoc, ...othersLoc];
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  checkShowtimes(List<Location>? loc) {
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

  Widget _showtimesModule(BuildContext context) {
    return Builder(builder: (context) {
      addViewMoreId(String? i) {
        if (i == null) {
          keyCap.clear();
        }
        if (keyCap.contains(i)) {
          keyCap.remove(i);
        } else {
          keyCap.add(i!);
        }
      }

      return Container(
        width: MediaQuery.of(context).size.width,
        color: AppColor.backgroundBlack(),
        child: Container(
          padding: const EdgeInsets.only(top: 20),
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
              locationDTO != null
                  ? checkShowtimes(locationDTO)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (var i = 0; i < locationList!.length; i++)
                              Accordion(
                                data: locationList![i],
                                index: i,
                                filter: preferredExpList,
                                isReset: rearrangeDataList,
                                viewMoreToggle: addViewMoreId,
                                isOpsdateChange: selectedOpsdate ?? '',
                                previousID: previousSelectedShow,
                                viewMore: keyCap,
                                selectShow: turnOnPopUp,
                                isLast: i == locationList!.length - 1,
                              )
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
                      margin: const EdgeInsets.only(top: 30),
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
                                Utils.getTranslated(
                                    context, "showtimes_emtpy_error"),
                                style: AppFont.poppinsSemibold(12,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ))
                        ],
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget experienceSelectionSection(
      BuildContext ctx, List<CustomSelector> expList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
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
            // Wrap(
            //   runSpacing: 10,
            //   spacing: 0,
            //   children: expList.map((e) => expItem(context, e)).toList(),
            // ),
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
              child: MapCinemaExperiences.experiences[item.displayName] !=
                          null &&
                      MapCinemaExperiences.experiences[item.displayName] != ''
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
      margin: const EdgeInsets.only(
        top: 20,
        bottom: 20,
      ),
      padding: const EdgeInsets.only(left: 16),
      width: MediaQuery.of(context).size.width,
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
          var prevDate = selectedOpsdate;
          setState(() {
            selectedOpsdate = date;
          });

          reloadLocationNewDate(prevDate);
        }
      },
      child: Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 5),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: date == selectedOpsdate
                    ? AppColor.appYellow()
                    : Colors.white),
            color: date == selectedOpsdate
                ? AppColor.appYellow()
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
              style: AppFont.poppinsSemibold(18,
                  color: date == selectedOpsdate ? Colors.black : Colors.white),
            ),
            Text(
              DateFormat.MMM().format(DateFormat('yyyy-MM-dd').parse(date)),
              style: AppFont.poppinsRegular(10,
                  color: date == selectedOpsdate
                      ? Colors.black
                      : AppColor.appYellow(),
                  height: 1),
            )
          ],
        ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: Colors.transparent, boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 20.0,
          spreadRadius: 20.0,
          offset: Offset(0, -40),
        ),
      ]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            Constants.ASSET_IMAGES + 'white-left-icon.png',
            fit: BoxFit.cover,
            height: 28,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(Utils.getTranslated(context, 'showtimes'),
              style: AppFont.montRegular(18, color: Colors.white)),
        ),
        experienceFilterList.isNotEmpty && regionFilterList.isNotEmpty
            ? IconButton(
                onPressed: () async {
                  setState(() {
                    offFilter = false;
                  });
                  final result = await filterPopUp(
                      context,
                      experienceFilterList,
                      hallTypeListFilter,
                      regionFilterList);

                  if (result == null || result != null) {
                    setState(() {
                      offFilter = true;
                    });
                  }
                },
                icon: Image.asset(
                  Constants.ASSET_IMAGES + 'New_filter_icon.png',
                  fit: BoxFit.cover,
                  height: 28,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  Constants.ASSET_IMAGES + 'New_filter_icon.png',
                  fit: BoxFit.cover,
                  height: 28,
                  color: Colors.transparent,
                ),
              ),
      ]),
    );
  }

  filterResetState() {
    preferredExpList.clear();
    preferredRegionList.clear();

    rearrangeDataList();
    for (var element in regionFilterList) {
      element.isSelected = false;
    }

    for (var element in experienceFilterList) {
      element.isSelected = false;
    }
    for (var element in hallTypeListFilter) {
      element.isSelected = false;
    }
    for (var element in experienceSelectionList) {
      element.isSelected!
          ? !preferredExpList.contains(element.code!)
              ? preferredExpList.add(element.code!)
              : null
          : null;
    }

    setState(() {});
  }

  filterShowTimesFunction() {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    locationList = [];
    List<Location> preferredLoc = [];
    List<Location> othersLoc = [];
    preferredExpList.clear();
    preferredRegionList.clear();
    for (var element in regionFilterList) {
      element.isSelected!
          ? !preferredRegionList.contains(element.code!)
              ? preferredRegionList.add(element.code!)
              : null
          : null;
    }
    preferredRegionList.isNotEmpty
        ? {
            for (var data in locationDTO!)
              {
                if (preferredRegionList.contains(data.regionsCode))
                  {locationList!.add(data)}
              },
            for (var element in locationList!)
              if (selectedFavourite.any((e) =>
                  e.id == int.parse(element.id!) &&
                  e.hallGroup == element.hallGroup))
                {preferredLoc.add(element)}
              else
                {othersLoc.add(element)},
            locationList = [...preferredLoc, ...othersLoc]
          }
        : rearrangeDataList();

    for (var element in experienceSelectionList) {
      element.isSelected!
          ? !preferredExpList.contains(element.code!)
              ? preferredExpList.add(element.code!)
              : null
          : null;
    }

    for (var element in experienceFilterList) {
      element.isSelected!
          ? !preferredExpList.contains(element.code!)
              ? preferredExpList.add(element.code!)
              : null
          : null;
    }
    for (var element in hallTypeListFilter) {
      element.isSelected!
          ? !preferredExpList.contains(element.code!)
              ? preferredExpList.add(element.code!)
              : null
          : null;
    }

    setState(() {});
    EasyLoading.dismiss();
  }

  filterPopUp(BuildContext ctx, List<CustomSelector> exp,
      List<CustomSelector> htype, List<CustomSelector> reg) {
    bool expOpen = true;
    bool regOpen = true;
    List<CustomSelector> tempExp = [];
    List<CustomSelector> tempReg = [];

    for (var e in exp) {
      tempExp.add(CustomSelector(
          code: e.code, displayName: e.displayName, isSelected: e.isSelected));
    }
    for (var e in reg) {
      tempReg.add(CustomSelector(
          code: e.code, displayName: e.displayName, isSelected: e.isSelected));
    }
    return showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.white.withOpacity(0.2),
        context: ctx,
        builder: (c) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewPadding.bottom + 20),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                          child: Text(
                        Utils.getTranslated(context, "filters_btn"),
                        style: AppFont.montMedium(18, color: Colors.white),
                      )),
                      width: MediaQuery.of(context).size.width,
                    ),
                    if (exp.isNotEmpty)
                      filterBtmModalExperienceUI(
                          setState, expOpen, tempExp, context),
                    if (reg.isNotEmpty)
                      filterBtmModalRegionUI(
                          setState, regOpen, tempReg, context),
                    Container(
                      margin: const EdgeInsets.only(top: 32),
                      width: MediaQuery.of(context).size.width,
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(c).pop(false),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width / 2 - 24,
                              decoration: BoxDecoration(
                                color: AppColor.lightGrey(),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  Utils.getTranslated(context, "cancel_btn"),
                                  style: AppFont.montRegular(14,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              for (var e in tempExp) {
                                e.isSelected!
                                    ? exp
                                        .firstWhere(
                                            (element) => element.code == e.code)
                                        .isSelected = true
                                    : exp
                                        .firstWhere(
                                            (element) => element.code == e.code)
                                        .isSelected = false;
                              }
                              for (var e in tempReg) {
                                e.isSelected!
                                    ? reg
                                        .firstWhere(
                                            (element) => element.code == e.code)
                                        .isSelected = true
                                    : reg
                                        .firstWhere(
                                            (element) => element.code == e.code)
                                        .isSelected = false;
                              }
                              filterShowTimesFunction();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width / 2 - 24,
                              decoration: BoxDecoration(
                                color: AppColor.yellow(),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  Utils.getTranslated(context, "continue_btn"),
                                  style: AppFont.montSemibold(14,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget filterBtmModalExperienceUI(StateSetter setState, bool isOpen,
      List<CustomSelector> data, BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() {
                isOpen = !isOpen;
              }),
              child: Container(
                color: Colors.transparent,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        Utils.getTranslated(context, "experiences"),
                        style: AppFont.montRegular(14, color: Colors.white),
                      ),
                    ),
                    Image.asset(isOpen
                        ? Constants.ASSET_IMAGES + 'white-arrow-up.png'
                        : Constants.ASSET_IMAGES + 'white-arrow-down.png')
                  ],
                ),
              ),
            ),
            isOpen
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Wrap(
                      runSpacing: 12,
                      spacing: 0,
                      children:
                          data.map((e) => expFilterItem(context, e)).toList(),
                    ),
                  )
                : const SizedBox(),
            Divider(
              color: AppColor.dividerColor(),
            ),
          ],
        );
      },
    );
  }

  Widget expFilterItem(BuildContext ctx, CustomSelector item) {
    return MapCinemaExperiences.experiencesFilter[item.displayName] != null
        ? StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
            return InkWell(
              onTap: (() {
                item.isSelected = !item.isSelected!;

                setState(() {});
              }),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: (MediaQuery.of(ctx).size.width - 48 - 32) / 4,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    border: Border.all(
                        color: item.isSelected!
                            ? AppColor.appYellow()
                            : Colors.white),
                    color:
                        item.isSelected! ? AppColor.appYellow() : Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: MediaQuery.of(ctx).size.width - 62 / 4,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          color: Colors.black),
                      child: MapCinemaExperiences
                                      .experiencesFilter[item.displayName] !=
                                  null &&
                              MapCinemaExperiences
                                      .experiencesFilter[item.displayName] !=
                                  ''
                          ? Image.asset(
                              MapCinemaExperiences
                                  .experiencesFilter[item.displayName],
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                '${item.code}',
                                textAlign: TextAlign.center,
                                style: AppFont.poppinsSemibold(10,
                                    color: AppColor.appYellow()),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        '${item.code}',
                        textAlign: TextAlign.center,
                        style: AppFont.poppinsSemibold(10, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            );
          })
        : const SizedBox();
  }

  Widget filterBtmModalHallTypeUI(StateSetter setState, bool isOpen,
      List<CustomSelector> data, BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() {
                isOpen = !isOpen;
              }),
              child: Container(
                color: Colors.transparent,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        Utils.getTranslated(context, "hall_types"),
                        style: AppFont.montRegular(14, color: Colors.white),
                      ),
                    ),
                    Image.asset(isOpen
                        ? Constants.ASSET_IMAGES + 'white-arrow-up.png'
                        : Constants.ASSET_IMAGES + 'white-arrow-down.png')
                  ],
                ),
              ),
            ),
            isOpen
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Wrap(
                      runSpacing: 12,
                      spacing: 12,
                      children:
                          data.map((e) => htypeFilterItem(context, e)).toList(),
                    ),
                  )
                : const SizedBox(),
            Divider(
              color: AppColor.dividerColor(),
            ),
          ],
        );
      },
    );
  }

  Widget htypeFilterItem(BuildContext ctx, CustomSelector item) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        onTap: (() {
          item.isSelected = !item.isSelected!;

          setState(() {});
        }),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        item.isSelected! ? AppColor.appYellow() : Colors.white),
                color: item.isSelected! ? AppColor.appYellow() : Colors.white),
            child: Text(
              '${item.displayName}',
              textAlign: TextAlign.center,
              style: AppFont.poppinsMedium(10, color: Colors.black),
            )),
      );
    });
  }

  Widget filterBtmModalRegionUI(StateSetter setState, bool isOpen,
      List<CustomSelector> data, BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() {
              isOpen = !isOpen;
            }),
            child: Container(
              color: Colors.transparent,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      Utils.getTranslated(context, "regions"),
                      style: AppFont.montRegular(14, color: Colors.white),
                    ),
                  ),
                  Image.asset(isOpen
                      ? Constants.ASSET_IMAGES + 'white-arrow-up.png'
                      : Constants.ASSET_IMAGES + 'white-arrow-down.png')
                ],
              ),
            ),
          ),
          isOpen
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children:
                        data.map((e) => regFilterItem(context, e)).toList(),
                  ),
                )
              : const SizedBox(),
          Divider(
            color: AppColor.dividerColor(),
          ),
        ],
      );
    });
  }

  Widget regFilterItem(BuildContext ctx, CustomSelector item) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        onTap: (() {
          item.isSelected = !item.isSelected!;

          setState(() {});
        }),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        item.isSelected! ? AppColor.appYellow() : Colors.white),
                color: item.isSelected! ? AppColor.appYellow() : Colors.white),
            child: Text(
              '${item.displayName}',
              textAlign: TextAlign.center,
              style: AppFont.poppinsMedium(10, color: Colors.black),
            )),
      );
    });
  }

  onConfirm(BuildContext context, CustomShowModel showtimes,
      Child? selectedChild) async {
    if (isLogin) {
      Navigator.pushNamed(context, AppRoutes.movieSeatSelection,
          arguments: CustomSeatSelectionArg(
              opsdate: selectedOpsdate!,
              selectedShowtimesData: showtimes,
              title: showtimesDTO!.locations!.parentTitle!,
              fromWher: Constants.GSC_INIT_ENTRYPOINT_BYMOVIE,
              movieDetails: selectedChild));
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
