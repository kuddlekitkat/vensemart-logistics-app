import 'dart:convert';

import 'package:taxi_booking/model/CurrentRequestModel.dart';

class LDBaseResponse {
  int? rideRequestId;
  int? status;
  String? message;

  LDBaseResponse({this.status, this.message, this.rideRequestId});

  LDBaseResponse.fromJson(Map<String, dynamic> json) {
    rideRequestId = json['riderequest_id'];
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.rideRequestId;
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

// To parse this JSON data, do
//
//     final saveWallet = saveWalletFromJson(jsonString);

SaveWallet saveWalletFromJson(String str) =>
    SaveWallet.fromJson(json.decode(str));

String saveWalletToJson(SaveWallet data) => json.encode(data.toJson());

class SaveWallet {
  int? status;
  String? message;

  SaveWallet({
    this.status,
    this.message,
  });

  factory SaveWallet.fromJson(Map<String, dynamic> json) => SaveWallet(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

// To parse this JSON data, do
//
//     final requestRider = requestRiderFromJson(jsonString);

RequestRider requestRiderFromJson(String str) =>
    RequestRider.fromJson(json.decode(str));

String requestRiderToJson(RequestRider data) => json.encode(data.toJson());

class RequestRider {
  int? status;
  String? message;
  Data? data;

  RequestRider({
    this.status,
    this.message,
    this.data,
  });

  factory RequestRider.fromJson(Map<String, dynamic> json) => RequestRider(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}

class Data {
  int? orderId;
  int? riderequestId;

  Data({
    this.orderId,
    this.riderequestId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["order_id"],
        riderequestId: json["riderequest_id"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "riderequest_id": riderequestId,
      };
}

RideStatus rideStatusFromJson(String str) =>
    RideStatus.fromJson(json.decode(str));

String rideStatusToJson(RideStatus data) => json.encode(data.toJson());

class RideStatus {
  int? status;
  String? message;
  Datum? data;

  RideStatus({
    this.status,
    this.message,
    this.data,
  });

  factory RideStatus.fromJson(Map<String, dynamic> json) => RideStatus(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Datum.fromJson(json["data"]),
        // data: Datum.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}

class Datum {
  OnRideRequest? onRideRequest;
  Driver? driver;

  Datum({
    this.onRideRequest,
    this.driver,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        onRideRequest: json['on_ride_request'] != null
            ? new OnRideRequest.fromJson(json['on_ride_request'])
            : null,
        driver:
            json['driver'] != null ? new Driver.fromJson(json['driver']) : null,
        // onRideRequest: OnRideRequest.fromJson(json["on_ride_request"]),
        // driver: Driver.fromJson(json["driver"]),
      );

  Map<String, dynamic> toJson() => {
        "on_ride_request": onRideRequest!.toJson(),
        "driver": driver!.toJson(),
      };
}
