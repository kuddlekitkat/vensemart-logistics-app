// class ChangePasswordResponseModel {
//   int? status;
//   String? message;

//   ChangePasswordResponseModel({this.message});

//   factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
//     return ChangePasswordResponseModel(
//       status: json['status'],
//       message: json['message'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     return data;
//   }
// }

// To parse this JSON data, do
//
//     final changePasswordResponseModel = changePasswordResponseModelFromJson(jsonString);

import 'dart:convert';

ChangePasswordResponseModel changePasswordResponseModelFromJson(String str) =>
    ChangePasswordResponseModel.fromJson(json.decode(str));

String changePasswordResponseModelToJson(ChangePasswordResponseModel data) =>
    json.encode(data.toJson());

class ChangePasswordResponseModel {
  int? status;
  String? message;

  ChangePasswordResponseModel({
    this.status,
    this.message,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ChangePasswordResponseModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
