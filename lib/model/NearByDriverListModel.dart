class NearByDriverListModel {
  String? name;
  int? id;
  num? isOnline;
  // String? lastLocationUpdateAt;
  // String? lastName;
  String? latitude;
  String? longitude;
  // num? rating;
  String? status;

  NearByDriverListModel({
    this.name,
    this.id,
    // this.isAvailable,
    this.isOnline,
    // this.lastLocationUpdateAt,
    // this.lastName,
    this.latitude,
    this.longitude,
    // this.rating,
    this.status,
  });

  factory NearByDriverListModel.fromJson(Map<String, dynamic> json) {
    return NearByDriverListModel(
      name: json['name'],
      // firstName: json['first_name'],
      id: json['id'],
      // isAvailable: json['is_available'],
      isOnline: json['is_online'],
      // lastLocationUpdateAt: json['last_location_update_at'],
      // lastName: json['last_name'],
      latitude: json['location_lat'],
      longitude: json['location_long'],
      // rating: json['rating'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    // data['first_name'] = this.firstName;
    data['id'] = this.id;
    // data['is_available'] = this.isAvailable;
    data['is_online'] = this.isOnline;
    // data['last_location_update_at'] = this.lastLocationUpdateAt;
    // data['last_name'] = this.lastName;
    data['location_lat'] = this.latitude;
    data['location_long'] = this.longitude;
    // data['rating'] = this.rating;
    data['status'] = this.status;
    return data;
  }
}
