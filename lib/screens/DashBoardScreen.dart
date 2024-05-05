import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../utils/Extensions/context_extension.dart';
import '../components/drawer_component.dart';
import '../screens/ReviewScreen.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../main.dart';
import '../model/CurrentRequestModel.dart';
import '../model/NearByDriverListModel.dart';
import '../model/TextModel.dart';
import '../network/RestApis.dart';
import '../screens/RidePaymentDetailScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import '../utils/images.dart';
import 'LocationPermissionScreen.dart';
import 'NewEstimateRideListWidget.dart';
import 'NotificationScreen.dart';
import 'RiderWidget.dart';

class DashBoardScreen extends StatefulWidget {
  final String? type;
  final String? itemType;
  final String? deliveringType;

  DashBoardScreen({this.type, this.itemType, this.deliveringType});

  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

class DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LatLng? sourceLocation;

  List<TexIModel> list = getBookList();
  List<Marker> markers = [];
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  OnRideRequest? servicesListData;

  double cameraZoom = 17.0, cameraTilt = 1;

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
    super.initState();
    locationPermission();
    getCurrentRequest();
    afterBuildCreated(() {
      init();
    });
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
              type: widget.type,
              itemType: widget.itemType,
              deliveringType: widget.deliveringType,
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    LiveStream().on(CHANGE_LANGUAGE, (p0) {
      setState(() {});
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: DrawerComponent(),
      body: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
            markers: markers.map((e) => e).toSet(),
            polylines: _polyLines,
            initialCameraPosition: CameraPosition(
              target: sourceLocation ??
                  LatLng(sharedPref.getDouble(LATITUDE)!,
                      sharedPref.getDouble(LONGITUDE)!),
              zoom: cameraZoom,
              tilt: cameraTilt,
              bearing: cameraBearing,
            ),
          ),
          Positioned(
            top: context.statusBarHeight + 10,
            right: 8,
            left: 8,
            child: topWidget(),
          ),
          SlidingUpPanel(
            padding: EdgeInsets.all(16),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(defaultRadius),
                topRight: Radius.circular(defaultRadius)),
            backdropTapClosesPanel: true,
            minHeight: 140,
            maxHeight: 140,
            panel: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 12),
                    height: 5,
                    width: 70,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius)),
                  ),
                ),
                // Text("Where are you delivering to?",
                Text(
                    widget.type == 'Send'
                        ? 'Send from?'
                        : 'Pickup from?',
                    style: primaryTextStyle()),
                SizedBox(height: 12),
                AppTextField(
                  autoFocus: false,
                  readOnly: true,
                  onTap: () async {
                    if (await checkPermission()) {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(defaultRadius),
                              topRight: Radius.circular(defaultRadius)),
                        ),
                        context: context,
                        builder: (_) {
                          return RiderWidget(
                              type: widget.type,
                              itemType: widget.itemType,
                              deliveringType: widget.deliveringType,
                              title: sourceLocationTitle);
                        },
                      );
                    }
                  },
                  textFieldType: TextFieldType.EMAIL,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Feather.search),
                    filled: false,
                    isDense: true,
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: dividerColor)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: dividerColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: dividerColor)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: Colors.red)),
                    alignLabelWithHint: true,
                    hintText: language.enterYourDestination,
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          Visibility(
            visible: appStore.isLoading,
            child: loaderWidget(),
          ),
        ],
      ),
    );
  }

  Widget topWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        inkWellWidget(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Image.asset(
              "assets/icons/hamburger.png",
              height: 20,
              width: 20,
            ),
          ),
        ),
        // inkWellWidget(
        //   onTap: () {
        //     launchScreen(context, NotificationScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
        //   },
        //   child: Container(
        //     padding: EdgeInsets.all(4),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       boxShadow: [
        //         BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1),
        //       ],
        //       borderRadius: BorderRadius.circular(defaultRadius),
        //     ),
        //     child: Icon(Ionicons.notifications_outline),
        //   ),
        // ),
      ],
    );
  }
}
