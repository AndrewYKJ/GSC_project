// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
// import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/cache/app_cache.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/my_ticket/my_ticket.dart';
import 'package:gsc_app/controllers/tab/homebase.dart';
import '../../const/analytics_constant.dart';
import '../../models/arguments/payment_result_arguments.dart';

class CompletePurchase extends StatefulWidget {
  final TransactionResultArg data;
  const CompletePurchase({Key? key, required this.data}) : super(key: key);

  @override
  State<CompletePurchase> createState() => _CompletePurchaseState();
}

const PADDING = 20.0;
const CIRCULAR_RADIUS = 50.0;

class _CompletePurchaseState extends State<CompletePurchase> {
  String? imageUrl;
  // static final facebookAppEvents = FacebookAppEvents();

  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_DONE_TRANSACTION_SCREEN);
    checkImagePoster();
    super.initState();
    logFbEvent();
  }

  checkImagePoster() {
    if (AppCache.movieEpaymentList?.films?.parent != null) {
      if (AppCache.movieEpaymentList!.films!.parent!
          .any((element) => element.title == widget.data.movieTitle)) {
        imageUrl = AppCache.movieEpaymentList!.films!.parent!
            .firstWhere((element) => element.title == widget.data.movieTitle)
            .child!
            .first
            .thumbBig;
      }
    }
  }

  logFbEvent() {
    // if (widget.data.isSuccess) {
    //   facebookAppEvents.logEvent(
    //       name: Constants.GSC_FB_COMPLETE_TRANSACTION_EVENT,
    //       parameters: {
    //         Constants.GSC_FB_COMPLETE_TRANSACTION_SUCCESS: true,
    //         Constants.GSC_FB_COMPLETE_TRANSACTION_PLATFORM:
    //             Constants.GSC_FB_COMPLETE_TRANSACTION_APP
    //       });
    // } else {
    //   facebookAppEvents.logEvent(
    //       name: Constants.GSC_FB_COMPLETE_TRANSACTION_EVENT,
    //       parameters: {
    //         Constants.GSC_FB_COMPLETE_TRANSACTION_SUCCESS: false,
    //         Constants.GSC_FB_COMPLETE_TRANSACTION_PLATFORM:
    //             Constants.GSC_FB_COMPLETE_TRANSACTION_APP
    //       });
    // }
  }

  @override
  Widget build(BuildContext context) {
    Color foreground = AppColor.iconGrey().withOpacity(0.2);
    Color backgroundColor = Colors.black45;
    Color newColor = Color.alphaBlend(foreground, backgroundColor);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            imageUrl != null
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) {
                        return Image.asset(
                            'assets/images/Default placeholder_app_img.png',
                            fit: BoxFit.fitWidth);
                      },
                    ),
                  )
                : Container(),
            Container(
              color: newColor,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Stack(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.only(
                              left: PADDING,
                              top: CIRCULAR_RADIUS + PADDING,
                              right: PADDING,
                            ),
                            margin: const EdgeInsets.only(
                                top: CIRCULAR_RADIUS, left: 16, right: 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(PADDING),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                    widget.data.isSuccess
                                        ? "Payment successful"
                                        : "Payment Failed",
                                    textAlign: TextAlign.center,
                                    style: AppFont.montBold(16,
                                        color: Colors.black)),
                                const SizedBox(
                                  height: 8,
                                ),
                                widget.data.isSuccess
                                    ? Text(
                                        """
Thank you for your payment. 
Your purchase is confirmed. 

GSCoins will be credited withn 24 hours after date of movie on F&B transaction. You will receive a confirmation email shortly.
                               """,
                                        style: AppFont.poppinsRegular(14),
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        """
Oops! It seems like your transaction didn't go through. 

No worries! Please check your "My Tickets" page to verify the status.
                             """,
                                        style: AppFont.poppinsRegular(14),
                                        textAlign: TextAlign.center,
                                      ),
                                const SizedBox(
                                  height: 22,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              left: PADDING,
                              right: PADDING,
                              child: Image.asset(
                                widget.data.isSuccess
                                    ? Constants.ASSET_IMAGES +
                                        "ticket-success-icon.png"
                                    : Constants.ASSET_IMAGES +
                                        "failed-icon.png",
                                width: 100,
                                height: 100,
                              )),
                        ],
                      )),
                    )),
                    InkWell(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MyTicketScreen(
                          afterPurchase: widget.data.isSuccess,
                        );
                      })).then((_) {
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) {
                          return const HomeBase(
                            tab: 3,
                            hasLogin: true,
                          );
                        }), (route) => false);
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppColor.appYellow(),
                        ),
                        margin: EdgeInsets.fromLTRB(16, 16, 16,
                            MediaQuery.of(context).viewPadding.bottom + 10),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: Center(
                          child: Text(
                            Utils.getTranslated(
                                context, "to_ticket_listing_btn"),
                            style: AppFont.montSemibold(14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
