// To parse this JSON data, do
//
//     final crowdSource = crowdSourceFromJson(jsonString);

import 'dart:convert';

List<Helpdesk> helpdeskFromJson(String str) =>
    List<Helpdesk>.from(json.decode(str).map((x) => Helpdesk.fromJson(x)));

String helpdeskToJson(List<Helpdesk> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Helpdesk {
  bool action; // New field indicating if the helpdesk is settled
  DateTime dateTime;
  String description;
  String fileUrl;
  String id;
  String userId;
  String imageUrl;
  UserDetails? userDetails;

  Helpdesk({
    required this.action,
    required this.dateTime,
    required this.description,
    required this.fileUrl,
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.userDetails,
  });

  factory Helpdesk.fromJson(Map<String, dynamic> json) => Helpdesk(
        action: json["action"], // Assuming 'action' is a boolean
        dateTime: DateTime.parse(json["dateTime"] ?? ''),
        description: json["description"] ?? '',
        fileUrl: json["fileUrl"] ?? '',
        userId: json["userId"],
        id: json["id"] ?? '',
        imageUrl: json["imageUrl"] ?? '',
        userDetails: json["userDetails"] != null
            ? UserDetails.fromJson(json["userDetails"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "action": action, // Assuming 'action' is a boolean
        "dateTime": dateTime.toIso8601String(),
        "description": description,
        "userId": userId,
        "fileUrl": fileUrl,
        "id": id,
        "imageUrl": imageUrl,
        "userDetails": userDetails?.toJson(),
      };
}

class UserDetails {
  String civilstatus;
  String residency;
  String fname;
  String role;
  DateTime birthdate;
  String address;
  String work;
  String sex;
  String profile;
  String purok;
  String mname;
  bool isActive;
  String number;
  String lname;
  String school;
  String youthclass;
  String voter;
  String id;
  int age;
  String email;

  UserDetails({
    required this.civilstatus,
    required this.residency,
    required this.fname,
    required this.role,
    required this.birthdate,
    required this.address,
    required this.work,
    required this.sex,
    required this.profile,
    required this.purok,
    required this.mname,
    required this.isActive,
    required this.number,
    required this.lname,
    required this.school,
    required this.youthclass,
    required this.voter,
    required this.id,
    required this.age,
    required this.email,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        civilstatus: json["civilstatus"],
        residency: json["residency"],
        fname: json["fname"],
        role: json["role"],
        birthdate: DateTime.parse(json["birthdate"]),
        address: json["address"],
        work: json["work"],
        sex: json["sex"],
        profile: json["profile"],
        purok: json["purok"],
        mname: json["mname"],
        isActive: json["isActive"],
        number: json["number"],
        lname: json["lname"],
        school: json["school"],
        youthclass: json["youthclass"],
        voter: json["voter"],
        id: json["id"],
        age: json["age"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "civilstatus": civilstatus,
        "residency": residency,
        "fname": fname,
        "role": role,
        "birthdate": birthdate.toIso8601String(),
        "address": address,
        "work": work,
        "sex": sex,
        "profile": profile,
        "purok": purok,
        "mname": mname,
        "isActive": isActive,
        "number": number,
        "lname": lname,
        "school": school,
        "youthclass": youthclass,
        "voter": voter,
        "id": id,
        "age": age,
        "email": email,
      };
}
