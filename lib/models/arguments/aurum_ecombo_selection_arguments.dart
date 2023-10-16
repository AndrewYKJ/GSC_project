import '../json/ticket_item_model.dart';

class AurumEComboArgs {
  String? locationId;
  String? hallId;
  String? filmId;
  String? showId;
  String? showDate;
  String? showTime;
  String? opsDate;
  String? movieTitle;
  String? cinemaName;
  List<String>? seats;
  List<ComboItemModel>? comboList;
  int? ticketQty;
  Map<String, Map<String, dynamic>>? seatTypeMap;
  List<TicketModel>? selectedTicket;
  bool? isAurum;
  String fromWher;
  AurumEComboArgs(
      {this.locationId,
      this.hallId,
      this.filmId,
      this.showId,
      this.showDate,
      this.showTime,
      this.opsDate,
      this.movieTitle,
      this.cinemaName,
      this.seats,
      this.ticketQty,
      this.seatTypeMap,
      this.selectedTicket,
      this.isAurum,
      required this.fromWher,
      this.comboList});
}
