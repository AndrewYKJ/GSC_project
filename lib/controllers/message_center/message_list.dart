import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/analytics_constant.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/dio/api/as_messages_api.dart';
import 'package:gsc_app/models/json/as_messages_delete_model.dart';
import 'package:gsc_app/models/json/as_messages_model.dart';
import 'package:gsc_app/widgets/custom_slidable_motion.dart';
import 'package:intl/intl.dart';

import '../../const/app_color.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';
import '../../routes/approutes.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MessageListScreen();
  }
}

class _MessageListScreen extends State<MessageListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isBulkDelete = false;
  int countCheckedMsg = 0;
  String appName = Constants.MessageAppName;
  String memberId = AppCache.me?.MemberLists?.first.MemberID ?? '';
  int page = 1;
  int pageSize = 20;
  List<InAppMessageInfoDTO> inAppMessgeInfoList = [];
  List<InAppMessageInfoDTO> deleteInAppList = [];
  bool isBulkDeleteError = false;
  ScrollController scrollController = ScrollController();
  bool isEnableRefreshIndicator = true;
  bool isLoading = false;
  bool noMoreData = false;
  late String deviceUUID;

  Future getAllInfo() async {
    await AppCache.getStringValue(AppCache.DEVICE_INFO).then((value) {
      var dataMap = json.decode(value);

      deviceUUID = dataMap["deviceUUID"];
    });

    setState(() {});
  }

  Future<InAppMessageDTO> getInAppMessagesList(
      BuildContext context, String appName, String memberId) async {
    AsMessagesApi asMessagesApi = AsMessagesApi(context);
    return asMessagesApi.getInAppMessagesList(
        context, appName, memberId, deviceUUID, page, pageSize);
  }

  Future<DeleteInAppMessageDTO> deleteInAppMessages(
      BuildContext context, String blastId) async {
    AsMessagesApi asMessagesApi = AsMessagesApi(context);
    return asMessagesApi.deleteInAppMessages(context, blastId);
  }

  void deleteMessage(BuildContext context) {}

  callGetInAppMessageList(
      BuildContext context, String appName, String memberId) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await getInAppMessagesList(context, appName, memberId).then((value) {
      if (value.returnStatus == 1) {
        if (value.inAppMessageInfoList != null &&
            value.inAppMessageInfoList!.isNotEmpty) {
          if (value.inAppMessageInfoList!.isEmpty ||
              value.inAppMessageInfoList!.length < pageSize) {
            noMoreData = true;
          }
          inAppMessgeInfoList.addAll(value.inAppMessageInfoList!);
        } else {
          noMoreData = true;
        }
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.returnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      }
    }).onError((error, stackTrace) {
      Utils.printInfo('GET IN APP MESSAGES ERROR: $error');
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
    }).whenComplete(() {
      setState(() {
        EasyLoading.dismiss();
      });
    });
  }

  callDeleteInAppMessage(InAppMessageInfoDTO inAppMessageInfoDTO) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await deleteInAppMessages(context, inAppMessageInfoDTO.blastId!)
        .then((value) {
      if (value.returnStatus == 1) {
        inAppMessgeInfoList.remove(inAppMessageInfoDTO);
      } else {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            value.returnMessage ??
                Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      }
    }).onError((error, stackTrace) {
      Utils.printInfo('DELETE IN APP MESSAGES ERROR: $error');
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
    }).whenComplete(() {
      setState(() {
        EasyLoading.dismiss();
        final controller = Slidable.of(context);
        controller?.dismiss(
          ResizeRequest(const Duration(milliseconds: 300), () => {}),
          duration: const Duration(milliseconds: 300),
        );
      });
    });
  }

  callBulkDeleteInAppMessage() async {
    if (deleteInAppList.isNotEmpty) {
      await deleteInAppMessages(context, deleteInAppList[0].blastId!)
          .then((value) {
        setState(() {
          if (value.returnStatus == 1) {
            inAppMessgeInfoList.remove(deleteInAppList[0]);
            deleteInAppList.removeAt(0);
            countCheckedMsg = deleteInAppList.length;
          } else {
            isBulkDeleteError = true;
          }
        });
      }).onError((error, stackTrace) {
        Utils.printInfo('BULK DELETE IN APP MESSAGES ERROR: $error');
        setState(() {
          isBulkDeleteError = true;
        });
      }).whenComplete(() {
        callBulkDeleteInAppMessage();
      });
    } else {
      EasyLoading.dismiss();

      if (isBulkDeleteError) {
        Utils.showAlertDialog(
            context,
            Utils.getTranslated(context, "error_title"),
            Utils.getTranslated(context, "general_error"),
            true,
            false, () {
          Navigator.pop(context);
        });
      } else {
        isBulkDelete = false;
      }
    }
  }

  Future<void> callRefreshData() async {
    inAppMessgeInfoList.clear();
    page = 1;
    noMoreData = false;
    callGetInAppMessageList(
        scaffoldKey.currentState!.context, appName, memberId);
  }

  @override
  void initState() {
    super.initState();
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_MESSAGE_LIST_SCREEN);

    getAllInfo().then((value) {
      callGetInAppMessageList(context, appName, memberId);
    });
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (noMoreData || inAppMessgeInfoList.length < pageSize) {
          return;
        }

        callGetInAppMessageList(
            scaffoldKey.currentState!.context, appName, memberId);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: AppColor.backgroundBlack(),
        centerTitle: true,
        title: Text(
          Utils.getTranslated(context, 'message_appbar_title'),
          style: AppFont.montRegular(18, color: Colors.white),
        ),
        leading: InkWell(
          onTap: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          child: Image.asset('assets/images/white-left-icon.png'),
        ),
        actions: [
          inAppMessgeInfoList.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      isBulkDelete = !isBulkDelete;
                      isEnableRefreshIndicator = true;
                      if (isBulkDelete) {
                        isEnableRefreshIndicator = false;
                        for (var element in inAppMessgeInfoList) {
                          element.isChecked = true;
                        }
                        deleteInAppList.addAll(inAppMessgeInfoList);
                        countCheckedMsg = inAppMessgeInfoList.length;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                    decoration: BoxDecoration(
                        color: AppColor.lightGrey(),
                        borderRadius: BorderRadius.circular(13)),
                    child: Text(
                      isBulkDelete
                          ? Utils.getTranslated(context, 'cancel_btn')
                          : Utils.getTranslated(
                              context, 'message_appbar_select_all'),
                      style: AppFont.montRegular(
                        10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, right: 16),
        height: height,
        width: width,
        color: Colors.black,
        child: SafeArea(
          child: inAppMessgeInfoList.isNotEmpty
              ? !isBulkDelete
                  ? RefreshIndicator(
                      backgroundColor: Colors.transparent,
                      color: AppColor.appYellow(),
                      onRefresh: () => callRefreshData(),
                      child: SlidableAutoCloseBehavior(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: inAppMessgeInfoList
                                .map((e) => messageItem(context, e))
                                .toList(),
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      notificationPredicate:
                          isEnableRefreshIndicator ? (_) => true : (_) => false,
                      backgroundColor: Colors.transparent,
                      color: AppColor.appYellow(),
                      onRefresh: () => callRefreshData(),
                      child: ListView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: inAppMessgeInfoList
                            .map((e) => messageItemWithCheckbox(context, e))
                            .toList(),
                      ),
                    )
              : emptyScreen(context),
        ),
      ),
      bottomNavigationBar:
          inAppMessgeInfoList.isNotEmpty ? _submitBtn() : const SizedBox(),
    );
  }

  Widget emptyScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/no-records-icon.png',
        ),
        Text(
          Utils.getTranslated(context, 'no_record_found'),
          style: AppFont.montRegular(
            16,
            color: AppColor.dividerColor(),
          ),
        ),
      ],
    );
  }

  Widget messageTitle(BuildContext context, InAppMessageInfoDTO messagesDTO) {
    return Text(
      messagesDTO.inAppSubject != null ? messagesDTO.inAppSubject! : '',
      style: AppFont.montSemibold(
        14,
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget messageDateTime(
      BuildContext context, InAppMessageInfoDTO messagesDTO) {
    var dateTime =
        Utils.epochToDate(int.parse(Utils.getEpochUnix(messagesDTO.sentOn!)));
    return Wrap(
      children: [
        Image.asset(
          Constants.ASSET_IMAGES + 'time-simple-icon.png',
          color: AppColor.iconGrey(),
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat('hh:mm a').format(dateTime),
          style: AppFont.poppinsRegular(
            12,
            color: AppColor.iconGrey(),
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 16),
        Image.asset(
          Constants.ASSET_IMAGES + 'calender-simple-icon.png',
          color: AppColor.iconGrey(),
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat('E, dd MMM yyyy').format(dateTime),
          style: AppFont.poppinsRegular(
            12,
            color: AppColor.iconGrey(),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget messageItem(BuildContext context, InAppMessageInfoDTO messagesDTO) {
    return InkWell(
      onTap: () {
        setState(() {
          messagesDTO.readStatus = true;
        });
        Navigator.pushNamed(context, AppRoutes.messageDetailRoute,
            arguments: [messagesDTO.blastHeadId, deviceUUID]);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => WebView(
        //       useHtmlString: true,
        //       htmlString: messagesDTO.inAppMessage,
        //       url: '',
        //     ),
        //   ),
        // );
      },
      child: Slidable(
        key: Key('${messagesDTO.blastId}'),
        endActionPane: ActionPane(
          extentRatio: 0.2,
          motion: CustomSlidableMotion(
              onOpen: () {
                setState(() {
                  for (var element in inAppMessgeInfoList) {
                    element.isShowArrowRightIcon = true;
                  }
                  messagesDTO.isShowArrowRightIcon = false;
                });
              },
              onClose: () {
                setState(() {
                  messagesDTO.isShowArrowRightIcon = true;
                });
              },
              motionWidget: const BehindMotion()),
          children: [
            CustomSlidableAction(
              autoClose: false,
              padding: const EdgeInsets.all(15),
              onPressed: deleteMessage,
              backgroundColor: AppColor.msgDeleteActionBackground(),
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  callDeleteInAppMessage(messagesDTO);
                  // setState(() {
                  //   inAppMessgeInfoList.remove(messagesDTO);
                  //   final controller = Slidable.of(context);
                  //   controller?.dismiss(
                  //     ResizeRequest(
                  //         const Duration(milliseconds: 300), () => {}),
                  //     duration: const Duration(milliseconds: 300),
                  //   );
                  // });
                },
                child: Image.asset(
                  Constants.ASSET_IMAGES + 'delete-icon.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 22, bottom: 22),
              decoration: BoxDecoration(
                border: Border(
                  top: inAppMessgeInfoList.indexOf(messagesDTO) == 0
                      ? BorderSide.none
                      : BorderSide(
                          width: 1.0,
                          color: AppColor.dividerColor(),
                        ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !messagesDTO.readStatus!
                      ? Image.asset(
                          Constants.ASSET_IMAGES + 'message-icon.png',
                          width: 46,
                          height: 46,
                        )
                      : Image.asset(
                          Constants.ASSET_IMAGES + 'open-message-icon.png',
                          width: 46,
                          height: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        messageTitle(context, messagesDTO),
                        const SizedBox(height: 5),
                        messageDateTime(context, messagesDTO),
                      ],
                    ),
                  ),
                  messagesDTO.isShowArrowRightIcon!
                      ? Image.asset(
                          Constants.ASSET_IMAGES + 'right-simple-arrow.png',
                          width: 20,
                          height: 20,
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageItemWithCheckbox(
      BuildContext context, InAppMessageInfoDTO messagesDTO) {
    return InkWell(
      onTap: () {
        setState(() {
          messagesDTO.readStatus = true;
        });
        Navigator.pushNamed(context, AppRoutes.messageDetailRoute,
            arguments: messagesDTO.blastHeadId);
      },
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 22, bottom: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    checkColor: Colors.black,
                    activeColor: AppColor.appYellow(),
                    value: messagesDTO.isChecked,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          if (value) {
                            if (!deleteInAppList.contains(messagesDTO)) {
                              deleteInAppList.add(messagesDTO);
                            }
                          } else {
                            if (deleteInAppList.contains(messagesDTO)) {
                              deleteInAppList.remove(messagesDTO);
                            }
                          }
                          messagesDTO.isChecked = value;
                          countCheckedMsg = deleteInAppList.length;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 13),
                  !messagesDTO.readStatus!
                      ? Image.asset(
                          Constants.ASSET_IMAGES + 'message-icon.png',
                          width: 46,
                          height: 46,
                        )
                      : Image.asset(
                          Constants.ASSET_IMAGES + 'open-message-icon.png',
                          width: 46,
                          height: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        messageTitle(context, messagesDTO),
                        const SizedBox(height: 5),
                        messageDateTime(context, messagesDTO),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            inAppMessgeInfoList.indexOf(messagesDTO) !=
                    inAppMessgeInfoList.length - 1
                ? Divider(
                    color: AppColor.dividerColor(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _submitBtn() {
    if (isBulkDelete) {
      return BottomAppBar(
        color: Colors.black,
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 13),
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: AppColor.msgDeleteActionBackground()),
            onPressed: () async {
              if (countCheckedMsg > 0) {
                EasyLoading.show(maskType: EasyLoadingMaskType.black);
                callBulkDeleteInAppMessage();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                Utils.getTranslated(context, "message_delete_btn")
                    .replaceAll('<number>', '$countCheckedMsg'),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
