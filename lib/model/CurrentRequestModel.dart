import '../model/CouponData.dart';
import '../model/ExtraChargeRequestModel.dart';

class CurrentRequestModel {
  int? id;
  String? displayName;
  String? email;
  String? username;
  String? userType;
  String? profileImage;
  String? status;
  OnRideRequest? rideRequest;
  OnRideRequest? onRideRequest;
  Driver? driver;
  // Payment? payment;

  CurrentRequestModel({
    this.id,
    this.displayName,
    this.email,
    this.username,
    this.userType,
    this.profileImage,
    this.status,
    this.rideRequest,
    this.onRideRequest,
    this.driver,
    // this.payment,
  });

  CurrentRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['display_name'];
    email = json['email'];
    username = json['username'];
    userType = json['user_type'];
    profileImage = json['profile_image'];
    status = json['status'];
    rideRequest = json['ride_request'] != null
        ? new OnRideRequest.fromJson(json['ride_request'])
        : null;
    onRideRequest = json['on_ride_request'] != null
        ? new OnRideRequest.fromJson(json['on_ride_request'])
        : null;
    driver =
        json['driver'] != null ? new Driver.fromJson(json['driver']) : null;
    // payment = json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['display_name'] = this.displayName;
    data['email'] = this.email;
    data['username'] = this.username;
    data['user_type'] = this.userType;
    data['profile_image'] = this.profileImage;
    data['status'] = this.status;
    if (this.rideRequest != null) {
      data['ride_request'] = this.rideRequest!.toJson();
    }
    if (this.onRideRequest != null) {
      data['on_ride_request'] = this.onRideRequest!.toJson();
    }
    if (this.driver != null) {
      data['driver'] = this.driver!.toJson();
      // }
      // if (this.payment != null) {
      //   data['payment'] = this.payment!.toJson();
    }
    return data;
  }
}

class OnRideRequest {
  int? id;
  int? userId;
  int? shopId;
  int? orderId;
  // String? orderId;
  int? addressId;
  int? driverId;
  int? offerId;
  int? rideRequestId;
  dynamic? netAmount;
  dynamic? taxes;
  dynamic? offerAmount;
  int? deliveryCharge;
  dynamic totalAmount;
  dynamic? totalItem;
  String? status;
  String? paymentType;
  String? paymentStatus;
  dynamic? cancelReason;
  dynamic? otherReason;
  DateTime? orderDate;
  DateTime? expectedTime;
  String? transactionId;
  dynamic? refundAmount;
  dynamic? cancelBy;
  dynamic? returnRequestStatus;
  String? invoiceNo;
  DateTime? purchaseDate;
  dynamic? otp;
  dynamic? rejectDriverId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic? riderId;
  String? startLatitude;
  String? startLongitude;
  String? startAddress;
  String? endLatitude;
  String? endLongitude;
  String? endAddress;
  double? distance;
  double? baseDistance;
  double? duration;
  String? rideType;
  String? itemType;
  String? itemCategories;
  String? reason;
  int? isRideForOther;
  String? otherRiderData;
  // List<dynamic>? otherRiderData;
  String? userName;
  String? userPhone;
  String? userEmail;
  String? userImage;
  String? driverName;
  String? driverPhone;
  String? driverEmail;
  String? driverImage;

  OnRideRequest({
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
    this.riderId,
    this.startLatitude,
    this.startLongitude,
    this.startAddress,
    this.endLatitude,
    this.endLongitude,
    this.endAddress,
    this.distance,
    this.baseDistance,
    this.duration,
    this.rideType,
    this.itemType,
    this.itemCategories,
    this.reason,
    this.isRideForOther,
    this.otherRiderData,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.userImage,
    this.driverName,
    this.driverPhone,
    this.driverEmail,
    this.driverImage,
  });

