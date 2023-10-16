import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/controllers/tab/homebase.dart';
import 'package:gsc_app/models/json/as_vouchers_model.dart';
import 'package:intl/intl.dart';

class MyRewardDetailScreen extends StatefulWidget {
  final VoucherItemDTO voucherItemDTO;
  final bool isPast;
  const MyRewardDetailScreen(
      {Key? key, required this.voucherItemDTO, required this.isPast})
      : super(key: key);

  @override
  State<MyRewardDetailScreen> createState() => _MyRewardDetailScreenState();
}

class _MyRewardDetailScreenState extends State<MyRewardDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                voucher(context, screenWidth, screenHeight),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: useNowBtn(),
    );
  }

  Widget voucher(
      BuildContext context, double screenWidth, double screenHeight) {
    return Stack(
      children: [
        voucherImage(context, screenWidth),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                AppColor.gradientGrayColor().withOpacity(0),
                AppColor.gradientWhiteColor().withOpacity(0),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.asset(
                  Constants.ASSET_IMAGES + 'white-left-icon.png',
                  fit: BoxFit.cover,
                  height: 28,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: screenWidth - 100),
          child: voucherInfo(context, screenWidth, screenHeight),
        ),
      ],
    );
  }

  Widget voucherImage(BuildContext context, double width) {
    return SizedBox(
      width: width,
      height: width,
      child: Image.network(
        '${widget.voucherItemDTO.voucherImageLink}',
        fit: BoxFit.cover,
        width: width,
        height: width,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/Default placeholder_app_img.png',
              fit: BoxFit.fitWidth);
        },
      ),
    );
  }

  Widget voucherInfo(
      BuildContext context, double screenHWidth, double screenHeight) {
    var dateTimeFrom = Utils.epochToDate(
        int.parse(Utils.getEpochUnix(widget.voucherItemDTO.validFrom!)));
    var dateTimeTo = Utils.epochToDate(
        int.parse(Utils.getEpochUnix(widget.voucherItemDTO.validTo!)));
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              '${widget.voucherItemDTO.voucherTypeName}',
              style: AppFont.montSemibold(16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 33),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenHWidth * 0.3,
                child: Wrap(
                  spacing: 6,
                  direction: Axis.vertical,
                  children: [
                    Text(
                      Utils.getTranslated(context, 'points'),
                      style: AppFont.montRegular(12,
                          color: AppColor.greyWording()),
                    ),
                    RichText(
                      text: TextSpan(
                        text:
                            '${widget.voucherItemDTO.voucherRedemptionValue?.toStringAsFixed(0)}',
                        style: AppFont.montSemibold(14,
                            color: AppColor.appYellow()),
                        children: const [
                          // TextSpan(
                          //   text: Utils.getTranslated(context, 'reward_points'),
                          //   style: AppFont.poppinsRegular(14,
                          //       color: AppColor.borderGrey()),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: screenHWidth * 0.6,
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 1.0, color: AppColor.iconGrey()),
                  ),
                  color: Colors.transparent,
                ),
                child: Wrap(
                  spacing: 6,
                  direction: Axis.vertical,
                  children: [
                    Text(
                      Utils.getTranslated(context, 'validity'),
                      style: AppFont.montRegular(12,
                          color: AppColor.greyWording()),
                    ),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(dateTimeFrom)} - ${DateFormat('dd MMM yyyy').format(dateTimeTo)}',
                      style: AppFont.poppinsRegular(14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: AppColor.iconGrey()),
          const SizedBox(height: 20),
          Text(
            '${widget.voucherItemDTO.voucherTypeDescription}',
            style: AppFont.poppinsRegular(
              12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          if (widget.voucherItemDTO.voucherTnc != null &&
              widget.voucherItemDTO.voucherTnc! != Constants.EMPTY_TNC)
            Text(
              Utils.getTranslated(context, 'Terms_and_Conditions'),
              style: AppFont.montMedium(
                14,
                color: AppColor.greyWording(),
              ),
            ),
          ((widget.voucherItemDTO.voucherTnc != null &&
                      widget.voucherItemDTO.voucherTnc!.isNotEmpty) ||
                  (widget.voucherItemDTO.voucherTnc != null &&
                      widget.voucherItemDTO.voucherTnc != Constants.EMPTY_TNC))
              ? Html(
                  data: widget.voucherItemDTO.voucherTnc,
                  style: {
                    "body": Style(
                        padding: EdgeInsets.zero,
                        margin: Margins.zero,
                        textAlign: TextAlign.start,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins')
                  },
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget useNowBtn() {
    return BottomAppBar(
      color: Colors.black,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 13),
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: widget.isPast
                  ? AppColor.greyWording()
                  : AppColor.appYellow()),
          onPressed: () {
            widget.isPast
                ? null
                : Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                    return const HomeBase(tab: 0);
                  }), (route) => false);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              widget.isPast
                  ? widget.voucherItemDTO.voucherUsedOn != null
                      ? Utils.getTranslated(context, "used")
                      : Utils.getTranslated(context, "expired")
                  : Utils.getTranslated(context, "my_reward_use_now"),
              style: AppFont.montSemibold(14, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
