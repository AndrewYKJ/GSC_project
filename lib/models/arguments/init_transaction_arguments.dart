// ignore_for_file: non_constant_identifier_names

import 'package:gsc_app/models/json/aurum_ecombo_selection_option_model.dart';
import 'package:gsc_app/models/json/init_sales_trans_reponse.dart';
import 'package:gsc_app/models/json/ticket_item_model.dart';

class InitSalesTransactionArg {
  String locationId;
  String hallId;
  String showId;
  String filmId;
  String showDate;
  String showTime;
  String movieTitle;
  String cinemaName;
  String opsDate;
  List<String> seats;
  int ticketQty;
  Map<String, Map<String, dynamic>>? seatTypeMap;
  List<ComboModel>? selectedCombo;
  List<ComboModel>? aurumCombo;
  List<TicketModel>? selectedTicket;
  List<AurumEComboSelectedOption>? SelectedOptions;
  InitSalesDTO? initSalesDTO;
  bool? isAurum;
  bool? showEcombo;
  InitSalesTransactionArg(
      {required this.locationId,
      required this.hallId,
      required this.showId,
      required this.cinemaName,
      required this.opsDate,
      required this.filmId,
      required this.showDate,
      required this.showTime,
      required this.movieTitle,
      required this.selectedCombo,
      required this.selectedTicket,
      required this.seats,
      this.initSalesDTO,
      this.showEcombo,
      this.aurumCombo,
      required this.ticketQty,
      required this.seatTypeMap,
      this.SelectedOptions,
      this.isAurum});
}
