// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

UserModel userFromJson(String str) => UserModel.fromJson(json.decode(str));

String userToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  int? status;
  String? message;
  UserData? userdata;

  UserModel({
    this.status,
    this.message,
    this.userdata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        status: json["status"],
        message: json["message"],
        userdata: UserData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": userdata!.toJson(),
      };
}

class UserData {
  int? id;
  String? type;
  String? name;
  String? email;
  dynamic? age;
  dynamic? bvn;
  dynamic? gender;
  dynamic? countryCode;
  String? mobile;
  dynamic? emailVerifiedAt;
  dynamic? otp;
  dynamic? bvnPhoneNumber;
  String? deviceId;
  String? deviceType;
  String? deviceName;
  String? deviceToken;
  String? apiToken;
  String? profile;
  String? status;
  dynamic? textTest;
  dynamic? serviceType;
  dynamic? yearExpreance;
  String? location;
  String? locationLat;
  String? locationLong;
  dynamic idProf;
  String? documentsApproved;
  dynamic isOnline;
  int? whatApp;
  int? sms;
  int? notification;
  String? serviceTypePrice;
  dynamic guarantorName;
  dynamic guarantorEmail;
  dynamic guarantorPhoneNumber;
  dynamic guarantorAddress;
  dynamic serviceDiscription;
  String? state;
  String? town;
  int? gpsLocationStatus;
  int? isPhoneVerified;
  DateTime? createdAt;
  DateTime? updatedAt;
  Vehicledetails? vehicledetails;

  UserData({
    this.id,
    this.type,
    this.name,
    this.email,
    this.age,
    this.bvn,
    this.gender,
    this.countryCode,
    this.mobile,
    this.emailVerifiedAt,
    this.otp,
    this.bvnPhoneNumber,
    this.deviceId,
    this.deviceType,
    this.deviceName,
    this.deviceToken,
    this.apiToken,
    this.profile,
    this.status,
    this.textTest,
    this.serviceType,
    this.yearExpreance,
    this.location,
    this.locationLat,
    this.locationLong,
    this.idProf,
    this.documentsApproved,
    this.isOnline,
    this.whatApp,
    this.sms,
    this.notification,
    this.serviceTypePrice,
    this.guarantorName,
    this.guarantorEmail,
    this.guarantorPhoneNumber,
    this.guarantorAddress,
    this.serviceDiscription,
    this.state,
    this.town,
    this.gpsLocationStatus,
    this.isPhoneVerified,
    this.createdAt,
    this.updatedAt,
    this.vehicledetails,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        type: json["type"],
        name: json["name"],
        email: json["email"],
        age: json["age"],
        bvn: json["bvn"],
        gender: json["gender"],
        countryCode: json["country_code"],
        mobile: json["mobile"],
        emailVerifiedAt: json["email_verified_at"],
        otp: json["otp"],
        bvnPhoneNumber: json["bvn_phone_number"],
        deviceId: json["device_id"],
        deviceType: json["device_type"],
        deviceName: json["device_name"],
        deviceToken: json["device_token"],
        apiToken: json["api_token"],
        profile: json["profile"],
        status: json["status"],
        textTest: json["text_test"],
        serviceType: json["service_type"],
        yearExpreance: json["year_expreance"],
        location: json["location"],
        locationLat: json["location_lat"],
        locationLong: json["location_long"],
        idProf: json["id_prof"],
        documentsApproved: json["documents_approved"],
        isOnline: json["is_online"],
        whatApp: json["what_app"],
        sms: json["sms"],
        notification: json["notification"],
        serviceTypePrice: json["service_type_price"],
        guarantorName: json["guarantor_name"],
        guarantorEmail: json["guarantor_email"],
        guarantorPhoneNumber: json["guarantor_phone_number"],
        guarantorAddress: json["guarantor_address"],
        serviceDiscription: json["service_discription"],
        state: json["state"],
        town: json["town"],
        gpsLocationStatus: json["gps_location_status"],
        isPhoneVerified: json["is_phone_verified"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        vehicledetails: json["vehicledetails"] == null
            ? null
            : Vehicledetails.fromJson(json["vehicledetails"]),
        // vehicledetails: Vehicledetails.fromJson(json["vehicledetails"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "name": name,
        "email": email,
        "age": age,
        "bvn": bvn,
        "gender": gender,
        "country_code": countryCode,
        "mobile": mobile,
        "email_verified_at": emailVerifiedAt,
        "otp": otp,
        "bvn_phone_number": bvnPhoneNumber,
        "device_id": deviceId,
        "device_type": deviceType,
        "device_name": deviceName,
        "device_token": deviceToken,
        "profile": profile,
        "status": status,
        "text_test": textTest,
        "service_type": serviceType,
        "year_expreance": yearExpreance,
        "location": location,
        "location_lat": locationLat,
        "location_long": locationLong,
        "id_prof": idProf,
        "documents_approved": documentsApproved,
        "is_online": isOnline,
        "what_app": whatApp,
        "sms": sms,
        "notification": notification,
        "service_type_price": serviceTypePrice,
        "guarantor_name": guarantorName,
        "guarantor_email": guarantorEmail,
        "guarantor_phone_number": guarantorPhoneNumber,
        "guarantor_address": guarantorAddress,
        "service_discription": serviceDiscription,
        "state": state,
        "town": town,
        "gps_location_status": gpsLocationStatus,
        "is_phone_verified": isPhoneVerified,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "vehicledetails": vehicledetails!.toJson(),
      };
}

class Vehicledetails {
  int? id;
  int? userId;
  String? vehicleType;
  String? vehicleNumber;
  String? dlNumber;
  String? dlPicture;
  String? aadharNumber;
  String? insurancePicture;
  String? status;
  String? isVerify;
  String? insuranceNumber;
  String? state;
  String? town;
  DateTime? createdAt;
  DateTime? updatedAt;

  Vehicledetails({
    this.id,
    this.userId,
    this.vehicleType,
    this.vehicleNumber,
    this.dlNumber,
    this.dlPicture,
    this.aadharNumber,
    this.insurancePicture,
    this.status,
    this.isVerify,
    this.insuranceNumber,
    this.state,
    this.town,
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicledetails.fromJson(Map<String, dynamic> json) => Vehicledetails(
        id: json["id"],
        userId: json["user_id"],
        vehicleType: json["vehicle_type"],
        vehicleNumber: json["vehicle_number"],
        dlNumber: json["dl_number"],
        dlPicture: json["dl_picture"],
        aadharNumber: json["aadhar_number"],
        insurancePicture: json["insurance_picture"],
        status: json["status"],
        isVerify: json["isVerify"],
        insuranceNumber: json["insurance_number"],
        state: json["state"],
        town: json["town"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "vehicle_type": vehicleType,
        "vehicle_number": vehicleNumber,
        "dl_number": dlNumber,
        "dl_picture": dlPicture,
        "aadhar_number": aadharNumber,
        "insurance_picture": insurancePicture,
        "status": status,
        "isVerify": isVerify,
        "insurance_number": insuranceNumber,
        "state": state,
        "town": town,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
