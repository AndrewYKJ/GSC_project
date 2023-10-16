import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/controllers/tab/homebase.dart';
import 'package:gsc_app/dio/api/movie_api.dart';
import 'package:gsc_app/models/json/movie_listing.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../const/analytics_constant.dart';
import '../../const/utils.dart';
import '../../models/arguments/movie_to_buy_arguments.dart';
import '../../models/json/movie_listing_details.dart';
import '../../provider/home_provider.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  _MovieListScreen createState() => _MovieListScreen();
}

class _MovieListScreen extends State<MovieListScreen> {
  int currentTab = 0;
  int selectedMovie = 0;
  MovieListing movieListing = MovieListing();
  var scaffoldHomeScreenKey = GlobalKey<ScaffoldState>();
  List<MovieListingDetails> movieData = [];
  bool isLoading = true;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_MOVIES_LIST_SCREEN);
    super.initState();
    getMovieListingInfo();
  }

  Future<MovieListing> getMovieListings(
      BuildContext context, String operationDate) async {
    MovieApi itm = MovieApi(context);
    return itm.getMovieListing(operationDate);
  }

  getMovieListingInfo() async {
    EasyLoading.show();
    String operationDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      isLoading = true;
    });
    await getMovieListings(context, operationDate)
        .then((data) {
          setState(() {
            movieListing = data;
            movieData = [];
            isLoading = false;
            if (currentTab == 0) {
              movieData = movieListing.Response!.Body!.NowShowing != null
                  ? movieListing.Response!.Body!.NowShowing!
                  : [];
            } else {
              movieData = movieListing.Response!.Body!.AdvanceSales != null
                  ? movieListing.Response!.Body!.AdvanceSales!
                  : [];
            }
          });
        })
        .whenComplete(() => {EasyLoading.dismiss()})
        .catchError((error) {
          Utils.printInfo(error);
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final availableHeight = MediaQuery.of(context).size.height -
        180 -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
        key: scaffoldHomeScreenKey,
        onDrawerChanged: (isOpened) => _changeDrawerState(isOpened),
        drawerEnableOpenDragGesture: false,
        drawer: sidebarDrawer(context),
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
              onTap: () {
                setState(() {});
              },
              child: Image.asset(Constants.ASSET_IMAGES + 'menu-icon.png')),
          backgroundColor: AppColor.backgroundBlack(),
          title: Text(Utils.getTranslated(context, "movies"),
              style: AppFont.montBold(18)),
          actions: [
            InkWell(
                onTap: () {
                  setState(() {});
                },
                child:
                    Image.asset(Constants.ASSET_IMAGES + 'New_home_icon.png'))
          ],
        ),
        body: Container(
            padding: const EdgeInsets.only(top: 13),
            height: MediaQuery.of(context).size.height, //availableHeight,
            width: screenWidth,
            color: AppColor.backgroundBlack(),
            child: SafeArea(
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                        child: Column(children: [
                      _header(),
                      _tabController(),
                      _borderUnderline(),
                      _movieListing(availableHeight, screenWidth)
                    ]))))));
  }

  Widget _header() {
    return Container(
        color: AppColor.backgroundBlack(),
        padding: const EdgeInsets.only(
            left: 13, right: 13, bottom: 34), //left: 16, right: 16
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    scaffoldHomeScreenKey.currentState?.openDrawer();
                  });
                },
                child: Image.asset(
                  Constants.ASSET_IMAGES + 'menu-icon.png',
                  height: 30,
                  width: 30,
                )),
            Text(Utils.getTranslated(context, "movies"),
                style: AppFont.montBold(18, color: Colors.white)),
            InkWell(
                onTap: () {
                  setState(() {
                    Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeBase(),
                        ));
                  });
                },
                child:
                    Image.asset(Constants.ASSET_IMAGES + 'New_home_icon.png'))
          ],
        ));
  }

  Widget _tabController() {
    return Container(
        color: AppColor.backgroundBlack(),
        child: DefaultTabController(
            length: 2,
            child: TabBar(
              padding: const EdgeInsets.only(left: 12, right: 12),
              labelColor: Colors.black,
              labelStyle: AppFont.montSemibold(14),
              unselectedLabelStyle: AppFont.montRegular(14),
              unselectedLabelColor: AppColor.lightGrey(),
              onTap: (value) => {
                setState(() {
                  currentTab = value;
                  movieData = [];
                  getMovieListingInfo();
                })
              },
              indicatorColor: Colors.transparent,
              indicator: BoxDecoration(
                  color: AppColor.appYellow(),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              tabs: [
                Tab(child: Text(Utils.getTranslated(context, "now_showing"))),
                Tab(child: Text(Utils.getTranslated(context, "advance_sale")))
              ],
            )));
  }

  Widget _borderUnderline() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColor.appYellow()))),
    );
  }

  Widget _movieListing(double availableHeight, double width) {
    if (movieData.isNotEmpty) {
      return Container(
          height: movieData.length < 7 ? availableHeight : null,
          color: Colors.black,
          padding:
              const EdgeInsets.only(top: 14, left: 8, right: 8, bottom: 47),
          child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _movieItems(movieData, context)));
    } else {
      return Container(
        color: Colors.black,
        height: availableHeight,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: isLoading
                  ? Container()
                  : Text(Utils.getTranslated(context, "coming_soon"),
                      style: AppFont.poppinsMedium(14, color: Colors.white)),
            )
          ],
        ),
      );
    }
  }

  List<Widget> _movieItems(dynamic items, BuildContext context) {
    List<Widget> rowItems = [];

    for (int i = 0; i < items.length; i++) {
      int id = i;
      if (i % 3 == 0) {
        int a = 0;
        List<Widget> itm = [];
        while (a < 3 && id != items.length) {
          itm.add(_item(context, items, id));
          a++;
          id++;
        }
        rowItems.add(Row(
          children: itm,
          crossAxisAlignment: CrossAxisAlignment.start,
        ));
      }
    }

    return rowItems.toList();
  }

  Widget _item(BuildContext context, List items, int index) {
    // dynamic jsonData = movieListing.films?.parent[index].child.toString();
    // String type = jsonData[0];

    return InkWell(
        onTap: () {
          setState(() {
            selectedMovie = index;
            Navigator.pushNamed(context, AppRoutes.movieShowtimesByOpsdate,
                arguments: MovieToBuyArgs(
                  selectedCode: movieData[index].ParentCode ?? "-",
                  firstDate: '',
                  availableDate: [],
                ));
          });
        },
        child: Container(
            padding: const EdgeInsets.only(top: 16),
            width: (MediaQuery.of(context).size.width - 16) / 3,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    child: Container(
                        margin: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                        ),
                        width: (MediaQuery.of(context).size.width - 16) / 3,
                        decoration: BoxDecoration(
                          color: AppColor.lightGrey().withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: movieData[index].Poster.toString(),
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) {
                                return Image.asset(
                                    'assets/images/Default placeholder_app_img.png',
                                    fit: BoxFit.fitWidth);
                              },
                            ))),
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                          left: 4, right: 4, top: 6, bottom: 16),
                      child: Text(
                        movieData[index].Title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppFont.poppinsRegular(10, color: Colors.white),
                      ))
                ])));
  }

  void _changeDrawerState(bool isOpened) {
    if (isOpened) {
      Provider.of<DrawerState>(context, listen: false).setState(true);
    } else {
      Provider.of<DrawerState>(context, listen: false).setState(false);
    }
  }
}
