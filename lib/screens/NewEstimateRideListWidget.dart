import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:taxi_booking/model/UserDetailModel.dart';
import 'package:taxi_booking/screens/PaymentScreen.dart';
import 'package:taxi_booking/screens/WhatToDeliver.dart';
import '../screens/WalletScreen.dart';
import '../utils/Extensions/context_extension.dart';
import '../screens/ReviewScreen.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../../components/CouPonWidget.dart';
import '../../components/RideAcceptWidget.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../components/BookingWidget.dart';
import '../components/CarDetailWidget.dart';
import '../model/CurrentRequestModel.dart';
import '../model/EstimatePriceModel.dart';
import '../utils/images.dart';
import 'DashBoardScreen.dart';
import 'package:http/http.dart' as http;

class NewEstimateRideListWidget extends StatefulWidget {
  final String? type;
  final String? itemType;
  final String? deliveringType;
  final LatLng? sourceLatLog;
  final LatLng? destinationLatLog;
  final String? sourceTitle;
  final String? destinationTitle;
  bool isCurrentRequest;
  final int? servicesId;
  final int? id;

  NewEstimateRideListWidget(
      {this.type,
      this.itemType,
      this.deliveringType,
      this.sourceLatLog,
      this.destinationLatLog,
      this.sourceTitle,
      this.destinationTitle,
      this.isCurrentRequest = false,
      this.servicesId,
      this.id});

  @override
  NewEstimateRideListWidgetState createState() =>
      NewEstimateRideListWidgetState();
}

