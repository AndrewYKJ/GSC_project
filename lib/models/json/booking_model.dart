// ignore_for_file: non_constant_identifier_names

class BookingModel {
  String? cinema;
  String? title;
  String? hall;
  String? oprndate;
  String? showdate;
  String? showtime;
  String? tx_amt;
  String? tx_disc;
  String? amount;
  String? totalseats;
  String? resvno;
  String? ccno;
  String? seats;
  String? rating;
  String? oprndate_display;
  String? showdate_display;
  String? email_address;
  String? tktstr;
  String? econstr;
  String? bookingId;
  String? transdate;
  String? transdate_display;
  String? booking_fee;
  String? tx_status;
  String? tx_status_desc;
  String? barcode_string;
  String? poster_filename;
  String? remark;
  String? enc;
  String? locationid;
  String? filmid;
  String? hallgroup;

  BookingModel(
      {this.cinema,
      this.title,
      this.hall,
      this.oprndate,
      this.showdate,
      this.showtime,
      this.tx_amt,
      this.tx_disc,
      this.amount,
      this.totalseats,
      this.resvno,
      this.ccno,
      this.seats,
      this.rating,
      this.oprndate_display,
      this.showdate_display,
      this.email_address,
      this.tktstr,
      this.econstr,
      this.bookingId,
      this.transdate,
      this.transdate_display,
      this.booking_fee,
      this.tx_status,
      this.tx_status_desc,
      this.barcode_string,
      this.poster_filename,
      this.remark,
      this.enc,
      this.locationid,
      this.filmid,
      this.hallgroup});

  BookingModel.fromJson(Map<String, dynamic> json) {
    cinema = json['cinema'];
    title = json['title'];
    hall = json['hall'];
    oprndate = json['oprndate'];
    showdate = json['showdate'];
    showtime = json['showtime'];
    tx_amt = json['tx_amt'];
    tx_disc = json['tx_disc'];
    amount = json['amount'];
    totalseats = json['totalseats'];
    resvno = json['resvno'];
    ccno = json['ccno'];
    seats = json['seats'];
    rating = json['rating'];
    oprndate_display = json['oprndate_display'];
    showdate_display = json['showdate_display'];
    email_address = json['email_address'];
    tktstr = json['tktstr'];
    econstr = json['econstr'];
    bookingId = json['bookingId'];
    transdate = json['transdate'];
    transdate_display = json['transdate_display'];
    booking_fee = json['booking_fee'];
    tx_status = json['tx_status'];
    tx_status_desc = json['tx_status_desc'];
    barcode_string = json['barcode_string'];
    poster_filename = json['poster_filename'];
    remark = json['remark'];
    enc = json['enc'];
    locationid = json['locationid'];
    filmid = json['filmid'];
    hallgroup = json['hallgroup'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "cinema": cinema,
      "title": title,
      "hall": hall,
      "oprndate": oprndate,
      "showdate": showdate,
      "showtime": showtime,
      "tx_amt": tx_amt,
      "tx_disc": tx_disc,
      "amount": amount,
      "totalseats": totalseats,
      "resvno": resvno,
      "ccno": ccno,
      "seats": seats,
      "rating": rating,
      "oprndate_display": oprndate_display,
      "showdate_display": showdate_display,
      "email_address": email_address,
      "tktstr": tktstr,
      "econstr": econstr,
      "bookingId": bookingId,
      "transdate": transdate,
      "transdate_display": transdate_display,
      "booking_fee": booking_fee,
      "tx_status": tx_status,
      "tx_status_desc": tx_status_desc,
      "barcode_string": barcode_string,
      "poster_filename": poster_filename,
      "remark": remark,
      "enc": enc,
      "locationid": locationid,
      "filmid": filmid,
      "hallgroup": hallgroup
    };

    return data;
  }
}

class BookingItemWrapper {
  List<BookingModel>? booking;

  BookingItemWrapper({this.booking});

  BookingItemWrapper.fromJson(Map<String, dynamic> json) {
    if (json['booking'] != null) {
      booking = [];
      if (json['booking'] is List<dynamic>) {
        json['booking'].forEach((v) {
          booking!.add(BookingModel.fromJson(v));
        });
      } else {
        booking!.add(BookingModel.fromJson(json['booking']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "booking": booking,
    };

    return data;
  }
}

class BookingWrapper {
  BookingItemWrapper? success;
  String? RespStatus;
  String? RespDesc;
  String? RespDateTime;
  String? code;
  String? display_msg;

  BookingWrapper(
      {this.success, this.RespStatus, this.RespDesc, this.RespDateTime, this.code, this.display_msg});

  BookingWrapper.fromJson(Map<String, dynamic> json) {
    success = json['success'] != null
        ? BookingItemWrapper.fromJson(json['success'])
        : null;

    RespStatus = json['RespStatus'];
    RespDesc = json['RespDesc'];
    RespDateTime = json['RespDateTime'];
    code = json['code'];
    display_msg = json['display_msg'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "success": success,
      "RespStatus": RespStatus,
      "RespDesc": RespDesc,
      "RespDateTime": RespDateTime,
      "code": code,
      "display_msg": display_msg
    };

    return data;
  }
}
