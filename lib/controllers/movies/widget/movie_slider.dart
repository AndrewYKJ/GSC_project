import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';

import '../../../routes/approutes.dart';

class CarouselMovieSlider extends StatefulWidget {
  final MovieToBuyArgs data;
  final List<Parent>? allMovie;
  final int? index;
  final dynamic changeMovie;
  final bool? isAurum;
  final dynamic height;
  const CarouselMovieSlider(
      {Key? key,
      required this.data,
      this.index,
      this.allMovie,
      this.height,
      this.changeMovie,
      this.isAurum})
      : super(key: key);

  @override
  _CarouselMovieSliderState createState() => _CarouselMovieSliderState();
}

class _CarouselMovieSliderState extends State<CarouselMovieSlider>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  List<Parent> data = [];
  Parent? _selectedMovie;
  bool init = true;
  double _leftOffset = 0;
  String _selectedIndex = '';
  double? elementHeight;

  var scaffoldHomeScreenKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    getIndex();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final double? _height =
            scaffoldHomeScreenKey.currentContext?.size?.height;
        elementHeight = _height! * 1.2;

        widget.height(elementHeight);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  getIndex() {
    data = widget.allMovie!;

    _selectedIndex = widget.data.selectedCode;
    for (var i = 0; i < data.length; i++) {
      if (data[i].code! == _selectedIndex) {
        setState(() {
          _currentIndex = i;
          _selectedMovie = data[i];
        });

        break;
      }
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _leftOffset += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    double screenWidth = MediaQuery.of(context).size.width;
    double slideThreshold = screenWidth * 0.2;
    if (details.primaryVelocity! < 0 && _currentIndex < data.length - 1) {
      if (_leftOffset.abs() > slideThreshold) {
        setState(() {
          _currentIndex++;
          _selectedMovie = data[_currentIndex];
          widget.changeMovie(_selectedMovie);
        });
      }
    } else if (details.primaryVelocity! > 0 && _currentIndex > 0) {
      if (_leftOffset.abs() > slideThreshold) {
        setState(() {
          _currentIndex--;
          _selectedMovie = data[_currentIndex];
          widget.changeMovie(_selectedMovie);
        });
      }
    }

    setState(() {
      _leftOffset = 0;
    });
  }

  void postFrameCallback(_) {
    Future.delayed(const Duration(seconds: 1), () {
      final double? _height =
          scaffoldHomeScreenKey.currentContext?.size?.height;

      elementHeight = _height! * 1.2;
      setState(() {
        init = false;
      });
      widget.height(elementHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (init) {
      SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    }
    return SizedBox(
        child: _selectedMovie != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.center,
                    children: [
                      _leftMoviesImage(context),
                      _rightMoviesImage(context),
                      _centerSelectedMovies(context),
                      _swipeDetector(context),
                      _tapDetector(context),
                    ],
                  ),

                  // _downArrorw(),
                  _movieDetails(context)
                ],
              )
            : Container());
  }

  Widget _tapDetector(BuildContext context) {
    return SizedBox(
      height: elementHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _leftTapButton(context),
          _rightTapButton(context),
        ],
      ),
    );
  }

  GestureDetector _rightTapButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_currentIndex < data.length - 1)
          //    data.asMap().containsKey(_currentIndex + 1);
          {
            _currentIndex++;
            _selectedMovie = data[_currentIndex];
            widget.changeMovie(_selectedMovie);
          }
        });
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        height: elementHeight,
        color: Colors.transparent,
      ),
    );
  }

  GestureDetector _leftTapButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_currentIndex > 0) {
            _currentIndex--;
            _selectedMovie = data[_currentIndex];
            widget.changeMovie(_selectedMovie);
          }
        });
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.30,
        height: elementHeight,
        color: Colors.transparent,
      ),
    );
  }

  Widget _swipeDetector(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onTap: () => Navigator.pushNamed(context, AppRoutes.movieDetailsRoute,
          arguments: [_selectedMovie!.code, widget.isAurum ?? false, true]),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: elementHeight,
        color: Colors.transparent,
      ),
    );
  }

  Widget _centerSelectedMovies(BuildContext context) {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 3) + _leftOffset,
      child: Transform.scale(
        scale: 1.20,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: widget.isAurum != null
                ? Border.all(width: 2, color: AppColor.aurumGold())
                : Border.all(width: 2, color: AppColor.appYellow()),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black,
                  blurRadius: 50.0,
                  spreadRadius: 10,
                  offset: Offset(-40, 20)),
              BoxShadow(
                  color: Colors.black,
                  blurRadius: 50.0,
                  spreadRadius: 10,
                  offset: Offset(40, 20)),
            ],
          ),
          child: ClipRRect(
              key: scaffoldHomeScreenKey,
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data[_currentIndex].child!.first.thumbBig!,
                width: MediaQuery.of(context).size.width * .33,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/Default placeholder_app_img.png',
                    width: MediaQuery.of(context).size.width * .33,
                    fit: BoxFit.cover,
                  );
                },
              )),
        ),
      ),
    );
  }

  Widget _rightMoviesImage(BuildContext context) {
    return Positioned(
      right: 0 - _leftOffset,
      child: _currentIndex + 1 > data.length - 1
          ? Container()
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data[_currentIndex + 1].child!.first.thumbBig!,
                width: MediaQuery.of(context).size.width * .33,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/Default placeholder_app_img.png',
                    width: MediaQuery.of(context).size.width * .33,
                    fit: BoxFit.cover,
                  );
                },
              )),
    );
  }

  Widget _leftMoviesImage(BuildContext context) {
    return Positioned(
      left: 0 + _leftOffset,
      child: _currentIndex - 1 < 0
          ? Container()
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data[_currentIndex - 1].child!.first.thumbBig!,
                width: MediaQuery.of(context).size.width * .33,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/Default placeholder_app_img.png',
                    width: MediaQuery.of(context).size.width * .33,
                    fit: BoxFit.cover,
                  );
                },
              )),
    );
  }

  Widget _movieDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Center(
                        child: Text(
                          _selectedMovie!.title!,
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
                                _selectedMovie!.child!.first.duration!),
                            style:
                                AppFont.poppinsRegular(10, color: Colors.white),
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
                                _selectedMovie!.child!.first.lang!),
                            style:
                                AppFont.poppinsRegular(10, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (MovieClassification.movieRating[
                          data[_currentIndex].child!.first.rating!] !=
                      null &&
                  MovieClassification.movieRating[
                          data[_currentIndex].child!.first.rating!] !=
                      '')
                Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: Image.asset(
                          MovieClassification.movieRating[
                              data[_currentIndex].child!.first.rating!],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/Default placeholder_app_img.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )))
            ],
          )),
    );
  }
}
