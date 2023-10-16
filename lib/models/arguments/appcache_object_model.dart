import 'package:gsc_app/models/arguments/appcache_profile_model.dart';
import 'package:gsc_app/models/json/cms_experience_model.dart';
import 'package:gsc_app/models/json/cms_promotion_model.dart';
import 'package:gsc_app/models/json/splash_popup_model.dart';

import '../json/experience_promotion_model.dart';
import '../json/movie_listing.dart';

class AppCacheObjectModel {
  // MovieEpaymentDTO? epaymovie;
  MovieListing? swaggermovie;
  ExpNPromoResponse? promotion;
  List<CMS_PROMOTION>? promoList;
  List<CMS_EXPERIENCE>? expList;
  List<SplashImage>? splash;
  String? record;
  AppCacheProfileModel? ticket;

  AppCacheObjectModel(
      {this.splash,
      this.record,
      //  this.epaymovie,
      this.promoList,
      this.expList,
      this.swaggermovie,
      this.promotion,
      this.ticket});

  AppCacheObjectModel.fromJson(Map<String, dynamic> json) {
    if (json['splash'] != null) {
      splash = [];
      if (json['splash'] is List<dynamic>) {
        json['splash'].forEach((v) {
          splash!.add(SplashImage.fromJson(v));
        });
      } else {
        splash!.add(SplashImage.fromJson(json['splash']));
      }
    }

    swaggermovie = json['swaggermovie'] != null
        ? MovieListing.fromJson(json['swaggermovie'])
        : null;
    promotion = json['promotion'] != null
        ? ExpNPromoResponse.fromJson(json['promotion'])
        : null;

    if (json['promoList'] != null) {
      promoList = [];
      if (json['promoList'] is List<dynamic>) {
        json['promoList'].forEach((v) {
          promoList!.add(CMS_PROMOTION.fromJson(v));
        });
      } else {
        promoList!.add(CMS_PROMOTION.fromJson(json['promoList']));
      }
    }
    if (json['expList'] != null) {
      expList = [];
      if (json['expList'] is List<dynamic>) {
        json['expList'].forEach((v) {
          expList!.add(CMS_EXPERIENCE.fromJson(v));
        });
      } else {
        expList!.add(CMS_EXPERIENCE.fromJson(json['expList']));
      }
    }

    record = json['record'];
    if (json['ticket'] != null) {
      ticket = AppCacheProfileModel.fromJson(json['ticket']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'splash': splash,
      // 'epaymovie': epaymovie,
      'swaggermovie': swaggermovie,
      'promotion': promotion,
      'expList': expList,
      'promoList': promoList,
      'record': record,
      'ticket': ticket,
    };

    return res;
  }
}
