import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/dio/api/e_combo_api.dart';
import 'package:gsc_app/models/arguments/aurum_ecombo_selection_arguments.dart';
import 'package:gsc_app/models/json/aurum_ecombo.dart';
import 'package:gsc_app/models/json/aurum_ecombo_model.dart';
import 'package:gsc_app/models/json/aurum_ecombo_selection_option_model.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../const/analytics_constant.dart';
import '../../const/constants.dart';
import '../../const/utils.dart';
import '../../dio/api/transactions_api.dart';
import '../../models/arguments/combo_selection_arguments.dart';
import '../../models/arguments/init_transaction_arguments.dart';
import '../../models/json/e_combo_bundle.dart';
import '../../models/json/init_sales_trans_reponse.dart';
import '../../models/json/ticket_item_model.dart';
import '../../routes/approutes.dart';

class AurumEcombo extends StatefulWidget {
  final AurumEComboArgs data;
  const AurumEcombo({Key? key, required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AurumEcombo();
  }
}

class _AurumEcombo extends State<AurumEcombo>
    with SingleTickerProviderStateMixin {
  InitSalesDTO? initSalesDTO;
  List<dynamic> selectedTicket = [];
  int mainIndex = 0;
  int subIndex = 0;
  List<String> bundleCode = [];
  var body = {};
  List<EComboBundle>? ecomboOptions;
  int? bundleLen;
  dynamic foodMenu;
  dynamic drinkMenu;
  List foodMenuList = [];
  List drinkMenuList = [];
  String? appVersion;
  String? appPlatform;
  bool isComplete = false;
  bool absorb = false;
  late TabController _tabController;
  List<AurumEComboSelectedOption> selectedOption = [];
  List<ComboModel> selectedCombo = [];

  Future<dynamic> initTransactionApi(BuildContext context) async {
    List ticketType = [];
    List selecttkt = [];
    List seatType = [];

    for (var data in widget.data.selectedTicket!) {
      for (var i = 0; i < data.qty!; i++) {
        ticketType.add(data.type);
      }
    }

    widget.data.seatTypeMap!.forEach((key, value) {
      selecttkt.add("$key: ${value['qty']}");
      for (var i = 0; i < value['qty']; i++) {
        seatType.add(key);
      }
    });

    TransactionsApi itm = TransactionsApi(context);
    return itm.initSalesTransaction(
        widget.data.locationId!,
        widget.data.showId!,
        widget.data.seats!,
        ticketType.join(',').toString(),
        '',
        seatType.join(',').toString(),
        '',
        selecttkt.join(', ').toString(),
        "userEmail",
        "userIC",
        "userPhoneno",
        "token",
        appVersion,
        appPlatform!,
        widget.data.fromWher,
        selectedOption);
  }

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_ECOMBO_SELECTION_AURUM_SCREEN);

    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);

    var i = 0;

    while (i < widget.data.selectedTicket!.length) {
      bundleCode.add(widget.data.selectedTicket![i].bundleCode!);
      selectedTicket.add(AurumEcomboModel(
          name: widget.data.selectedTicket![i].type,
          quantity: widget.data.selectedTicket![i].qty,
          bundleCode: widget.data.selectedTicket![i].bundleCode!,
          isComplete: false,
          selectedFood: 0,
          selectedDrink: 0,
          selectedItmCode: []));
      i++;
    }
    getAurumEcomboDetails();
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

  generateBody() {
    var today = DateTime.now();
    var dateFormat = DateFormat('yyy-MM-dd HH:mm:ss');
    String currentDate = dateFormat.format(today);

    body = {
      "Request": {
        "Header": {
          "Ver": "1.0.0.1",
          "ReqDt": currentDate,
          "Req": "doGetBundleDetail"
        },
        "Body": {"Bundles": bundleCode}
      },
      "Signature": ""
    };
  }

  Future<AurumEcomboMain> getEcomboListing(BuildContext context, body) async {
    EComboApi itm = EComboApi(context);
    return itm.getAurumEcombo(body);
  }

  getAurumEcomboDetails() async {
    generateBody();

    await getEcomboListing(context, body)
        .then((data) {
          ecomboOptions = data.Response?.Body?.Bundles;
          bundleLen = data.Response?.Body?.Bundles?.length;

          int i = 0;
          while (i < bundleLen!) {
            foodMenu = ecomboOptions?[i]
                .Options
                ?.where((e) => e.OptionNo == 1)
                .toList();
            drinkMenu = ecomboOptions?[i]
                .Options
                ?.where((e) => e.OptionNo == 2)
                .toList();
            foodMenuList.add(foodMenu);
            drinkMenuList.add(drinkMenu);

            i++;
          }
        })
        .whenComplete(() => {
              setState(() {
                isComplete = true;
              })
            })
        .catchError((e) {
          Utils.printInfo("ERROR: $e");
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              e != null
                  ? e.message ?? Utils.getTranslated(context, "general_error")
                  : Utils.getTranslated(context, "general_error"),
              true,
              widget.data.isAurum, () {
            Navigator.of(context).pop();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColor.backgroundBlack(),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset('assets/images/white-left-icon.png')),
          title: Text(Utils.getTranslated(context, "select_ecombo"),
              style: AppFont.montMedium(18)),
        ),
        body: Container(
            width: width,
            color: Colors.black,
            child: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                      color: AppColor.backgroundBlack(), child: _mainTab()),
                  _title(),
                  _subTab(),
                  _foodLabel(),
                  isComplete == false
                      ? Container()
                      : subIndex == 0
                          ? _foodItems()
                          : _drinkItems()
                ]))),
        bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            child: SizedBox(
              height: 65,
              child: Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: AbsorbPointer(
                    absorbing: absorb,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: selectedTicket
                                        .where((e) =>
                                            e.selectedFood == e.quantity &&
                                            e.selectedDrink == e.quantity)
                                        .toList()
                                        .length ==
                                    selectedTicket.length
                                ? widget.data.isAurum == true
                                    ? AppColor.aurumGold()
                                    : AppColor.appYellow()
                                : widget.data.isAurum == true
                                    ? AppColor.aurumConfirmBtnDim()
                                    : AppColor.darkYellow()),
                        onPressed: () {
                          setState(() {
                            if (selectedTicket
                                    .where((e) =>
                                        e.selectedFood == e.quantity &&
                                        e.selectedDrink == e.quantity)
                                    .toList()
                                    .length ==
                                selectedTicket.length) {
                              _selectedOptionField();
                              if (widget.data.comboList!.isNotEmpty) {
                                Navigator.pushNamed(
                                    context, AppRoutes.comboSelectionScreen,
                                    arguments: ComboSelectionArguments(
                                        locationId: widget.data.locationId!,
                                        showId: widget.data.showId!,
                                        cinemaName: widget.data.cinemaName!,
                                        hallId: widget.data.hallId!,
                                        filmId: widget.data.filmId!,
                                        opsDate: widget.data.opsDate!,
                                        showDate: widget.data.showDate!,
                                        showTime: widget.data.showTime!,
                                        movieTitle: widget.data.movieTitle!,
                                        comboList: widget.data.comboList,
                                        seats: widget.data.seats!,
                                        ticketQty: widget.data.ticketQty!,
                                        seatTypeMap: widget.data.seatTypeMap,
                                        SelectedOptions: selectedOption,
                                        aurumCombo: selectedCombo,
                                        selectedTicket:
                                            widget.data.selectedTicket,
                                        fromWher: widget.data.fromWher,
                                        isAurum: widget.data.isAurum));
                              } else {
                                absorb = true;
                                EasyLoading.show(
                                    maskType: EasyLoadingMaskType.black);

                                getInitSalesApi(context);
                              }
                            }
                          });
                        },
                        child: Text(Utils.getTranslated(context, 'confirm_btn'),
                            style:
                                AppFont.montSemibold(14, color: Colors.black))),
                  )),
            )));
  }

  void getInitSalesApi(BuildContext context) {
    initTransactionApi(context).then((value) {
      EasyLoading.dismiss();
      setState(() {
        initSalesDTO = value;

        if (initSalesDTO!.error != null) {
          Utils.showAlertDialog(
              context,
              Utils.getTranslated(context, "error_title"),
              initSalesDTO!.error!.displayMsg!,
              true,
              widget.data.isAurum,
              () => Navigator.of(context).pop());
        } else {
          Navigator.pushNamed(context, AppRoutes.reviewSummaryRoute,
              arguments: InitSalesTransactionArg(
                  locationId: widget.data.locationId!,
                  hallId: widget.data.hallId!,
                  showId: widget.data.showId!,
                  cinemaName: widget.data.cinemaName!,
                  filmId: widget.data.filmId!,
                  initSalesDTO: initSalesDTO,
                  opsDate: widget.data.opsDate!,
                  showDate: widget.data.showDate!,
                  showTime: widget.data.showTime!,
                  movieTitle: widget.data.movieTitle!,
                  aurumCombo: selectedCombo,
                  selectedTicket: widget.data.selectedTicket,
                  seats: widget.data.seats!,
                  ticketQty: widget.data.ticketQty!,
                  seatTypeMap: widget.data.seatTypeMap,
                  SelectedOptions: selectedOption,
                  isAurum: widget.data.isAurum,
                  selectedCombo: []));
        }
      });
    }, onError: (e) {
      EasyLoading.dismiss();

      Utils.showAlertDialog(
          context,
          Utils.getTranslated(context, "error_title"),
          e != null
              ? e.message ?? Utils.getTranslated(context, "general_error")
              : Utils.getTranslated(context, "general_error"),
          true,
          widget.data.isAurum, () {
        Navigator.of(context).pop();
      });
    }).whenComplete(() {
      setState(() {
        absorb = false;
      });
    });
  }

  Widget _mainTab() {
    return Stack(children: [
      Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          width: MediaQuery.of(context).size.width,
          height: 60,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: selectedTicket.length,
              itemBuilder: (context, index) {
                return _mainTabItm(index);
              })),
    ]);
  }

  Widget _mainTabItm(int i) {
    return InkWell(
        onTap: () {
          setState(() {
            mainIndex = i;
            _tabController.animateTo(0);
            subIndex = 0;
          });
        },
        child: Container(
            width: (MediaQuery.of(context).size.width - 32) /
                selectedTicket.length,
            decoration: selectedTicket[i].isComplete == true
                ? BoxDecoration(
                    color: selectedTicket[i].isComplete == true
                        ? widget.data.isAurum == true
                            ? AppColor.aurumUnderline()
                            : AppColor.appYellow()
                        : AppColor.backgroundBlack(),
                    border: mainIndex == i
                        ? selectedTicket[i].isComplete == true
                            ? widget.data.isAurum == true
                                ? Border.all(color: AppColor.aurumUnderline())
                                : Border.all(color: AppColor.appYellow())
                            : Border.all(color: AppColor.backgroundBlack())
                        : Border.all(color: AppColor.backgroundBlack()),
                    borderRadius: selectedTicket[i].isComplete == true
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16))
                        : BorderRadius.zero,
                  )
                : BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: mainIndex == i
                                ? widget.data.isAurum == true
                                    ? AppColor.aurumUnderline()
                                    : AppColor.appYellow()
                                : AppColor.backgroundBlack()))),
            padding: const EdgeInsets.only(bottom: 0),
            child: Tab(
                child: Column(children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 6, top: 8),
                  child: Text(selectedTicket[i].name,
                      style: AppFont.montRegular(14,
                          color: selectedTicket[i].isComplete == true
                              ? Colors.black
                              : mainIndex == i
                                  ? Colors.white
                                  : AppColor.iconGrey()))),
              Image.asset(
                  selectedTicket[i].isComplete == false
                      ? Constants.ASSET_IMAGES +
                          'Aurum_eCombo_Grey_Circle_icon.png'
                      : widget.data.isAurum == true
                          ? Constants.ASSET_IMAGES + 'aurum-complete-icon.png'
                          : Constants.ASSET_IMAGES +
                              'Aurum_ecombo_tick_icon.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain),
            ]))));
  }

  Widget _title() {
    return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: RichText(
          text: TextSpan(
              text: Utils.getTranslated((context), "please_choose"),
              style: AppFont.poppinsRegular(14),
              children: [
                TextSpan(
                    text: selectedTicket[mainIndex].quantity.toString() +
                        " " +
                        Utils.getTranslated(context, "food"),
                    style: AppFont.poppinsSemibold(14,
                        color: widget.data.isAurum == true
                            ? AppColor.aurumUnderline()
                            : AppColor.appYellow())),
                TextSpan(
                    text: " " + Utils.getTranslated(context, "and") + " ",
                    style: AppFont.poppinsRegular(14)),
                TextSpan(
                    text: selectedTicket[mainIndex].quantity.toString() +
                        " " +
                        Utils.getTranslated(context, "drink"),
                    style: AppFont.poppinsSemibold(14,
                        color: widget.data.isAurum == true
                            ? AppColor.aurumUnderline()
                            : AppColor.appYellow())),
                TextSpan(
                    text: " " +
                        Utils.getTranslated(
                            context, "from_the_selection_below"),
                    style: AppFont.poppinsRegular(14)),
                TextSpan(
                    text: "(" +
                        selectedTicket[mainIndex].name.toUpperCase() +
                        " X " +
                        selectedTicket[mainIndex].quantity.toString() +
                        ')',
                    style: AppFont.poppinsRegular(14))
              ]),
        ));
  }

  Widget _subTab() {
    return Container(
        width: 164,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DefaultTabController(
            length: 2,
            child: Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: AppColor.iconGrey(), width: 2.0),
                      ),
                    ),
                  ),
                  TabBar(
                      controller: _tabController,
                      onTap: (value) => {
                            setState(() {
                              subIndex = value;
                            })
                          },
                      indicatorColor: widget.data.isAurum == true
                          ? AppColor.aurumUnderline()
                          : AppColor.appYellow(),
                      labelColor: widget.data.isAurum == true
                          ? AppColor.aurumUnderline()
                          : AppColor.appYellow(),
                      unselectedLabelColor: AppColor.iconGrey(),
                      isScrollable: true,
                      tabs: [
                        Tab(text: Utils.getTranslated(context, "food_title")),
                        Tab(text: Utils.getTranslated(context, "drink_title"))
                      ])
                ])));
  }

  Widget _foodLabel() {
    return subIndex == 0
        ? Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
                Utils.getTranslated(context, "food_title") +
                    " ( " +
                    selectedTicket[mainIndex].selectedFood.toString() +
                    " / " +
                    selectedTicket[mainIndex].quantity.toString() +
                    " )",
                style: AppFont.montRegular(12,
                    color: widget.data.isAurum == true
                        ? AppColor.aurumGold()
                        : AppColor.appYellow())))
        : Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
                Utils.getTranslated(context, "drink_title") +
                    " ( " +
                    selectedTicket[mainIndex].selectedDrink.toString() +
                    " / " +
                    selectedTicket[mainIndex].quantity.toString() +
                    " )",
                style: AppFont.montRegular(12,
                    color: widget.data.isAurum == true
                        ? AppColor.aurumGold()
                        : AppColor.appYellow())));
  }

  Widget _foodItems() {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ListView.builder(
                  itemCount: foodMenuList[mainIndex].length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
                    return _foodItm(context, index);
                  }),
                ))));
  }

  Widget _foodItm(BuildContext context, int i) {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
            onTap: () {
              setState(() {
                _showEnlargedImage(
                    foodMenuList[mainIndex][i].Items[0].ImageUrl);
              });
            },
            child: Stack(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                      foodMenuList[mainIndex][i].Items[0].ImageUrl,
                      width: 109,
                      height: 109,
                      fit: BoxFit.cover)),
              Padding(
                  padding: const EdgeInsets.only(top: 5.5, left: 6),
                  child: Image.asset(
                    Constants.ASSET_IMAGES + 'zoom-icon.png',
                    width: 14,
                    height: 14,
                  ))
            ])),
        Expanded(
            child: SizedBox(
                height: 109,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 12, left: 13.25),
                          child: Text(foodMenuList[mainIndex][i].Items[0].Name,
                              maxLines: 2,
                              style: AppFont.poppinsMedium(16,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis))),
                      const Spacer(),
                      _foodBtns(context, mainIndex, i),
                    ])))
      ]),
      Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 40),
          child: Divider(
            color: widget.data.isAurum == true
                ? AppColor.aurumDay()
                : AppColor.appYellow(),
            thickness: 1,
          ))
    ]);
  }

  Widget _drinkItems() {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ListView.builder(
                  itemCount: drinkMenuList[mainIndex].length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
                    return _drinkItm(context, index);
                  }),
                ))));
  }

  Widget _drinkItm(BuildContext context, int i) {
    String drinkCategory = '';

    if (i == 0) {
      drinkCategory = drinkMenuList[mainIndex][i].Items[0].Category;
    } else {
      drinkCategory = drinkMenuList[mainIndex][i - 1].Items[0].Category;
    }
    return Column(children: [
      drinkCategory != drinkMenuList[mainIndex][i].Items[0].Category || i == 0
          ? Padding(
              padding: (i == 0)
                  ? const EdgeInsets.only(bottom: 23)
                  : const EdgeInsets.only(top: 48, bottom: 23),
              child: Row(children: [
                Image.asset(Constants.ASSET_IMAGES + 'Aurum_Drink_icon.png',
                    width: 28, height: 28, fit: BoxFit.contain),
                Text(
                    drinkMenuList[mainIndex][i].Items[0].Category.toUpperCase(),
                    style: AppFont.montSemibold(14, color: Colors.white))
              ]))
          : Row(children: const []),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Text(drinkMenuList[mainIndex][i].Items[0].Name,
                style: AppFont.poppinsMedium(16,
                    color: Colors.white, overflow: TextOverflow.ellipsis))),
        _drinkBtns(context, mainIndex, i),
      ]),
      Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Divider(
            color: widget.data.isAurum == true
                ? AppColor.aurumDay()
                : AppColor.appYellow(),
            thickness: 1,
          ))
    ]);
  }

  Widget _foodBtns(BuildContext context, int mainIndex, int idx) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          InkWell(
              onTap: () {
                setState(() {
                  if (foodMenuList[mainIndex][idx].Items[0].itmQuantity > 0) {
                    foodMenuList[mainIndex][idx].Items[0].itmQuantity -= 1;
                    selectedTicket[mainIndex].selectedFood -= 1;
                    selectedTicket[mainIndex].isComplete = false;
                    selectedTicket[mainIndex].selectedItmCode.removeWhere(
                        (item) =>
                            item == foodMenuList[mainIndex][idx].Items[0].Code);
                  }
                });
              },
              child: foodMenuList[mainIndex][idx].Items[0].itmQuantity == 0
                  ? Image.asset(Constants.ASSET_IMAGES +
                      'aurum-darkgrey-minus-button.png')
                  : Image.asset(widget.data.isAurum == true
                      ? Constants.ASSET_IMAGES + 'aurum-minus-button.png'
                      : Constants.ASSET_IMAGES + 'minus-button.png')),
          SizedBox(
              width: 50,
              child: Text(
                  foodMenuList[mainIndex][idx].Items[0].itmQuantity.toString(),
                  textAlign: TextAlign.center,
                  style: AppFont.poppinsRegular(16, color: Colors.white))),
          InkWell(
              onTap: () {
                setState(() {
                  if (selectedTicket[mainIndex].selectedFood !=
                      selectedTicket[mainIndex].quantity) {
                    foodMenuList[mainIndex][idx].Items[0].itmQuantity += 1;
                    selectedTicket[mainIndex].selectedFood += 1;
                    selectedTicket[mainIndex].isComplete = false;
                    selectedTicket[mainIndex]
                        .selectedItmCode
                        .add(foodMenuList[mainIndex][idx].Items[0].Code);
                  }
                  if (selectedTicket[mainIndex].selectedFood ==
                          selectedTicket[mainIndex].quantity &&
                      selectedTicket[mainIndex].quantity ==
                          selectedTicket[mainIndex].selectedDrink) {
                    selectedTicket[mainIndex].isComplete = true;
                  }

                  if (selectedTicket[mainIndex].selectedFood ==
                      selectedTicket[mainIndex].quantity) {
                    subIndex = 1;
                    _tabController.animateTo(1);
                  }
                });
              },
              child: Image.asset(widget.data.isAurum == true
                  ? Constants.ASSET_IMAGES + 'aurum-plus-button.png'
                  : Constants.ASSET_IMAGES + 'plus-button.png'))
        ]));
  }

  Widget _drinkBtns(BuildContext context, int mainIndex, int idx) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      InkWell(
          onTap: () {
            setState(() {
              if (drinkMenuList[mainIndex][idx].Items[0].itmQuantity > 0) {
                drinkMenuList[mainIndex][idx].Items[0].itmQuantity -= 1;
                selectedTicket[mainIndex].selectedDrink -= 1;
                selectedTicket[mainIndex].isComplete = false;
                selectedTicket[mainIndex].selectedItmCode.removeWhere((item) =>
                    item == drinkMenuList[mainIndex][idx].Items[0].Code);
              }
            });
          },
          child: drinkMenuList[mainIndex][idx].Items[0].itmQuantity == 0
              ? Image.asset(
                  Constants.ASSET_IMAGES + 'aurum-darkgrey-minus-button.png')
              : Image.asset(widget.data.isAurum == true
                  ? Constants.ASSET_IMAGES + 'aurum-minus-button.png'
                  : Constants.ASSET_IMAGES + 'minus-button.png')),
      SizedBox(
          width: 50,
          child: Text(
              drinkMenuList[mainIndex][idx].Items[0].itmQuantity.toString(),
              textAlign: TextAlign.center,
              style: AppFont.poppinsRegular(16, color: Colors.white))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedTicket[mainIndex].selectedDrink !=
                  selectedTicket[mainIndex].quantity) {
                drinkMenuList[mainIndex][idx].Items[0].itmQuantity += 1;
                selectedTicket[mainIndex].selectedDrink += 1;
                selectedTicket[mainIndex].isComplete = false;
                selectedTicket[mainIndex]
                    .selectedItmCode
                    .add(drinkMenuList[mainIndex][idx].Items[0].Code);
              }
              if (selectedTicket[mainIndex].selectedFood ==
                      selectedTicket[mainIndex].quantity &&
                  selectedTicket[mainIndex].quantity ==
                      selectedTicket[mainIndex].selectedDrink) {
                selectedTicket[mainIndex].isComplete = true;
              }
            });
          },
          child: Image.asset(widget.data.isAurum == true
              ? Constants.ASSET_IMAGES + 'aurum-plus-button.png'
              : Constants.ASSET_IMAGES + 'plus-button.png'))
    ]);
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
                      width: 280,
                      height: 280,
                      fit: BoxFit.cover,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectedOptionField() {
    var i = 0;

    var selectedBundle = [];

    while (i < selectedTicket.length) {
      selectedOption.add(AurumEComboSelectedOption(selectedTicket[i].name,
          selectedTicket[i].bundleCode, selectedTicket[i].selectedItmCode));

      selectedTicket[i].selectedItmCode.forEach((e) => {selectedBundle.add(e)});

      i++;
    }

    var len = 0;
    for (var itm in foodMenuList) {
      {
        itm.forEach((e) => {
              len = selectedBundle
                  .where((element) => element == e.Items[0].Code)
                  .length,
              if (e.Items.length > 0 &&
                  selectedCombo
                      .where((item) => item.desc == e.Items[0].Name)
                      .isEmpty)
                {
                  selectedCombo.add(ComboModel(
                      id: '-1', qty: len, desc: e.Items[0].Name, price: '0'))
                }
            });
      }
    }

    for (var itm in drinkMenuList) {
      {
        itm.forEach((e) => {
              len = selectedBundle
                  .where((element) => element == e.Items[0].Code)
                  .length,
              if (e.Items.length > 0 &&
                  selectedCombo
                      .where((item) => item.desc == e.Items[0].Name)
                      .isEmpty)
                {
                  selectedCombo.add(ComboModel(
                      id: '-1', qty: len, desc: e.Items[0].Name, price: '0'))
                }
            });
      }
    }

    selectedCombo = selectedCombo.where((e) => e.qty! > 0).toList();
  }
}
