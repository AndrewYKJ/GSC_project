import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../cache/app_cache.dart';
import '../../const/analytics_constant.dart';
import '../../const/app_font.dart';
import '../../const/utils.dart';

class TicketQrScreen extends StatefulWidget {
  final String id;
  final String qrID;

  const TicketQrScreen({Key? key, required this.id, required this.qrID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TicketQrScreen();
  }
}

class _TicketQrScreen extends State<TicketQrScreen> {
  var isLogin = false;

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_TICKET_QR_SCREEN);
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    var hasAccessToken =
        await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    if (hasAccessToken) {
      setState(() {
        isLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white, actions: [
          IconButton(
            iconSize: 32,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          )
        ]),
        body: Container(
            height: height,
            width: width,
            color: Colors.white,
            child: SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  QrImage(
                      data: widget.qrID,
                      version: QrVersions.auto,
                      gapless: false,
                      size: 245.24
                      // embeddedImage: AssetImage('assets/images/logo.png'),
                      // embeddedImageStyle: QrEmbeddedImageStyle(
                      //   size: Size(106, 106),
                      // )
                      ),
                  Padding(
                      padding: const EdgeInsets.only(top: 20.38),
                      child: Text(
                          Utils.getTranslated(context, "confirmation_id") +
                              " " +
                              widget.id,
                          style:
                              AppFont.poppinsRegular(14, color: Colors.black)))
                ]))));
  }
}
