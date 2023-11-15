// To parse this JSON data, do
//
//     final crowdSource = crowdSourceFromJson(jsonString);

import 'dart:convert';

List<CrowdSource> crowdSourceFromJson(String str) => List<CrowdSource>.from(
    json.decode(str).map((x) => CrowdSource.fromJson(x)));

String crowdSourceToJson(List<CrowdSource> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CrowdSource {
  DateTime dateTime;
  List<dynamic> crowdSourceNew;
  List<Comment> comments;
  String description;
  String userId;
  bool isApprove;
  String imageUrl;
  String name;
  List<Option> options;
  String id;
  List<String> likes;
  UserDetails? userDetails;

  CrowdSource({
    required this.dateTime,
    required this.crowdSourceNew,
    required this.comments,
    required this.description,
    required this.userId,
    required this.isApprove,
    required this.imageUrl,
    required this.name,
    required this.options,
    required this.id,
    required this.likes,
    required this.userDetails,
  });

  factory CrowdSource.fromJson(Map<String, dynamic> json) => CrowdSource(
        dateTime: DateTime.parse(json["dateTime"]),
        crowdSourceNew: List<dynamic>.from(json["new"].map((x) => x)),
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
        description: json["description"],
        userId: json["userId"],
        isApprove: json["isApprove"],
        imageUrl: json["imageUrl"],
        name: json["name"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
        id: json["id"],
        likes: List<String>.from(json["likes"].map((x) => x)),
        userDetails: json["userDetails"] != null
            ? UserDetails.fromJson(json["userDetails"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "dateTime": dateTime.toIso8601String(),
        "new": List<dynamic>.from(crowdSourceNew.map((x) => x)),
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
        "description": description,
        "userId": userId,
        "isApprove": isApprove,
        "imageUrl": imageUrl,
        "name": name,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
        "id": id,
        "likes": List<dynamic>.from(likes.map((x) => x)),
        "userDetails": userDetails?.toJson(),
      };
}

class Comment {
  DateTime dateTime;
  String name;
  String comment;

  Comment({
    required this.dateTime,
    required this.name,
    required this.comment,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        dateTime: DateTime.parse(json["dateTime"]),
        name: json["name"],
        comment: json["comment"],
      );

  Map<String, dynamic> toJson() => {
        "dateTime": dateTime.toIso8601String(),
        "name": name,
        "comment": comment,
      };
}

class Option {
  List<String> votes1;
  String text;

  Option({
    required this.votes1,
    required this.text,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        votes1: List<String>.from(json["votes1"].map((x) => x)),
        text: json["text"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "votes1": List<dynamic>.from(votes1.map((x) => x)),
        "text": text,
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