  factory OnRideRequest.fromJson(Map<String, dynamic> json) => OnRideRequest(
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
        purchaseDate: json["purchase_date"] == null
            ? null
            : DateTime.parse(json["purchase_date"]),
        otp: json["otp"],
        rejectDriverId: json["reject_driver_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        // createdAt: DateTime.parse(json["created_at"]),
        // updatedAt: DateTime.parse(json["updated_at"]),
        riderId: json["rider_id"],
        startLatitude: json["start_latitude"],
        startLongitude: json["start_longitude"],
        startAddress: json["start_address"],
        endLatitude: json["end_latitude"],
        endLongitude: json["end_longitude"],
        endAddress: json["end_address"],
        distance: json["distance"],
        baseDistance: json["base_distance"],
        duration: json["duration"],
        rideType: json["ride_type"],
        itemType: json["item_type"],
        itemCategories: json["item_categories"],
        reason: json["reason"],
        isRideForOther: json["is_ride_for_other"],
        otherRiderData: json["other_rider_data"],
        userName: json["user_name"],
        userPhone: json["user_phone"],
        userEmail: json["user_email"],
        userImage: json["user_image"],
        driverName: json["driver_name"],
        driverPhone: json["driver_phone"],
        driverEmail: json["driver_email"],
        driverImage: json["driver_image"],
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
        "rider_id": riderId,
        "start_latitude": startLatitude,
        "start_longitude": startLongitude,
        "start_address": startAddress,
        "end_latitude": endLatitude,
        "end_longitude": endLongitude,
        "end_address": endAddress,
        "distance": distance,
        "base_distance": baseDistance,
        "duration": duration,
        "ride_type": rideType,
        "item_type": itemType,
        "item_categories": itemCategories,
        "reason": reason,
        "is_ride_for_other": isRideForOther,
        "other_rider_data": otherRiderData,
        "user_name": userName,
        "user_phone": userPhone,
        "user_email": userEmail,
        "user_image": userImage,
        "driver_name": driverName,
        "driver_phone": driverPhone,
        "driver_email": driverEmail,
        "driver_image": driverImage,
      };
}

class Driver {
  int? id;
  String? type;
  String? name;
  String? email;
  String? age;
  String? bvn;
  String? gender;
  String? countryCode;
  String? mobile;
  dynamic? emailVerifiedAt;
  String? password;
  String? otp;
  String? bvnPhoneNumber;
  String? deviceId;
  String? deviceType;
  String? deviceName;
  String? deviceToken;
  String? profile;
  String? status;
  String? textTest;
  String? serviceType;
  String? yearExpreance;
  String? location;
  String? locationLat;
  String? locationLong;
  dynamic? idProf;
  String? documentsApproved;
  int? isOnline;
  int? whatApp;
  int? sms;
  int? notification;
  String? serviceTypePrice;
  String? guarantorName;
  String? guarantorEmail;
  String? guarantorPhoneNumber;
  String? guarantorAddress;
  String? serviceDiscription;
  String? state;
  String? town;
  int? gpsLocationStatus;
  int? isPhoneVerified;
  DateTime? createdAt;
  DateTime? updatedAt;
  Vehicledetails? vehicledetails;

