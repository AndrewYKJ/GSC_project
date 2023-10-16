// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/aurum_ecombo_selection_option_model.dart';
import 'package:gsc_app/models/json/ticket_item_model.dart';

class ComboSelectionArguments {
  String locationId;
  String hallId;
  String filmId;
  String showId;
  String showDate;
  String showTime;
  String opsDate;
  String movieTitle;
  String cinemaName;
  List<String> seats;
  int ticketQty;
  Map<String, Map<String, dynamic>>? seatTypeMap;
  List<TicketModel>? selectedTicket;
  List<ComboItemModel>? comboList;
  bool? isAurum;
  List<ComboModel>? aurumCombo;
  List<AurumEComboSelectedOption>? SelectedOptions;
  List<ComboModel>? selectedCombo;
  String fromWher;
  ComboSelectionArguments(
      {required this.locationId,
      required this.hallId,
      required this.showId,
      required this.opsDate,
      required this.filmId,
      required this.cinemaName,
      required this.showDate,
      required this.showTime,
      required this.movieTitle,
      required this.comboList,
      required this.selectedTicket,
      required this.seats,
      required this.ticketQty,
      required this.seatTypeMap,
      required this.isAurum,
      required this.fromWher,
      this.SelectedOptions,
      this.selectedCombo,
      this.aurumCombo});
}
