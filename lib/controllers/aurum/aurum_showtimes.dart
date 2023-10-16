import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:intl/intl.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/constants.dart';
import '../../const/utils.dart';
import '../../dio/api/movie_api.dart';
import '../../models/arguments/custom_seat_selection_arguments.dart';
import '../../models/arguments/custom_selection_model.dart';
import '../../models/arguments/custom_show_model.dart';
import '../../models/json/as_list_favourite_cinema_model.dart';
import '../../models/json/movie_home_model.dart';
import '../../models/json/movie_showtimes.dart';
import '../../routes/approutes.dart';
import '../../widgets/custom_rating_popup.dart';
import '../movies/widget/movie_slider.dart';
import '../movies/widget/showtime_accordion.dart';

class AurumShowtimesScreen extends StatefulWidget {
  final MovieToBuyArgs? data;
  const AurumShowtimesScreen({Key? key, this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AurumShowtimesScreen();
  }
}

class _AurumShowtimesScreen extends State<AurumShowtimesScreen> {
  MovieShowtimesDTO? showtimesDTO;
  MovieEpaymentDTO? movieDTO;
  List<Parent> movieList = [];
  List<Location>? locationDTO;
  List<Location>? locationList;
  double baseHeight = 280;
  var isLogin = false;
  String? previousID;
  List<CustomSelector> experienceSelectionList = [];
  List<CustomSelector> experienceFilterList = [];
  List<CustomSelector> hallTypeListFilter = [];
  List<CustomSelector> regionFilterList = [];
  List<String> preferredExpList = [];
  List<String> opsdateList = [];
  List<String> keyCap = [];
  String? selectedOpsdate;
  Parent? selectedMovie;
  List<AS_FAVOURITE_CINEMA> selectedFavourite = [];
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_SELECT_MOVIES_BY_OPSDATE_AURUM_SCREEN);

    super.initState();
    _checkLoginState();
    if (widget.data != null) {
      selectedMovie = widget.data!.movieData;
      if (selectedMovie != null) {
        getOpsdate(selectedMovie!);
      } else {
        EasyLoading.dismiss();
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            Utils.getTranslated(context, "no_movie_msg"),
            false,
            true, () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      }
    } else {
      _getAllAurumMovies();
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

  Future<MovieEpaymentDTO> getAllMovie(BuildContext context) async {
    MovieApi movieApi = MovieApi(context);
    return movieApi.getAllAurumMovie();
  }

  Future<MovieShowtimesDTO> getMovieShowtimes(
      BuildContext context, String opsdate, String parentId) async {
    MovieApi movieApi = MovieApi(context);
    return movieApi.getAurumShowtimesByOpsdate(opsdate, parentId);
  }

  _getAllAurumMovies() async {
    EasyLoading.show();

    await getAllMovie(context).then((data) {
      setState(() {
        if (data.films != null) {
          if (data.films!.parent != null) {
            movieList = data.films!.parent!;
            if (movieList.isNotEmpty) {
              selectedMovie = movieList.first;
            }
          }
        }
      });
    }).whenComplete(() {
      if (selectedMovie != null) {
        getOpsdate(selectedMovie!);
      } else {
        EasyLoading.dismiss();
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            Utils.getTranslated(context, "no_movie_msg"),
            false,
            true, () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      }
    }).catchError((e) {
      EasyLoading.dismiss();
      Utils.printInfo(e);
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          e != null
              ? e.message ?? Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          true, () {
        Navigator.of(context).pop();
      });
    });
  }

