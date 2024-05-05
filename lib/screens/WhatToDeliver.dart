import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_booking/main.dart';
import 'package:taxi_booking/model/CurrentRequestModel.dart';
import 'package:taxi_booking/model/NearByDriverListModel.dart';
import 'package:taxi_booking/model/TextModel.dart';
import 'package:taxi_booking/network/RestApis.dart';
import 'package:taxi_booking/screens/DashBoardScreen.dart';
import 'package:taxi_booking/screens/LocationPermissionScreen.dart';
import 'package:taxi_booking/utils/Colors.dart';
import 'package:taxi_booking/utils/Common.dart';
import 'package:taxi_booking/utils/Constants.dart';
import 'package:taxi_booking/utils/DataProvider.dart';
import 'package:taxi_booking/utils/Extensions/AppButtonWidget.dart';
import 'package:taxi_booking/utils/Extensions/StringExtensions.dart';
import 'package:taxi_booking/utils/Extensions/app_common.dart';
import 'package:taxi_booking/utils/images.dart';
import 'NewEstimateRideListWidget.dart';

class WhatToDeliver extends StatefulWidget {
  const WhatToDeliver({super.key});

  @override
  State<WhatToDeliver> createState() => _WhatToDeliverState();
}

class _WhatToDeliverState extends State<WhatToDeliver>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final _tabs = [
    Tab(text: 'Send'),
    Tab(text: 'Pickup'),
  ];

  LatLng? sourceLocation;

  List<TexIModel> list = getBookList();
  List<Marker> markers = [];
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  OnRideRequest? servicesListData;

  double cameraZoom = 15.0, cameraTilt = 1;

  double cameraBearing = 30;
  int onTapIndex = 0;

  int selectIndex = 0;
  String sourceLocationTitle = '';

  late StreamSubscription<ServiceStatus> serviceStatusStream;

  LocationPermission? permissionData;

  late BitmapDescriptor riderIcon;
  late BitmapDescriptor driverIcon;
  List<NearByDriverListModel>? nearDriverModel;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    locationPermission();
    getCurrentRequest();
    afterBuildCreated(() {
      init();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  void init() async {
    getCurrentUserLocation();
    riderIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), MultipleDriver);

    polylinePoints = PolylinePoints();
  }

  Future<void> getCurrentUserLocation() async {
    if (permissionData != LocationPermission.denied) {
      final geoPosition = await Geolocator.getCurrentPosition(
              timeLimit: Duration(seconds: 30),
              desiredAccuracy: LocationAccuracy.high)
          .catchError((error) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
      });
      sourceLocation = LatLng(geoPosition.latitude, geoPosition.longitude);
      List<Placemark>? placemarks = await placemarkFromCoordinates(
          geoPosition.latitude, geoPosition.longitude);
      sharedPref.setString(COUNTRY,
          placemarks[0].isoCountryCode.validate(value: defaultCountry));

      Placemark place = placemarks[0];
      if (place != null) {
        sourceLocationTitle =
            "${place.name != null ? place.name : place.subThoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
        polylineSource = LatLng(geoPosition.latitude, geoPosition.longitude);
      }
      markers.add(
        Marker(
          markerId: MarkerId('Order Detail'),
          position: sourceLocation!,
          draggable: true,
          infoWindow: InfoWindow(title: sourceLocationTitle, snippet: ''),
          icon: riderIcon,
        ),
      );
      startLocationTracking();
      getNearByDriverList(latLng: sourceLocation).then((value) async {
        value.data!.forEach((element) {
          markers.add(
            Marker(
              markerId: MarkerId('Driver${element.id}'),
              position: LatLng(double.parse(element.latitude!.toString()),
                  double.parse(element.longitude!.toString())),
              infoWindow: InfoWindow(title: '${element.name}', snippet: ''),
              icon: driverIcon,
            ),
          );
        });
        setState(() {});
      });
      setState(() {});
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
    }
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequest().then((value) {
      servicesListData = value.rideRequest ?? value.onRideRequest;
      if (servicesListData != null) {
        if (servicesListData!.status != COMPLETED) {
          launchScreen(
            getContext,
            isNewTask: true,
            NewEstimateRideListWidget(
              type: servicesListData!.rideType,
              itemType: _selectedType,
              deliveringType: _selectedDelivering,
              sourceLatLog: LatLng(
                  double.parse(servicesListData!.startLatitude!),
                  double.parse(servicesListData!.startLongitude!)),
              destinationLatLog: LatLng(
                  double.parse(servicesListData!.endLatitude!),
                  double.parse(servicesListData!.endLongitude!)),
              sourceTitle: servicesListData!.startAddress!,
              destinationTitle: servicesListData!.endAddress!,
              isCurrentRequest: true,
              // servicesId: servicesListData!.serviceId,
              id: servicesListData!.orderId,
            ),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
          );
        } else if (servicesListData!.status == COMPLETED) {
          //   servicesListData!.isRiderRated == 0) {
          // launchScreen(
          //     context,
          //     ReviewScreen(
          //         rideRequest: servicesListData!, driverData: value.driver),
          //     pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
          //     isNewTask: true);
        }
      }
      // else if (value.payment != null &&
      //     value.payment!.paymentStatus != COMPLETED) {
      //   launchScreen(context,
      //       RidePaymentDetailScreen(rideId: value.payment!.rideRequestId),
      //       pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
      //       isNewTask: true);
      // }
    }).catchError((error) {
      log(error.toString());
    });
  }

  Future<void> locationPermission() async {
    serviceStatusStream =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        launchScreen(navigatorKey.currentState!.overlay!.context,
            LocationPermissionScreen());
      } else if (status == ServiceStatus.enabled) {
        getCurrentUserLocation();

        if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
          Navigator.pop(navigatorKey.currentState!.overlay!.context);
        }
      }
    }, onError: (error) {
      //
    });
  }

  Future<void> startLocationTracking() async {
    Map req = {
      // "status": "active",
      "latitude": sourceLocation!.latitude.toString(),
      "longitude": sourceLocation!.longitude.toString(),
    };

    await updateStatus(req).then((value) {}).catchError((error) {
      log(error);
    });
  }

  List<String> _delivering = [
    'Food',
    'Clothes',
    'Furniture',
    'Documents',
  ];
  List<String> itemType = [
    'Fragile',
    'Non-Fragile',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // padding: const EdgeInsets.all(8.0),
          child:
              // SingleChildScrollView(
              //   child:
              Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                width: 300,
                height: 89,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bike-animate.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                // height: ,
                // width: 350,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  // padding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: primaryColor),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  onTap: (_) {
                    setState(() {
                      _selectedType = null;
                      _selectedDelivering = null;
                    });
                  },
                  tabs: [
                    Tab(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(child: Text('Send')),
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: double.infinity,
                        child: Center(child: Text('Pickup')),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          // drop down for selecting item type
                          Container(
                              width: 350,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF6F8FE),
                                  border: Border.all(color: Color(0xFFE7E7E7)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: _dropDown(
                                underline: Container(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Color(0xFF9C9C9C),
                                  size: 30,
                                ),
                                delivingText: 'Select Item Type',
                                style: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                                dropdownColor: Colors.white,
                                iconEnabledColor: Colors.black,
                                delivering: itemType,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              width: 350,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF6F8FE),
                                  border: Border.all(color: Color(0xFFE7E7E7)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: _dropDown1(
                                underline: Container(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Color(0xFF9C9C9C),
                                  size: 30,
                                ),
                                delivingText: 'Select product category',
                                style: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                                dropdownColor: Colors.white,
                                iconEnabledColor: Colors.black,
                                delivering: _delivering,
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            width: 350,
                            height: 79,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              border: Border.all(color: Color(0xFF7A7C7F)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF6F8FE),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_outlined,
                                    color: Color(0xFF7A7C7F),
                                  ),
                                ),
                                SizedBox(
                                  width: 300,
                                  child: Text(
                                      'Vensemart riders do not transport any form of illegal or unlawful products.As such items will be reported to the authorities. '),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          AppButtonWidget(
                            width: 350,
                            radius: BorderRadius.circular(10.0),
                            text: 'Proceed',
                            color: primaryColor,
                            textColor: whiteColor,
                            onTap: () {
                              if (_selectedType == null ||
                                  _selectedDelivering == null) {
                                toast(
                                    'Please select item type and product category');
                              } else {
                                launchScreen(
                                  context,
                                  DashBoardScreen(
                                    type: 'Send',
                                    itemType: _selectedType!,
                                    deliveringType: _selectedDelivering!,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          // drop down for selecting item type
                          Container(
                              width: 350,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF6F8FE),
                                  border: Border.all(color: Color(0xFFE7E7E7)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: _dropDown(
                                underline: Container(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Color(0xFF9C9C9C),
                                  size: 30,
                                ),
                                delivingText: 'Select Item Type',
                                style: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                                dropdownColor: Colors.white,
                                iconEnabledColor: Colors.black,
                                delivering: itemType,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              width: 350,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF6F8FE),
                                  border: Border.all(color: Color(0xFFE7E7E7)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: _dropDown1(
                                underline: Container(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Color(0xFF9C9C9C),
                                  size: 30,
                                ),
                                delivingText: 'Select product category',
                                style: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
                                dropdownColor: Colors.white,
                                iconEnabledColor: Colors.black,
                                delivering: _delivering,
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            width: 350,
                            height: 79,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              border: Border.all(color: Color(0xFF7A7C7F)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF6F8FE),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_outlined,
                                    color: Color(0xFF7A7C7F),
                                  ),
                                ),
                                SizedBox(
                                  width: 300,
                                  child: Text(
                                      'Vensemart riders do not transport any form of illegal or unlawful products.As such items will be reported to the authorities. '),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          AppButtonWidget(
                            width: 350,
                            radius: BorderRadius.circular(10.0),
                            text: 'Proceed',
                            color: primaryColor,
                            textColor: whiteColor,
                            onTap: () {
                              if (_selectedType == null ||
                                  _selectedDelivering == null) {
                                toast(
                                    'Please select item type and product category');
                              } else {
                                launchScreen(
                                  context,
                                  DashBoardScreen(
                                    type: 'Pickup',
                                    itemType: _selectedType!,
                                    deliveringType: _selectedDelivering!,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ),
        ),
      ),
    );
  }

  String? _selectedType;
  String? _selectedDelivering;

  Widget _dropDown1({
    Widget? underline,
    Widget? icon,
    String? delivingText,
    TextStyle? style,
    TextStyle? hintStyle,
    Color? dropdownColor,
    Color? iconEnabledColor,
    List<String>? delivering,
  }) =>
      DropdownButton<String>(
          isExpanded: true,
          value: _selectedDelivering,
          underline: underline,
          icon: icon,
          dropdownColor: dropdownColor,
          style: style,
          iconEnabledColor: iconEnabledColor,
          iconSize: 42,
          onChanged: (String? newValue) {
            setState(() {
              _selectedDelivering = newValue!;
            });
          },
          hint: Text(delivingText ?? "Select ", style: hintStyle),
          items: delivering!
              .map((type) =>
                  DropdownMenuItem<String>(value: type, child: Text(type)))
              .toList());
  Widget _dropDown({
    Widget? underline,
    Widget? icon,
    String? delivingText,
    TextStyle? style,
    TextStyle? hintStyle,
    Color? dropdownColor,
    Color? iconEnabledColor,
    List<String>? delivering,
  }) =>
      DropdownButton<String>(
          isExpanded: true,
          value: _selectedType,
          underline: underline,
          icon: icon,
          dropdownColor: dropdownColor,
          style: style,
          iconEnabledColor: iconEnabledColor,
          iconSize: 42,
          onChanged: (String? newValue) {
            setState(() {
              _selectedType = newValue!;
            });
          },
          hint: Text(delivingText ?? "Select ", style: hintStyle),
          items: delivering!
              .map((type) =>
                  DropdownMenuItem<String>(value: type, child: Text(type)))
              .toList());
}
