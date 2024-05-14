import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:taxi_booking/model/UserDetailModel.dart';
import 'package:taxi_booking/screens/WhatToDeliver.dart';
import '../main.dart';
import '../model/CurrentRequestModel.dart';
import '../model/LoginResponse.dart';
import '../network/RestApis.dart';
import '../screens/ChatScreen.dart';
import '../screens/ReviewScreen.dart';
import '../screens/DashBoardScreen.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/Common.dart';
import '../screens/AlertScreen.dart';
import 'CancelOrderDialog.dart';

class RideAcceptWidget extends StatefulWidget {
  final Driver? driverData;
  final OnRideRequest? rideRequest;
  // callback function
  final Function()? onRideAccepted;

  RideAcceptWidget(
      {this.driverData, this.rideRequest, required this.onRideAccepted});

  @override
  RideAcceptWidgetState createState() => RideAcceptWidgetState();
}

class RideAcceptWidgetState extends State<RideAcceptWidget> {
  UserData? userData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await getUserDetail(userId: widget.rideRequest!.driverId).then((value) {
      sharedPref.remove(IS_TIME);
      appStore.setLoading(false);
      userData = value.userdata;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });

    // switch (widget.rideRequest!.status) {
    //   case ACCEPTED:
    //     // call the callback function every 40 seconds
    //     Timer.periodic(Duration(seconds: 40), (timer) {
    //       widget.onRideAccepted!();
    //     });
    //     break;
    //   case PICKINGUP:
    //     // call the callback function every 40 seconds
    //     Timer.periodic(Duration(seconds: 40), (timer) {
    //       widget.onRideAccepted!();
    //     });
    //     break;
    //   case PICKUP:
    //     // call the callback function every 40 seconds
    //     Timer.periodic(Duration(seconds: 40), (timer) {
    //       widget.onRideAccepted!();
    //     });
    //   default:
    // }

    if (widget.rideRequest!.status == ACCEPTED) {
      // call the callback function every 40 seconds
      Timer.periodic(Duration(seconds: 20), (timer) {
        widget.onRideAccepted!();
      });
    } else if (widget.rideRequest!.status == PICKINGUP) {
      // call the callback function every 40 seconds
      Timer.periodic(Duration(seconds: 20), (timer) {
        widget.onRideAccepted!();
      });
    } else if (widget.rideRequest!.status == INPROGRESS) {
      // call the callback function every 40 seconds
      Timer.periodic(Duration(seconds: 10), (timer) {
        widget.onRideAccepted!();
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> cancelRequest(String reason) async {
    Map req = {
      "id": widget.rideRequest!.id,
      "cancel_by": RIDER,
      "status": CANCELED,
      "reason": reason,
    };
    await rideRequestUpdate(request: req, rideId: widget.rideRequest!.orderId)
        .then((value) async {
      launchScreen(getContext, WhatToDeliver(), isNewTask: true);

      toast(value.message);
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              height: 5,
              width: 70,
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(defaultRadius)),
            ),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              // decoration:
              //     BoxDecoration(color: primaryColor, borderRadius: radius()),
              child: Text(
                  statusName(status: widget.rideRequest!.status.validate()),
                  style: boldTextStyle(color: primaryColor)),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.driverData!.name.validate(),
                        style: boldTextStyle()),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(language.lblCarNumberPlate,
                            style: secondaryTextStyle()),
                        Text(
                            '(${widget.driverData!.vehicledetails!.vehicleNumber.validate()})',
                            style: secondaryTextStyle()),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //     border: Border.all(color: dividerColor),
                //     borderRadius: radius(defaultRadius)),
                child: Text('${language.otp} ${widget.rideRequest!.otp ?? ''}',
                    style: boldTextStyle()),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: commonCachedNetworkImage(
                    "https://www.pngall.com/wp-content/uploads/12/Driver-PNG-Picture.png",
                    // widget.driverData!.profileImage.validate(),
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${widget.driverData!.name.validate()} ',
                        // Text('John Driver ',
                        style: boldTextStyle()),
                    SizedBox(height: 2),
                    Text('${widget.driverData!.email.validate()}',
                        // Text('johndriver@email.com',
                        style: secondaryTextStyle()),
                  ],
                ),
              ),
              inkWellWidget(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.all(0),
                        content: AlertScreen(
                          rideId: widget.rideRequest!.id,
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: dividerColor),
                      borderRadius: radius(defaultRadius)),
                  child: Text(language.sos, style: boldTextStyle(size: 14)),
                ),
              ),
              SizedBox(width: 8),
              // inkWellWidget(
              //   onTap: () {
              //     // launchScreen(context, ChatScreen(userData: userData), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              //   },
              //   child: chatCallWidget(Icons.chat_bubble_outline),
              // ),
              SizedBox(width: 8),
              inkWellWidget(
                onTap: () {
                  launchUrl(Uri.parse('tel:${widget.driverData!.mobile}'),
                      mode: LaunchMode.externalApplication);
                },
                child: chatCallWidget(Icons.call),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.near_me, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          widget.rideRequest!.startAddress ?? ''.validate(),
                          style: primaryTextStyle(size: 14),
                          maxLines: 2)),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 8),
                  SizedBox(
                    height: 24,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      lineThickness: 1,
                      dashLength: 2,
                      dashColor: primaryColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(widget.rideRequest!.endAddress ?? '',
                          style: primaryTextStyle(size: 14), maxLines: 2)),
                ],
              ),
            ],
          ),
          Visibility(
            visible: widget.rideRequest!.status == COMPLETED,
            child: Column(
              children: [
                SizedBox(height: 8),
                AppButtonWidget(
                  text: "Complete Ride / Order Again",
                  // text: language.driverReview,
                  width: MediaQuery.of(context).size.width,
                  textStyle: boldTextStyle(color: Colors.white),
                  color: primaryColor,
                  onTap: () {
                    Map req = {
                      "status": "riderated",
                      "is_ride_rated": 1,
                    };
                    print(widget.rideRequest!.orderId);
                    print("request: $req");
                    rideRequestUpdate(
                            request: req, rideId: widget.rideRequest!.orderId)
                        .then((value) {
                      launchScreen(getContext, WhatToDeliver(),
                          isNewTask: true);
                      toast(value.message);
                    }).catchError((error) {
                      log(error.toString());
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          if (widget.rideRequest!.status == ACCEPTED ||
              widget.rideRequest!.status == INPROGRESS ||
              widget.rideRequest!.status == ARRIVED)
            AppButtonWidget(
              width: MediaQuery.of(context).size.width,
              text: language.cancelRide,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CancelOrderDialog(
                      onCancel: (reason) {
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

  Widget chatCallWidget(IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          // color: scaffoldColorDark,
          borderRadius: BorderRadius.circular(defaultRadius)),
      child: Icon(icon, size: 18, color: primaryColor),
    );
  }
}
