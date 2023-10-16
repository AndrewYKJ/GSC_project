import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import '../../const/analytics_constant.dart';
import '../../models/json/cms_promotion_model.dart';
import '../../widgets/custom_web_view.dart';

class PromotionList extends StatefulWidget {
  final List<CMS_PROMOTION> data;
  const PromotionList({Key? key, required this.data}) : super(key: key);

  @override
  State<PromotionList> createState() => _PromotionListState();
}

class _PromotionListState extends State<PromotionList> {
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_PROMOTION_LIST_SCREEN);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.appSecondaryBlack(),
        body: Stack(
          children: [
            SafeArea(
                child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        promotionsListAppBar(context),
                      ];
                    },
                    body: Container(
                      color: Colors.black,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 24, bottom: 24),
                        physics: const ClampingScrollPhysics(),
                        child: Column(children: [
                          Wrap(
                            spacing: 25,
                            runSpacing: 18,
                            children: widget.data
                                .map((e) => promotionItem(context, e))
                                .toList(),
                          ),
                        ]),
                      ),
                    ))),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black,
                height: MediaQuery.of(context).padding.bottom,
              ),
            )
          ],
        ));
  }
}

Widget promotionItem(BuildContext ctx, CMS_PROMOTION e) {
  return SizedBox(
    width: (MediaQuery.of(ctx).size.width / 2) - 25,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: (() {
            if (e.path!.first.alias != null) {
              Navigator.push(
                  ctx,
                  MaterialPageRoute(
                      builder: (context) => WebView(
                          useHtmlString: false,
                          url: Constants.ESERVICES_GSC_PROMOTION +
                              e.path!.first.alias!.substring(1) +
                              Constants.ESERVICES_GSC_NO_CTA)));
            }
          }),
          child: Container(
            height: (MediaQuery.of(ctx).size.width) / 2 - 25,
            decoration: BoxDecoration(
              color: AppColor.lightGrey(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: e.fieldCoverImage?.first.url ??
                      '', //e.coverImage?.url ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) {
                    return Image.asset(
                        'assets/images/Default placeholder_app_img.png',
                        fit: BoxFit.fitWidth);
                  },
                )),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          e.metatag?.value?.title ?? '',
          style: AppFont.montMedium(12, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          e.metatag?.value?.description ?? '',
          style: AppFont.poppinsRegular(12, color: AppColor.greyWording()),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

SliverAppBar promotionsListAppBar(BuildContext context) {
  return SliverAppBar(
    backgroundColor: AppColor.appSecondaryBlack(),
    elevation: 0,
    automaticallyImplyLeading: true,
    centerTitle: true,
    title: Text(
      Utils.getTranslated(context, "home_promotions_title_text"),
      style: AppFont.montRegular(18, color: Colors.white),
    ),
  );
}
