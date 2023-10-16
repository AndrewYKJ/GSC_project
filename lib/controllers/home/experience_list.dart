import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/const/utils.dart';
import 'package:gsc_app/models/json/cms_experience_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../const/analytics_constant.dart';

class ExperienceList extends StatefulWidget {
  final List<CMS_EXPERIENCE> data;
  const ExperienceList({Key? key, required this.data}) : super(key: key);

  @override
  State<ExperienceList> createState() => _ExperienceListState();
}

class _ExperienceListState extends State<ExperienceList> {
  @override
  void initState() {
    Utils.setFirebaseAnalyticsCurrentScreen(
        AnalyticsConstants.ANALYTICS_EXPERIENCE_LIST_SCREEN);
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
                      experienceListAppBar(context),
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
                                .map((e) => experienceItem(context, e))
                                .toList(),
                          ),
                        ]),
                      ))),
            ),
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

  Widget experienceItem(BuildContext ctx, CMS_EXPERIENCE e) {
    return SizedBox(
      width: (MediaQuery.of(ctx).size.width / 2) - 25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (() {
              if (e.path!.first.alias != null) {
                _launchUrl(Constants.ESERVICES_GSC_EXPERIENCE +
                    e.path!.first.alias!.substring(1) +
                    Constants.ESERVICES_GSC_NO_CTA);
              }
            }),
            child: Stack(
              children: [
                Container(
                  height: (MediaQuery.of(ctx).size.width) / 2 - 25,
                  decoration: BoxDecoration(
                    color: AppColor.lightGrey(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: e.fieldCoverImage?.first.url ??
                            '', // e.coverImage?.url ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Image.asset(
                              'assets/images/Default placeholder_app_img.png',
                              fit: BoxFit.contain);
                        },
                      )),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: ((MediaQuery.of(ctx).size.width) / 2 - 25) / 5,
                    width: ((MediaQuery.of(ctx).size.width) / 2 - 25) / 3,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black,
                    ),
                    margin: const EdgeInsets.all(3),
                    child: CachedNetworkImage(
                      imageUrl:
                          e.fieldLogo?.first.url ?? '', //e.logo?.url ?? '',
                      fit: BoxFit.contain,
                      errorWidget: (context, error, stackTrace) {
                        return Image.asset(
                            'assets/images/Default placeholder_app_img.png',
                            fit: BoxFit.contain);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            e.metatag?.value?.title ?? '', //e.title!,
            style: AppFont.montMedium(12, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            e.metatag?.value?.description ?? '', //  e.subtitle!,
            style: AppFont.poppinsRegular(12, color: AppColor.greyWording()),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  SliverAppBar experienceListAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColor.appSecondaryBlack(),
      elevation: 0,
      automaticallyImplyLeading: true,
      centerTitle: true,
      title: Text(
        Utils.getTranslated(context, "home_cinema_experiences_title_text"),
        style: AppFont.montRegular(18, color: Colors.white),
      ),
    );
  }

  Future<void> _launchUrl(link) async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
