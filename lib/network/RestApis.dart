import 'dart:convert';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import '../model/CouponListModel.dart';
import '../model/CurrentRequestModel.dart';
import '../model/EstimatePriceModel.dart';
import '../model/GooglePlaceIdModel.dart';
import '../model/LDBaseResponse.dart';
import '../model/WalletInfoModel.dart';
import '../model/WithDrawListModel.dart';
import '../utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../model/AppSettingModel.dart';
import '../model/ChangePasswordResponseModel.dart';
import '../model/ComplaintCommentModel.dart';
import '../model/ContactNumberListModel.dart';
import '../model/GoogleMapSearchModel.dart';
import '../model/LoginResponse.dart';
import '../model/NearByDriverModel.dart';
import '../model/NotificationListModel.dart';
import '../model/PaymentListModel.dart';
import '../model/RideDetailModel.dart';
import '../model/RiderListModel.dart';
import '../model/ServiceModel.dart';
import '../model/UserDetailModel.dart';
import '../model/WalletListModel.dart';
import '../screens/SignInScreen.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import 'NetworkUtils.dart';

Future<UserModel> signUpApi(Map request) async {
  Response response = await buildHttpResponse('register',
      request: request, method: HttpMethod.POST);

  if (!(response.statusCode >= 200 && response.statusCode <= 206)) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      // if status is 0 then show error message
      if (json.containsKey('status') && json['status'] == 0) {
        throw json['message'];
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = UserModel.fromJson(json);
    if (loginResponse.userdata != null) {
      await sharedPref.setString(
          TOKEN, loginResponse.userdata!.apiToken.validate());
      await sharedPref.setString(
          USER_TYPE, loginResponse.userdata!.type.validate());
      await sharedPref.setString(NAME, loginResponse.userdata!.name.validate());
      await sharedPref.setString(
          CONTACT_NUMBER, loginResponse.userdata!.mobile.validate());
      await sharedPref.setString(
          USER_EMAIL, loginResponse.userdata!.email.validate());
      // await sharedPref.setString(ADDRESS, loginResponse.userdata!.address.validate());
      await sharedPref.setInt(USER_ID, loginResponse.userdata!.id ?? 0);
      await sharedPref.setString(
          USER_PROFILE_PHOTO, loginResponse.userdata!.profile.validate());
      await appStore.setLoggedIn(true);
      await appStore.setUserEmail(loginResponse.userdata!.email.validate());
      if (loginResponse.userdata!.id != null)
        await sharedPref.setInt(UID, loginResponse.userdata!.id!);
      await appStore.setUserProfile(loginResponse.userdata!.profile.validate());
    }

    return loginResponse;
  }).catchError((e) {
    throw e.toString();
    // toast(e.toString());
  });
}

Future<UserModel> logInApi(Map request) async {
  Response response = await buildHttpResponse('login',
      request: request, method: HttpMethod.POST);

  if (!(response.statusCode >= 200 && response.statusCode <= 206)) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      // if status is 0 then show error message
      if (json.containsKey('status') && json['status'] == 0) {
        throw json['message'];
      }
    }
  }
  print(response.body);

  return await handleResponse(response).then((json) async {
    var loginResponse = UserModel.fromJson(json);
    if (loginResponse.userdata != null) {
      await sharedPref.setString(
          TOKEN, loginResponse.userdata!.apiToken.validate());
      await sharedPref.setString(
          USER_TYPE, loginResponse.userdata!.type.validate());
      await sharedPref.setString(NAME, loginResponse.userdata!.name.validate());
      await sharedPref.setString(
          CONTACT_NUMBER, loginResponse.userdata!.mobile.validate());
      await sharedPref.setString(
          USER_EMAIL, loginResponse.userdata!.email.validate());
      // await sharedPref.setString(ADDRESS, loginResponse.userdata!.address.validate());
      await sharedPref.setInt(USER_ID, loginResponse.userdata!.id ?? 0);
      await sharedPref.setString(
          USER_PROFILE_PHOTO, loginResponse.userdata!.profile.validate());
      await appStore.setLoggedIn(true);
      await appStore.setUserEmail(loginResponse.userdata!.email.validate());
      if (loginResponse.userdata!.id != null)
        await sharedPref.setInt(UID, loginResponse.userdata!.id!);
      await appStore
          .setUserProfile(loginResponse.userdata!.profile.validate() ?? '');
    }

    return loginResponse;
  }).catchError((e) {
    log('${e}');
    throw e.toString();
  });
}

