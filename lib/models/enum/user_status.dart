// ignore_for_file: constant_identifier_names

//SAMPLE, CAN BE REMOVE/CHANGE
enum UserStatus { Active, Inactive, Pending }

extension CatExtension on UserStatus {
  String get name {
    return ["ACTIVE", "INACTIVE", "PENDING"][index];
  }
}
