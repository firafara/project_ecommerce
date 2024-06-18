// To parse this JSON data, do
//
//     final modelRegister = modelRegisterFromJson(jsonString);

import 'dart:convert';

ModelRegister modelRegisterFromJson(String str) => ModelRegister.fromJson(json.decode(str));

String modelRegisterToJson(ModelRegister data) => json.encode(data.toJson());

class ModelRegister {
  int value;
  String username;
  String email;
  String fullname;
  String nohp;
  String message;

  ModelRegister({
  required this.value,
  required this.username,
  required this.email,
  required this.fullname,
  required this.nohp,
  required this.message,
  });


  factory ModelRegister.fromJson(Map<String, dynamic> json) => ModelRegister(
    value: json["value"],
    message: json["message"], username: 'json["username"]', email: 'json["email"]', fullname: 'json["fullname"]', nohp: 'json["nohp"]',
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "message": message,
    "username": username,
    "email": email,
    "fullname": fullname,
    "nohp": nohp,
  };
}
