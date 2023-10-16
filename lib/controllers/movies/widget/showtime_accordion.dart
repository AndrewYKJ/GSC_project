// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/models/arguments/custom_show_model.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:intl/intl.dart';

import '../../../const/utils.dart';
import '../../../models/json/movie_home_model.dart';
import '../../../widgets/custom_favourite_button.dart';

class Accordion extends StatefulWidget {
  final add;
  final isReset;
  final remove;
  final viewMoreToggle;
  final int index;
  final List<String> filter;
  final selectShow;
  final String? previousID;
  final Location data;
  final bool? isAurum;
  final bool? isLast;
  final String isOpsdateChange;
  final List<String> viewMore;
  const Accordion({
    Key? key,
    required this.data,
    this.selectShow,
    this.viewMoreToggle,
    required this.filter,
    this.previousID,
    this.add,
    this.remove,
    this.isReset,
    this.isAurum,
    this.isLast,
    required this.isOpsdateChange,
    required this.viewMore,
    required this.index,
  }) : super(key: key);
  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  bool _showContent = true;
  int maxCount = 8;
  int currentCount = 0;
  late bool viewMore;
  List<CustomShowModel> customShowModelList = [];
  dynamic isSelectedData;
  dynamic currentDate;
  @override
  void initState() {
    currentDate = widget.isOpsdateChange;
    viewMore = widget.viewMore
            .contains("${widget.data.id ?? ''} +${widget.data.hallGroup ?? ''}")
        ? true
        : false;
    checkShowList();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    viewMore = widget.viewMore
        .contains("${widget.data.id ?? ''} +${widget.data.hallGroup ?? ''}");
    isSelectedData != widget.previousID
        ? setState(() {
            isSelectedData = widget.previousID;

            viewMore = widget.viewMore.contains(
                    "${widget.data.id ?? ''} +${widget.data.hallGroup ?? ''}")
                ? true
                : false;
            checkShowList();
          })
        : setState(() {
            _showContent = true;
            checkShowList();
          });

    currentDate != widget.isOpsdateChange
        ? setState(
            () {
              currentDate = widget.isOpsdateChange;

              viewMore = widget.viewMore.contains(
                      "${widget.data.id ?? ''} +${widget.data.hallGroup ?? ''}")
                  ? true
                  : false;
              checkShowList();
            },
          )
        : null;

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkShowList() async {
    customShowModelList.clear();
    for (var childs in widget.data.child ?? []) {
      for (var shows in childs.show ?? []) {
        if (widget.filter.isEmpty) {
          customShowModelList.add(CustomShowModel(
              childID: childs.code,
              locationDisplayName: widget.data.epaymentName,
              locationID: widget.data.id,
              rating: childs.rating,
              id: shows.id,
              date: shows.date,
              time: shows.time,
              timestr: shows.timestr,
              hid: shows.hid,
              hallgroup: widget.data.hallGroup,
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
          var showsType = (shows.type ?? "").split(" ");
          if (widget.filter.any((element) => showsType.contains(element))) {
            customShowModelList.add(CustomShowModel(
                childID: childs.code,
                locationDisplayName: widget.data.epaymentName,
                locationID: widget.data.id,
                rating: childs.rating,
                id: shows.id,
                date: shows.date,
                time: shows.time,
                timestr: shows.timestr,
                hid: shows.hid,
                filmType: childs.filmType,
                hname: shows.hname,
                hallfull: shows.hallfull,
                hallorder: shows.hallorder,
                hallgroup: widget.data.hallGroup,
                barcodeEnabled: shows.barcodeEnabled,
                displayDate: shows.displayDate,
                hasGscPrivilege: shows.hasGscPrivilege,
                type: shows.type,
                typeDesc: shows.typeDesc,
                freelist: shows.freelist));
          }
        }
      }

      customShowModelList.sort(((a, b) {
        return Utils.compareAndArrangeTimes(a.time!, b.time!);
      }));
      setState(() {
        !viewMore
            ? customShowModelList.length - 1 >= maxCount
                ? currentCount = maxCount
                : currentCount = customShowModelList.length
            : currentCount = customShowModelList.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return customShowModelList.isNotEmpty
        ? Column(
            children: [
              Card(
                elevation: 0,
                color: Colors.transparent,
                child: Column(children: [
                  GestureDetector(
                      onTap: (() => setState(() {
                            _showContent = !_showContent;
                          })),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  _showContent = false;
                                },
                                child: SizedBox(
                                  child: FavouriteButton(
                                    isAurum: widget.isAurum ?? false,
                                    isReload: widget.isReset,
                                    isFavourite: false,
                                    hallGroup: widget.data.hallGroup ?? '',
                                    cinemaId: int.parse(widget.data.id ?? "0"),
                                  ),
                                )),
                            Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width - 70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      child: Text(
                                        '${widget.data.epaymentName}',
                                        style: AppFont.montRegular(14,
                                            color: _showContent
                                                ? widget.isAurum != null
                                                    ? widget.isAurum!
                                                        ? AppColor.aurumGold()
                                                        : AppColor.appYellow()
                                                    : AppColor.appYellow()
                                                : Colors.white),
                                      )),
                                  Icon(_showContent ? Icons.remove : Icons.add,
                                      color: _showContent
                                          ? widget.isAurum != null
                                              ? widget.isAurum!
                                                  ? AppColor.aurumGold()
                                                  : AppColor.appYellow()
                                              : AppColor.appYellow()
                                          : Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ExpandedSection(
                      expand: _showContent,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 26, 0, 29),
                        child: customShowModelList.isNotEmpty
                            ? showList(context)
                            : const SizedBox(),
                      ),
                    ),
                  )
                ]),
              ),
              if (widget.isLast != null && widget.isLast == false)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    color: AppColor.dividerColor(),
                  ),
                )
            ],
          )
        : const SizedBox();
  }

