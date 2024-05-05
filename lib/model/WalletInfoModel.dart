import 'dart:convert';

// class WalletInfoModel {
//   WalletData? walletData;
//   num? minAmountToGetRide;
//   num? totalAmount;

//   WalletInfoModel({this.walletData, this.minAmountToGetRide, this.totalAmount});

//   WalletInfoModel.fromJson(Map<String, dynamic> json) {
//     walletData = json['wallet_data'] != null ? new WalletData.fromJson(json['wallet_data']) : null;
//     minAmountToGetRide = json['min_amount_to_get_ride'];
//     totalAmount = json['total_amount'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.walletData != null) {
//       data['wallet_data'] = this.walletData!.toJson();
//     }
//     data['min_amount_to_get_ride'] = this.minAmountToGetRide;
//     data['total_amount'] = this.totalAmount;
//     return data;
//   }
// }

// class WalletData {
//   int? id;
//   int? userId;
//   int? totalAmount;
//   num? totalWithdrawn;
//   String? currency;
//   String? createdAt;
//   String? updatedAt;

//   WalletData({
//     this.id,
//     this.userId,
//     this.totalAmount,
//     this.totalWithdrawn,
//     this.currency,
//     this.createdAt,
//     this.updatedAt,
//   });

//   WalletData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     totalAmount = json['total_amount'];
//     totalWithdrawn = json['total_withdrawn'];
//     currency = json['currency'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['total_amount'] = this.totalAmount;
//     data['total_withdrawn'] = this.totalWithdrawn;
//     data['currency'] = this.currency;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }

// To parse this JSON data, do
//
//     final walletModel = walletModelFromJson(jsonString);

WalletInfoListModel walletInfoListModelFromJson(String str) =>
    WalletInfoListModel.fromJson(json.decode(str));

String walletInfoListModelToJson(WalletInfoListModel data) =>
    json.encode(data.toJson());

class WalletInfoListModel {
  WalletData? walletData;
  List<WalletHistory>? walletHistory;
  dynamic totalAmount;

  WalletInfoListModel({
    this.walletData,
    this.walletHistory,
    this.totalAmount,
  });

  factory WalletInfoListModel.fromJson(Map<String, dynamic> json) =>
      WalletInfoListModel(
        walletData: json['wallet_data'] == null
            ? null
            : WalletData.fromJson(json['wallet_data']),
        walletHistory: json["wallet_history"] == null
            ? null
            : List<WalletHistory>.from(
                json["wallet_history"].map((x) => WalletHistory.fromJson(x))),
        totalAmount: json["total_amount"],
      );

  Map<String, dynamic> toJson() => {
        "wallet_data": walletData!.toJson(),
        "wallet_history":
            List<dynamic>.from(walletHistory!.map((x) => x.toJson())),
        "total_amount": totalAmount,
      };
}

class WalletData {
  int? id;
  int? userId;
  dynamic? amount;
  dynamic date;
  int? createdAt;
  // DateTime updatedAt;

  WalletData({
    this.id,
    this.userId,
    this.amount,
    this.date,
    this.createdAt,
    // this.updatedAt,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
        id: json["id"],
        userId: json["user_id"],
        amount: json["amount"],
        date: json["date"],
        createdAt: json["created_at"],
        // updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "amount": amount,
        "date": date,
        "created_at": createdAt,
        // "updated_at": updatedAt.toIso8601String(),
      };
}

class WalletHistory {
  int? id;
  String? userId;
  String? amount;
  String? message;
  dynamic reference;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  WalletHistory({
    this.id,
    this.userId,
    this.amount,
    this.message,
    this.reference,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletHistory.fromJson(Map<String, dynamic> json) => WalletHistory(
        id: json["id"],
        userId: json["user_id"],
        amount: json["amount"],
        message: json["message"],
        reference: json["reference"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "amount": amount,
        "message": message,
        "reference": reference,
        "status": status,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
