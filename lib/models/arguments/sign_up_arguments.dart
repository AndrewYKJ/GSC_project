
//SAMPLE, CAN BE REMOVE/CHANGE
class SignUpArguments {
  String name;
  String dob;
  String email;
  String mobile;
  String password;
  int isVerifyPromo;
  String gender;
  String location;
  String profession;
  String race;
  String countryCode;
  String? nationality;
  String? referral;

  SignUpArguments({
    required this.name,
    required this.dob,
    required this.email,
    required this.mobile,
    required this.password,
    required this.isVerifyPromo,
    required this.gender,
    required this.location,
    required this.profession,
    required this.race,
    required this.countryCode,
    this.nationality,
    this.referral
  });
}

