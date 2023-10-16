// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import 'app_color.dart';
import 'constants.dart';

class SeatConstants {
  static const String NORMAL = "NORMAL";
  static const String TWIN = "TWIN";
  static const String WHEELCHAIR = "WHEEL CHAIR";
  static const String HOUSESEAT = "HOUSE SEAT";
  static const String RESERVATION = "RESERVATION";
  static const String VIP = "VIP SEAT";
  static const String SELECTED = "SELECTED";
  static const String OCCUPIED = "OCCUPIED";
  static const String REPAIR = "REPAIR";
  static const String LOCKSEATS = "LOCKED SEAT";
  static const String FOURSEATER = "4-SEATER";
  static const String CABIN = "CABIN";
  static const String SUITE = "SUITE";
  static const String CHAISE = "CHAISE";
  static const String TWINSOFA = "TWINSOFA";
  static const String RECLINER = "RECLINER";
  static const String LOUNGER = "LOUNGER";
  static const String CUDDLECOUCH = "CUDDLECOUCH";
  static const String TWINRECLINER = "TWINRECLINER";
  static const String BEANBAG = "BEANBAG";
  static const String BLOCKSEAT = "BLOCKED SEAT";
  static const List showBooked = [HOUSESEAT, RESERVATION, OCCUPIED, LOCKSEATS];
  static const Map<String, String> seatMap = {
    '1': NORMAL,
    '3001': NORMAL,
    '2': TWIN,
    '3002': TWIN,
    '3': WHEELCHAIR,
    '3003': WHEELCHAIR,
    '4': HOUSESEAT,
    '3004': HOUSESEAT,
    '5': RESERVATION,
    '3005': RESERVATION,
    '6': VIP,
    '3006': VIP,
    '7': SELECTED,
    '3007': SELECTED,
    '8': OCCUPIED,
    '9': LOCKSEATS,
    '3008': OCCUPIED,
    '1007': REPAIR,
    '3009': REPAIR,
    '1008': LOCKSEATS,
    '3010': LOCKSEATS,
    '1011': FOURSEATER,
    '3011': FOURSEATER,
    '1012': CABIN,
    '3012': CABIN,
    '1013': SUITE,
    '3013': SUITE,
    '1014': CHAISE,
    '3014': CHAISE,
    '1015': TWINSOFA,
    '3015': TWINSOFA,
    '1016': RECLINER,
    '3016': RECLINER,
    '1017': LOUNGER,
    '3017': LOUNGER,
    '1018': CUDDLECOUCH,
    '3018': CUDDLECOUCH,
    '1019': BEANBAG,
    '3019': TWINRECLINER,
    '3020': BEANBAG,
    '3021': BLOCKSEAT,
  };

  static const Map<String, String> seatCode = {
    "N": NORMAL,
    "T": TWIN,
    "W": WHEELCHAIR,
    "H": HOUSESEAT,
    "HS": HOUSESEAT,
    "R": RESERVATION,
    "V": VIP,
    "S": SELECTED,
    "O": OCCUPIED,
    'D': REPAIR,
    'L': LOCKSEATS,
    '4S': FOURSEATER,
    'CA': CABIN,
    'SU': SUITE,
    'CH': CHAISE,
    'TS': TWINSOFA,
    'RC': RECLINER,
    'LG': LOUNGER,
    'C': CUDDLECOUCH,
    'TR': TWINRECLINER,
    'B': BEANBAG,
    'X': BLOCKSEAT
  };
  static const Map<String, String> seatName = {
    "NORMAL": NORMAL,
    "TWIN": TWIN,
    "WHEEL CHAIR": WHEELCHAIR,
    "HOUSE SEAT": HOUSESEAT,
    "RESERVATION": RESERVATION,
    "VIP SEAT": VIP,
    "SELECTED": SELECTED,
    "OCCUPIED": OCCUPIED,
    "REPAIR": REPAIR,
    "LOCKED SEAT": LOCKSEATS,
    "4-SEATER": FOURSEATER,
    "CABIN": CABIN,
    "SUITE": SUITE,
    "CHAISE": CHAISE,
    "TWINSOFA": TWINSOFA,
    "RECLINER": RECLINER,
    "LOUNGER": LOUNGER,
    "CUDDLECOUCH": CUDDLECOUCH,
    "TWINRECLINER": TWINRECLINER,
    "BEANBAG": BEANBAG,
    "BLOCKED SEAT": BLOCKSEAT
  };

  static const Map<String, String> seatStatus = {
    'A': NORMAL,
    'B': OCCUPIED,
    'T': LOCKSEATS,
    'X': BLOCKSEAT,
    'D': REPAIR,
    'OC': OCCUPIED,
    'O': OCCUPIED,
    'LC': LOCKSEATS,
    'REP': REPAIR,
  };

