import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:taxi_booking/screens/WhatToDeliver.dart';
import '../screens/RidePaymentDetailScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

import '../main.dart';
import '../model/CurrentRequestModel.dart';
import '../network/RestApis.dart';
import 'DashBoardScreen.dart';

class ReviewScreen extends StatefulWidget {
  final Driver? driverData;
  final OnRideRequest rideRequest;

  ReviewScreen({this.driverData, required this.rideRequest});

  @override
  ReviewScreenState createState() => ReviewScreenState();
}

class ReviewScreenState extends State<ReviewScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController reviewController = TextEditingController();
  TextEditingController tipController = TextEditingController();

  num rattingData = 0;
  int currentIndex = -1;
  bool isMoreTip = false;
  bool isTipShow = true;

  OnRideRequest? servicesListData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    mqttForUser();
    appStore.walletPresetTipAmount.isNotEmpty
        ? appStore.setWalletTipAmount(appStore.walletPresetTipAmount)
        : appStore.setWalletTipAmount('10|20|50');
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequest().then((value) {
      servicesListData = value.onRideRequest;
      if (value.onRideRequest == null) {
        launchScreen(context, WhatToDeliver(),
            isNewTask: true,
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      } else {
        launchScreen(context, RidePaymentDetailScreen(),
            isNewTask: true,
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      }
    }).catchError((error) {
      log(error.toString());
    });
  }

  Future<void> userReviewData() async {
    if (formKey.currentState!.validate()) {
      hideKeyboard(context);
      if (rattingData == 0) return toast(language.pleaseSelectRating);
      formKey.currentState!.save();
      appStore.setLoading(true);
      Map req = {
        "ride_request_id": widget.rideRequest.id,
        "rating": rattingData,
        "comment": reviewController.text.trim(),
        if (tipController.text.isNotEmpty) "tips": tipController.text,
      };
      await ratingReview(request: req).then((value) {
        appStore.setLoading(false);
        getCurrentRequest();
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  mqttForUser() async {
    client.setProtocolV311();
    client.logging(on: true);
    client.keepAlivePeriod = 120;
    client.autoReconnect = true;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      debugPrint(e.toString());
      client.connect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.onSubscribed = onSubscribed;

      debugPrint('connected');
    } else if (client.connectionStatus!.state ==
        MqttConnectionState.disconnected) {
      client.connect();
      debugPrint('connected');
    } else if (client.connectionStatus!.state ==
        MqttConnectionState.disconnecting) {
      client.connect();
      debugPrint('connected');
    } else if (client.connectionStatus!.state == MqttConnectionState.faulted) {
      client.connect();
      debugPrint('connected');
    }

    void onconnected() {
      debugPrint('connected');
    }

    client.subscribe(
        mMQTT_UNIQUE_TOPIC_NAME +
            'ride_request_status_' +
            sharedPref.getInt(USER_ID).toString(),
        MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (jsonDecode(pt)['success_type'] == 'payment_status_message') {
        isTipShow = false;
        setState(() {});
      }
    });

    client.onConnected = onconnected;
  }

  void onConnected() {
    log('Connected');
  }

  void onSubscribed(String topic) {
    log('Subscription confirmed for topic $topic');
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(language.howWasYourRide,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: commonCachedNetworkImage(
                            // "data:image/png;base64,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",
                            "https://www.pngall.com/wp-content/uploads/12/Driver-PNG-Picture.png",

                            // widget.driverData!.profileImage.validate(),
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('${widget.driverData!.name.validate()}',
                              style: boldTextStyle()),
                          SizedBox(height: 4),
                          Text('${widget.driverData!.email.validate()}',
                              style: primaryTextStyle()),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  RatingBar.builder(
                    direction: Axis.horizontal,
                    glow: false,
                    allowHalfRating: false,
                    wrapAlignment: WrapAlignment.spaceBetween,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, _) =>
                        Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      rattingData = rating;
                    },
                  ),
                  SizedBox(height: 16),
                  Text(language.addReviews, style: boldTextStyle()),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: reviewController,
                    decoration: inputDecoration(context,
                        label: language.writeYourComments),
                    textFieldType: TextFieldType.NAME,
                    minLines: 2,
                    maxLines: 5,
                  ),
                  SizedBox(height: 16),
                  if (widget.rideRequest.paymentStatus != PAID && isTipShow)
                    Row(
                      children: [
                        Text(language.wouldYouLikeToAddTip,
                            style: boldTextStyle()),
                        SizedBox(width: 16),
                        if (tipController.text.isNotEmpty)
                          inkWellWidget(
                            onTap: () {
                              currentIndex = -1;
                              tipController.clear();
                              setState(() {});
                            },
                            child: Icon(Icons.clear_all,
                                size: 30, color: primaryColor),
                          )
                      ],
                    ),
                  if (widget.rideRequest.paymentStatus != PAID && isTipShow)
                    SizedBox(height: 10),
                  if (widget.rideRequest.paymentStatus != PAID && isTipShow)
                    Wrap(
                      spacing: 10,
                      runSpacing: 16,
                      children:
                          appStore.walletPresetTipAmount.split('|').map((e) {
                        return inkWellWidget(
                          onTap: () {
                            currentIndex = appStore.walletPresetTipAmount
                                .split('|')
                                .indexOf(e);
                            tipController.text = e;
                            tipController.selection =
                                TextSelection.fromPosition(
                                    TextPosition(offset: e.toString().length));
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 10),
                            decoration: BoxDecoration(
                                color: currentIndex ==
                                        appStore.walletPresetTipAmount
                                            .split('|')
                                            .indexOf(e)
                                    ? primaryColor
                                    : primaryColor.withOpacity(0.4),
                                borderRadius:
                                    BorderRadius.circular(defaultRadius)),
                            child: Text(
                                appStore.currencyPosition == LEFT
                                    ? '${appStore.currencyCode} $e'
                                    : '$e ${appStore.currencyCode}',
                                style: primaryTextStyle(
                                    color: Colors.white, size: 14)),
                          ),
                        );
                      }).toList(),
                    ),
                  if (widget.rideRequest.paymentStatus != PAID && isTipShow)
                    SizedBox(height: 16),
                  if (widget.rideRequest.paymentStatus != PAID && isTipShow)
                    Column(
                      children: [
                        Visibility(
                          visible: isMoreTip,
                          child: AppTextField(
                            textFieldType: TextFieldType.PHONE,
                            controller: tipController,
                            isValidationRequired: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: inputDecoration(context,
                                label: language.addMoreTip),
                          ),
                        ),
                        if (!isMoreTip)
                          inkWellWidget(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius)),
                                child: Text(language.addMore,
                                    style: boldTextStyle(
                                        color: Colors.white, size: 14)),
                              ),
                              onTap: () {
                                isMoreTip = true;
                                setState(() {});
                              }),
                      ],
                    ),
                  SizedBox(height: 16),
                  AppButtonWidget(
                    text: language.continueD,
                    width: MediaQuery.of(context).size.width,
                    onTap: () {
                      userReviewData();
                    },
                  )
                ],
              ),
            ),
          ),
          Observer(builder: (context) {
            return Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            );
          })
        ],
      ),
    );
  }
}
