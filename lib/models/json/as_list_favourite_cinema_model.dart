// ignore_for_file: camel_case_types

class AS_FAVOURITE_CINEMA {
  final int id;
  final String hallGroup;

  AS_FAVOURITE_CINEMA(this.id, this.hallGroup);

  @override
  String toString() {
    return "$id|$hallGroup";
  }
}
