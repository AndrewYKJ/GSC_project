// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../const/app_font.dart';

class WebView extends StatefulWidget {
  String url = "";
  String? title = "";
  String? htmlString = "";
  bool? useHtmlString = false;
  WebView(
      {Key? key,
      required this.url,
      this.useHtmlString,
      this.htmlString,
      this.title})
      : super(key: key);

  @override
  State<WebView> createState() {
    return _WebViewPage();
  }
}

class _WebViewPage extends State<WebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    Utils.printInfo("URL: ${widget.title}");
    super.initState();
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
              isLoading = false;
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
      );
    widget.useHtmlString != null
        ? !widget.useHtmlString!
            ? controller.loadRequest(Uri.parse(widget.url))
            : controller.loadHtmlString(widget.htmlString!)
        : controller.loadRequest(Uri.parse(widget.url));
    widget.useHtmlString != null
        ? !widget.useHtmlString!
            ? controller.setBackgroundColor(const Color(0x00000000))
            : controller
                .setBackgroundColor(const Color.fromARGB(255, 255, 255, 255))
        : controller.setBackgroundColor(const Color(0x00000000));
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
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: widget.title != null
              ? Text(widget.title!,
                  textAlign: TextAlign.center,
                  style: AppFont.montMedium(18, color: Colors.white))
              : const Material(),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/images/white-left-icon.png',
                color: Colors.white,
              )),
          backgroundColor: Colors.black,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.lightGrey(),
                ),
              )
            : SafeArea(child: WebViewWidget(controller: _controller)));
  }
}
