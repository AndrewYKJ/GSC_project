// ignore_for_file: non_constant_identifier_names

import 'movie_listing_header.dart';
import 'movie_listing_status.dart';

class MovieListingDetails {
  String? Language;
  String? ParentCode;
  String? Title;
  String? Genre;
  String? Duration;
  String? Subtitle;
  String? Poster;
  String? Link_Url;
  String? Synopsis;
  String? Main_Stars;
  String? Trailer_Url;
  String? Rating;
  String? Release_Date;
  String? Director;
  String? Experience;

  MovieListingDetails(
      {this.Language,
      this.ParentCode,
      this.Title,
      this.Genre,
      this.Duration,
      this.Subtitle,
      this.Poster,
      this.Link_Url,
      this.Synopsis,
      this.Main_Stars,
      this.Trailer_Url,
      this.Rating,
      this.Release_Date,
      this.Director,
      this.Experience});

  MovieListingDetails.fromJson(Map<String, dynamic> json) {
    Language = json['Language'];
    ParentCode = json['ParentCode'];
    Title = json['Title'];
    Genre = json['Genre'];
    Duration = json['Duration'];
    Subtitle = json['Subtitle'];
    Poster = json['Poster'];
    Link_Url = json['Link_Url'];
    Synopsis = json['Synopsis'];
    Main_Stars = json['Main_Stars'];
    Trailer_Url = json['Trailer_Url'];
    Rating = json['Rating'];
    Release_Date = json['Release_Date'];
    Director = json['Director'];
    Experience = json['Experience'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Language'] = Language;
    data['ParentCode'] = ParentCode;
    data['Title'] = Title;
    data['Genre'] = Genre;
    data['Duration'] = Duration;
    data['Subtitle'] = Subtitle;
    data['Poster'] = Poster;
    data['Link_Url'] = Link_Url;
    data['Synopsis'] = Synopsis;
    data['Main_Stars'] = Main_Stars;
    data['Trailer_Url'] = Trailer_Url;
    data['Rating'] = Rating;
    data['Release_Date'] = Release_Date;
    data['Director'] = Director;
    data['Experience'] = Experience;
    return data;
  }
}

class MovieDetails {
  MovieDetailsResponse? Response;

  MovieDetails({this.Response});

  MovieDetails.fromJson(Map<String, dynamic> json) {
    Response = MovieDetailsResponse.fromJson(json['Response']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Response'] = Response;

    return data;
  }
}

class MovieDetailsResponse {
  MovieListingHeader? Header;
  MovieDetailsBody? Body;

  MovieDetailsResponse({this.Header});

  MovieDetailsResponse.fromJson(Map<String, dynamic> json) {
    Header = MovieListingHeader.fromJson(json['Header']);
    Body = MovieDetailsBody.fromJson(json['Body']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Header'] = Header;
    data['Body'] = Body;

    return data;
  }
}

class MovieDetailsBody {
  MovieListingStatus? Status;
  List<MovieListingDetails>? MovieDetail;

  MovieDetailsBody({
    this.Status,
    this.MovieDetail,
  });

  MovieDetailsBody.fromJson(Map<String, dynamic> json) {
    Status = MovieListingStatus.fromJson(json['Status']);

    var movieDetailList = json['MovieDetail'] as List;
    if (movieDetailList.isNotEmpty) {
      MovieDetail =
          movieDetailList.map((e) => MovieListingDetails.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Status'] = Status;
    data['MovieDetail'] = MovieDetail;

    return data;
  }
}
