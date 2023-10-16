import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/dio/api/movie_api.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../const/analytics_constant.dart';
import '../../const/utils.dart';
import '../../models/arguments/movie_to_buy_arguments.dart';
import '../../models/json/movie_listing_details.dart';
import '../../routes/approutes.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String parentCode;
  final bool isAurum;
  final bool fromMoviePopup;
  const MovieDetailsScreen(
      {Key? key,
      required this.parentCode,
      required this.isAurum,
      required this.fromMoviePopup})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MovieDetailsScreen();
  }
}

class _MovieDetailsScreen extends State<MovieDetailsScreen> {
  late YoutubePlayerController _controller;
  // late VideoPlayerController _videoController;
  dynamic checkType;
  MovieListingDetails? movieDetails;
  late bool isDyanmic;
  late String movieId;
  List movieType = [];
  bool toFullScreen = false;
  bool toExpand = false;
  dynamic id = "";
  int clickCount = 0;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_MOVIE_DETAILS_SCREEN);
    super.initState();
    getMovieDetailsInfo(widget.parentCode);
    checkPush();
  }

  checkPush() {
    if (AppCache.payload != null) {
      AppCache.payload = null;
    }
  }

  Future<MovieDetails> getMovieDetails(
      BuildContext context, String parentCode) async {
    MovieApi itm = MovieApi(context);
    return itm.getMovieDetails(parentCode);
  }

  getMovieDetailsInfo(String parentCode) async {
    EasyLoading.show();

    await getMovieDetails(context, parentCode)
        .then((data) {
          setState(() {
            movieDetails = data.Response?.Body?.MovieDetail?.first;
            movieType = movieDetails != null
                ? movieDetails!.Experience != null
                    ? movieDetails!.Experience!.isNotEmpty
                        ? movieDetails!.Experience!.split(',')
                        : []
                    : []
                : [];

            // "2D,4DX,DBOX,IMAX,MX4D,SrnX".split(",");
            if (movieType.length > 8) {
              movieType.insert(7, 'More');
            }

            String result = movieDetails?.Trailer_Url != null
                ? movieDetails!.Trailer_Url!.isNotEmpty
                    ? movieDetails!.Trailer_Url!
                    : ""
                : "";
            dynamic videoID = result.split("=");
            if (videoID.length > 1) {
              id = videoID[1];
            }

            _controller = YoutubePlayerController.fromVideoId(
              videoId: id,
              autoPlay: false,
              params: const YoutubePlayerParams(
                strictRelatedVideos: true,
                showFullscreenButton: false,
              ),
            );

            _controller.setFullScreenListener(
              (isFullScreen) {
                setState(() {
                  toFullScreen = isFullScreen;
                });
              },
            );
          });
        })
        .whenComplete(() => {EasyLoading.dismiss()})
        .catchError((e) {
          Utils.printInfo(e);
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              e != null
                  ? e.message ?? Utils.getTranslated(context, "general_error")
                  : Utils.getTranslated(context, "general_error"),
              true,
              null, () {
            Navigator.of(context).pop();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0,
        ),
        body: Container(
            color: Colors.black,
            height: height,
            width: width,
            child: SafeArea(
                child: movieDetails == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _back(context),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: kToolbarHeight),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/no-records-icon.png',
                                      ),
                                      Text(
                                          Utils.getTranslated(
                                              context, 'no_record_found'),
                                          style: AppFont.montRegular(16,
                                              color: AppColor.dividerColor()))
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      )
                    : toFullScreen
                        ? _toFullScreen()
                        : SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(children: [
                                    (id != "") ? _videoPlayer() : Container(),
                                    _back(context)
                                  ]),
                                  _movieTitle(widget, movieDetails),
                                  _releaseDate(context, movieDetails!),
                                  _spokenLanguage(context, movieDetails!),
                                  _runningTime(context, movieDetails!),
                                  _subtitles(context, movieDetails!),
                                  _genre(context, movieDetails!),
                                  _classifications(context, movieDetails!),
                                  if (movieType.isNotEmpty)
                                    _cinemaExperiencesTitle(context),
                                  if (movieType.isNotEmpty)
                                    _cinemaExperiences(context, toExpand),
                                  _directorTitle(context),
                                  _directorInfo(movieDetails!),
                                  _castTitle(context),
                                  _castInfo(movieDetails!),
                                  _synopsisTitle(context),
                                  _synopsisInfo(movieDetails!)
                                ])))),
        bottomNavigationBar: !toFullScreen
            ? BottomAppBar(
                color: Colors.black,
                child: Container(
                    margin:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: movieDetails != null
                                ? widget.isAurum
                                    ? AppColor.aurumGold()
                                    : AppColor.appYellow()
                                : AppColor.greyWording(),
                            padding: const EdgeInsets.only(top: 6, bottom: 6)),
                        onPressed: () {
                          movieDetails != null
                              ? widget.fromMoviePopup
                                  ? Navigator.pop(context)
                                  : widget.isAurum
                                      ? Navigator.pushNamed(context,
                                          AppRoutes.aurumShowtimesRoute,
                                          arguments: MovieToBuyArgs(
                                            selectedCode: widget.parentCode,
                                            movieDetails: movieDetails,
                                            firstDate: '',
                                            availableDate: [],
                                          ))
                                      : Navigator.pushNamed(context,
                                          AppRoutes.movieShowtimesByOpsdate,
                                          arguments: MovieToBuyArgs(
                                            selectedCode: widget.parentCode,
                                            movieDetails: movieDetails,
                                            firstDate: '',
                                            availableDate: [],
                                          ))
                              : null;
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                                Utils.getTranslated(context, "book_ticket"),
                                style: AppFont.montSemibold(14,
                                    color: Colors.black))))))
            : const BottomAppBar());
  }

  Widget _videoPlayer() {
    return YoutubePlayer(
      controller: _controller,
      backgroundColor: Colors.black,
    );
    //   YoutubePlayerScaffold(
    //     backgroundColor: Colors.black,
    //     // autoFullScreen: true,
    //     controller: _controller,
    //     autoFullScreen: false,
    //     builder: (context, player) {
    //       return Row(children: [
    //         Expanded(
    //             child: SizedBox(
    //                 child: toFullScreen
    //                     ? Container(
    //                         alignment: Alignment.center,
    //                         height: MediaQuery.of(context).size.height,
    //                         width: MediaQuery.of(context).size.width,
    //                         child: player)
    //                     : Container(child: player)))
    //       ]);
    //     },
    //   );
  }

  Widget _toFullScreen() {
    return YoutubePlayerScaffold(
      backgroundColor: Colors.black,
      // autoFullScreen: true,
      controller: _controller,
      autoFullScreen: false,
      builder: (context, player) {
        return Center(
            child: Container(
                alignment: Alignment.center,
                height: 500,
                width: MediaQuery.of(context).size.width,
                child: player));
      },
    );
  }

  Widget _back(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, top: 14),
        child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child:
                Image.asset(Constants.ASSET_IMAGES + 'white-left-icon.png')));
  }

  Widget _movieTitle(widget, MovieListingDetails? movieDetails) {
    return Padding(
        padding:
            const EdgeInsets.only(left: 16, top: 20, bottom: 26, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 11),
                child: MovieClassification.movieRating[movieDetails?.Rating] !=
                            null &&
                        MovieClassification.movieRating[movieDetails?.Rating] !=
                            ''
                    ? SizedBox(
                        height: 36,
                        width: 36,
                        child: Image.asset(
                            MovieClassification
                                .movieRating[movieDetails?.Rating],
                            fit: BoxFit.cover))
                    : Container()),
            Expanded(
                child: Text(
              movieDetails?.Title ?? "-",
              style: AppFont.montBold(16, color: Colors.white),
            ))
          ],
        ));
  }

  Widget _releaseDate(BuildContext context, MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 11),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                    height: 18,
                    width: 18,
                    child: Image.asset(
                      Constants.ASSET_IMAGES + 'calender-simple-icon.png',
                      color: Colors.white,
                    ))),
            Expanded(
                child: Text(
                    Utils.getTranslated(context, "release_date") +
                        ": " +
                        movieDetails.Release_Date!,
                    style: AppFont.poppinsRegular(12, color: Colors.white)))
          ],
        ));
  }

  Widget _spokenLanguage(
      BuildContext context, MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                    height: 18,
                    width: 18,
                    child: Image.asset(
                        Constants.ASSET_IMAGES + 'speech-icon.png',
                        color: Colors.white,
                        fit: BoxFit.fill))),
            Expanded(
                child: Text(
                    Utils.getTranslated(context, "spoken_language") +
                        ": " +
                        formatSpokenLanguage(movieDetails.Language ?? ""),
                    style: AppFont.poppinsRegular(12, color: Colors.white)))
          ],
        ));
  }

  Widget _runningTime(BuildContext context, MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 11),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                    height: 18,
                    width: 18,
                    child: Image.asset(
                      Constants.ASSET_IMAGES + 'time-simple-icon.png',
                      color: Colors.white,
                    ))),
            Expanded(
                child: Text(
                    Utils.getTranslated(context, "running_time") +
                        ": " +
                        movieDetails.Duration!,
                    style: AppFont.poppinsRegular(12, color: Colors.white)))
          ],
        ));
  }

  Widget _subtitles(BuildContext context, MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 11),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                    height: 18,
                    width: 18,
                    child: Image.asset(
                        Constants.ASSET_IMAGES + 'substitle-icon.png',
                        color: Colors.white,
                        fit: BoxFit.fill))),
            Expanded(
                child: Text(
                    Utils.getTranslated(context, "subtitles") +
                        ": " +
                        formatSubtitle(movieDetails.Subtitle ?? ""),
                    style: AppFont.poppinsRegular(12, color: Colors.white)))
          ],
        ));
  }

  Widget _genre(BuildContext context, MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 11),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                    height: 18,
                    width: 18,
                    child: Image.asset(
                        Constants.ASSET_IMAGES + 'genre-icon.png',
                        color: Colors.white,
                        fit: BoxFit.cover))),
            Expanded(
                child: Text(
                    Utils.getTranslated(context, "genre") +
                        ": " +
                        formatGenre(movieDetails.Genre ?? ""),
                    style: AppFont.poppinsRegular(12, color: Colors.white)))
          ],
        ));
  }

  Widget _classifications(
      BuildContext context, MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                    height: 18,
                    width: 18,
                    child: Image.asset(
                        Constants.ASSET_IMAGES + 'classification-icon.png',
                        color: Colors.white,
                        fit: BoxFit.cover))),
            Expanded(
                child: Text(
                    (movieDetails.Rating != null)
                        ? Utils.getTranslated(context, "classifications") +
                            ": " +
                            movieDetails.Rating!
                        : Utils.getTranslated(context, "classifications") +
                            ": " +
                            "N/A",
                    style: AppFont.poppinsRegular(12, color: Colors.white)))
          ],
        ));
  }

  Widget _cinemaExperiencesTitle(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 30),
        child: Text(Utils.getTranslated(context, "cinema_experiences"),
            style: AppFont.montMedium(14, color: AppColor.greyWording())));
  }

  Widget _cinemaExperiences(BuildContext context, bool toExpand) {
    if (movieType.length > 7) {
      if (toExpand == true) {
        return Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            width: MediaQuery.of(context).size.width,
            child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: movieType.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 13,
                  crossAxisCount: 4,
                  mainAxisExtent: 40,
                ),
                itemBuilder: (context, index) {
                  return _cinemaExperienceItem(context, index);
                }));
      } else {
        return Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            width: MediaQuery.of(context).size.width,
            child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 13,
                  crossAxisCount: 4,
                  mainAxisExtent: 40,
                ),
                itemBuilder: (context, index) {
                  return _cinemaExperienceItem(context, index);
                }));
      }
    } else {
      return Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          width: MediaQuery.of(context).size.width,
          child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movieType.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 10,
                crossAxisSpacing: 13,
                crossAxisCount: 4,
                mainAxisExtent: 40,
              ),
              itemBuilder: (context, index) {
                return _cinemaExperienceItem(context, index);
              }));
    }
  }

  Widget _cinemaExperienceItem(BuildContext context, int idx) {
    return SizedBox(
      child: (idx == 7 && movieType[idx] == 'More')
          ? InkWell(
              onTap: () {
                setState(() {
                  toExpand = true;
                  movieType.removeAt(7);
                });
              },
              child: Container(
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColor.appYellow()),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(movieType[idx],
                      style: AppFont.montRegular(14,
                          color: AppColor.appYellow()))))
          : SizedBox(
              width: (MediaQuery.of(context).size.width - 30 - 32) / 4,
              height: 40,
              child: MapCinemaExperiences.experiences[movieType[idx]] != null
                  ? Image.asset(
                      MapCinemaExperiences.experiences[movieType[idx]],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    )
                  : Center(
                      child: Text(movieType[idx],
                          style: AppFont.montRegular(14,
                              color: AppColor.appYellow())),
                    ),
            ),
    );
  }

  Widget _directorTitle(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 25, left: 16, right: 16, bottom: 4),
        child: Text(Utils.getTranslated(context, "director"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _directorInfo(MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
        child: movieDetails.Director != null
            ? movieDetails.Director!.isNotEmpty
                ? Text(movieDetails.Director!,
                    style: AppFont.poppinsRegular(12, color: Colors.white))
                : Text('-',
                    style: AppFont.poppinsRegular(12, color: Colors.white))
            : Text('-',
                style: AppFont.poppinsRegular(12, color: Colors.white)));
  }

  Widget _castTitle(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 4),
        child: Text(Utils.getTranslated(context, "cast"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _castInfo(MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
        child: Text(
            movieDetails.Main_Stars != null
                ? movieDetails.Main_Stars!.isNotEmpty
                    ? movieDetails.Main_Stars!
                    : "-"
                : "-",
            style: AppFont.poppinsRegular(12, color: Colors.white)));
  }

  Widget _synopsisTitle(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 4),
        child: Text(Utils.getTranslated(context, "synopsis"),
            style: AppFont.montRegular(14, color: AppColor.greyWording())));
  }

  Widget _synopsisInfo(MovieListingDetails movieDetails) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50),
        child: movieDetails.Synopsis != null
            ? Text(
                movieDetails.Synopsis!.isNotEmpty
                    ? movieDetails.Synopsis!
                    : "-",
                style: AppFont.poppinsRegular(12, color: Colors.white))
            : Text('-',
                style: AppFont.poppinsRegular(12, color: Colors.white)));
  }

  String formatSpokenLanguage(String data) {
    dynamic val = data.split(", ");
    String returnMsg = "";
    if (val.length > 0) {
      for (int i = 0; i < val.length; i++) {
        String massage = val[i].toLowerCase();
        returnMsg +=
            massage[0].toUpperCase() + val[i].substring(1).toLowerCase();
        if (val.length > 1 && (i != val.length - 1)) {
          returnMsg += ", ";
        }
      }
    } else {
      // ignore: unused_local_variable
      String massage = data[0].toLowerCase();
      returnMsg += data.substring(1).toLowerCase();
    }

    return returnMsg;
  }

  String formatSubtitle(String data) {
    String dt = data.toUpperCase();
    return dt;
  }

  String formatGenre(String data) {
    dynamic getData = data.split(" ");
    String msg = "";

    if (getData.length > 0) {
      for (int i = 0; i < getData.length; i++) {
        String message = getData[i].toLowerCase();
        if (getData[i].isNotEmpty) {
          msg +=
              message[0].toUpperCase() + getData[i].substring(1).toLowerCase();
          if (getData.length > 1 && (i != getData.length - 1)) {
            msg += " ";
          }
        }
      }
    } else {
      String dt = data.toLowerCase();
      msg += dt[0].toUpperCase() + dt.substring(1).toLowerCase();
    }

    return msg;
  }

  String formatReleaseDate(String date) {
    return DateFormat("dd MMMM yyyy").format(DateTime.parse(date));
  }

  String formatRunningTime(String time) {
    int value = int.parse(time);
    final int hour = value ~/ 60;
    final int minutes = value % 60;
    if (minutes.toString().length == 1) {
      return '$hour hr  0$minutes mins';
    } else {
      return '$hour hr $minutes mins';
    }
  }
}
