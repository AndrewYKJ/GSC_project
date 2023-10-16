// ignore_for_file: unused_local_variable

import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/dio/api/transactions_api.dart';
import 'package:gsc_app/models/arguments/init_transaction_arguments.dart';
import 'package:gsc_app/models/json/init_sales_trans_reponse.dart';
import 'package:gsc_app/models/json/ticket_item_model.dart';
import 'package:collection/collection.dart';
import 'package:gsc_app/routes/approutes.dart';
import 'package:gsc_app/widgets/custom_quantity_stepper.dart';
import 'package:gsc_app/widgets/custom_quantity_stepper_for_ecombo_variation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../const/analytics_constant.dart';
import '../../const/constants.dart';
import '../../models/arguments/combo_selection_arguments.dart';

class EcomboSelectionScreen extends StatefulWidget {
  final ComboSelectionArguments data;
  const EcomboSelectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<EcomboSelectionScreen> createState() => _EcomboSelectionScreenState();
}

class _EcomboSelectionScreenState extends State<EcomboSelectionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();
  InitSalesDTO? initSalesDTO;
  GlobalKey key = GlobalKey();
  bool isLoading = true;
  bool absorb = false;

  int currentTab = 0;
  List<ComboModel> selectedCombo = [];

  bool init = true;
  double _previousOffset = 0.0;
  List<GlobalKey> listKey = [];
  List<ComboItemModel>? products;
  late TabController _tabController;
  late Map<String?, List<ComboItemModel>> productTab;

  String? appVersion;
  String? appPlatform;
  final List<Tab> _tabs = [];
  List<double> tabHeightList = [];

  Future<void> callFood() async {
    products = widget.data.comboList!;

    groupByLastStatusData(products!);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    setState(() {
      List<GlobalKey> keyCap = List<GlobalKey>.generate(
          _tabs.length, (index) => GlobalKey(debugLabel: 'key_$index'),
          growable: false);
      listKey = keyCap;

      isLoading = false;
    });
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_ECOMBO_SELECTION_SCREEN);

    callFood();
    _controller.addListener(_scrollListener);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPlatform();
  }

  Future<void> _checkPlatform() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.version.isNotEmpty) {
      appVersion = packageInfo.version;
      appPlatform = Platform.isAndroid
          ? Constants.IS_HUAWEI
              ? 'Huawei'
              : 'Android'
          : 'iOS';
    }
  }

  void groupByLastStatusData(List<ComboItemModel> data) {
    final groups = groupBy(data, (ComboItemModel e) {
      return e.Combo_Category;
    });

    setState(() {
      productTab = groups;
      if (productTab.isNotEmpty) {
        for (var element in productTab.keys) {
          _tabs.add(tabItem(element));
        }
      }
      _tabController = TabController(
          initialIndex: currentTab, length: _tabs.length, vsync: this);
    });
  }

  Tab tabItem(String? element) {
    return Tab(
      text: element,
    );
  }

  _scrollListener() {
    double scrollOffset = _controller.offset;

    int newSelectedTab = _tabController.index;

    if (scrollOffset > _previousOffset &&
        newSelectedTab < tabHeightList.length - 1) {
      double heightSum = 0;
      for (int i = 0; i < tabHeightList.length; i++) {
        heightSum += tabHeightList[i];
        if (scrollOffset < heightSum) {
          newSelectedTab = i;
          break;
        }
      }
    } else if (scrollOffset < _previousOffset && newSelectedTab > 0) {
      double heightSum = 0;
      for (int i = 0; i < tabHeightList.length - 1; i++) {
        heightSum += tabHeightList[i];
        if (heightSum > _previousOffset) {
          newSelectedTab = i;
          break;
        }
      }
    }

    if (newSelectedTab != _tabController.index &&
        _tabController.index >= 0 &&
        (_tabController.index < _tabs.length)) {
      _tabController.index = newSelectedTab;
    }

    _previousOffset = scrollOffset;
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void postFrameCallback(_) {
    for (var i = 0; i < listKey.length; i++) {
      var context = listKey[i];

      if (!init) {
        tabHeightList[i] = context.currentContext!.size!.height;
      } else {
        tabHeightList.add(context.currentContext!.size!.height);
      }
    }
    setState(() {
      init = false;
    });
  }

  Future<dynamic> initTransactionApi(BuildContext context) async {
    List ticketType = [];
    List econ = [];
    List selectedecon = [];
    List selecttkt = [];
    List seatType = [];
    for (var data in widget.data.selectedTicket!) {
      if (data.qty! > 0) {
        for (var i = 0; i < data.qty!; i++) {
          ticketType.add(data.type);
        }
      }
    }
    if (selectedCombo.isNotEmpty) {
      for (var data in selectedCombo) {
        if (data.qty! > 0) {
          for (var i = 0; i < data.qty!; i++) {
            econ.add(data.id);
          }
          selectedecon.add("${data.qty}x${data.desc}");
        }
      }
    }

    widget.data.seatTypeMap!.forEach((key, value) {
      if (value['qty'] > 0) {
        selecttkt.add("$key: ${value['qty']}");
        for (var i = 0; i < value['qty']; i++) {
          seatType.add(key);
        }
      }
    });

    TransactionsApi itm = TransactionsApi(context);
    return itm.initSalesTransaction(
        widget.data.locationId,
        widget.data.showId,
        widget.data.seats,
        ticketType.join(',').toString(),
        econ.join(',').toString(),
        seatType.join(',').toString(),
        selectedecon.join(', ').toString(),
        selecttkt.join(', ').toString(),
        "userEmail",
        "userIC",
        "userPhoneno",
        "token",
        appVersion,
        appPlatform!,
        widget.data.fromWher,
        widget.data.SelectedOptions);
  }

  _getInitSaleApi(BuildContext context) async {
    await initTransactionApi(context).then((value) {
      EasyLoading.dismiss();
      setState(() {
        initSalesDTO = value;

        if (initSalesDTO!.error != null) {
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              initSalesDTO!.error!.displayMsg!,
              true,
              null,
              () => Navigator.of(context).pop());
        } else {
          Navigator.pushNamed(context, AppRoutes.reviewSummaryRoute,
              arguments: InitSalesTransactionArg(
                  locationId: widget.data.locationId,
                  hallId: widget.data.hallId,
                  showId: widget.data.showId,
                  cinemaName: widget.data.cinemaName,
                  filmId: widget.data.filmId,
                  initSalesDTO: initSalesDTO,
                  opsDate: widget.data.opsDate,
                  showDate: widget.data.showDate,
                  showTime: widget.data.showTime,
                  movieTitle: widget.data.movieTitle,
                  selectedCombo: selectedCombo,
                  aurumCombo: widget.data.aurumCombo,
                  selectedTicket: widget.data.selectedTicket,
                  seats: widget.data.seats,
                  showEcombo: true,
                  ticketQty: widget.data.ticketQty,
                  seatTypeMap: widget.data.seatTypeMap,
                  SelectedOptions: widget.data.SelectedOptions,
                  isAurum: widget.data.isAurum));
        }
      });
    }, onError: (error) {
      EasyLoading.dismiss();
      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          error != null
              ? error.toString().isNotEmpty
                  ? error.toString()
                  : Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          null, () {
        Navigator.of(context).pop();
      });
    }).whenComplete(() => setState(
          () {
            absorb = false;
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (init) {
      SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    }
    return isLoading
        ? Container()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.appSecondaryBlack(),
              elevation: 0,
              title: Text(
                Utils.getTranslated(context, "ecombo_title"),
                style: AppFont.montRegular(18, color: Colors.white),
              ),
              centerTitle: true,
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              color: AppColor.appSecondaryBlack(),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                TabBar(
                    isScrollable: true,
                    labelStyle: AppFont.montRegular(14),
                    labelColor: Colors.black,
                    unselectedLabelStyle: AppFont.montRegular(
                      14,
                    ),
                    indicatorWeight: 0.000000001,
                    unselectedLabelColor: AppColor.greyWording(),
                    indicatorColor: widget.data.isAurum != null
                        ? widget.data.isAurum!
                            ? AppColor.aurumGold()
                            : AppColor.appYellow()
                        : AppColor.appYellow(),
                    indicator: BoxDecoration(
                      color: widget.data.isAurum != null
                          ? widget.data.isAurum!
                              ? AppColor.aurumGold()
                              : AppColor.appYellow()
                          : AppColor.appYellow(),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12)),
                    ),
                    controller: _tabController,
                    onTap: (value) {
                      currentTab = value;

                      var animateHeight = 0.0;

                      for (var tabIndex = 0;
                          tabIndex < currentTab;
                          tabIndex++) {
                        animateHeight +=
                            listKey[tabIndex].currentContext!.size!.height;
                      }
                      _controller.animateTo(
                        animateHeight,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                      setState(() {});
                    },
                    tabs: _tabs),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1.5,
                    color: widget.data.isAurum != null
                        ? widget.data.isAurum!
                            ? AppColor.aurumGold()
                            : AppColor.appYellow()
                        : AppColor.appYellow()),
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      controller: _controller,
                      child: Column(
                        key: key,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (var x = 0; x < productTab.length; x++)
                            comboList(context, x)
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            ),
            bottomNavigationBar: confirmBtn(context));
  }

  Widget comboList(BuildContext ctx, int x) {
    return Column(
        key: listKey[x],
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          comboItemTitle(x),
          for (var y = 0; y < productTab.entries.elementAt(x).value.length; y++)
            comboItem(ctx, x, y),
        ]);
  }

  Widget comboItemTitle(int x) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: Text(productTab.keys.elementAt(x).toString(),
          textAlign: TextAlign.left,
          style: AppFont.montRegular(14,
              color: widget.data.isAurum != null
                  ? widget.data.isAurum!
                      ? AppColor.aurumGold()
                      : AppColor.appYellow()
                  : AppColor.appYellow())),
    );
  }

  Widget comboItem(BuildContext ctx, int x, int y) {
    ComboItemModel item = productTab.entries.elementAt(x).value.elementAt(y);
    int currentQty = 0;
    if (selectedCombo.isNotEmpty) {
      if (item.CHILD!.CHILD!.length > 1) {
        ComboModel? buffer;
        for (var data in item.CHILD!.CHILD!) {
          buffer = null;
          for (var element in selectedCombo) {
            if (element.id == data.CODE) {
              buffer = element;
            }
          }
          if (buffer != null) {
            currentQty = currentQty + buffer.qty!;
          }
        }
      } else {
        for (var element in selectedCombo) {
          if (element.id == item.PARENT_ID) {
            currentQty = element.qty ?? 0;
          }
        }
      }
      setState(() {});
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                comboItemImage(item),
                comboItemDesc(ctx, item),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              comboItemPrice(item),
              QuantityButton(
                  isAurum: widget.data.isAurum != null
                      ? widget.data.isAurum!
                      : false,
                  hasVariation: item.CHILD!.CHILD!.length > 1 ? true : false,
                  fromModal: currentQty,
                  initialQuantity: currentQty,
                  maxQuantity: item.SOLD_OUT_FLAG == "true" ? 0 : 999,
                  currentQuantity: currentQty,
                  onQuantityChange: (qty) async {
                    if (item.CHILD!.CHILD!.length > 1) {
                      if (item.SOLD_OUT_FLAG != "true") {
                        final finalQty = await showVariation(ctx, item);
                      }

                      var currentVa = 0;
                      for (var data in item.CHILD!.CHILD!) {
                        ComboModel? buffer;
                        for (var element in selectedCombo) {
                          if (element.id == data.CODE) {
                            buffer = element;
                          }
                        }
                        if (buffer != null) {
                          currentVa = buffer.qty! + currentVa;
                        }
                      }
                      setState(() {});
                      return currentVa;
                    } else {
                      if (item.CHILD!.CHILD!.length == 1) {
                        setState(() {
                          if (selectedCombo
                              .where((element) => element.id == item.PARENT_ID)
                              .isEmpty) {
                            selectedCombo.add(ComboModel(
                                id: item.PARENT_ID,
                                qty: qty,
                                desc: item.Combo_Desc,
                                price: item.Price_Description ??
                                    "RM ${item.Price}"));
                          }

                          currentQty = 0;
                          for (var element in selectedCombo) {
                            if (element.id == item.PARENT_ID) {
                              element.qty = qty;
                            }
                            currentQty += element.qty!;
                          }
                        });
                      }
                      return qty;
                    }
                  })
            ],
          ),
          const SizedBox(
            height: 23,
          ),
          Divider(
            height: 1,
            color: AppColor.dividerColor(),
          )
        ],
      ),
    );
  }

  Column comboItemPrice(ComboItemModel item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        item.Price_Description != null && item.Price_Description!.isNotEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width * .40,
                child: Text("RM ${item.Price}",
                    style: AppFont.poppinsRegular(10,
                        color: AppColor.greyWording(),
                        decoration: TextDecoration.lineThrough)),
              )
            : const SizedBox(),
        item.Price_Description != null && item.Price_Description!.isNotEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width * .40,
                child: Text(item.Price_Description ?? "-",
                    style: AppFont.poppinsRegular(16, color: Colors.white)),
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width * .40,
                child: Text("RM ${item.Price}",
                    style: AppFont.poppinsRegular(16, color: Colors.white)),
              ),
      ],
    );
  }

  Widget comboItemDesc(BuildContext ctx, ComboItemModel item) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6, left: 12),
      width: MediaQuery.of(context).size.width * .70 - 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * .70 - 16,
            padding: const EdgeInsets.only(bottom: 6, top: 12),
            child: Text(item.Combo_Desc ?? "-",
                style: AppFont.poppinsMedium(16, color: Colors.white)),
          ),
          item.CHILD!.CHILD!.length > 1
              ? InkWell(
                  onTap: () async {
                    if (item.SOLD_OUT_FLAG != "true") {
                      await showVariation(ctx, item);
                      setState(() {});
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppColor.iconGrey()),
                    width: MediaQuery.of(context).size.width * .70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            Utils.getTranslated(
                                context, "ecombo_variation_title"),
                            style: AppFont.poppinsRegular(12,
                                color: Colors.white)),
                        Image.asset(
                          'assets/images/right-simple-arrow.png',
                          height: 12,
                          width: 12,
                        )
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width * .70,
                  child: Text(item.Detail_Desc ?? "-",
                      style: AppFont.montRegular(12,
                          color: AppColor.greyWording())),
                ),
        ],
      ),
    );
  }

  Widget comboItemImage(ComboItemModel item) {
    return Stack(
      children: [
        InkWell(
          onTap: () => item.SOLD_OUT_FLAG != "true"
              ? _showEnlargedImage(item.ImageUrl!)
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: item.ImageUrl!,
              width: MediaQuery.of(context).size.width * .30 - 16,
              height: MediaQuery.of(context).size.width * .30 - 16,
              fit: BoxFit.cover,
              errorWidget: (context, error, stackTrace) {
                return Image.asset(
                    'assets/images/Default placeholder_app_img.png',
                    fit: BoxFit.fitWidth);
              },
            ),
          ),
        ),
        Positioned(
            top: 6,
            left: 6,
            child: Image.asset('assets/images/zoom-icon.png',
                fit: BoxFit.fitWidth)),
        item.SOLD_OUT_FLAG == "true"
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColor.dividerColor().withOpacity(0.78)),
                width: MediaQuery.of(context).size.width * .30 - 16,
                height: MediaQuery.of(context).size.width * .30 - 16,
                child: Center(
                  child: Text(
                    item.SOLD_OUT_MSG ??
                        Utils.getTranslated(context, "sold_out").toUpperCase(),
                    style: AppFont.poppinsBold(18, color: Colors.white),
                  ),
                ))
            : Container()
      ],
    );
  }

  Widget comboItemChild(ComboChildItemModel item, int finalqty,
      List<ComboChildItemModel> list, update) {
    int currentQty = 0;
    ComboModel tempFile = ComboModel(
        id: item.CODE, qty: 0, desc: item.DESC, price: "RM ${item.AMOUNT}");
    if (selectedCombo.isNotEmpty) {
      for (var element in selectedCombo) {
        if (element.id == item.CODE) {
          ComboModel tempFile = ComboModel(
              id: element.id,
              qty: element.qty,
              desc: element.desc,
              price: element.price);
          currentQty = element.qty!;
        }
      }
    }
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                comboChildItemImage(item),
                comboChildItemDesc(item),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              comboItemChildPrice(item),
              QuantityVariationButton(
                  isAurum: widget.data.isAurum != null
                      ? widget.data.isAurum!
                      : false,
                  hasVariation: false,
                  list: list,
                  selectedCombo: selectedCombo,
                  initialQuantity: currentQty,
                  maxQuantity: item.SOLD_OUT_FLAG == "true" ? 0 : 999,
                  currentQuantity: currentQty,
                  onQuantityChange: (qty) {
                    setState(() {
                      tempFile.qty = qty;
                    });

                    update(tempFile);

                    return null;
                  })
            ],
          ),
          const SizedBox(
            height: 23,
          ),
          Divider(
            height: 1,
            color: AppColor.dividerColor(),
          )
        ],
      ),
    );
  }

  Widget comboItemChildPrice(ComboChildItemModel item) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .40,
      child: Text("RM ${item.AMOUNT}",
          style: AppFont.poppinsRegular(16, color: Colors.white)),
    );
  }

  Container comboChildItemDesc(ComboChildItemModel item) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6, left: 12),
      width: MediaQuery.of(context).size.width * .70 - 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * .70 - 16,
            padding: const EdgeInsets.only(bottom: 6, top: 12),
            child: Text(item.DESC ?? "-",
                style: AppFont.poppinsMedium(16, color: Colors.white)),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .70,
            child: Text(item.Detail_Desc ?? "-",
                style: AppFont.montRegular(12, color: AppColor.greyWording())),
          ),
        ],
      ),
    );
  }

  void _showEnlargedImage(String url) {
    showDialog(
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.15),
      context: context,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'assets/images/close-icon.png',
                      height: 18,
                      width: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, top: 20),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      width: 280, // Adjust the size as needed
                      height: 280,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) {
                        return Image.asset(
                            'assets/images/Default placeholder_app_img.png',
                            fit: BoxFit.fitWidth);
                      },
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget comboChildItemImage(ComboChildItemModel item) {
    return Stack(
      children: [
        InkWell(
          onTap: () => _showEnlargedImage(item.ImageUrl!),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: item.ImageUrl!,
              width: MediaQuery.of(context).size.width * .30 - 16,
              height: MediaQuery.of(context).size.width * .30 - 16,
              fit: BoxFit.cover,
              errorWidget: (context, error, stackTrace) {
                return Image.asset(
                    'assets/images/Default placeholder_app_img.png',
                    fit: BoxFit.fitWidth);
              },
            ),
          ),
        ),
        Positioned(
            top: 6,
            left: 6,
            child: Image.asset('assets/images/zoom-icon.png',
                fit: BoxFit.fitWidth))
      ],
    );
  }

  Container confirmBtn(BuildContext context) {
    int totalItem = 0;
    double totalAmount = 0;

    for (var element in selectedCombo) {
      totalItem += element.qty!;

      var tempPrice =
          double.parse(element.price!.replaceAll("RM", "")) * element.qty!;

      totalAmount += tempPrice;
    }

    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
          left: 16.0,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 20),
      child: AbsorbPointer(
        absorbing: absorb,
        child: InkWell(
          onTap: () async {
            setState(() {
              absorb = true;
            });
            EasyLoading.show(maskType: EasyLoadingMaskType.black);
            _getInitSaleApi(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 15.0,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: widget.data.isAurum != null
                    ? widget.data.isAurum!
                        ? AppColor.aurumGold()
                        : AppColor.appYellow()
                    : AppColor.appYellow(),
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Utils.getTranslated(context, "ecombo_total_price")
                      .replaceAll('<qty>', totalItem.toString()),
                  style: AppFont.montSemibold(14, color: Colors.black),
                ),
                Text(
                  "RM ${totalAmount.toStringAsFixed(2)}",
                  style: AppFont.montSemibold(14, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showVariation(BuildContext ctx, ComboItemModel item) {
    List<ComboModel> tempbuffer = [];
    for (var data in item.CHILD!.CHILD!) {
      for (var element in selectedCombo) {
        if (data.CODE == element.id) {
          tempbuffer.add(ComboModel(
              id: element.id,
              qty: element.qty,
              desc: element.desc,
              price: element.price));
        }
      }
    }

    return showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.white.withOpacity(0.2),
        context: ctx,
        builder: (_) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              void update(ComboModel item) {
                setState(() {
                  if (!tempbuffer.any((element) => element.id == item.id)) {
                    tempbuffer.add(ComboModel(
                        id: item.id,
                        qty: item.qty,
                        desc: item.desc,
                        price: item.price));
                  } else {
                    for (var element in tempbuffer) {
                      if (element.id == item.id) {
                        element.qty = item.qty;
                      }
                    }
                  }
                });
              }

              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7 + 50,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 30, bottom: 35),
                          child: Stack(
                            children: [
                              SizedBox(
                                  height: 36,
                                  child: Center(
                                      child: Text(
                                    Utils.getTranslated(
                                        context, "ecombo_variation_title"),
                                    style: AppFont.montMedium(18,
                                        color: Colors.white),
                                  )),
                                  width: MediaQuery.of(context).size.width),
                              Positioned(
                                top: 0,
                                right: 16,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: Image.asset(
                                      'assets/images/close-icon.png',
                                      height: 14,
                                      width: 14,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7 -
                              50 -
                              101,
                          child: SingleChildScrollView(
                            primary: true,
                            child: Column(
                              children: [
                                for (var z = 0;
                                    z < item.CHILD!.CHILD!.length;
                                    z++)
                                  comboItemChild(item.CHILD!.CHILD![z], 0,
                                      item.CHILD!.CHILD!, update),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: widget.data.isAurum != null
                                  ? widget.data.isAurum!
                                      ? AppColor.aurumGold()
                                      : AppColor.appYellow()
                                  : AppColor.appYellow(),
                              borderRadius: BorderRadius.circular(6)),
                          child: TextButton(
                              onPressed: () {
                                for (var item in tempbuffer) {
                                  if (!selectedCombo.any(
                                      (element) => element.id == item.id)) {
                                    selectedCombo.add(ComboModel(
                                        id: item.id,
                                        qty: item.qty,
                                        desc: item.desc,
                                        price: item.price));
                                  } else {
                                    for (var element in selectedCombo) {
                                      if (element.id == item.id) {
                                        element.qty = item.qty;
                                      }
                                    }
                                  }
                                }

                                Navigator.of(context).pop(true);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: widget.data.isAurum != null
                                    ? widget.data.isAurum!
                                        ? AppColor.aurumGold()
                                        : AppColor.appYellow()
                                    : AppColor.appYellow(),
                                primary: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              child: variationConfirmBtn(
                                  context, item.CHILD!.CHILD!, tempbuffer)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  Widget variationConfirmBtn(
    BuildContext context,
    List<ComboChildItemModel> list,
    List<ComboModel> tempbuffer,
  ) {
    int totalItem = 0;
    double totalAmount = 0;
    for (var data in list) {
      for (var element in tempbuffer) {
        if (data.CODE == element.id) {
          totalItem += element.qty!;

          var tempPrice =
              double.parse(element.price!.replaceAll("RM", "")) * element.qty!;

          totalAmount += tempPrice;
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Utils.getTranslated(context, "confirm_btn"),
          style: AppFont.montSemibold(14, color: Colors.black),
        ),
        Text(
          "RM ${totalAmount.toStringAsFixed(2)}",
          style: AppFont.montSemibold(14, color: Colors.black),
        ),
      ],
    );
  }
}
