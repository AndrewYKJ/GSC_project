// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/movie_listing_details.dart';
import 'package:gsc_app/models/json/movie_listing_status.dart';

class MovieListingBody {
  MovieListingStatus? Status;
  List<MovieListingDetails>? NowShowing;
  List<MovieListingDetails>? AdvanceSales;
  List<MovieListingDetails>? ComingSoon;
  //List<MovieListingDetails>? TopTen;
  List<MovieListingDetails>? InternationalScreen;

  MovieListingBody(
      {this.Status,
      this.NowShowing,
      this.AdvanceSales,
      this.ComingSoon,
      //   this.TopTen,
      this.InternationalScreen});

  MovieListingBody.fromJson(Map<String, dynamic> json) {
    Status = MovieListingStatus.fromJson(json['Status']);

    if (json['NowShowing'] != null) {
      var nowShowingList = json['NowShowing'] as List;
      if (nowShowingList.isNotEmpty) {
        NowShowing =
            nowShowingList.map((e) => MovieListingDetails.fromJson(e)).toList();
      }
    }

    if (json['AdvanceSales'] != null) {
      var advanceSalesList = json['AdvanceSales'] as List;
      if (advanceSalesList.isNotEmpty) {
        AdvanceSales = advanceSalesList
            .map((e) => MovieListingDetails.fromJson(e))
            .toList();
      }
    }
    if (json['ComingSoon'] != null) {
      var comingSoonList = json['AdvanceSales'] as List;
      if (comingSoonList.isNotEmpty) {
        ComingSoon =
            comingSoonList.map((e) => MovieListingDetails.fromJson(e)).toList();
      }
    }
    // if (json['TopTen'] != null) {
    //   var topTenList = json['TopTen'] as List;
    //   if (topTenList.isNotEmpty) {
    //     topTenList =
    //         topTenList.map((e) => MovieListingDetails.fromJson(e)).toList();
    //   }
    // }
    if (json['InternationalScreen'] != null) {
      var internationalList = json['InternationalScreen'] as List;
      if (internationalList.isNotEmpty) {
        InternationalScreen = internationalList
            .map((e) => MovieListingDetails.fromJson(e))
            .toList();
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Status'] = Status;
    data['NowShowing'] = NowShowing?.map((e) => e.toJson()).toList();
    data['AdvanceSales'] = AdvanceSales?.map((e) => e.toJson()).toList();
    data['ComingSoon'] = ComingSoon?.map((e) => e.toJson()).toList();
    //data['TopTen'] = TopTen?.map((e) => e.toJson()).toList();
    data['InternationalScreen'] =
        InternationalScreen?.map((e) => e.toJson()).toList();

    return data;
  }
}


  // if (json['NowShowing'] != null) {
  //     var nowShowingList = json['NowShowing'] as List;

  //     if (nowShowingList.isNotEmpty) {
  //       nowShowingList =
  //           nowShowingList.map((e) => MovieListingDetails.fromJson(e)).toList();
  //     }
  //   }
  //   if (json['AdvanceSales'] != null) {
  //     var advanceSalesList = json['AdvanceSales'] as List;
  //     if (advanceSalesList.isNotEmpty) {
  //       AdvanceSales = advanceSalesList
  //           .map((e) => MovieListingDetails.fromJson(e))
  //           .toList();
  //     }
  //   }
  //   if (json['ComingSoon'] != null) {
  //     var comingSoonList = json['AdvanceSales'] as List;
  //     if (comingSoonList.isNotEmpty) {
  //       ComingSoon =
  //           comingSoonList.map((e) => MovieListingDetails.fromJson(e)).toList();
  //     }
  //   }
  //   if (json['TopTen'] != null) {
  //     var topTenList = json['TopTen'] as List;
  //     if (topTenList.isNotEmpty) {
  //       topTenList =
  //           topTenList.map((e) => MovieListingDetails.fromJson(e)).toList();
  //     }
  //   }
  //   if (json['InternationalScreen'] != null) {
  //     var internationalList = json['InternationalScreen'] as List;
  //     if (internationalList.isNotEmpty) {
  //       InternationalScreen = internationalList
  //           .map((e) => MovieListingDetails.fromJson(e))
  //           .toList();
  //     }
  //   }