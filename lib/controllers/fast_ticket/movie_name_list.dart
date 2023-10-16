import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';

import '../../const/analytics_constant.dart';

class MovieNameListScreen extends StatefulWidget {
  final List<Parent> movieList;
  final Parent recommendedMovie;

  const MovieNameListScreen(
      {Key? key, required this.movieList, required this.recommendedMovie})
      : super(key: key);

  @override
  _MovieNameListScreen createState() => _MovieNameListScreen();
}

class _MovieNameListScreen extends State<MovieNameListScreen> {
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_FAST_TICKET_MOVIE_SELECTION_SCREEN);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  closeIcon(context),
                  chooseMovieLabel(context),
                  showMovieListing(context, width)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget closeIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Align(
        alignment: Alignment.topRight,
        child: Image.asset(
          Constants.ASSET_IMAGES + 'close-circle.png',
          fit: BoxFit.cover,
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  Widget chooseMovieLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        Utils.getTranslated(context, 'choose_movies'),
        style: AppFont.montMedium(
          18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget showMovieListing(BuildContext context, double width) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.movieList.map((e) => movieItem(context, e)).toList(),
      ),
    );
  }

  Widget movieItem(BuildContext context, Parent movie) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, movie);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            movie.title != null ? movie.title.toString() : '',
            style: AppFont.montRegular(
              14,
              color: widget.recommendedMovie.code == movie.code
                  ? AppColor.appYellow()
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          widget.movieList.indexOf(movie) == widget.movieList.length - 1
              ? Container()
              : Divider(
                  color: AppColor.dividerColor(),
                )
        ],
      ),
    );
  }
}
