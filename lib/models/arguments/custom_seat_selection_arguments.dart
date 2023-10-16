import 'package:gsc_app/models/arguments/custom_show_model.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';

class CustomSeatSelectionArg {
  CustomShowModel selectedShowtimesData;
  Child? movieDetails;
  String title;
  String opsdate;
  bool? isAurum;
  String fromWher;
  CustomSeatSelectionArg(
      {required this.selectedShowtimesData,
      this.movieDetails,
      required this.title,
      required this.opsdate,
      required this.fromWher,
      this.isAurum});
}
