import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_listing_details.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:gsc_app/models/json/nearby_location_model.dart';

class MovieToBuyArgs {
  Parent? movieData;
  MovieListingDetails? movieDetails;
  String firstDate;
  String selectedCode;
  List<String> availableDate;
  List<Parent>? allMovieData;
  Location? location;
  SwaggerLocation? swaggerLocation;
  MovieToBuyArgs(
      {required this.selectedCode,
      this.movieData,
      this.location,
      this.allMovieData,
      this.movieDetails,
      this.swaggerLocation,
      required this.firstDate,
      required this.availableDate});
}