Future<MultipartRequest> getMultiPartRequest(String endPoint,
    {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future sendMultiPartRequest(MultipartRequest multiPartRequest,
    {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  multiPartRequest.headers.addAll(buildHeaderTokens());

  await multiPartRequest.send().then((res) {
    log(res.statusCode);
    res.stream.transform(utf8.decoder).listen((value) {
      log(value);
      onSuccess?.call(jsonDecode(value));
    });
  }).catchError((error) {
    onError?.call(error.toString());
  });
}

/// Profile Update
Future updateProfile(
    {String? name,
    String? userEmail,
    String? contactNumber,
    File? file}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update_profile');
  multiPartRequest.fields['email'] = userEmail ?? appStore.userEmail;
  multiPartRequest.fields['name'] = name.validate();
  multiPartRequest.fields['mobile'] = contactNumber.validate();

  if (file != null)
    multiPartRequest.files
        .add(await MultipartFile.fromPath('profile', file.path));

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      print("data:$data");
      print("data with user ${data['data']['user']}");

      Map<String, dynamic> dataRes = {
        'status': data['status'],
        'message': data['message'],
        'data': data['data']['user']
      };

      UserModel res = UserModel.fromJson(dataRes);

      await sharedPref.setString(NAME, res.userdata!.name.validate());
      await sharedPref.setString(
          CONTACT_NUMBER, res.userdata!.mobile.validate());
      await sharedPref.setString(USER_EMAIL, res.userdata!.email.validate());
      await sharedPref.setString(
          USER_PROFILE_PHOTO, res.userdata!.profile.validate());

      await appStore.setUserEmail(res.userdata!.email.validate());
      await appStore.setUserProfile(res.userdata!.profile.validate());
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<void> logout({bool isDelete = false}) async {
  // if (!isDelete) {
  //     logOutSuccess();
  // await logoutApi().then((value) async {
  // }).catchError((e) {
  //   throw e.toString();
  // });
  // } else {
  logOutSuccess();
  // }
}

Future<ChangePasswordResponseModel> changePassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('change-password',
          request: req, method: HttpMethod.POST)));
}

Future<ChangePasswordResponseModel> forgotPassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('forgot-password-change',
          request: req, method: HttpMethod.POST)));
}

Future<ServiceModel> getServices() async {
  return ServiceModel.fromJson(await handleResponse(
      await buildHttpResponse('service-list', method: HttpMethod.GET)));
}

Future<UserModel> getUserDetail({int? userId}) async {
  return UserModel.fromJson(await handleResponse(await buildHttpResponse(
      'user_detail?id=$userId',
      method: HttpMethod.GET)));
}

Future<UserModel> getUserDetails() async {
  return UserModel.fromJson(await handleResponse(
      await buildHttpResponse('user_details', method: HttpMethod.GET)));
}

// Future<LDBaseResponse> changeStatusApi(Map request) async {
//   return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
//       'update-user-status',
//       method: HttpMethod.POST,
//       request: request)));
// }

// Future<LDBaseResponse> saveBooking(Map request) async {
//   return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
//       'update-user-status',
//       method: HttpMethod.POST,
//       request: request)));
// }

// Future<WalletListModel> getWalletList({required int page}) async {
//   return WalletListModel.fromJson(await handleResponse(await buildHttpResponse(
//       'wallet-list?page=$page',
//       method: HttpMethod.GET)));
// }

Future<PaymentListModel> getPaymentList() async {
  return PaymentListModel.fromJson(await handleResponse(await buildHttpResponse(
      'payment-gateway-list?status=1',
      method: HttpMethod.GET)));
}

Future<SaveWallet> saveWallet(Map request) async {
  return SaveWallet.fromJson(await handleResponse(await buildHttpResponse(
      'save-wallet',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> saveSOS(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-sos',
      method: HttpMethod.POST,
      request: request)));
}

Future<ContactNumberListModel> getSosList({int? regionId}) async {
  return ContactNumberListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          regionId != null ? 'sos-list?region_id=$regionId' : 'sos-list',
          method: HttpMethod.GET)));
}

Future<ContactNumberListModel> deleteSosList({int? id}) async {
  return ContactNumberListModel.fromJson(await handleResponse(
      await buildHttpResponse('sos-delete/$id', method: HttpMethod.POST)));
}

Future<EstimatePriceModel> estimatePriceList(Map request) async {
  return EstimatePriceModel.fromJson(await handleResponse(
      await buildHttpResponse('estimate-price-time',
          method: HttpMethod.POST, request: request)));
}