class NewEstimateRideListWidgetState extends State<NewEstimateRideListWidget> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _googleMapController;
  final Set<Marker> markers = {};
  String countryCode = defaultCountryCode;
  Set<Polyline> _polyLines = Set<Polyline>();

  late PolylinePoints polylinePoints;
  late Marker sourceMarker;
  late Marker destinationMarker;
  late LatLng userLatLong;
  late DateTime scheduleData;

  double locationDistance = 0.0;
  String? distanceUnit = 'KM';
  double? durationOfDrop = 0.0;

  double? distance = 0;

  TextEditingController promoCode = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isBooking = false;
  bool isRideSelection = false;
  bool isOther = true;

  int selectedIndex = 0;
  int rideRequestId = 0;
  num mTotalAmount = 0;

  // String mSelectServiceAmount = '1500';

  List<String> cashList = ['cash', 'wallet'];
  // List<ServicesListData> serviceList = [];
  List<LatLng> polylineCoordinates = [];

  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor driverIcon;

  LatLng? driverLatitudeLocation;

  String paymentMethodType = '';

  UserModel? userData;

  // ServicesListData? servicesListData;
  OnRideRequest? rideRequest;
  Driver? driverData;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    init();
  }

  String distanceBetweenTwoPoints = '';
  String durationBetweenTwoPoints = '';
  double mRideTotalAmount = 0;
  double baseFare = 500;

  void calculatePrice() async {
    LatLng pickupLocation =
        LatLng(widget.sourceLatLog!.latitude, widget.sourceLatLog!.longitude);
    LatLng deliveryLocation = LatLng(widget.destinationLatLog!.latitude,
        widget.destinationLatLog!.longitude);

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${pickupLocation.latitude},${pickupLocation.longitude}&destinations=${deliveryLocation.latitude},${deliveryLocation.longitude}&key=$GOOGLE_MAP_API_KEY'));
    final responseJson = json.decode(response.body);
    final distance =
        responseJson['rows'][0]['elements'][0]['distance']['value'];
    final distanceText =
        responseJson['rows'][0]['elements'][0]['distance']['text'];
    final duration =
        responseJson['rows'][0]['elements'][0]['duration']['value'];
    final durationTime =
        responseJson['rows'][0]['elements'][0]['duration']['text'];

    // double distanceInKm = distance / 1000;
    // double durationInMinutes = duration / 60;
    double pricePerKm = 1;
    double taxes = 75;
    double surgeMultiplier = 1.8;
    // double totalPrice = baseFare + (distance * pricePerKm);
    // double totalPrice = baseFare + (distance * pricePerKm * surgeMultiplier);
    double totalPrice = (duration * surgeMultiplier * 120) / 100;

    setState(() {
      mRideTotalAmount = totalPrice;
      distanceBetweenTwoPoints = distanceText;
      durationBetweenTwoPoints = durationTime;
    });
  }

  void init() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon);
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);
    getServiceList();
    getCurrentRequest();
    calculatePrice();
    // mqttForUser();
    // if (!widget.isCurrentRequest) getNewService();
    isBooking = widget.isCurrentRequest;
    getWalletData().then((value) {
      print(value.totalAmount);
      mTotalAmount = value.totalAmount!;
    }).catchError((error) {
      log('${error.toString()}');
    });
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequest().then((value) {
      if (value.rideRequest != null || value.onRideRequest != null) {
        rideRequest = value.rideRequest ?? value.onRideRequest;
      }
      if (value.driver != null) {
        driverData = value.driver!;
      }

      if (rideRequest != null) {
        setState(() {});
        if (driverData != null && rideRequest!.status != COMPLETED) {
          timer = Timer.periodic(
              Duration(seconds: 10), (Timer t) => getUserDetailLocation());
        } else {
          timer?.cancel();
          timer = null;
        }
      }
      // if (rideRequest!.status == COMPLETED &&
      //     rideRequest != null &&
      //     driverData != null) {
      //   timer!.cancel();
      //   timer = null;
      //   launchScreen(context,
      //       ReviewScreen(rideRequest: rideRequest!, driverData: driverData),
      //       pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
      //       isNewTask: true);
      // }
    }).catchError((error) {
      log(error.toString());
    });
  }

  Future<void> getServiceList() async {
    markers.clear();
    polylinePoints = PolylinePoints();
    setPolyLines(
      sourceLocation:
          LatLng(widget.sourceLatLog!.latitude, widget.sourceLatLog!.longitude),
      destinationLocation: LatLng(widget.destinationLatLog!.latitude,
          widget.destinationLatLog!.longitude),
      driverLocation: driverLatitudeLocation,
    );
    MarkerId id = MarkerId('Source');
    markers.add(
      Marker(
        markerId: id,
        position: LatLng(
            widget.sourceLatLog!.latitude, widget.sourceLatLog!.longitude),
        infoWindow: InfoWindow(title: widget.sourceTitle),
        icon: sourceIcon,
      ),
    );
    MarkerId id2 = MarkerId('DriverLocation');
    markers.remove(id2);
    if (rideRequest != null &&
        (rideRequest!.status == ACCEPTED ||
            rideRequest!.status == PICKINGUP ||
            rideRequest!.status == PICKUP ||
            rideRequest!.status == INPROGRESS ||
            rideRequest!.status == ARRIVED))
      markers.add(
        Marker(
          markerId: id2,
          position: driverLatitudeLocation!,
          icon: driverIcon,
        ),
      );

    MarkerId id3 = MarkerId('Destination');
    markers.remove(id3);
    markers.add(
      Marker(
        markerId: MarkerId('Destination'),
        position: LatLng(widget.destinationLatLog!.latitude,
            widget.destinationLatLog!.longitude),
        infoWindow: InfoWindow(title: widget.destinationTitle),
        icon: destinationIcon,
      ),
    );

    setState(() {});
  }

  Future<void> setPolyLines({
    required LatLng sourceLocation,
    required LatLng destinationLocation,
    LatLng? driverLocation,
  }) async {
    _polyLines.clear();
    polylineCoordinates.clear();

    PointLatLng originPoint;
    PointLatLng destinationPoint;

    // Determine the origin and destination based on the ride request status
    if (rideRequest != null) {
      if (rideRequest!.status == ACCEPTED ||
          rideRequest!.status == PICKINGUP ||
          rideRequest!.status == PICKUP) {
        // If rideRequest is in progress, route from source to driver
        originPoint =
            PointLatLng(driverLocation!.latitude, driverLocation.longitude);
        destinationPoint =
            PointLatLng(sourceLocation.latitude, sourceLocation.longitude);
      } else if (rideRequest!.status == INPROGRESS) {
        // If rideRequest is in progress, route from driver to destination
        originPoint =
            PointLatLng(driverLocation!.latitude, driverLocation.longitude);
        destinationPoint = PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude);
      } else {
        // If rideRequest is null or not in progress, route from source to destination
        originPoint =
            PointLatLng(sourceLocation.latitude, sourceLocation.longitude);
        destinationPoint = PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude);
      }
    } else {
      // If rideRequest is null or not in progress, route from source to destination
      originPoint =
          PointLatLng(sourceLocation.latitude, sourceLocation.longitude);
      destinationPoint = PointLatLng(
          destinationLocation.latitude, destinationLocation.longitude);
    }

    var result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAP_API_KEY,
      originPoint,
      destinationPoint,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((element) {
        polylineCoordinates.add(LatLng(element.latitude, element.longitude));
      });
      _polyLines.add(Polyline(
        visible: true,
        width: 3,
        polylineId: PolylineId('poly'),
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates,
      ));
      setState(() {});
    }
  }

  // Future<void> setPolyLines(
  //     {required LatLng sourceLocation,
  //     required LatLng destinationLocation,
  //     LatLng? driverLocation}) async {
  //   _polyLines.clear();
  //   polylineCoordinates.clear();
  //   var result = await polylinePoints.getRouteBetweenCoordinates(
  //     GOOGLE_MAP_API_KEY,
  //     PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //     // PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
  //     rideRequest != null &&
  //             (rideRequest!.status == ACCEPTED ||
  //                 rideRequest!.status == PICKINGUP ||
  //                 rideRequest!.status == PICKUP ||
  //                 rideRequest!.status == INPROGRESS)
  //         ? PointLatLng(driverLocation!.latitude, driverLocation.longitude)
  //         : PointLatLng(
  //             destinationLocation.latitude, destinationLocation.longitude),
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((element) {
  //       polylineCoordinates.add(LatLng(element.latitude, element.longitude));
  //     });
  //     _polyLines.add(Polyline(
  //       visible: true,
  //       width: 3,
  //       polylineId: PolylineId('poly'),
  //       color: Color.fromARGB(255, 40, 122, 198),
  //       points: polylineCoordinates,
  //     ));
  //     setState(() {});
  //   }
  // }

  onMapCreated(GoogleMapController controller) async {
    _googleMapController = controller;
    _controller.complete(controller);
    await Future.delayed(Duration(milliseconds: 50));
    _googleMapController!.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(
                widget.sourceLatLog!.latitude <=
                        widget.destinationLatLog!.latitude
                    ? widget.sourceLatLog!.latitude
                    : widget.destinationLatLog!.latitude,
                widget.sourceLatLog!.longitude <=
                        widget.destinationLatLog!.longitude
                    ? widget.sourceLatLog!.longitude
                    : widget.destinationLatLog!.longitude),
            northeast: LatLng(
                widget.sourceLatLog!.latitude <=
                        widget.destinationLatLog!.latitude
                    ? widget.destinationLatLog!.latitude
                    : widget.sourceLatLog!.latitude,
                widget.sourceLatLog!.longitude <=
                        widget.destinationLatLog!.longitude
                    ? widget.destinationLatLog!.longitude
                    : widget.sourceLatLog!.longitude)),
        100));
    setState(() {});
  }

  Future<void> saveBookingData() async {
    if (isOther == false && nameController.text.isEmpty) {
      return toast(language.nameFieldIsRequired);
    } else if (isOther == false && phoneController.text.isEmpty) {
      return toast(language.phoneNumberIsRequired);
    }
    // chec if payment method is not selected
    else if (paymentMethodType.isEmpty) {
      return toast("Please select payment method");
    } else if (paymentMethodType != 'cash_wallet' &&
        paymentMethodType == 'wallet' &&
        mRideTotalAmount.toDouble() >= mTotalAmount.toDouble()) {
      return toast("Insufficient wallet balance");
    }
    appStore.setLoading(true);

    Map req = {
      "start_latitude": widget.sourceLatLog!.latitude.toString(),
      "start_longitude": widget.sourceLatLog!.longitude.toString(),
      "start_address": widget.sourceTitle,
      "end_latitude": widget.destinationLatLog!.latitude.toString(),
      "end_longitude": widget.destinationLatLog!.longitude.toString(),
      "end_address": widget.destinationTitle,
      "total_amount": mRideTotalAmount.toStringAsFixed(2),
      // "total_amount": mTotalAmount,
      // "payment_type": paymentMethodType,
      "payment_type":
          paymentMethodType == 'cash_wallet' ? 'cash' : paymentMethodType,
      "delivery_charge": baseFare,
      "is_ride_for_other": isOther ? 0 : 1,
      if (isOther == false)
        "other_rider_data": {
          "name": nameController.text.trim(),
          "phone_number": phoneController.text.trim(),
        },
      "ride_type": widget.type,
      "item_type": widget.itemType,
      "item_categories": widget.deliveringType
    };

    log('$req');
    await saveRideRequest(req).then((value) async {
      // print(value.data!.riderequestId);
      rideRequestId = value.data!.orderId!;
      widget.isCurrentRequest = true;
      isBooking = true;
      appStore.setLoading(false);
      setState(() {});
      getCurrentRequest();
    }).catchError((error) {
      print(error);
      appStore.setLoading(false);
      // toast(error.toString());
    });
  }

  // mqttForUser() async {
  //   client.setProtocolV311();
  //   client.logging(on: true);
  //   client.keepAlivePeriod = 120;
  //   client.autoReconnect = true;

  //   try {
  //     await client.connect();
  //   } on NoConnectionException catch (e) {
  //     debugPrint(e.toString());
  //     client.connect();
  //   }

  //   if (client.connectionStatus!.state == MqttConnectionState.connected) {
  //     client.onSubscribed = onSubscribed;

  //     debugPrint('connected');
  //   } else if (client.connectionStatus!.state ==
  //       MqttConnectionState.disconnected) {
  //     client.connect();
  //     debugPrint('connected');
  //   } else if (client.connectionStatus!.state ==
  //       MqttConnectionState.disconnecting) {
  //     client.connect();
  //     debugPrint('connected');
  //   } else if (client.connectionStatus!.state == MqttConnectionState.faulted) {
  //     client.connect();
  //     debugPrint('connected');
  //   }

  //   void onconnected() {
  //     debugPrint('connected');
  //   }

  //   client.subscribe(
  //       mMQTT_UNIQUE_TOPIC_NAME +
  //           'ride_request_status_' +
  //           sharedPref.getInt(USER_ID).toString(),
  //       MqttQos.atLeastOnce);

  //   client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //     final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
  //     final pt =
  //         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

  //     print("Received message: $pt");

  //     print("jsonDecode(pt)['success_type']" +
  //         jsonDecode(pt)['success_type'].toString());

  //     if (jsonDecode(pt)['success_type'] == ACCEPTED ||
  //         jsonDecode(pt)['success_type'] == ARRIVING ||
  //         jsonDecode(pt)['success_type'] == ARRIVED ||
  //         jsonDecode(pt)['success_type'] == IN_PROGRESS) {
  //       isBooking = true;
  //       getCurrentRequest();
  //     } else if (jsonDecode(pt)['success_type'] == CANCELED) {
  //       launchScreen(context, DashBoardScreen(), isNewTask: true);
  //     } else if (jsonDecode(pt)['success_type'] == COMPLETED) {
  //       if (timer != null) timer!.cancel();
  //       getCurrentRequest();
  //       if (timer != null) timer!.cancel();
  //     } else if (appStore.isRiderForAnother == "1" &&
  //         jsonDecode(pt)['success_type'] == SUCCESS) {
  //       if (timer != null) timer!.cancel();
  //       launchScreen(context, DashBoardScreen(), isNewTask: true);
  //     }
  //   });
  //   client.onConnected = onconnected;
  // }

  // void onConnected() {
  //   log('Connected');
  // }

  // void onSubscribed(String topic) {
  //   log('Subscription confirmed for topic $topic');
  // }

  Future<void> getUserDetailLocation() async {
    if (rideRequest!.status != COMPLETED) {
      getUserDetail(userId: driverData!.id).then((value) {
        driverLatitudeLocation = LatLng(
            double.parse(value.userdata!.locationLat!),
            double.parse(value.userdata!.locationLong!));
        getServiceList();
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      if (timer != null) timer?.cancel();
    }
  }

  Future<void> cancelRequest() async {
    Map req = {
      "id": rideRequestId == 0 ? widget.id : rideRequestId,
      "cancel_by": RIDER,
      "status": CANCELED,
    };
    await rideRequestUpdate(
      request: req,
    )
        // rideId: rideRequestId == 0 ? widget.id : rideRequestId)
        .then((value) async {
      launchScreen(context, DashBoardScreen(), isNewTask: true);

      toast(value.message);
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void dispose() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      polylineSource = LatLng(value.latitude, value.longitude);
    });
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mSomeOnElse() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child:
                    Text(language.lblRideInformation, style: boldTextStyle()),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: nameController,
              autoFocus: false,
              isValidationRequired: false,
              textFieldType: TextFieldType.NAME,
              keyboardType: TextInputType.name,
              errorThisFieldRequired: language.thisFieldRequired,
              decoration: inputDecoration(context,
                  label: language.enterName, hintText: "Contact Name"),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: phoneController,
              autoFocus: false,
              isValidationRequired: false,
              textFieldType: TextFieldType.PHONE,
              keyboardType: TextInputType.number,
              errorThisFieldRequired: language.thisFieldRequired,
              decoration: inputDecoration(
                context,
                label: language.enterContactNumber,
                hintText: "Contact Number",
                // prefixIcon: IntrinsicHeight(
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       CountryCodePicker(
                //         padding: EdgeInsets.zero,
                //         initialSelection: countryCode,
                //         showCountryOnly: false,
                //         dialogSize: Size(MediaQuery.of(context).size.width - 60,
                //             MediaQuery.of(context).size.height * 0.6),
                //         showFlag: true,
                //         showFlagDialog: true,
                //         showOnlyCountryWhenClosed: false,
                //         alignLeft: false,
                //         textStyle: primaryTextStyle(),
                //         dialogBackgroundColor: Theme.of(context).cardColor,
                //         barrierColor: Colors.black12,
                //         dialogTextStyle: primaryTextStyle(),
                //         searchDecoration: InputDecoration(
                //           iconColor: Theme.of(context).dividerColor,
                //           enabledBorder: UnderlineInputBorder(
                //               borderSide: BorderSide(
                //                   color: Theme.of(context).dividerColor)),
                //           focusedBorder: UnderlineInputBorder(
                //               borderSide: BorderSide(color: primaryColor)),
                //         ),
                //         searchStyle: primaryTextStyle(),
                //         onInit: (c) {
                //           countryCode = c!.dialCode!;
                //         },
                //         onChanged: (c) {
                //           countryCode = c.dialCode!;
                //         },
                //       ),
                //       VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                //     ],
                //   ),
                // ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: AppButtonWidget(
              width: MediaQuery.of(context).size.width,
              text: language.done,
              textStyle: boldTextStyle(color: Colors.white),
              color: primaryColor,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // double calculateTotalAmount({required ServicesListData? serviceList}) {
  //   num? baseFare = serviceList!.baseFare;
  //   num? perDistance = serviceList.perDistance;
  //   num? perMinuteDrive = serviceList.perMinuteDrive;
  //   num? distance = serviceList.distance;
  //   num? duration = serviceList.duration;
  //   num? discountAmount = serviceList.discountAmount;
  //   log("discountAmount 0-----$discountAmount");

  //   num? distancePrice = distance! * perDistance!;

  //   num? timePrice = duration! * perMinuteDrive!;
  //   num? totalAmount = baseFare! + distancePrice + timePrice;
  //   if (totalAmount < serviceList.minimumFare!) {
  //     totalAmount = serviceList.minimumFare!;
  //   }
  //   if (promoCode.text.isNotEmpty) {
  //     log("Total amaount $totalAmount");
  //     totalAmount = totalAmount - discountAmount!;
  //   }
  //   return totalAmount.toDouble();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 40,
        leading: Visibility(
          visible: !isBooking,
          child: inkWellWidget(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: context.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: dividerColor)),
              child: Icon(Icons.close, color: context.iconColor, size: 20),
            ),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            // height: !isBooking
            //     ? (isRideSelection == false && appStore.isRiderForAnother == "1"
            //         ? MediaQuery.of(context).size.height * 0.65
            //         : MediaQuery.of(context).size.height * 0.55)
            //     : MediaQuery.of(context).size.height * 0.55,
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.25),
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.sourceLatLog ??
                    LatLng(sharedPref.getDouble(LATITUDE)!,
                        sharedPref.getDouble(LONGITUDE)!),
                zoom: 20,
              ),
              markers: markers,
              mapType: MapType.normal,
              polylines: _polyLines,
            ),
          ),
          // bookRideWidget(),
          !isBooking
              ? bookRideWidget()
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(defaultRadius),
                          topRight: Radius.circular(defaultRadius))),
                  child: rideRequest != null
                      ? rideRequest!.status == NEW_RIDE_REQUESTED
                          ? BookingWidget(
                              type: widget.type,
                              itemType: widget.itemType,
                              deliveringType: widget.deliveringType,
                              sourceLatLog: widget.sourceLatLog,
                              destinationLatLog: widget.destinationLatLog,
                              sourceTitle: widget.sourceTitle,
                              destinationTitle: widget.destinationTitle,
                              // id: widget.id,
                              id: rideRequestId == 0
                                  ? widget.id
                                  : rideRequestId,
                              isLast: true,
                              onRideAccepted: () {
                                getCurrentRequest();
                              })
                          : rideRequest!.status == ACCEPTED ||
                                  rideRequest!.status == PICKINGUP ||
                                  rideRequest!.status == PICKUP ||
                                  rideRequest!.status == INPROGRESS ||
                                  rideRequest!.status == COMPLETED
                              ? RideAcceptWidget(
                                  rideRequest: rideRequest,
                                  driverData: driverData,
                                  onRideAccepted: () {
                                    getCurrentRequest();
                                  },
                                )
                              : BookingWidget(
                                  type: widget.type,
                                  itemType: widget.itemType,
                                  deliveringType: widget.deliveringType,
                                  sourceLatLog: widget.sourceLatLog,
                                  destinationLatLog: widget.destinationLatLog,
                                  sourceTitle: widget.sourceTitle,
                                  destinationTitle: widget.destinationTitle,
                                  id: rideRequestId == 0
                                      ? widget.id
                                      : rideRequestId,
                                  isLast: true,
                                  onRideAccepted: () {
                                    getCurrentRequest();
                                  })
                      : BookingWidget(
                          type: widget.type,
                          itemType: widget.itemType,
                          deliveringType: widget.deliveringType,
                          sourceLatLog: widget.sourceLatLog,
                          destinationLatLog: widget.destinationLatLog,
                          sourceTitle: widget.sourceTitle,
                          destinationTitle: widget.destinationTitle,
                          id: rideRequestId == 0 ? widget.id : rideRequestId,
                          isLast: true,
                          onRideAccepted: () {
                            getCurrentRequest();
                          },
                        )
                  // child: RideAcceptWidget(
                  //     rideRequest: rideRequest, driverData: driverData)
                  // : BookingWidget(
                  //     type: widget.type,
                  //     itemType: widget.itemType,
                  //     deliveringType: widget.deliveringType,
                  //     sourceLatLog: widget.sourceLatLog,
                  //     destinationLatLog: widget.destinationLatLog,
                  //     sourceTitle: widget.sourceTitle,
                  //     destinationTitle: widget.destinationTitle,
                  //     id: rideRequestId == 0 ? widget.id : rideRequestId,
                  //     isLast: true),
                  // child: BookingWidget(
                  //     id: rideRequestId == 0 ? widget.id : rideRequestId,
                  //     isLast: true),
                  ),

          Observer(builder: (context) {
            return Visibility(
                visible: appStore.isLoading, child: loaderWidget());
          }),
        ],
      ),
    );
  }

  Widget bookRideWidget() {
    return Stack(
      children: [
        Visibility(
          visible: true,
          // visible: serviceList.isEmpty,
          // visible: serviceList.isNotEmpty,
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.35,
            height: isRideSelection == false
                ? MediaQuery.of(context).size.height * 0.33
                : MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(defaultRadius),
                    topRight: Radius.circular(defaultRadius))),
            child: SingleChildScrollView(
              child: isRideSelection == false
                  ? riderSelectionWidget()
                  : serviceSelectWidget(),
              // child: riderSelectionWidget() ,
              // child: isRideSelection == false && appStore.isRiderForAnother == "1" ? riderSelectionWidget() : serviceSelectWidget(),
            ),
          ),
        ),
        // Visibility(
        //   visible: !appStore.isLoading && serviceList.isEmpty,
        //   child: Container(
        //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         emptyWidget(),
        //         Text(language.servicesNotFound, style: boldTextStyle()),
        //         SizedBox(height: 8),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget riderSelectionWidget() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 16),
              height: 5,
              width: 70,
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(defaultRadius)),
            ),
          ),
          Text(language.whoWillBeSeated, style: primaryTextStyle(size: 18)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              inkWellWidget(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: textSecondaryColorGlobal, width: 1)),
                            padding: EdgeInsets.all(12),
                            child: Image.asset(ic_add_user, fit: BoxFit.fill),
                          ),
                          if (!isOther)
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(language.lblSomeoneElse, style: primaryTextStyle()),
                    ],
                  ),
                  onTap: () {
                    isOther = false;
                    showDialog(
                      context: context,
                      builder: (_) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            contentPadding: EdgeInsets.all(0),
                            content: mSomeOnElse(),
                          );
                        });
                      },
                    ).then((value) {
                      setState(() {});
                    });
                    setState(() {});
                  }),
              SizedBox(width: 30),
              inkWellWidget(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child:
                                // child: appStore.userProfile != null ||
                                //         appStore.userProfile.validate().isNotEmpty
                                //     ? commonCachedNetworkImage(
                                //         appStore.userProfile.validate(),
                                //         height: 70,
                                //         width: 70,
                                //         fit: BoxFit.cover)
                                //     :
                                Image.asset(ic_profile, height: 70, width: 70),
                            // child: commonCachedNetworkImage(
                            //     // us
                            //     sharedPref.getString(USER_PROFILE_PHOTO),
                            //     height: 70,
                            //     width: 70,
                            //     fit: BoxFit.cover),
                          ),
                          if (isOther)
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                    Text("Me", style: primaryTextStyle()),
                    ],
                  ),
                  onTap: () {
                    isOther = true;
                    setState(() {});
                  })
            ],
          ),
          SizedBox(height: 12),
          Text(language.lblWhoRidingMsg, style: secondaryTextStyle()),
          SizedBox(height: 8),
          AppButtonWidget(
            color: primaryColor,
            onTap: () async {
              if (!isOther) {
                if (nameController.text.isEmptyOrNull ||
                    phoneController.text.isEmptyOrNull) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          content: mSomeOnElse(),
                        );
                      });
                    },
                  ).then((value) {
                    setState(() {});
                  });
                } else {
                  isRideSelection = true;
                }
              } else {
                isRideSelection = true;
              }
              // isRideSelection = true;
              setState(() {});
            },
            text: language.lblNext,
            textStyle: boldTextStyle(color: Colors.white),
            width: MediaQuery.of(context).size.width,
          ),
        ],
      ),
    );
  }

  Widget serviceSelectWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 8, top: 16),
            height: 5,
            width: 70,
            decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(defaultRadius)),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ride Information", style: boldTextStyle()),
              SizedBox(height: 4),
              Text("Total Amount - $currencyNameConst ${mRideTotalAmount.toStringAsFixed(2)}",
                  style: boldTextStyle()),
            ],
          ),
        ),
        inkWellWidget(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Observer(builder: (context) {
                    return Stack(
                      children: [
                        AlertDialog(
                          contentPadding: EdgeInsets.all(16),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(language.paymentMethod,
                                        style: boldTextStyle()),
                                    inkWellWidget(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.close,
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text("Choose your preferred payment method",
                                    style: secondaryTextStyle()),
                                Text(isOther.toString(),
                                    style: secondaryTextStyle()),
                                // isOther == false
                                //     ? RadioListTile(
                                //         contentPadding: EdgeInsets.zero,
                                //         dense: true,
                                //         controlAffinity:
                                //             ListTileControlAffinity.trailing,
                                //         activeColor: primaryColor,
                                //         value: 'cash',
                                //         groupValue: 'cash',
                                //         title: Text(language.cash,
                                //             style: boldTextStyle()),
                                //         onChanged: (String? val) {},
                                //       )
                                //     :
                                Column(
                                  children: cashList.map((e) {
                                    return RadioListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      activeColor: primaryColor,
                                      value: e,
                                      groupValue:
                                          paymentMethodType == 'cash_wallet'
                                              ? 'cash'
                                              : paymentMethodType,
                                      title: Text(paymentStatus(e),
                                          style: boldTextStyle()),
                                      onChanged: (String? val) {
                                        paymentMethodType = val!;
                                        setState(() {});
                                      },
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 16),
                                AppButtonWidget(
                                  width: MediaQuery.of(context).size.width,
                                  text: language.confirm,
                                  textStyle: boldTextStyle(color: Colors.white),
                                  color: primaryColor,
                                  onTap: () {
                                    // getNewService();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Observer(builder: (context) {
                          return Visibility(
                              visible: appStore.isLoading,
                              child: loaderWidget());
                        }),
                      ],
                    );
                  });
                });
              },
            ).then((value) {
              setState(() {});
            });
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
                border: Border.all(color: dividerColor),
                borderRadius: BorderRadius.circular(defaultRadius)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.paymentVia, style: secondaryTextStyle(size: 12)),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(defaultRadius)),
                      child: Icon(Icons.wallet_outlined,
                          size: 20, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isOther == false
                                      ? language.cash
                                      : paymentMethodType == 'cash_wallet'
                                          ? language.cash
                                          : paymentStatus(paymentMethodType),
                                  style: boldTextStyle(size: 14),
                                ),
                              ),
                              if (paymentMethodType != 'cash_wallet' &&
                                  paymentMethodType == 'wallet' &&
                                  mRideTotalAmount.toDouble() >=
                                      mTotalAmount.toDouble())
                                inkWellWidget(
                                  onTap: () {
                                    launchScreen(context, WalletScreen())
                                        .then((value) {
                                      init();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: dividerColor),
                                        color: primaryColor,
                                        borderRadius: radius()),
                                    child: Text(language.addMoney,
                                        style: primaryTextStyle(
                                            size: 14, color: Colors.white)),
                                  ),
                                )
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                              paymentMethodType != 'cash_wallet'
                                  ? language.forInstantPayment
                                  : language.lblPayWhenEnds,
                              style: secondaryTextStyle(size: 12)),
                          if (paymentMethodType != 'cash_wallet' &&
                              paymentMethodType == 'wallet' &&
                              mRideTotalAmount.toDouble() >=
                                  mTotalAmount.toDouble())
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                  "Amount needed is $currencyNameConst $mRideTotalAmount for this delivery ride and ${language.lblLessWalletAmount} ",
                                  style: boldTextStyle(
                                      size: 12,
                                      color: Colors.red,
                                      letterSpacing: 0.5,
                                      weight: FontWeight.w500)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: AppButtonWidget(
            onTap: () {
              saveBookingData();
            },
            text: language.bookNow,
            textStyle: boldTextStyle(color: Colors.white),
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ],
    );
  }
}
