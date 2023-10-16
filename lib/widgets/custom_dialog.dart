// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/utils.dart';

import '../const/constants.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, message;
  final String? img;
  final bool? showButton;
  final String? confirmStr;
  final String? cancelStr;
  final bool? showConfirm;
  final bool? isPaymentSuccess;
  final bool? showCancel;
  final double? contentWidth;
  final bool? isAurum;
  final void Function()? onConfirm;
  final void Function()? onCancel;

  const CustomDialogBox(
      {Key? key,
      required this.title,
      required this.message,
      this.img,
      this.showButton,
      this.confirmStr,
      this.cancelStr,
      this.showConfirm,
      this.showCancel,
      this.contentWidth,
      this.isPaymentSuccess,
      this.isAurum,
      this.onConfirm,
      this.onCancel})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

const PADDING = 20.0;
const VERTICAL_PADDING = 10.0;
const CIRCULAR_RADIUS = 50.0;

class _CustomDialogBoxState extends State<CustomDialogBox>
    with WidgetsBindingObserver {
  bool isFold = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          final double _width = MediaQuery.of(context).size.width;
          _width > 400.0 ? isFold = true : false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
          constraints: BoxConstraints(maxWidth: widget.contentWidth ?? 300),
          width: widget.contentWidth ?? 300,
          padding: const EdgeInsets.only(
              left: PADDING,
              top: CIRCULAR_RADIUS + VERTICAL_PADDING,
              right: PADDING,
              bottom: PADDING),
          margin: const EdgeInsets.only(top: CIRCULAR_RADIUS),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(PADDING),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.title.isNotEmpty)
                Text(widget.title,
                    textAlign: TextAlign.center,
                    style: AppFont.montBold(16, color: Colors.black)),
              if (widget.title.isNotEmpty)
                const SizedBox(
                  height: 8,
                ),
              if (widget.message.isNotEmpty)
                Text(
                  widget.message,
                  style: AppFont.poppinsRegular(14),
                  textAlign: TextAlign.center,
                ),
              if (widget.showButton != null && widget.showButton! == true)
                const SizedBox(
                  height: 22,
                ),
              if (widget.showButton != null && widget.showButton! == true)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.showCancel != null && widget.showCancel! == true)
                      SizedBox(
                          width: widget.contentWidth != null
                              ? isFold
                                  ? widget.contentWidth! / 2 - 30 - 8
                                  : 150 - 36 - 8
                              : 150 - 36 - 8,
                          height: 50,
                          child: TextButton(
                              onPressed: widget.onCancel,
                              child: Text(
                                widget.cancelStr ??
                                    Utils.getTranslated(context, "cancel_btn"),
                                style: AppFont.montSemibold(14,
                                    color: Colors.black),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColor.buttonGrey(),
                              ))),
                    if (widget.showConfirm != null &&
                        widget.showConfirm! == true)
                      SizedBox(
                          width: widget.contentWidth != null
                              ? isFold
                                  ? widget.contentWidth! / 2 - 30 - 8
                                  : 150 - 36 - 8
                              : 150 - 36 - 8,
                          height: 50,
                          child: TextButton(
                              onPressed: widget.onConfirm,
                              child: Text(
                                widget.confirmStr ??
                                    Utils.getTranslated(context, "confirm_btn"),
                                style: AppFont.montSemibold(14,
                                    color: Colors.black),
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
        Positioned(
            left: PADDING,
            right: PADDING,
            child: widget.img != null
                ? Image.asset(
                    Constants.ASSET_IMAGES + widget.img!,
                    width: 100,
                    height: 100,
                  )
                : Image.asset(
                    Constants.ASSET_IMAGES + "success-icon.png",
                    width: 100,
                    height: 100,
                  )),
      ],
    );
  }
}