  Driver({
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
    this.password,
    this.otp,
    this.bvnPhoneNumber,
    this.deviceId,
    this.deviceType,
    this.deviceName,
    this.deviceToken,
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

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
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
        password: json["password"],
        otp: json["otp"],
        bvnPhoneNumber: json["bvn_phone_number"],
        deviceId: json["device_id"],
        deviceType: json["device_type"],
        deviceName: json["device_name"],
        deviceToken: json["device_token"],
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
        vehicledetails: Vehicledetails.fromJson(json["vehicledetails"]),
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
        "password": password,
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
// class Driver {
//   int? id;
//   String? displayName;
//   String? email;
//   String? status;
//   String? userType;
//   String? address;
//   String? phone;
//   String? profileImage;
//   String? loginType;
//   String? latitude;
//   String? longitude;
//   num? isOnline;
//   String? createdAt;
//   String? updatedAt;

//   Driver({
//     this.id,
//     this.displayName,
//     this.email,
//     this.status,
//     this.userType,
//     this.address,
//     this.phone,
//     this.profileImage,
//     this.loginType,
//     this.latitude,
//     this.longitude,
//     this.isOnline,
//     this.createdAt,
//     this.updatedAt,
//   });

//   Driver.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     displayName = json['display_name'];
//     email = json['email'];
//     status = json['status'];
//     userType = json['user_type'];
//     address = json['address'];
//     phone = json['phone'];
//     profileImage = json['profile_image'];
//     loginType = json['login_type'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     isOnline = json['is_online'];

//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['display_name'] = this.displayName;
//     data['email'] = this.email;
//     data['status'] = this.status;
//     data['user_type'] = this.userType;
//     data['address'] = this.address;
//     data['phone'] = this.phone;
//     data['profile_image'] = this.profileImage;
//     data['login_type'] = this.loginType;
//     data['latitude'] = this.latitude;
//     data['longitude'] = this.longitude;
//     data['is_online'] = this.isOnline;

//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }

// class UserDetail {
//   int? id;
//   int? userId;
//   String? carModel;
//   String? carColor;
//   String? carPlateNumber;
//   String? carProductionYear;
//   String? workAddress;
//   String? homeAddress;
//   String? workLatitude;
//   String? workLongitude;
//   String? homeLatitude;
//   String? homeLongitude;
//   String? createdAt;
//   String? updatedAt;

//   UserDetail({
//     this.id,
//     this.userId,
//     this.carModel,
//     this.carColor,
//     this.carPlateNumber,
//     this.carProductionYear,
//     this.workAddress,
//     this.homeAddress,
//     this.workLatitude,
//     this.workLongitude,
//     this.homeLatitude,
//     this.homeLongitude,
//     this.createdAt,
//     this.updatedAt,
//   });

//   UserDetail.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     carModel = json['car_model'];
//     carColor = json['car_color'];
//     carPlateNumber = json['car_plate_number'];
//     carProductionYear = json['car_production_year'];
//     workAddress = json['work_address'];
//     homeAddress = json['home_address'];
//     workLatitude = json['work_latitude'];
//     workLongitude = json['work_longitude'];
//     homeLatitude = json['home_latitude'];
//     homeLongitude = json['home_longitude'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['car_model'] = this.carModel;
//     data['car_color'] = this.carColor;
//     data['car_plate_number'] = this.carPlateNumber;
//     data['car_production_year'] = this.carProductionYear;
//     data['work_address'] = this.workAddress;
//     data['home_address'] = this.homeAddress;
//     data['work_latitude'] = this.workLatitude;
//     data['work_longitude'] = this.workLongitude;
//     data['home_latitude'] = this.homeLatitude;
//     data['home_longitude'] = this.homeLongitude;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }

// class DriverService {
//   int? id;
//   String? name;
//   int? regionId;
//   int? capacity;
//   num? baseFare;
//   num? minimumFare;
//   num? minimumDistance;
//   num? perDistance;
//   num? perMinuteDrive;
//   num? perMinuteWait;
//   num? waitingTimeLimit;
//   num? cancellationFee;
//   num? perMinutePriorCancel;
//   num? perDistancePriorCancel;
//   String? paymentMethod;
//   String? commissionType;
//   num? adminCommission;
//   num? fleetCommission;
//   num? status;
//   String? createdAt;
//   String? updatedAt;

//   DriverService({
//     this.id,
//     this.name,
//     this.regionId,
//     this.capacity,
//     this.baseFare,
//     this.minimumFare,
//     this.minimumDistance,
//     this.perDistance,
//     this.perMinuteDrive,
//     this.perMinuteWait,
//     this.waitingTimeLimit,
//     this.cancellationFee,
//     this.perMinutePriorCancel,
//     this.perDistancePriorCancel,
//     this.paymentMethod,
//     this.commissionType,
//     this.adminCommission,
//     this.fleetCommission,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//   });

//   DriverService.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     regionId = json['region_id'];
//     capacity = json['capacity'];
//     baseFare = json['base_fare'];
//     minimumFare = json['minimum_fare'];
//     minimumDistance = json['minimum_distance'];
//     perDistance = json['per_distance'];
//     perMinuteDrive = json['per_minute_drive'];
//     perMinuteWait = json['per_minute_wait'];
//     waitingTimeLimit = json['waiting_time_limit'];
//     cancellationFee = json['cancellation_fee'];
//     perMinutePriorCancel = json['per_minute_prior_cancel'];
//     perDistancePriorCancel = json['per_distance_prior_cancel'];
//     paymentMethod = json['payment_method'];
//     commissionType = json['commission_type'];
//     adminCommission = json['admin_commission'];
//     fleetCommission = json['fleet_commission'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['region_id'] = this.regionId;
//     data['capacity'] = this.capacity;
//     data['base_fare'] = this.baseFare;
//     data['minimum_fare'] = this.minimumFare;
//     data['minimum_distance'] = this.minimumDistance;
//     data['per_distance'] = this.perDistance;
//     data['per_minute_drive'] = this.perMinuteDrive;
//     data['per_minute_wait'] = this.perMinuteWait;
//     data['waiting_time_limit'] = this.waitingTimeLimit;
//     data['cancellation_fee'] = this.cancellationFee;
//     data['per_minute_prior_cancel'] = this.perMinutePriorCancel;
//     data['per_distance_prior_cancel'] = this.perDistancePriorCancel;
//     data['payment_method'] = this.paymentMethod;
//     data['commission_type'] = this.commissionType;
//     data['admin_commission'] = this.adminCommission;
//     data['fleet_commission'] = this.fleetCommission;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }

// class Payment {
//   int? id;
//   int? rideRequestId;
//   int? riderId;
//   String? riderName;
//   String? datetime;
//   num? totalAmount;
//   var receivedBy;
//   num? adminCommission;
//   num? fleetCommission;
//   num? driverFee;
//   int? driverTips;
//   var driverCommission;
//   var txnId;
//   String? paymentType;
//   String? paymentStatus;
//   var transactionDetail;
//   String? createdAt;
//   String? updatedAt;

//   Payment({
//     this.id,
//     this.rideRequestId,
//     this.riderId,
//     this.riderName,
//     this.datetime,
//     this.totalAmount,
//     this.receivedBy,
//     this.adminCommission,
//     this.fleetCommission,
//     this.driverFee,
//     this.driverTips,
//     this.driverCommission,
//     this.txnId,
//     this.paymentType,
//     this.paymentStatus,
//     this.transactionDetail,
//     this.createdAt,
//     this.updatedAt,
//   });

//   Payment.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     rideRequestId = json['ride_request_id'];
//     riderId = json['rider_id'];
//     riderName = json['rider_name'];
//     datetime = json['datetime'];
//     totalAmount = json['total_amount'];
//     receivedBy = json['received_by'];
//     adminCommission = json['admin_commission'];
//     fleetCommission = json['fleet_commission'];
//     driverFee = json['driver_fee'];
//     driverTips = json['driver_tips'];
//     driverCommission = json['driver_commission'];
//     txnId = json['txn_id'];
//     paymentType = json['payment_type'];
//     paymentStatus = json['payment_status'];
//     transactionDetail = json['transaction_detail'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['ride_request_id'] = this.rideRequestId;
//     data['rider_id'] = this.riderId;
//     data['rider_name'] = this.riderName;
//     data['datetime'] = this.datetime;
//     data['total_amount'] = this.totalAmount;
//     data['received_by'] = this.receivedBy;
//     data['admin_commission'] = this.adminCommission;
//     data['fleet_commission'] = this.fleetCommission;
//     data['driver_fee'] = this.driverFee;
//     data['driver_tips'] = this.driverTips;
//     data['driver_commission'] = this.driverCommission;
//     data['txn_id'] = this.txnId;
//     data['payment_type'] = this.paymentType;
//     data['payment_status'] = this.paymentStatus;
//     data['transaction_detail'] = this.transactionDetail;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
