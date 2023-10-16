import 'dart:convert';

class BookingResponseDTO {
  BookingsDataDTO? bookings;

  BookingResponseDTO({
    this.bookings,
  });

  factory BookingResponseDTO.fromRawJson(String str) =>
      BookingResponseDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BookingResponseDTO.fromJson(Map<String, dynamic> json) =>
      BookingResponseDTO(
        bookings: json["bookings"] == null
            ? null
            : BookingsDataDTO.fromJson(json["bookings"]),
      );

  Map<String, dynamic> toJson() => {
        "bookings": bookings?.toJson(),
      };
}

class BookingsDataDTO {
  BookingStatus? bookingStatus;
  PaymentStatus? paymentStatus;
  BookingsDataDTO({this.bookingStatus, this.paymentStatus});

  factory BookingsDataDTO.fromRawJson(String str) =>
      BookingsDataDTO.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BookingsDataDTO.fromJson(Map<String, dynamic> json) =>
      BookingsDataDTO(
        bookingStatus: json["booking_status"] == null
            ? null
            : BookingStatus.fromJson(json["booking_status"]),
        paymentStatus: json["payment_status"] == null
            ? null
            : PaymentStatus.fromJson(json["payment_status"]),
      );

  Map<String, dynamic> toJson() => {
        "booking_status": bookingStatus?.toJson(),
      };
}

class PaymentStatus {
  String? status;

  PaymentStatus({
    this.status,
  });

  factory PaymentStatus.fromRawJson(String str) =>
      PaymentStatus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}

class BookingStatus {
  String? status;
  String? confirmationid;
  String? oprndate;
  DateTime? showdate;
  String? showtime;
  String? promoCode;
  String? discAmt;
  String? nettAmt;
  String? encodedValue;

  BookingStatus({
    this.status,
    this.confirmationid,
    this.oprndate,
    this.showdate,
    this.showtime,
    this.promoCode,
    this.discAmt,
    this.nettAmt,
    this.encodedValue,
  });

  factory BookingStatus.fromRawJson(String str) =>
      BookingStatus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BookingStatus.fromJson(Map<String, dynamic> json) => BookingStatus(
        status: json["status"],
        confirmationid: json["confirmationid"],
        oprndate: json["oprndate"],
        showdate:
            json["showdate"] == null ? null : DateTime.parse(json["showdate"]),
        showtime: json["showtime"],
        promoCode: json["promo_code"],
        discAmt: json["disc_amt"],
        nettAmt: json["nett_amt"],
        encodedValue: json["encoded_value"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "confirmationid": confirmationid,
        "oprndate": oprndate,
        "showdate":
            "${showdate!.year.toString().padLeft(4, '0')}-${showdate!.month.toString().padLeft(2, '0')}-${showdate!.day.toString().padLeft(2, '0')}",
        "showtime": showtime,
        "promo_code": promoCode,
        "disc_amt": discAmt,
        "nett_amt": nettAmt,
        "encoded_value": encodedValue,
      };
}