  Widget showList(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 10, children: [
      for (var i = 0; i < currentCount; i++)
        showtimesItems(context, i, customShowModelList[i])
    ]);
  }

  Widget showtimesItems(
      BuildContext context, var currentIndex, CustomShowModel time) {
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

    if (currentIndex == 7 && !viewMore && customShowModelList.length - 1 != 7) {
      return InkWell(
        onTap: () {
          setState(() {
            currentCount = customShowModelList.length;
            widget.viewMoreToggle(
                "${widget.data.id ?? ''} +${widget.data.hallGroup ?? ''}");
            viewMore = widget.viewMore.contains(
                "${widget.data.id ?? ''} +${widget.data.hallGroup ?? ''}");
          });
        },
        child: Container(
          width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
          height: 65,
          decoration: BoxDecoration(
              border: Border.all(
                  color: widget.isAurum != null
                      ? AppColor.aurumGold()
                      : AppColor.yellow()),
              borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(
              Utils.getTranslated(context, "more_btn"),
              textAlign: TextAlign.center,
              style: AppFont.poppinsRegular(12,
                  color: widget.isAurum != null
                      ? AppColor.aurumGold()
                      : AppColor.yellow()),
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          widget.selectShow(time);
        },
        child: Container(
          height: 65,
          width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
          decoration: BoxDecoration(
              color: isSelectedData == time.id
                  ? widget.isAurum != null
                      ? AppColor.aurumGold()
                      : AppColor.appYellow()
                  : Colors.transparent,
              border: Border.all(
                  color: widget.isAurum != null
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
                            ? widget.isAurum != null
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
                        height: 1,
                        color: isSelectedData == time.id
                            ? widget.isAurum != null
                                ? AppColor.aurumBase()
                                : Colors.black
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

  Widget selectedShowtimesCancelButton(BuildContext context) {
    return SizedBox(
      height: 30,
      width: MediaQuery.of(context).size.width,
      child: Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.cancel,
              size: 30,
              color: Colors.white,
            ),
          )),
    );
  }
}

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  const ExpandedSection({Key? key, this.expand = false, required this.child})
      : super(key: key);

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeOut,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
  }
}
