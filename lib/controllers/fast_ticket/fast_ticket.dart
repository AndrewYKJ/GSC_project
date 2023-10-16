import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/booking_api.dart';
import 'package:gsc_app/dio/api/movie_api.dart';
import 'package:gsc_app/dio/api/movie_showtimes.dart';
import 'package:gsc_app/models/arguments/custom_seat_selection_arguments.dart';
import 'package:gsc_app/models/arguments/custom_show_model.dart';
import 'package:gsc_app/models/json/as_list_favourite_cinema_model.dart';
import 'package:gsc_app/models/json/booking_model.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/custom_favourite_button.dart';
import 'package:gsc_app/widgets/custom_rating_popup.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../const/analytics_constant.dart';
import '../../models/arguments/appcache_object_model.dart';
import '../../models/arguments/appcache_profile_model.dart';

class FastTicketScreen extends StatefulWidget {
  const FastTicketScreen({Key? key}) : super(key: key);

  @override
  _FastTicketScreen createState() => _FastTicketScreen();
}

class _FastTicketScreen extends State<FastTicketScreen> {
  List<BookingModel> tickets = [];
  List<Parent>? movieList = [];
  List<String> movieDateList = [];
  List<Show> showtimeList = [];
  MovieShowtimesDTO? showtimesDTO;
  List<Location>? locationDTO;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String memberId = AppCache.me?.MemberLists?.first.MemberID ?? "";
  String email = AppCache.me?.MemberLists?.first.Email ?? "";
  String phoneNo = AppCache.me?.MemberLists?.first.MobileNo ?? "";
  String token = "1";
  Parent? recommendedMovie;
  Show? recommendedShowTime;
  String recommendedDate = '';
  String recommendedTime = '';
  String recommendedCinema = '';
  String recommendedLocationId = '';
  String recommendedHallGroup = '';
  List<Location> favLocationList = [];
  bool isFavourite = false;
  Location? recLocation;
  bool viewMore = false;
  bool isLogin = false;
  final scrollController = ScrollController();
  double scrollMark = 0;
  bool isReversing = false;
  bool init = false;
  final ItemScrollController itemScrollController = ItemScrollController();
  AppCacheObjectModel? storedData;
  bool changedCinema = false;
  bool changedFromRecCinema = false;
  bool changedFromRecMovie = false;
  bool changedFromRecDate = false;
  bool changedFromRecTime = false;
  bool showMore = false;

