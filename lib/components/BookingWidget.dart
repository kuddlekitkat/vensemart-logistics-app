import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:taxi_booking/components/RideAcceptWidget.dart';
import 'package:taxi_booking/screens/NewEstimateRideListWidget.dart';
import 'package:taxi_booking/screens/WhatToDeliver.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../main.dart';
import '../network/RestApis.dart';
import '../screens/DashBoardScreen.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import 'CancelOrderDialog.dart';

class BookingWidget extends StatefulWidget {
  final String? type;
  final String? itemType;
  final String? deliveringType;
  final LatLng? sourceLatLog;
  final LatLng? destinationLatLog;
  final String? sourceTitle;
  final String? destinationTitle;
  // bool isCurrentRequest;
  final int? id;
  final bool isLast;
  final Function()? onRideAccepted; // Callback function

  BookingWidget(
      {required this.type,
      required this.itemType,
      required this.deliveringType,
      required this.sourceLatLog,
      required this.destinationLatLog,
      required this.sourceTitle,
      required this.destinationTitle,
      // required this.isCurrentRequest = false,
      required this.id,
      this.isLast = false,
      required this.onRideAccepted});

  // BookingWidget({required this.id, this.isLast = false});

  @override
  BookingWidgetState createState() => BookingWidgetState();
}

class BookingWidgetState extends State<BookingWidget> {
  final int timerMaxSeconds = 10 * 60;

  int currentSeconds = 0;
  int duration = 0;
  int count = 0;
  Timer? timer;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String get timerText =>
      '${((duration - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((duration - currentSeconds) % 60).toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    print(REMAINING_TIME);
    print(IS_TIME);
    if (sharedPref.getString(IS_TIME) == null) {
      duration = timerMaxSeconds;
      startTimeout();
      sharedPref.setString(IS_TIME,
          DateTime.now().add(Duration(seconds: timerMaxSeconds)).toString());
      sharedPref.setString(REMAINING_TIME, timerMaxSeconds.toString());
    } else {
      duration = DateTime.parse(sharedPref.getString(IS_TIME)!)
          .difference(DateTime.now())
          .inSeconds;
      if (duration > 0) {
        startTimeout();
      } else {
        sharedPref.remove(IS_TIME);
        duration = timerMaxSeconds;
        setState(() {});
      }
    }
  }

  startTimeout() {
    var duration2 = Duration(seconds: 1);
    timer = Timer.periodic(duration2, (timer) {
      setState(
        () {
          currentSeconds = timer.tick;
          count++;
          if (count >= 20) {
            int data = int.parse(sharedPref.getString(REMAINING_TIME)!);
            data = data - count;
            Map req = {
              'max_time_for_find_driver_for_ride_request': data,
            };

            rideRequestUpdate(request: req, rideId: widget.id).then((value) {
              log(value.message);
              if (value.status == 1) {
                // toast(value.message);

                if (value.data!.onRideRequest!.status == CANCELED) {
                  sharedPref.remove(REMAINING_TIME);
                  sharedPref.remove(IS_TIME);
                  launchScreen(context, WhatToDeliver());
                  toast("Ride is auto cancelled");
                } else if (value.data!.onRideRequest!.status == ACCEPTED ||
                    value.data!.onRideRequest!.status == PICKINGUP ||
                    value.data!.onRideRequest!.status == PICKUP ||
                    value.data!.onRideRequest!.status == INPROGRESS ||
                    value.data!.onRideRequest!.status == ARRIVED ||
                    value.data!.onRideRequest!.status == IN_PROGRESS) {
                  // sharedPref.remove(REMAINING_TIME);
                  // sharedPref.remove(IS_TIME);
                  // timer.cancel();
                  widget.onRideAccepted!();

                  // launchScreen(
                  //     context,
                  //     RideAcceptWidget(
                  //       driverData: value.data!.driver,
                  //       rideRequest: value.data!.onRideRequest,
                  //     ));
                }
              }
            }).catchError((error) {
              log(error.toString());
            });

            sharedPref.setString(REMAINING_TIME, data.toString());
            count = 0;
          }
          if (timer.tick >= duration) {
            timer.cancel();
            Map req = {
              'status': CANCELED,
              'cancel_by': AUTO,
              "reason": "Ride is auto cancelled",
            };
            rideRequestUpdate(request: req, rideId: widget.id).then((value) {
              launchScreen(context, WhatToDeliver());
              sharedPref.remove(REMAINING_TIME);
              sharedPref.remove(IS_TIME);
              toast("Ride is auto cancelled");
            }).catchError((error) {
              log(error.toString());
            });
          }
        },
      );
    });
  }

  Future<void> cancelRequest(String? reason) async {
    Map req = {
      "id": widget.id,
      "cancel_by": RIDER,
      "status": CANCELED,
      "reason": reason,
    };
    await rideRequestUpdate(request: req, rideId: widget.id)
        .then((value) async {
      if (widget.isLast) {
        launchScreen(getContext, WhatToDeliver(), isNewTask: true);
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
      }

      toast(value.message);
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.lookingForNearbyDrivers, style: boldTextStyle()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration:
                    BoxDecoration(color: primaryColor, borderRadius: radius(8)),
                child:
                    Text(timerText, style: boldTextStyle(color: Colors.white)),
              )
            ],
          ),
          SizedBox(height: 8),
          Lottie.asset('images/booking.json',
              height: 100,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain),
          SizedBox(height: 20),
          Text(language.weAreLookingForNearDriversAcceptsYourRide,
              style: primaryTextStyle(), textAlign: TextAlign.center),
          SizedBox(height: 16),
          AppButtonWidget(
            radius: BorderRadius.circular(50),
            width: MediaQuery.of(context).size.width,
            text: language.cancel,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CancelOrderDialog(
                    onCancel: (reason) {
                      sharedPref.remove(REMAINING_TIME);
                      sharedPref.remove(IS_TIME);
                      cancelRequest(reason);
                    },
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
