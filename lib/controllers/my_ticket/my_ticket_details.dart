// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../const/analytics_constant.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String url;
  final String? title;
  const TicketDetailsScreen({Key? key, required this.url, this.title})
      : super(key: key);

  @override
  State<TicketDetailsScreen> createState() {
    return _TicketDetailsScreen();
  }
}

class _TicketDetailsScreen extends State<TicketDetailsScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        clearCache: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_TICKET_DETAILS_SCREEN);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.appSecondaryBlack(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            )
          ],
          title: widget.title != null
              ? Text(widget.title!,
                  textAlign: TextAlign.center,
                  style: AppFont.montMedium(18, color: Colors.white))
              : const Material(),
          backgroundColor: AppColor.appSecondaryBlack(),
        ),
        body: SafeArea(
            child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
          initialOptions: options,
          onWebViewCreated: (controller) {
            webViewController = controller;
            webViewController?.loadUrl(
                urlRequest: URLRequest(url: Uri.parse(widget.url)));
          },
          onLoadStart: (controller, url) async {
            await EasyLoading.show(maskType: EasyLoadingMaskType.black);
            Utils.printInfo('Load Start url: $url');
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about"
            ].contains(uri.scheme)) {
              if (uri.scheme.startsWith("tel")) {
                if (await canLaunch(widget.url)) {
                  await launch(uri.toString());
                  return NavigationActionPolicy.CANCEL;
                }
              }

              if (await canLaunch(widget.url)) {
                // Launch the App
                await launch(
                  widget.url,
                );
                // and cancel the request
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            EasyLoading.dismiss();
            Utils.printInfo("on Load Stop");
          },
          onLoadError: (controller, url, code, message) {
            EasyLoading.dismiss();
            Utils.printInfo("Load Error: $message || URL: $url");
            Utils.showAlertDialog(
                context,
                Utils.getTranslated(context, "info_title"),
                message,
                true,
                false, () {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
          onProgressChanged: (controller, progress) {},
          onUpdateVisitedHistory: (controller, url, androidIsReload) {},
          onConsoleMessage: (controller, consoleMessage) {},
        )));
  }
}
