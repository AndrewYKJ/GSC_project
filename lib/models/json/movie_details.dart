// ignore_for_file: non_constant_identifier_names

class MovieDetails {
  String? Language;
  String? ParentCode;
  String? Title;
  String? Synopsis;
  String? Main_Stars;
  String? Trailer_Url;
  String? Rating;
  String? Genre;
  String? Duration;
  String? Subtitle;
  String? Release_Date;
  String? Director;
  String? Poster;
  String? Experience;
  String? Link_Url;

  MovieDetails(
      {this.Language,
      this.ParentCode,
      this.Title,
      this.Synopsis,
      this.Main_Stars,
      this.Trailer_Url,
      this.Rating,
      this.Genre,
      this.Duration,
      this.Subtitle,
      this.Release_Date,
      this.Director,
      this.Poster,
      this.Experience,
      this.Link_Url});

  MovieDetails.fromJson(Map<String, dynamic> json) {
    Language = json['Language'];
    ParentCode = json['ParentCode'];
    Title = json['Title'];
    Synopsis = json['Synopsis'];
    Main_Stars = json['Main_Stars'];
    Trailer_Url = json['Trailer_Url'];
    Rating = json['Rating'];
    Genre = json['Genre'];
    Duration = json['Duration'];
    Subtitle = json['Subtitle'];
    Release_Date = json['Release_Date'];
    Director = json['Director'];
    Poster = json['Poster'];
    Experience = json['Experience'];
    Link_Url = json['Link_Url'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['Language'] = Language;
    data['ParentCode'] = ParentCode;
    data['Title'] = Title;
    data['Synopsis'] = Synopsis;
    data['Main_Stars'] = Main_Stars;
    data['Trailer_Url'] = Trailer_Url;
    data['Rating'] = Rating;
    data['Genre'] = Genre;
    data['Duration'] = Duration;
    data['Subtitle'] = Subtitle;
    data['Release_Date'] = Release_Date;
    data['Director'] = Director;
    data['Poster'] = Poster;
    data['Experience'] = Experience;
    data['Link_Url'] = Link_Url;

    return data;
  }
}
