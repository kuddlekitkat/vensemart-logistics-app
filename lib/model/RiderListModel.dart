import 'dart:convert';
import '../model/OrderHistory.dart';
import '../model/RiderModel.dart';
import 'PaginationModel.dart';

class RiderListModel {
  List<RiderModel>? data;
  PaginationModel? pagination;
  List<RideHistory>? rideHistory;

  RiderListModel({this.data, this.pagination, this.rideHistory});

  factory RiderListModel.fromJson(Map<String, dynamic> json) {
    return RiderListModel(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => RiderModel.fromJson(i)).toList()
          : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
      rideHistory: json['ride_history'] != null
          ? (json['ride_history'] as List)
              .map((i) => RideHistory.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.rideHistory != null) {
      data['ride_history'] = this.rideHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// To parse this JSON data, do
//
//     final rideList = rideListFromJson(jsonString);

RideList rideListFromJson(String str) => RideList.fromJson(json.decode(str));

String rideListToJson(RideList data) => json.encode(data.toJson());

class RideList {
  int? status;
  String? message;
  List<RideListData>? data;

  RideList({
    this.status,
    this.message,
    this.data,
  });

  factory RideList.fromJson(Map<String, dynamic> json) => RideList(
        status: json["status"],
        message: json["message"],
        data: List<RideListData>.from(
            json["data"].map((x) => RideListData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class RideListData {
  int? id;
  int? userId;
  dynamic? shopId;
  int? orderId;
  dynamic? addressId;
  int? driverId;
  dynamic? offerId;
  int? rideRequestId;
  int? netAmount;
  dynamic? taxes;
  dynamic? offerAmount;
  int? deliveryCharge;
  dynamic? totalAmount;
  dynamic? totalItem;
  dynamic status;
  dynamic? paymentType;
  dynamic? paymentStatus;
  String? cancelReason;
  String? otherReason;
  String? orderDate;
  String? expectedTime;
  String? transactionId;
  dynamic? refundAmount;
  dynamic? cancelBy;
  dynamic? returnRequestStatus;
  dynamic? invoiceNo;
  DateTime? purchaseDate;
  dynamic? otp;
  dynamic? rejectDriverId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? rideStartAddress;
  String? rideEndAddress;
  String? rideStartLatitude;
  String? rideStartLongitude;
  String? rideDeliveryLatitude;
  String? rideDeliveryLongitude;
  String? rideStatus;
  String? rideType;
  String? itemType;
  String? itemCategories;
  String? storeName;
  String? storeAddress;
  String? storeLatitude;
  String? storeLongitude;
  String? deliveryAddress;
  String? deliveryLatitude;
  String? deliveryLongitude;
  String? deliveryMobile;
  String? otherRiderName;
  String? otherRiderPhoneNumber;
  List<Product>? products;

  RideListData({
    this.id,
    this.userId,
    this.shopId,
    this.orderId,
    this.addressId,
    this.driverId,
    this.offerId,
    this.rideRequestId,
    this.netAmount,
    this.taxes,
    this.offerAmount,
    this.deliveryCharge,
    this.totalAmount,
    this.totalItem,
    this.status,
    this.paymentType,
    this.paymentStatus,
    this.cancelReason,
    this.otherReason,
    this.orderDate,
    this.expectedTime,
    this.transactionId,
    this.refundAmount,
    this.cancelBy,
    this.returnRequestStatus,
    this.invoiceNo,
    this.purchaseDate,
    this.otp,
    this.rejectDriverId,
    this.createdAt,
    this.updatedAt,
    this.rideStartAddress,
    this.rideEndAddress,
    this.rideStartLatitude,
    this.rideStartLongitude,
    this.rideDeliveryLatitude,
    this.rideDeliveryLongitude,
    this.rideStatus,
    this.rideType,
    this.itemType,
    this.itemCategories,
    this.storeName,
    this.storeAddress,
    this.storeLatitude,
    this.storeLongitude,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryMobile,
    this.otherRiderName,
    this.otherRiderPhoneNumber,
    this.products,
  });

  factory RideListData.fromJson(Map<String, dynamic> json) => RideListData(
        id: json["id"],
        userId: json["user_id"],
        shopId: json["shop_id"],
        orderId: json["order_id"],
        addressId: json["address_id"],
        driverId: json["driver_id"],
        offerId: json["offer_id"],
        rideRequestId: json["ride_request_id"],
        netAmount: json["net_amount"],
        taxes: json["taxes"],
        offerAmount: json["offer_amount"],
        deliveryCharge: json["delivery_charge"],
        totalAmount: json["total_amount"],
        totalItem: json["total_item"],
        status: json["status"],
        paymentType: json["payment_type"],
        paymentStatus: json["payment_status"],
        cancelReason: json["cancel_reason"],
        otherReason: json["other_reason"],
        orderDate: json["order_date"],
        expectedTime: json["expected_time"],
        transactionId: json["transaction_id"],
        refundAmount: json["refund_amount"],
        cancelBy: json["cancel_by"],
        returnRequestStatus: json["return_request_status"],
        invoiceNo: json["invoice_no"],
        purchaseDate: DateTime.parse(json["purchase_date"]),
        rideStatus: json["ride_status"],
        otp: json["otp"],
        rejectDriverId: json["reject_driver_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        rideStartAddress: json["ride_start_address"],
        rideEndAddress: json["ride_end_address"],
        rideStartLatitude: json["ride_start_latitude"],
        rideStartLongitude: json["ride_start_longitude"],
        rideDeliveryLatitude: json["ride_delivery_latitude"],
        rideDeliveryLongitude: json["ride_delivery_longitude"],
        rideType: json["ride_type"],
        itemType: json["item_type"],
        itemCategories: json["item_categories"],
        storeName: json["store_name"],
        storeAddress: json["store_address"],
        storeLatitude: json["store_latitude"],
        storeLongitude: json["store_longitude"],
        deliveryAddress: json["delivery_address"],
        deliveryLatitude: json["delivery_latitude"],
        deliveryLongitude: json["delivery_longitude"],
        deliveryMobile: json["delivery_mobile"],
        otherRiderName: json["other_rider_name"],
        otherRiderPhoneNumber: json["other_rider_phone_number"],
        products: json["products"] == null
            ? null
            : List<Product>.from(
                json["products"].map((x) => Product.fromJson(x))),
        // products: List<Product>.from(json["products"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "shop_id": shopId,
        "order_id": orderId,
        "address_id": addressId,
        "driver_id": driverId,
        "offer_id": offerId,
        "ride_request_id": rideRequestId,
        "net_amount": netAmount,
        "taxes": taxes,
        "offer_amount": offerAmount,
        "delivery_charge": deliveryCharge,
        "total_amount": totalAmount,
        "total_item": totalItem,
        "status": status,
        "payment_type": paymentType,
        "payment_status": paymentStatus,
        "cancel_reason": cancelReason,
        "other_reason": otherReason,
        "order_date": orderDate,
        "expected_time": expectedTime,
        "transaction_id": transactionId,
        "refund_amount": refundAmount,
        "cancel_by": cancelBy,
        "return_request_status": returnRequestStatus,
        "invoice_no": invoiceNo,
        "purchase_date":
            "${purchaseDate!.year.toString().padLeft(4, '0')}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}",
        "otp": otp,
        "reject_driver_id": rejectDriverId,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "ride_start_address": rideStartAddress,
        "ride_end_address": rideEndAddress,
        "ride_start_latitude": rideStartLatitude,
        "ride_start_longitude": rideStartLongitude,
        "ride_delivery_latitude": rideDeliveryLatitude,
        "ride_delivery_longitude": rideDeliveryLongitude,
        "ride_status": rideStatus,
        "ride_type": rideType,
        "item_type": itemType,
        "item_categories": itemCategories,
        "store_name": storeName,
        "store_address": storeAddress,
        "store_latitude": storeLatitude,
        "store_longitude": storeLongitude,
        "delivery_address": deliveryAddress,
        "delivery_latitude": deliveryLatitude,
        "delivery_longitude": deliveryLongitude,
        "delivery_mobile": deliveryMobile,
        "other_rider_name": otherRiderName,
        "other_rider_phone_number": otherRiderPhoneNumber,
        "products": products == null
            ? null
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        // "products": List<Product>.from(products!.map((x) => x)),
      };
}

class Product {
  int? id;
  String? productId;
  String? orderId;
  String? invoiceNumber;
  String? productName;
  String? userId;
  String? quantity;
  String? netPrice;
  dynamic? price;
  dynamic? gst;
  String? gstPercent;
  String? tax;
  dynamic? sellerId;
  String? basicDp;
  String? dp;
  String? pImage;
  String? payMode;
  String? uomId;
  DateTime? purchaseDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    this.id,
    this.productId,
    this.orderId,
    this.invoiceNumber,
    this.productName,
    this.userId,
    this.quantity,
    this.netPrice,
    this.price,
    this.gst,
    this.gstPercent,
    this.tax,
    this.sellerId,
    this.basicDp,
    this.dp,
    this.pImage,
    this.payMode,
    this.uomId,
    this.purchaseDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["product_id"],
        orderId: json["order_id"],
        invoiceNumber: json["invoice_number"],
        productName: json["product_name"],
        userId: json["user_id"],
        quantity: json["quantity"],
        netPrice: json["net_price"],
        price: json["price"],
        gst: json["gst"],
        gstPercent: json["gst_percent"],
        tax: json["tax"],
        sellerId: json["seller_id"],
        basicDp: json["basic_dp"],
        dp: json["dp"],
        pImage: json["p_image"],
        payMode: json["pay_mode"],
        uomId: json["uom_id"],
        purchaseDate: DateTime.parse(json["purchase_date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "order_id": orderId,
        "invoice_number": invoiceNumber,
        "product_name": productName,
        "user_id": userId,
        "quantity": quantity,
        "net_price": netPrice,
        "price": price,
        "gst": gst,
        "gst_percent": gstPercent,
        "tax": tax,
        "seller_id": sellerId,
        "basic_dp": basicDp,
        "dp": dp,
        "p_image": pImage,
        "pay_mode": payMode,
        "uom_id": uomId,
        "purchase_date":
            "${purchaseDate!.year.toString().padLeft(4, '0')}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}",
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