  getOpsdate(Parent movieData) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
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
      selectedOpsdate = opsdateList.firstWhere((element) =>
          DateTime.parse(element).isAfter(now) ||
          DateTime.parse(element).isAtSameMomentAs(now));
    });
    await getMovieShowtimes(context, selectedOpsdate!, movieData.code!)
        .then((value) {
          locationList = null;
          setState(() {
            showtimesDTO = value;
            locationDTO = value.locations!.location;
          });
          EasyLoading.dismiss();
        })
        .whenComplete(() => getAllFilterParams())
        .catchError((e) {
          EasyLoading.dismiss();
          Utils.printInfo(e);
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              e != null
                  ? e.message ?? Utils.getTranslated(context, "general_error")
                  : Utils.getTranslated(context, "general_error"),
              true,
              true, () {
            Navigator.of(context).pop();
          });
        });
  }

  Future<void> reloadLocation(Parent newSelectedMovie) async {
    setState(() {
      selectedMovie = newSelectedMovie;
    });
    getOpsdate(selectedMovie!);
  }

  reloadLocationNewDate() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getMovieShowtimes(context, selectedOpsdate!, selectedMovie!.code!)
        .then((value) {
      EasyLoading.dismiss();
      setState(() {
        showtimesDTO = value;
        locationDTO = value.locations!.location;
        keyCap.clear();
      });
    }).whenComplete(() => getAllFilterParams());
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

    setState(() {});
  }

  filterShowTimesFunction() {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    rearrangeDataList();
    preferredExpList.clear();

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
      return true;
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
      setState(() {});
    }
  }

  changeHeight(double height) {
    setState(() {
      baseHeight = height;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appBar(context, width),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomLeft,
                      colors: [
                    Colors.black,
                    Colors.black,
                    AppColor.aurumBase()
                  ])),
              child: Stack(
                children: [
                  Image.asset(
                      Constants.ASSET_IMAGES + 'aurum-showtime-base.png',
                      width: width,
                      height: baseHeight + 70,
                      color: Colors.white,
                      fit: BoxFit.cover),
                  if (selectedMovie != null && movieList.isNotEmpty)
                    CarouselMovieSlider(
                      data: MovieToBuyArgs(
                        selectedCode: selectedMovie!.code ?? '-',
                        allMovieData: movieList,
                        movieData: selectedMovie!,
                        firstDate: '',
                        availableDate: [],
                      ),
                      height: changeHeight,
                      allMovie: movieList,
                      changeMovie: reloadLocation,
                      isAurum: true,
                    ),
                ],
              ),
            ),
            _showtimesModule(context, width)
          ],
        ),
      ),
    );
  }

  Widget appBar(BuildContext context, double width) {
    return Container(
      height: kToolbarHeight,
      width: width,
      decoration: const BoxDecoration(color: Colors.transparent, boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 20.0,
          spreadRadius: 20.0,
          offset: Offset(0, -40),
        ),
      ]),
      child: Stack(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset(
              Constants.ASSET_IMAGES + 'white-left-icon.png',
              fit: BoxFit.cover,
              height: 28,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(Utils.getTranslated(context, 'showtimes'),
              style: AppFont.montRegular(18, color: Colors.white)),
        )
      ]),
    );
  }

  Widget dateSelectionSlider(
      BuildContext ctx, List<String> dateList, double width) {
    return Container(
      margin: const EdgeInsets.only(top: 22, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Text(Utils.getTranslated(context, 'select_date'),
                style: AppFont.montMedium(14, color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            width: width,
            height: 62,
            child: ListView(
              scrollDirection: Axis.horizontal,
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

          reloadLocationNewDate();
        }
      },
      child: Container(
        width: 44,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColor.aurumGold()),
            color: date == selectedOpsdate
                ? AppColor.aurumGold()
                : Colors.transparent),
        child: Column(
          children: [
            Text(
              DateFormat.E()
                  .format(DateFormat('yyyy-MM-dd').parse(date))
                  .toUpperCase(),
              style: AppFont.poppinsRegular(
                12,
                color: date == selectedOpsdate
                    ? AppColor.aurumDay()
                    : AppColor.lightGrey(),
              ),
            ),
            Text(
              DateFormat.d().format(DateFormat('yyyy-MM-dd').parse(date)),
              style: AppFont.montSemibold(
                18,
                color: date == selectedOpsdate ? Colors.black : Colors.white,
              ),
            ),
            Text(
              DateFormat.MMM().format(DateFormat('yyyy-MM-dd').parse(date)),
              style: AppFont.poppinsRegular(
                10,
                color: date == selectedOpsdate
                    ? Colors.black
                    : AppColor.aurumGold(),
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget _showtimesModule(BuildContext context, double width) {
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
        width: width,
        color: AppColor.aurumBase(),
        child: Container(
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
              dateSelectionSlider(context, opsdateList, width),
              experienceSelectionList.isNotEmpty
                  ? experienceSelectionSection(
                      context, experienceSelectionList, width)
                  : const SizedBox(),
              Divider(
                thickness: 1,
                color: AppColor.aurumDay(),
              ),
              const Padding(
                padding: EdgeInsets.only(
                  top: 5,
                ),
              ),
              locationList != null
                  ? checkShowtimes(locationList)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (var i = 0; i < locationList!.length; i++)
                              Accordion(
                                data: locationList![i],
                                index: i,
                                filter: preferredExpList,
                                isAurum: true,
                                viewMoreToggle: addViewMoreId,
                                previousID: previousID,
                                viewMore: keyCap,
                                isReset: rearrangeDataList,
                                selectShow: moviePopUpModule,
                                isOpsdateChange: selectedOpsdate ?? '',
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
              const SizedBox(
                height: 16,
              )
            ],
          ),
        ),
      );
    });
  }

  Widget experienceSelectionSection(
      BuildContext ctx, List<CustomSelector> expList, double width) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Text(Utils.getTranslated(context, 'select_experience'),
                style: AppFont.montMedium(14, color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            width: width,
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
    return InkWell(
        onTap: (() {
          item.isSelected = !item.isSelected!;

          setState(() {
            filterShowTimesFunction();
          });
        }),
        child: MapCinemaExperiences.experiences[item.displayName] != null
            ? Container(
                margin: const EdgeInsets.only(right: 10),
                width: (MediaQuery.of(context).size.width - 30 - 32) / 4,
                child: Image.asset(
                  item.isSelected!
                      ? MapCinemaExperiences
                          .aurumExperiencesSelected[item.displayName]
                      : MapCinemaExperiences.aurumExperiences[item.displayName],
                  fit: BoxFit.cover,
                  width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColor.aurumGold()),
                    color:
                        item.isSelected! ? AppColor.aurumGold() : Colors.black,
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
                width: (MediaQuery.of(context).size.width - 30 - 32) / 4,
                height: 40,
                child: Center(
                  child: Text(
                    '${item.code}',
                    textAlign: TextAlign.center,
                    style: AppFont.poppinsSemibold(18,
                        color: item.isSelected!
                            ? AppColor.aurumBase()
                            : AppColor.aurumGold()),
                  ),
                ),
              ));
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

  moviePopUpModule(CustomShowModel showtimes) {
    String hallDisplayName = '';
    var ratingAssetName = MovieClassification.movieRating[showtimes.rating];
    double physicalSizeheight =
        WidgetsBinding.instance.window.physicalSize.height;
    setState(() {
      previousID = showtimes.id;
    });

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
                                          : Text(
                                              type,
                                              style: AppFont.montBold(14,
                                                  color: AppColor.aurumGold()),
                                            ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        thickness: 1,
                        color: AppColor.aurumDay(),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.all(physicalSizeheight > 2000 ? 16.0 : 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              Utils.getTranslated(
                                  context, "aurum_cinema_title"),
                              style:
                                  AppFont.montRegular(14, color: Colors.white)),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            '${showtimes.locationDisplayName}',
                            style: AppFont.poppinsMedium(14,
                                color: AppColor.aurumGold()),
                          ),
                          SizedBox(
                            height: physicalSizeheight > 2000 ? 19 : 14,
                          ),
                          Text(Utils.getTranslated(context, "hall"),
                              style:
                                  AppFont.montRegular(14, color: Colors.white)),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            hallDisplayName,
                            style: AppFont.poppinsMedium(14,
                                color: AppColor.aurumGold()),
                          ),
                          SizedBox(
                            height: physicalSizeheight > 2000 ? 19 : 14,
                          ),
                          Text(Utils.getTranslated(context, "time_and_date"),
                              style:
                                  AppFont.montRegular(14, color: Colors.white)),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            difference > 0
                                ? "${DateFormat('E dd MMM').format(opsDate)}, ${showtimes.timestr} (${showtimes.displayDate})"
                                : "${showtimes.displayDate}, ${showtimes.timestr}", //  '
                            style: AppFont.poppinsMedium(14,
                                color: AppColor.aurumGold()),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Location s = locationDTO!.firstWhere(
                            (element) => element.id == showtimes.locationID);
                        Child selectedChild = s.child!.firstWhere(
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
                                  isAurum: true,
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
                                  isAurum: true,
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
                              color: AppColor.aurumGold(),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRoutes.movieDetailsRoute,
                            arguments: [selectedMovie?.code, true, true]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColor.aurumGold(), width: 2),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
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
                                  fit: BoxFit.cover);
                            },
                          ),
                        ),
                      ),
                    ),
                    ratingAssetName != null
                        ? Container(
                            margin: EdgeInsets.only(
                                top: physicalSizeheight > 2000 ? 195 : 170,
                                left: 12),
                            child: Image.asset(
                              ratingAssetName,
                              height: 30,
                              width: 30,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 30,
                                  width: 30,
                                );
                              },
                            ),
                          )
                        : const SizedBox(
                            height: 30,
                            width: 30,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onConfirm(BuildContext context, CustomShowModel showtimes,
      Child? selectedChild) async {
    if (isLogin) {
      Navigator.pushNamed(context, AppRoutes.movieSeatSelection,
          arguments: CustomSeatSelectionArg(
              selectedShowtimesData: showtimes,
              title: showtimesDTO!.locations!.parentTitle!,
              movieDetails: selectedChild,
              opsdate: selectedOpsdate ?? "",
              fromWher: Constants.GSC_INIT_ENTRYPOINT_BYMOVIE,
              isAurum: true));
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