  static String seatImage(String id, bool isAurum) {
    switch (id) {
      case NORMAL:
        return Constants.ASSET_IMAGES + "available-icon.png";
      case TWIN:
        return Constants.ASSET_IMAGES + "twin-seat-icon.png";
      case WHEELCHAIR:
        return Constants.ASSET_IMAGES + "oku-seat-icon.png";
      case OCCUPIED:
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case HOUSESEAT:
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case RESERVATION:
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case VIP:
        return Constants.ASSET_IMAGES + 'VIP seat_icon.png';
      case SELECTED:
        return isAurum
            ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
            : Constants.ASSET_IMAGES + "selected-icon.png";
      case LOCKSEATS:
        return Constants.ASSET_IMAGES + "locked-seat-icon.png";
      case REPAIR:
        return Constants.ASSET_IMAGES + "aurum_seat_underepair_icon.png";
      case BLOCKSEAT:
        return Constants.ASSET_IMAGES + "blocked-seat-icon.png";
      case CABIN:
        return Constants.ASSET_IMAGES + "aurum_cabin_seat_icon.png";
      case SUITE:
        return Constants.ASSET_IMAGES + "aurum_getha_seat_icon.png";
      case CHAISE:
        return Constants.ASSET_IMAGES + "aurum_ps_seat_icon.png";
      case RECLINER:
        return Constants.ASSET_IMAGES + "aurum-seat-icon.png";
      case CUDDLECOUCH:
        return Constants.ASSET_IMAGES + "cuddlecouch_icon.png";

      case BEANBAG:
        return Constants.ASSET_IMAGES + "beanbag_icon.png";
      case LOUNGER:
        return Constants.ASSET_IMAGES + "lounger_icon.png";
      case TWINSOFA:
        return Constants.ASSET_IMAGES + "aurum-recliner-seat.png";

      case FOURSEATER:
        return Constants.ASSET_IMAGES + "aurum-4seats.png";

      default:
        return '';
    }
  }

  static String seatSeletecImage(String id, bool isAurum) {
    switch (id) {
      case NORMAL:
        return Constants.ASSET_IMAGES + "available-icon.png";
      case TWIN:
        return Constants.ASSET_IMAGES + "twin-seat-icon.png";
      case WHEELCHAIR:
        return Constants.ASSET_IMAGES + "oku-seat-icon.png";
      case OCCUPIED:
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case HOUSESEAT:
        return Constants.ASSET_IMAGES + "booked-icon.png";
      case SELECTED:
        return isAurum
            ? Constants.ASSET_IMAGES + "aurum-selected-icon.png"
            : Constants.ASSET_IMAGES + "selected-icon.png";
      case LOCKSEATS:
        return Constants.ASSET_IMAGES + "locked-seat-icon.png";
      case REPAIR:
        return Constants.ASSET_IMAGES + "aurum_seat_underepair_icon.png";

      case CABIN:
        return Constants.ASSET_IMAGES + "aurum_cabin_seat_icon.png";
      case SUITE:
        return Constants.ASSET_IMAGES + "aurum_getha_seat_icon.png";
      case CHAISE:
        return Constants.ASSET_IMAGES + "aurum_ps_seat_icon.png";
      case RECLINER:
        return Constants.ASSET_IMAGES + "aurum-selected-icon.png";
      case CUDDLECOUCH:
        return Constants.ASSET_IMAGES + "cuddlecouch_icon.png";

      case BEANBAG:
        return Constants.ASSET_IMAGES + "beanbag_icon.png";
      case LOUNGER:
        return Constants.ASSET_IMAGES + "louger_icon.png";
      case TWINSOFA:
        return Constants.ASSET_IMAGES + "aurum-recliner-seat.png";

      case FOURSEATER:
        return Constants.ASSET_IMAGES + "aurum-4seats.png";

      default:
        return '';
    }
  }

  static Color seatLableColor(String id, bool isAurum) {
    switch (id) {
      case NORMAL:
        return Colors.white;
      case TWIN:
        return AppColor.twinSeatColor();
      case WHEELCHAIR:
        return AppColor.okuSeatColor();
      case HOUSESEAT:
        return AppColor.greyWording();
      case RESERVATION:
        return AppColor.greyWording();
      case VIP:
        return AppColor.greyWording();
      case SELECTED:
        return isAurum ? AppColor.aurumGold() : AppColor.appYellow();
      case OCCUPIED:
        return AppColor.greyWording();
      case LOCKSEATS:
        return AppColor.greyWording();
      case BLOCKSEAT:
        return AppColor.greyWording();
      case REPAIR:
        return AppColor.greyWording();

      default:
        return Colors.white;
    }
  }
}
