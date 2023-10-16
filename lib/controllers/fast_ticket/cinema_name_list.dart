import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';

import '../../const/analytics_constant.dart';
import '../../widgets/custom_favourite_button.dart';

class CinemaNameListScreen extends StatefulWidget {
  final List<Location> locationList;
  final Location recommendedCinema;
  final List<Location> favList;
  const CinemaNameListScreen(
      {Key? key,
      required this.locationList,
      required this.recommendedCinema,
      required this.favList})
      : super(key: key);

  @override
  _CinemaNameListScreen createState() => _CinemaNameListScreen();
}

class _CinemaNameListScreen extends State<CinemaNameListScreen> {
  sortCinemaByFavourite() {
    if (widget.favList.isNotEmpty) {
      widget.locationList.sort((a, b) {
        bool isFav = widget.favList.any((element) =>
            element.id == b.id && element.hallGroup == b.hallGroup);
        if (isFav) return 1;
        return -1;
      });
    }
  }

  returnButton() {
    return Navigator.pop(context, true);
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_FAST_TICKET_CINEMA_SELECTION_SCREEN);

    super.initState();
    sortCinemaByFavourite();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () => returnButton(),
      child: Scaffold(
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
                    chooseCinemaLabel(context),
                    showCinemaListing(context, width)
                  ],
                ),
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
        Navigator.pop(context, true);
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

  Widget chooseCinemaLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        Utils.getTranslated(context, 'choose_cinemas'),
        style: AppFont.montMedium(
          18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget showCinemaListing(BuildContext context, double width) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            widget.locationList.map((e) => cinemaItem(context, e)).toList(),
      ),
    );
  }

  Widget cinemaItem(BuildContext context, Location cinema) {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () {
          Navigator.pop(context, cinema);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FavouriteButton(
                  isReload: () {},
                  isAurum: false,
                  isFavourite: false,
                  hallGroup: cinema.hallGroup ?? '',
                  cinemaId: int.parse(cinema.id ?? "0"),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    cinema.epaymentName != null
                        ? cinema.epaymentName.toString()
                        : '',
                    style: AppFont.montRegular(
                      14,
                      color: widget.recommendedCinema.id == cinema.id &&
                              widget.recommendedCinema.hallGroup ==
                                  cinema.hallGroup
                          ? AppColor.appYellow()
                          : Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            widget.locationList.indexOf(cinema) ==
                    widget.locationList.length - 1
                ? Container()
                : Divider(
                    color: AppColor.dividerColor(),
                  )
          ],
        ),
      );
    });
  }
}