  Future<void> checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken && AppCache.me != null) {
      setState(() {
        isLogin = true;
      });
    }
  }

  Future<BookingWrapper> getMyTickets(BuildContext context, String currentDate,
      String memberId, String email, String phoneno, String token) async {
    BookingApi bookingApi = BookingApi(context);
    return bookingApi.getTickets(currentDate, memberId, email, phoneno, token);
  }

  Future<MovieEpaymentDTO> getMovieDTO(BuildContext context) async {
    MovieApi movieApi = MovieApi(context);
    return movieApi.getMovie();
  }

  Future<MovieShowtimesDTO> getMovieShowtimes(
      BuildContext context, String opsdate, String parentId) async {
    MovieShowtimes showtimesApi = MovieShowtimes(context);
    return showtimesApi.getShowtimesByOpsdate(opsdate, parentId);
  }

  getFavouriteList() {
    if (AppCache.me?.MemberLists?.first.MemberID != null) {
      if (AppCache.me?.MemberLists?.first.DynamicFieldLists != null) {
        if (AppCache.me!.MemberLists!.first.DynamicFieldLists!.any((element) =>
            element.name == Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)) {
          List<AS_FAVOURITE_CINEMA> tempfile = Utils.setASFavCinemaToList(
              AppCache.me!.MemberLists!.first.DynamicFieldLists!
                  .firstWhere((element) =>
                      element.name ==
                      Constants.ASCENTIS_DYNAMIC_FAV_CINEMA_CODE)
                  .colValue);

          favLocationList = locationDTO!
              .where((l) => tempfile.any((t) => t.id.toString() == l.id))
              .toList();
        }
      }
    }

    if (recLocation != null) {
      recommendedCinema = recLocation!.id!;

      isFavourite = favLocationList.any((element) =>
          element.id == recLocation!.id &&
          element.hallGroup == recLocation!.hallGroup);
    }
  }

  findLatestTicketHistory() {
    if (tickets.isNotEmpty) {
      var latestTicket = tickets.first;
      recommendedDate = latestTicket.showdate!;
      recommendedTime = latestTicket.showtime!;
      recommendedLocationId = latestTicket.locationid!;
      recommendedHallGroup =
          latestTicket.hallgroup != null ? latestTicket.hallgroup! : '';
      var splitData = latestTicket.showtime!.split(':');
      String timeIn24 = '';
      if (latestTicket.showtime!.contains("AM")) {
        var hour = splitData[0] == '12' ? '00' : splitData[0];
        var minute = splitData[1].substring(0, 2);
        timeIn24 = '$hour$minute';
      } else {
        var hour = int.parse(splitData[0]) + 12;
        var minute = splitData[1].substring(0, 2);
        timeIn24 = '$hour$minute';
      }
      recommendedTime = timeIn24;
    } else {
      recommendedDate = '';
      recommendedTime = '';
      recommendedLocationId = '';
      recommendedHallGroup = '';
      recommendedTime = '';
    }
  }

  resetMovieDate() {
    recommendedDate = movieDateList[0];
    if (movieDateList.isNotEmpty) {
      autoScrollToSelectedDate(movieDateList.indexOf(recommendedDate));
    }

    recommendedShowTime = null;
  }

  findClosetsMovieDate(bool isSwitchMovie) {
    findLatestTicketHistory();
    List<DateTime> showDateList = [];
    movieDateList.clear();
    recLocation = null;
    // for (var element in recommendedMovie!.child!) {
    var element = recommendedMovie!.child!.first;
    for (var showDate in element.show!) {
      DateTime sDate = DateTime.parse(showDate.opsdate!);
      if (!showDateList.contains(sDate)) {
        showDateList.add(sDate);
        movieDateList.add(showDate.opsdate!);
        movieDateList.sort((a, b) {
          DateTime timeA = DateFormat('yyyy-MM-dd').parse(a);
          DateTime timeB = DateFormat('yyyy-MM-dd').parse(b);
          return timeA.compareTo(timeB);
        });
      }
    }
    // }

    if ((changedFromRecTime || changedFromRecDate) &&
        (changedFromRecMovie || changedFromRecCinema)) {
      recommendedDate = "";
    }

    if (recommendedDate.isNotEmpty) {
      var recDateTime = DateTime.parse(recommendedDate);
      var nowFormat = DateFormat("yyyy-MM-dd").format(DateTime.now());
      var now = DateTime.parse(nowFormat);
      late dynamic nextRecDateTime;
      if (now.compareTo(recDateTime) == 0) {
        nextRecDateTime = now.add(const Duration(days: 7));
      } else if (recDateTime.isAfter(now)) {
        nextRecDateTime = recDateTime.add(const Duration(days: 7));
      } else {
        if (recDateTime.weekday == now.weekday) {
          nextRecDateTime = now.add(const Duration(days: 7));
        } else if (recDateTime.weekday < now.weekday) {
          var diff = 7 - (now.weekday - recDateTime.weekday);
          nextRecDateTime = now.add(Duration(days: diff));
        } else {
          var diff = recDateTime.weekday - now.weekday;
          nextRecDateTime = now.add(Duration(days: diff));
        }
      }

      var closetsDate = showDateList.reduce((a, b) =>
          a.difference(nextRecDateTime).abs() <
                  b.difference(nextRecDateTime).abs()
              ? a
              : b);
      recommendedDate = DateFormat('yyyy-MM-dd').format(closetsDate);
    } else {
      recommendedDate = movieDateList[0];
    }

    if (isSwitchMovie) {
      if (movieDateList.isNotEmpty) {
        autoScrollToSelectedDate(movieDateList.indexOf(recommendedDate));
      }
    } else {
      init = true;
    }

    getOpsdate(recommendedDate);
  }

  findShowTimesByLocation() {
    showtimeList.clear();
    for (var element in recLocation!.child!) {
      for (var showtime in element.show!) {
        showtimeList.add(showtime);
      }
    }

    showtimeList.sort((a, b) {
      return Utils.compareAndArrangeTimes(a.time!, b.time!);
    });

    if (recommendedTime.isNotEmpty) {
      List<int> differenceList = [];
      for (var i = 0; i < showtimeList.length; i++) {
        int timeInInt = int.parse(recommendedTime);
        DateTime dt1 = DateTime.parse(showtimeList[i].date!);
        DateTime dt2 = DateTime.parse(recommendedDate);
        int showtimeInInt = dt1.compareTo(dt2) > 0
            ? int.parse(showtimeList[i].time!) + 2400
            : int.parse(showtimeList[i].time!);

        if (showtimeInInt > timeInInt) {
          int difference = showtimeInInt - timeInInt;
          differenceList.add(difference);
        } else {
          int difference = timeInInt - showtimeInInt;
          differenceList.add(difference);
        }
      }

      int index =
          differenceList.indexWhere((e) => e == differenceList.reduce(min));
      if (index > 6) {
        setState(() {
          showMore = true;
          viewMore = showMore;
        });
      }

      recommendedShowTime = showtimeList[index];
      recommendedShowTime ??= showtimeList[0];
    } else {
      recommendedShowTime = showtimeList[0];
    }

    if (changedCinema) {
      recommendedShowTime = null;
      setState(() {
        changedCinema = false;
      });
    } else {
      if ((changedFromRecTime || changedFromRecDate) &&
          (changedFromRecMovie || changedFromRecCinema)) {
        recommendedShowTime = null;
      }
    }
  }

  getMovie() async {
    if (AppCache.movieEpaymentList?.films?.parent == null) {
      await getMovieDTO(context).then((value) {
        movieList = value.films!.parent!;
        AppCache.movieEpaymentList = value;
        recommendedMovie = movieList!.first;
        if (tickets.isNotEmpty) {
          var matchMovie = recommendedMovie!.child!
              .where((element) => element.code == tickets.first.filmid);
          if (matchMovie.isNotEmpty) {
            recommendedMovie = movieList![1];
          }
        }

        findClosetsMovieDate(false);
      }).catchError((e) {
        setState(() {
          EasyLoading.dismiss();
        });
      });
    } else {
      movieList = AppCache.movieEpaymentList!.films!.parent!;
      recommendedMovie = movieList!.first;
      if (tickets.isNotEmpty) {
        var matchMovie = recommendedMovie!.child!
            .where((element) => element.code == tickets.first.filmid);
        if (matchMovie.isNotEmpty) {
          recommendedMovie = movieList![1];
        }
      }

      findClosetsMovieDate(false);
    }
  }

  getOpsdate(String recommendedDate) async {
    await getMovieShowtimes(context, recommendedDate, recommendedMovie!.code!)
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
        showtimesDTO = value;
        locationDTO = value.locations!.location;

        getFavouriteList();
        if (value.locations != null && value.locations!.location!.isNotEmpty) {
          if (recLocation == null) {
            if (favLocationList.isNotEmpty) {
              bool isMatch = false;
              for (var favLoc in favLocationList) {
                for (var loc in value.locations!.location!) {
                  if (favLoc.id == loc.id &&
                      favLoc.hallGroup == loc.hallGroup) {
                    isMatch = true;
                    recLocation = loc;
                    break;
                  }
                }
              }

              if (recLocation == null && !isMatch) {
                recLocation = value.locations!.location!.first;
              }
            } else {
              if (recommendedLocationId.isEmpty) {
                recLocation = value.locations!.location!.first;
              } else {
                var result = value.locations!.location!.where((element) =>
                    (element.id == recommendedLocationId &&
                        element.hallGroup == recommendedHallGroup));
                if (result.isEmpty) {
                  recLocation = value.locations!.location!.first;
                } else {
                  recLocation = result.first;
                }
              }
            }
          } else {
            var dataIndex = value.locations!.location!.indexWhere((element) =>
                element.id == recLocation!.id &&
                element.hallGroup == recLocation!.hallGroup);
            var oldCinema = recLocation;
            recLocation = dataIndex > -1
                ? value.locations!.location![dataIndex]
                : value.locations!.location!.first;
            setState(() {
              changedCinema = recLocation != oldCinema;
            });

            if (changedCinema && dataIndex < 0) {
              Utils.showAlertDialog(
                  context,
                  Utils.getTranslated(context, "info_title"),
                  Utils.getTranslated(context, "fast_ticket_change_loc_popup")
                      .replaceAll(RegExp(r'\<oldCinema>'),
                          oldCinema?.epaymentName ?? "")
                      .replaceAll(
                          '<newCinema>', recLocation?.epaymentName ?? ""),
                  true,
                  false, () {
                Navigator.pop(context);
              });
            }
          }

          findShowTimesByLocation();
        }
      }
    }).whenComplete(() {
      setState(() {
        viewMore = showMore;
        EasyLoading.dismiss();
      });
    });
  }

  checkCacheTicket() async {
    if (AppCache.tickets != null) {
      if (AppCache.tickets!.isNotEmpty) {
        tickets = AppCache.tickets!;
        findLatestTicketHistory();
        getMovie();
      } else {
        getTicketInfo();
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
                  getTicketInfo();
                } else {
                  if (storedData!.ticket!.cacheData != null) {
                    AppCache.tickets =
                        toResponseList(storedData!.ticket!.cacheData);
                    tickets = toResponseList(storedData!.ticket!.cacheData);
                    findLatestTicketHistory();
                    getMovie();
                  } else {
                    getTicketInfo();
                  }
                }
              } else {
                getTicketInfo();
              }
            } else {
              getTicketInfo();
            }
          } else {
            getTicketInfo();
          }
        });
      } else {
        getTicketInfo();
      }
    }
  }

  List<BookingModel> toResponseList(List<dynamic> data) {
    List<BookingModel> value = <BookingModel>[];
    for (var element in data) {
      value.add(BookingModel.fromJson(element));
    }
    return value;
  }

  getTicketInfo() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getMyTickets(context, currentDate, memberId, email, phoneNo, token)
        .then((data) {
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
                storedData!.ticket!.cacheDate =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                storedData!.ticket!.cacheData = data.success!.booking!;
              } else {
                var ticketObj = AppCacheProfileModel();
                ticketObj.cacheDate =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                ticketObj.cacheData = data.success!.booking!;
                storedData!.ticket = ticketObj;
              }
              AppCache.setString(
                  AppCache.SPLASH_SCREEN_REF, json.encode(storedData));
            }
            tickets = data.success!.booking!;
            AppCache.tickets = data.success!.booking!;
            findLatestTicketHistory();
          }
        }
        getMovie();
      }
    }).catchError((e) {
      Utils.printInfo(e);
      setState(() {
        EasyLoading.dismiss();
      });
    });
  }

  addScrollControlListener() {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if ((scrollMark - scrollController.position.pixels) > 50.0) {
          setState(() {
            isReversing = false;
          });
        }
      } else {
        scrollMark = scrollController.position.pixels;
        setState(() {
          isReversing = true;
        });
      }
    });
  }

  autoScrollToSelectedDate(int i) {
    itemScrollController.scrollTo(
        index: i,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOutCubic);
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_FAST_TICKET_SCREEN);
    addScrollControlListener();
    super.initState();
    checkLoginState();
    checkCacheTicket();
  }

  void postFrameCallback(_) {
    if (movieDateList.isNotEmpty) {
      autoScrollToSelectedDate(movieDateList.indexOf(recommendedDate));
    }
    init = false;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (init) {
      SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: AppColor.backgroundBlack(),
        centerTitle: true,
        title: Text(
          Utils.getTranslated(context, 'fast_ticket'),
          style: AppFont.montMedium(18, color: Colors.white),
        ),
        leading: InkWell(
          onTap: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          child: Image.asset('assets/images/white-left-icon.png'),
        ),
      ),
      body: Container(
        width: width,
        height: height,
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    selectMovies(context),
                    selectCinemas(context),
                    selectDateTime(context),
                  ],
                ),
              ),
              (isReversing &&
                      scrollController.position.pixels > 0.0 &&
                      recLocation != null)
                  ? topDisplayInfoLayout(context, width)
                  : const SizedBox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Container(
          margin:
              const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: !(recommendedMovie == null ||
                        recLocation == null ||
                        recommendedShowTime == null)
                    ? AppColor.appYellow()
                    : AppColor.checkOutDisabled(),
                padding: const EdgeInsets.only(top: 6, bottom: 6)),
            onPressed: () {
              if (!(recommendedMovie == null ||
                  recLocation == null ||
                  recommendedShowTime == null)) {
                if (recommendedShowTime == null) {
                  Utils.showAlertDialog(
                      context,
                      Utils.getTranslated(context, "info_title"),
                      Utils.getTranslated(
                          context, "fast_ticket_showtime_empty"),
                      true,
                      false, () {
                    Navigator.pop(context);
                  });
                  return;
                }

                Child recChild = recLocation!.child!.firstWhere(
                    (element) => element.show!.contains(recommendedShowTime));
                var customModel = CustomShowModel(
                    childID: recChild.code,
                    locationID: recLocation!.id,
                    locationDisplayName: recLocation!.epaymentName,
                    rating: recChild.rating,
                    id: recommendedShowTime!.id,
                    date: recommendedShowTime!.date,
                    time: recommendedShowTime!.time,
                    timestr: recommendedShowTime!.timestr,
                    hid: recommendedShowTime!.hid,
                    hname: recommendedShowTime!.hname,
                    hallfull: recommendedShowTime!.hallfull,
                    hallorder: recommendedShowTime!.hallorder,
                    barcodeEnabled: recommendedShowTime!.barcodeEnabled,
                    displayDate: recommendedShowTime!.displayDate,
                    hasGscPrivilege: recommendedShowTime!.hasGscPrivilege,
                    type: recommendedShowTime!.type,
                    typeDesc: recommendedShowTime!.typeDesc,
                    freelist: recommendedShowTime!.freelist,
                    filmType: recChild.filmType);
                moviePopUpModule(context, customModel);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                Utils.getTranslated(context, "confirm_btn"),
                style: AppFont.montSemibold(14, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar(BuildContext context, double width) {
    return Container(
      height: kToolbarHeight,
      width: width,
      decoration: BoxDecoration(
        color: AppColor.backgroundBlack(),
      ),
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
          child: Text(Utils.getTranslated(context, 'fast_ticket'),
              style: AppFont.montMedium(18, color: Colors.white)),
        )
      ]),
    );
  }

  Widget selectMovies(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 30),
      decoration: BoxDecoration(
        color: AppColor.backgroundBlack(),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslated(context, "fast_ticket_select_movie_label"),
            style: AppFont.montMedium(
              14,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            Utils.getTranslated(context, "fast_ticket_select_movie_desc"),
            style: AppFont.montRegular(
              12,
              color: AppColor.greyWording(),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (recommendedMovie == null &&
                      recommendedMovie?.child?.first.thumbBig == null)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width - 32 - 14,
                      child: Center(
                        child: Text(
                            Utils.getTranslated(context, 'no_record_found'),
                            style: AppFont.montRegular(16,
                                color: AppColor.dividerColor())),
                      ),
                    )
                  : Container(),
              (recommendedMovie != null &&
                      recommendedMovie!.child!.first.thumbBig != null)
                  ? SizedBox(
                      width: 129,
                      height: 189,
                      child: Image.network(
                        recommendedMovie!.child!.first.thumbBig!,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                              'assets/images/Default placeholder_app_img.png',
                              fit: BoxFit.cover);
                        },
                      ),
                    )
                  : Container(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    recommendedMovie != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (recommendedMovie!.child!.first.rating != null &&
                                      MovieClassification.movieRating[
                                              recommendedMovie!
                                                  .child!.first.rating] !=
                                          null &&
                                      MovieClassification.movieRating[
                                              recommendedMovie!
                                                  .child!.first.rating] !=
                                          "")
                                  ? Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Image.asset(
                                        MovieClassification.movieRating[
                                            recommendedMovie!
                                                .child!.first.rating],
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ))
                                  : Container(),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.movieDetailsRoute,
                                      arguments: [
                                        recommendedMovie!.code,
                                        false,
                                        true
                                      ]);
                                },
                                child: Image.asset(
                                  Constants.ASSET_IMAGES + "info-icon.png",
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                ),
                              )
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 10),
                    Text(
                      (recommendedMovie != null &&
                              recommendedMovie!.title!.isNotEmpty)
                          ? recommendedMovie!.title!
                          : '',
                      style: AppFont.montBold(
                        14,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      (recommendedMovie != null)
                          ? '${Utils.formatDuration(recommendedMovie!.child!.first.duration!)} • ${Utils.getLanguageName(recommendedMovie!.child!.first.lang!)}'
                          : '',
                      style: AppFont.poppinsRegular(
                        10,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            color: AppColor.dividerColor(),
          ),
          const SizedBox(height: 20),
          Center(
            child: InkWell(
              onTap: () async {
                if (movieList != null && movieList!.isNotEmpty) {
                  var navigatorResult = await Navigator.pushNamed(
                      context, AppRoutes.movieNameListingRoute,
                      arguments: [movieList, recommendedMovie]);

                  if (navigatorResult != null) {
                    setState(() {
                      isReversing = false;
                      var newMovie = navigatorResult as Parent;
                      if (recommendedMovie != null) {
                        if (newMovie.code != recommendedMovie?.code) {
                          recommendedMovie = newMovie;
                          changedFromRecMovie = true;
                          Utils.showAlertDialog(
                              context,
                              Utils.getTranslated(context, "info_title"),
                              Utils.getTranslated(context,
                                  "fast_ticket_change_selection_popup"),
                              true,
                              false, () {
                            Navigator.pop(context);
                          });
                        }
                      }

                      if (changedFromRecDate || changedFromRecTime) {
                        resetMovieDate();
                      } else {
                        findClosetsMovieDate(true);
                      }
                    });
                  }
                }
              },
              child: SizedBox(
                width: 150,
                child: Container(
                  padding: const EdgeInsets.only(top: 14, bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: AppColor.appYellow(),
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    Utils.getTranslated(context, "fast_ticket_change_text"),
                    style: AppFont.montRegular(
                      14,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectCinemas(BuildContext context) {
    String cinemaLocation = '';
    if (recLocation != null) {
      cinemaLocation = recLocation!.epaymentName!;
    }
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 30),
      decoration: BoxDecoration(
        color: AppColor.backgroundBlack(),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslated(context, "fast_ticket_select_cinema_label"),
            style: AppFont.montMedium(
              14,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            Utils.getTranslated(context, "fast_ticket_select_cinema_desc"),
            style: AppFont.montRegular(
              12,
              color: AppColor.greyWording(),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 28),
          recLocation != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FavouriteButton(
                      isReload: () {},
                      isAurum: false,
                      isFavourite: isFavourite,
                      cinemaId: int.parse(recLocation?.id ?? '0'),
                      hallGroup: recLocation?.hallGroup ?? '',
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        cinemaLocation,
                        style: AppFont.montRegular(
                          14,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(Utils.getTranslated(context, 'no_record_found'),
                      style: AppFont.montRegular(16,
                          color: AppColor.dividerColor())),
                ),
          const SizedBox(height: 20),
          Divider(
            color: AppColor.dividerColor(),
          ),
          const SizedBox(height: 20),
          Center(
            child: InkWell(
              onTap: () async {
                if (locationDTO != null && locationDTO!.isNotEmpty) {
                  var navigatorResult = await Navigator.pushNamed(
                      context, AppRoutes.cinemaNameListingRoute,
                      arguments: [locationDTO, recLocation, favLocationList]);
                  setState(() {
                    if (navigatorResult != null) {
                      if (navigatorResult is Location) {
                        isReversing = false;
                        var newCinema = navigatorResult;
                        if (recLocation != null) {
                          if (newCinema.id != recLocation?.id ||
                              newCinema.hallGroup != recLocation?.hallGroup) {
                            recLocation = newCinema;
                            changedFromRecCinema = true;
                            Utils.showAlertDialog(
                                context,
                                Utils.getTranslated(context, "info_title"),
                                Utils.getTranslated(context,
                                    "fast_ticket_change_selection_popup"),
                                true,
                                false, () {
                              Navigator.pop(context);
                            });
                          }
                        }

                        findShowTimesByLocation();
                        if (changedFromRecDate || changedFromRecTime) {
                          resetMovieDate();
                        }
                      }
                      getFavouriteList();
                    }
                  });
                }
              },
              child: SizedBox(
                width: 150,
                child: Container(
                  padding: const EdgeInsets.only(top: 14, bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: AppColor.appYellow(),
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    Utils.getTranslated(context, "fast_ticket_change_text"),
                    style: AppFont.montRegular(
                      14,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectDateTime(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 30),
      decoration: BoxDecoration(
        color: AppColor.backgroundBlack(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslated(context, "fast_ticket_time_convenience_label"),
            style: AppFont.montMedium(
              14,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            Utils.getTranslated(context, "fast_ticket_time_convenience_desc"),
            style: AppFont.montRegular(
              12,
              color: AppColor.greyWording(),
              decoration: TextDecoration.none,
            ),
          ),
          movieDateList.isNotEmpty && showtimeList.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    movieDateList.isNotEmpty
                        ? dateSelectionSlider(context, movieDateList,
                            MediaQuery.of(context).size.width)
                        : const SizedBox(),
                    showtimeList.isNotEmpty
                        ? experienceShowTimeSection(context)
                        : const SizedBox()
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32 - 14,
                    child: Center(
                      child: Text(
                          Utils.getTranslated(context, 'no_record_found'),
                          style: AppFont.montRegular(16,
                              color: AppColor.dividerColor())),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget dateSelectionSlider(
      BuildContext ctx, List<String> dateList, double width) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
            child: Text(
              Utils.getTranslated(context, 'select_date'),
              style: AppFont.montMedium(
                14,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: width,
            height: 62,
            child: ScrollablePositionedList.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dateList.length,
              itemBuilder: (context, index) =>
                  dateItem(context, dateList[index]),
              itemScrollController: itemScrollController,
            ),
          ),
        ],
      ),
    );
  }

  Widget dateItem(BuildContext context, String date) {
    return InkWell(
      onTap: () {
        setState(() {
          if (date != recommendedDate) {
            changedFromRecDate = true;
          }
          recommendedDate = date;
          showMore = false;
          getOpsdate(recommendedDate);
        });
      },
      child: Container(
        width: 48,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: date == recommendedDate
                ? Border.all(color: AppColor.appYellow())
                : Border.all(color: Colors.white),
            color: date == recommendedDate
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
              style: AppFont.poppinsSemibold(
                18,
                color: date == recommendedDate ? Colors.black : Colors.white,
              ),
            ),
            Text(
              DateFormat.MMM().format(DateFormat('yyyy-MM-dd').parse(date)),
              style: AppFont.poppinsRegular(10,
                  color: date == recommendedDate
                      ? Colors.black
                      : AppColor.appYellow(),
                  height: 1),
              textAlign: TextAlign.end,
            )
          ],
        ),
      ),
    );
  }

  Widget experienceShowTimeSection(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.only(top: 40, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
                Utils.getTranslated(
                    context, "fast_ticket_experience_and_time_label"),
                style: AppFont.montMedium(14, color: Colors.white)),
          ),
          showList(context)
        ],
      ),
    );
  }

  Widget showList(BuildContext context) {
    var count = !viewMore && showtimeList.length > 7 ? 8 : showtimeList.length;
    return Wrap(spacing: 8, runSpacing: 10, children: [
      for (var i = 0; i < count; i++)
        showtimesItems(context, i, showtimeList[i])
    ]);
  }

  Widget showtimesItems(BuildContext context, int index, Show show) {
    String time24 = show.time!;
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

    if (index == 7 && !viewMore && showtimeList.length > 8) {
      return InkWell(
        onTap: () {
          setState(() {
            viewMore = true;
          });
        },
        child: Container(
          width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
          height: 65,
          decoration: BoxDecoration(
              border: Border.all(color: AppColor.yellow()),
              borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(
              Utils.getTranslated(context, "more_btn"),
              textAlign: TextAlign.center,
              style: AppFont.poppinsRegular(12, color: AppColor.yellow()),
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          setState(() {
            if (recommendedShowTime != show) {
              changedFromRecTime = true;
            }

            recommendedShowTime = show;
          });
        },
        child: Container(
          height: 65,
          width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
          decoration: BoxDecoration(
              color: recommendedShowTime != null
                  ? recommendedShowTime!.id == show.id
                      ? AppColor.appYellow()
                      : Colors.transparent
                  : Colors.transparent,
              border: Border.all(
                color: recommendedShowTime != null
                    ? recommendedShowTime!.id == show.id
                        ? AppColor.appYellow()
                        : Colors.white
                    : Colors.white,
              ),
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
                        color: recommendedShowTime != null
                            ? recommendedShowTime!.id == show.id
                                ? Colors.black
                                : Colors.white
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
                    show.type ?? '',
                    textAlign: TextAlign.center,
                    style: AppFont.poppinsRegular(12,
                        height: 1,
                        color: recommendedShowTime != null
                            ? recommendedShowTime!.id == show.id
                                ? Colors.black
                                : Colors.white
                            : Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  moviePopUpModule(BuildContext context, CustomShowModel showtimes) {
    String hallDisplayName = '';
    var ratingAssetName = MovieClassification.movieRating[showtimes.rating];
    double physicalSizeheight =
        WidgetsBinding.instance.window.physicalSize.height;

    var typeList = showtimes.typeDesc!.replaceAll(";", ", ").split(",");
    final itmDate = DateTime.parse(showtimes.date!);
    final opsDate = DateTime.parse(recommendedDate);
    final difference = itmDate.difference(opsDate).inDays;

    if (showtimes.hname != null) {
      if (int.tryParse(showtimes.hname!) != null) {
        showtimes.hname!.toLowerCase().contains('hall')
            ? hallDisplayName = showtimes.hname!
            : hallDisplayName =
                "${Utils.getTranslated(context, "hall")} ${showtimes.hname}";
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
                                recommendedMovie!.title!,
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
                                      recommendedMovie!.child!.first.duration!),
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
                                      recommendedMovie!.child!.first.lang!),
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
                          Text(
                              Utils.getTranslated(
                                  context, "aurum_cinema_title"),
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
                                : "${showtimes.displayDate}, ${showtimes.timestr}", //  '
                            style: AppFont.poppinsMedium(14,
                                color: AppColor.appYellow()),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Location s = recLocation!;

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
                              color: AppColor.appYellow(),
                              borderRadius: BorderRadius.circular(6))),
                    ),
                    SizedBox(
                      height: physicalSizeheight > 2000 ? 20 : 14,
                    ),
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
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.movieDetailsRoute,
                            arguments: [recommendedMovie?.code, false, true]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recommendedMovie!.child!.first.thumbBig!,
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

  onConfirm(BuildContext context, CustomShowModel showtimes,
      Child? selectedChild) async {
    if (isLogin) {
      Navigator.pushNamed(context, AppRoutes.movieSeatSelection,
          arguments: CustomSeatSelectionArg(
              opsdate: recommendedDate,
              selectedShowtimesData: showtimes,
              title: showtimesDTO!.locations!.parentTitle!,
              fromWher: Constants.GSC_INIT_ENTRYPOINT_FASTICKET,
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

  Widget topDisplayInfoLayout(BuildContext context, double width) {
    return GestureDetector(
      onTap: () {
        scrollController.animateTo(
          0.0,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 500),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColor.appYellow(),
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10, top: 14),
                      padding: const EdgeInsets.only(top: 3),
                      decoration: DottedDecoration(
                          shape: Shape.line,
                          linePosition: LinePosition.left,
                          strokeWidth: 1.5,
                          color: Colors.black),
                      child: topDisplayMovieInfo(context, width),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '1',
                              style: AppFont.montBold(
                                12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            Utils.getTranslated(context, "movies"),
                            style: AppFont.montBold(
                              14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10, top: 14),
                      padding: const EdgeInsets.only(top: 3),
                      child: topDisplayCinemaLocationInfo(context, width),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: AppFont.montBold(
                                12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            Utils.getTranslated(context, "cinemas"),
                            style: AppFont.montBold(
                              14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget topDisplayMovieInfo(BuildContext context, double width) {
    var movieRating = MovieClassification
                    .moviewRatingStr[recommendedMovie!.child!.first.rating] !=
                null &&
            MovieClassification
                    .moviewRatingStr[recommendedMovie!.child!.first.rating] !=
                ""
        ? '${MovieClassification.moviewRatingStr[recommendedMovie!.child!.first.rating]} -'
        : '';
    return Container(
      margin: const EdgeInsets.only(left: 26),
      width: width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            recommendedMovie!.title!,
            style: AppFont.montMedium(
              15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$movieRating ${Utils.formatDuration(recommendedMovie!.child!.first.duration!)} - ${Utils.getLanguageName(recommendedMovie!.child!.first.lang!)}',
            style: AppFont.montMedium(
              10,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget topDisplayCinemaLocationInfo(BuildContext context, double width) {
    return Container(
      margin: const EdgeInsets.only(left: 26),
      width: width * 0.8,
      child: Text(
        recLocation!.epaymentName!,
        style: AppFont.montMedium(
          15,
          color: Colors.black,
        ),
      ),
    );
  }
}
