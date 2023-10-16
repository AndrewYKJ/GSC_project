// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/json/as_messages_model.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../const/app_color.dart';
import '../../dio/api/as_messages_api.dart';

class MessageDetailScreen extends StatefulWidget {
  // final InAppMessageInfoDTO messagesDTO;
  final String blastHeaderId;
  final String deviceUUID;
  const MessageDetailScreen(
      {Key? key, required this.blastHeaderId, required this.deviceUUID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MessageDetailScreen();
  }
}

class _MessageDetailScreen extends State<MessageDetailScreen> {
  late WebViewController _controller;
  InAppMessageInfoDTO? messageItem;
  String appName = Constants.MessageAppName;
  String memberId = AppCache.me?.MemberLists?.first.MemberID ?? '';
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_MESSAGE_DETAILS_SCREEN);

    callGetInAppMessageDetails(
        context, appName, memberId, widget.blastHeaderId, widget.deviceUUID);
    super.initState();
  }

  Future<InAppMessageDTO> getInAppMessageDetails(
      BuildContext context,
      String appName,
      String memberId,
      String blastHeaderId,
      String deviceUUID) async {
    AsMessagesApi asMessagesApi = AsMessagesApi(context);
    return asMessagesApi.getInAppMessagesDetails(
        context, appName, memberId, blastHeaderId, deviceUUID);
  }

  callGetInAppMessageDetails(BuildContext context, String appName,
      String memberId, String blastHeaderId, String deviceUUID) async {
    EasyLoading.show();
    await getInAppMessageDetails(
            context, appName, memberId, blastHeaderId, deviceUUID)
        .then((value) {
      if (value.returnStatus == 1) {
        if (value.inAppMessageInfoList != null &&
            value.inAppMessageInfoList!.isNotEmpty) {
          messageItem = value.inAppMessageInfoList!.first;
          if (messageItem != null) {
            getWebController(messageItem!);
          }
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
      Utils.printInfo('GET IN APP MESSAGE DETAILS ERROR: $error');
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

  getWebController(InAppMessageInfoDTO item) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              // isLoading = false;
            });
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
                      ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadHtmlString(item.inAppMessage!);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appBar(context, width),
                if (messageItem != null) messageTitle(context, messageItem!),
                if (messageItem != null) messageDateTime(context, messageItem!),
                if (messageItem != null) messageImage(context, messageItem!),
                if (messageItem != null)
                  messageDescription(context, messageItem!),
              ],
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
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            padding: const EdgeInsets.only(left: 6),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset(
              Constants.ASSET_IMAGES + 'white-left-icon.png',
              fit: BoxFit.cover,
              width: 23,
              height: 23,
            ),
          ),
        ),
      ]),
    );
  }

  Widget messageTitle(BuildContext context, InAppMessageInfoDTO item) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Text(
        item.inAppSubject != null ? item.inAppSubject! : '',
        style: AppFont.montBold(
          18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget messageDateTime(BuildContext context, InAppMessageInfoDTO item) {
    var dateTime =
        Utils.epochToDate(int.parse(Utils.getEpochUnix(item.sentOn!)));
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }

  Widget messageImage(BuildContext context, InAppMessageInfoDTO item) {
    if (item.inAppImageLink != null && item.inAppImageLink!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 28),
        child: Image.network(
          item.inAppImageLink!,
          fit: BoxFit.contain,
          width: double.infinity,
        ),
      );
    }

    return Container();
  }

  Widget messageDescription(BuildContext context, InAppMessageInfoDTO item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      child: Text(
        item.inAppDescription != null ? item.inAppDescription! : '',
        style: AppFont.poppinsRegular(
          12,
          color: Colors.white,
        ),
      ),
    );
  }
}