Future<CouponListModel> getCouponList() async {
  return CouponListModel.fromJson(await handleResponse(
      await buildHttpResponse('coupon-list', method: HttpMethod.GET)));
}

Future<LDBaseResponse> savePayment(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-payment',
      method: HttpMethod.POST,
      request: request)));
}

Future<RequestRider> saveRideRequest(Map request) async {
  return RequestRider.fromJson(await handleResponse(await buildHttpResponse(
      'save-order-request',
      method: HttpMethod.POST,
      request: request)));
  // return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
  //     'save-order-request',
  //     method: HttpMethod.POST,
  //     request: request)));
}

// Future<AppSettingModel> getAppSetting() async {
//   return AppSettingModel.fromJson(await handleResponse(
//       await buildHttpResponse('admin-dashboard', method: HttpMethod.GET)));
// }

Future<CurrentRequestModel> getCurrentRideRequest() async {
  return CurrentRequestModel.fromJson(await handleResponse(
      await buildHttpResponse('current-ride-request', method: HttpMethod.GET)));
}

Future<RideStatus> rideRequestUpdate(
    {required Map request, int? rideId}) async {
  return RideStatus.fromJson(await handleResponse(await buildHttpResponse(
      'update-order-request/$rideId',
      method: HttpMethod.POST,
      request: request)));

  // return RideStatus.fromJson(await handleResponse(await buildHttpResponse(
  //     'update-order-request/$rideId',
  //     method: HttpMethod.POST,
  //     request: request)));
  // return LDBaseResponse.fromJson(await handleResponse(
  //     await buildHttpResponse('update-order-request/$rideId',
  //         // 'riderequest-update/$rideId',
  //         method: HttpMethod.POST,
  //         request: request)));
}
// Future<LDBaseResponse> rideRequestRate(
//     {required Map request, int? rideId}) async {
//   return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
//       'update-order-request/$rideId',
//       method: HttpMethod.POST,
//       request: request)));

// return RideStatus.fromJson(await handleResponse(await buildHttpResponse(
//     'update-order-request/$rideId',
//     method: HttpMethod.POST,
//     request: request)));
// return LDBaseResponse.fromJson(await handleResponse(
//     await buildHttpResponse('update-order-request/$rideId',
//         // 'riderequest-update/$rideId',
//         method: HttpMethod.POST,
//         request: request)));
// }

Future<LDBaseResponse> ratingReview({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-ride-rating',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> adminNotify({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'admin-sos-notify',
      method: HttpMethod.POST,
      request: request)));
}

Future<RideList> getRiderRequestList(String status) async {
  return RideList.fromJson(
    await handleResponse(
      await buildHttpResponse(
        'my-orders?status=$status',
        method: HttpMethod.GET,
      ),
    ),
  );
  // if (sourceLatLog != null) {
  //   return RiderListModel.fromJson(await handleResponse(await buildHttpResponse(
  //       'riderequest-list?page=$page&rider_id=$riderId',
  //       method: HttpMethod.GET)));
  // } else {
  //   return RiderListModel.fromJson(await handleResponse(await buildHttpResponse(
  //       status != null
  //           ? 'riderequest-list?page=$page&status=$status&rider_id=$riderId'
  //           : 'riderequest-list?page=$page&rider_id=$riderId',
  //       method: HttpMethod.GET)));
  // }
}

Future<LDBaseResponse> saveComplain({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-complaint',
      method: HttpMethod.POST,
      request: request)));
}

Future<RideListData> rideDetail({required int? orderId}) async {
  return RideListData.fromJson(await handleResponse(await buildHttpResponse(
      'ride-request-detail?order_id=$orderId',
      method: HttpMethod.GET)));
}

/// Get Notification List
Future<NotificationListModel> getNotification({required int page}) async {
  return NotificationListModel.fromJson(await handleResponse(
      await buildHttpResponse('notification-list?page=$page&limit=$PER_PAGE',
          method: HttpMethod.POST)));
}

Future<GoogleMapSearchModel> searchAddressRequest({String? search}) async {
  return GoogleMapSearchModel.fromJson(await handleResponse(await buildHttpResponse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$GOOGLE_MAP_API_KEY&components=country:${sharedPref.getString(COUNTRY).validate(value: defaultCountry)}',
      method: HttpMethod.GET)));
}

Future<GooglePlaceIdModel> searchAddressRequestPlaceId(
    {String? placeId}) async {
  return GooglePlaceIdModel.fromJson(await handleResponse(await buildHttpResponse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$GOOGLE_MAP_API_KEY',
      method: HttpMethod.GET)));
}

