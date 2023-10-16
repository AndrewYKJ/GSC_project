class BuyTicketTypeArgs {
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
  bool? isAurum;
  String fromWher;

  BuyTicketTypeArgs(
      {required this.locationId,
      required this.hallId,
      required this.filmId,
      required this.showId,
      required this.opsDate,
      required this.showDate,
      required this.cinemaName,
      required this.showTime,
      required this.seats,
      required this.movieTitle,
      required this.ticketQty,
      required this.fromWher,
      this.seatTypeMap,
      this.isAurum});
}
