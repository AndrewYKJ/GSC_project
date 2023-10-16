// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';

import '../const/app_color.dart';
import '../const/app_font.dart';

class CustomRatingPopup extends StatefulWidget {
  final String title, message, rating;
  final bool? isAurum;
  final void Function()? onConfirm;
  final void Function()? onCancel;

  const CustomRatingPopup(
      {Key? key,
      required this.title,
      required this.message,
      required this.rating,
      this.isAurum,
      this.onConfirm,
      this.onCancel})
      : super(key: key);

  @override
  _CustomRatingPopupState createState() => _CustomRatingPopupState();
}

const PADDING = 20.0;
const CIRCULAR_RADIUS = 50.0;

class _CustomRatingPopupState extends State<CustomRatingPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PADDING),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _contentBox(context),
    );
  }

  Widget _contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          width: 300,
          padding: const EdgeInsets.only(
              left: PADDING, top: PADDING, right: PADDING, bottom: PADDING),
          margin: const EdgeInsets.only(top: CIRCULAR_RADIUS),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(PADDING),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 40,
                width: 40,
                child: widget.rating == '18'
                    ? Image.asset(
                        Constants.ASSET_IMAGES + 'Klasifikasi 18_img.png',
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        Constants.ASSET_IMAGES + 'Klasifikasi 16_img.png',
                        fit: BoxFit.cover),
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.title.isNotEmpty)
                Text(widget.title,
                    textAlign: TextAlign.center,
                    style: AppFont.montBold(16, color: Colors.black)),
              if (widget.title.isNotEmpty)
                const SizedBox(
                  height: 8,
                ),
              Text(
                widget.message,
                style: AppFont.poppinsRegular(14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 100,
                      height: 50,
                      child: TextButton(
                          onPressed: widget.onCancel,
                          child: Text(
                            Utils.getTranslated(context, "cancel_btn"),
                            style:
                                AppFont.montSemibold(14, color: Colors.black),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColor.buttonGrey(),
                          ))),
                  SizedBox(
                      width: 100,
                      height: 50,
                      child: TextButton(
                          onPressed: widget.onConfirm,
                          child: Text(
                            Utils.getTranslated(context, "proceed_btn"),
                            style:
                                AppFont.montSemibold(14, color: Colors.black),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: widget.isAurum != null
                                ? widget.isAurum!
                                    ? AppColor.aurumGold()
                                    : AppColor.appYellow()
                                : AppColor.appYellow(),
                          ))),
                ],
              )
            ],
          ),
        ),
        // Positioned(
        //     left: PADDING,
        //     right: PADDING,
        //     child: widget.img != null
        //         ? Image.asset(
        //             Constants.ASSET_IMAGES + widget.img!,
        //             width: 100,
        //             height: 100,
        //           )
        //         : Image.asset(
        //             Constants.ASSET_IMAGES + "success-icon.png",
        //             width: 100,
        //             height: 100,
        //           )),
      ],
    );
  }
}