Future<UserModel> updateStatus(Map request) async {
  return UserModel.fromJson(await handleResponse(await buildHttpResponse(
      'update-user-status',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> deleteUser() async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('delete-user-account', method: HttpMethod.POST)));
}

/// Profile Update
Future updateProfileUid() async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = sharedPref.getInt(USER_ID).toString();
  multiPartRequest.fields['username'] =
      sharedPref.getString(USER_NAME).validate();
  multiPartRequest.fields['email'] =
      sharedPref.getString(USER_EMAIL).validate();
  multiPartRequest.fields['uid'] = sharedPref.getString(UID).toString();

  log('multipart request:${multiPartRequest.fields}');
  log(sharedPref.getString(UID).toString());

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<LDBaseResponse> complaintComment({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-complaintcomment',
      method: HttpMethod.POST,
      request: request)));
}

Future<ComplaintCommentModel> complaintList(
    {required int complaintId, required int currentPage}) async {
  return ComplaintCommentModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'complaintcomment-list?complaint_id=$complaintId&page=$currentPage',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> logoutApi() async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('logout', method: HttpMethod.GET)));
}

Future<UserModel> getDriverDetail({int? userId}) async {
  return UserModel.fromJson(await handleResponse(await buildHttpResponse(
      'user_detail?id=$userId',
      method: HttpMethod.GET)));
}

logOutSuccess() async {
  sharedPref.remove(FIRST_NAME);
  sharedPref.remove(LAST_NAME);
  sharedPref.remove(USER_PROFILE_PHOTO);
  sharedPref.remove(USER_NAME);
  sharedPref.remove(USER_ADDRESS);
  sharedPref.remove(CONTACT_NUMBER);
  sharedPref.remove(GENDER);
  sharedPref.remove(UID);
  sharedPref.remove(TOKEN);
  sharedPref.remove(USER_TYPE);
  sharedPref.remove(ADDRESS);
  sharedPref.remove(USER_ID);
  sharedPref.remove(COUNTRY);
  appStore.setLoggedIn(false);
  if (!(sharedPref.getBool(REMEMBER_ME) ?? false) ||
      sharedPref.getString(LOGIN_TYPE) == LoginTypeGoogle ||
      sharedPref.getString(LOGIN_TYPE) == 'mobile') {
    sharedPref.remove(USER_EMAIL);
    sharedPref.remove(USER_PASSWORD);
    sharedPref.remove(REMEMBER_ME);
  }
  sharedPref.remove(LOGIN_TYPE);
  launchScreen(getContext, SignInScreen(), isNewTask: true);
}

Future<NearByDriverModel> getNearByDriverList({LatLng? latLng}) async {
  return NearByDriverModel.fromJson(await handleResponse(await buildHttpResponse(
      'near-by-driver',
      // 'near-by-driver?latitude=${latLng!.latitude}&longitude=${latLng.longitude}',
      method: HttpMethod.GET)));
}

// Future<AppSettingModel> getAppSettingApi() async {
//   return AppSettingModel.fromJson(await handleResponse(
//       await buildHttpResponse('appsetting', method: HttpMethod.GET)));
// }

Future<WalletInfoListModel> getWalletData() async {
  return WalletInfoListModel.fromJson(await handleResponse(
      await buildHttpResponse('wallet-detail', method: HttpMethod.GET)));
}

Future<WithDrawListModel> getWithDrawList({int? page}) async {
  return WithDrawListModel.fromJson(await handleResponse(
      await buildHttpResponse('withdrawrequest-list?page=$page',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWithDrawRequest(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-withdrawrequest',
      method: HttpMethod.POST,
      request: request)));
}

/// Update Bank Info
Future updateBankDetail(
    {String? bankName,
    String? bankCode,
    String? accountName,
    String? accountNumber}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['email'] =
      sharedPref.getString(USER_EMAIL).validate();
  multiPartRequest.fields['contact_number'] =
      sharedPref.getString(CONTACT_NUMBER).validate();
  multiPartRequest.fields['username'] =
      sharedPref.getString(USER_NAME).validate();
  multiPartRequest.fields['user_bank_account[bank_name]'] = bankName.validate();
  multiPartRequest.fields['user_bank_account[bank_code]'] = bankCode.validate();
  multiPartRequest.fields['user_bank_account[account_holder_name]'] =
      accountName.validate();
  multiPartRequest.fields['user_bank_account[account_number]'] =
      accountNumber.validate();

  log('Request:${multiPartRequest.fields}');

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    log('data:$data');
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}
