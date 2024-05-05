import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart' as payTab;
import 'package:flutter_paytabs_bridge/IOSThemeConfiguration.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkApms.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutterwave_standard/view/view_utils.dart';
import 'package:http/http.dart' as http;

// import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
import 'package:paytm/paytm.dart';
import '../screens/DashBoardScreen.dart';
import '../utils/Extensions/StringExtensions.dart';

import '../../main.dart';
import '../../network/NetworkUtils.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../model/PaymentListModel.dart';
import '../model/StripePayModel.dart';
import '../utils/images.dart';

class PaymentScreen extends StatefulWidget {
  final int? amount;
  final Function()? onCallback; // Callback function

  PaymentScreen({this.amount, this.onCallback});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  List<PaymentModel> paymentList = [
    PaymentModel(
        id: 1,
        title: 'PayStack',
        type: PAYMENT_TYPE_PAYSTACK,
        gatewayLogo:
            'https://raw.githubusercontent.com/PaystackHQ/wordpress-payment-forms-for-paystack/master/icon.png'),
    // PaymentModel(
    //     id: 2,
    //     title: 'FlutterWave',
    //     type: PAYMENT_TYPE_FLUTTERWAVE,
    //     gatewayLogo: 'https://www.flutterwave.com/images/logo-dark.png'),
  ];

  String? selectedPaymentType;
  // flutterWavePublicKey,
  // flutterWaveSecretKey,
  // flutterWaveEncryptionKey,
  //     stripPaymentKey,
  //     stripPaymentPublishKey,
  //     payPalTokenizationKey,
  //     payTabsProfileId,
  //     payTabsServerKey,
  //     payTabsClientKey,
  //     mercadoPagoPublicKey,
  //     mercadoPagoAccessToken,
  //     myFatoorahToken,
  //     paytmMerchantId,
  //     paytmMerchantKey;

  String payStackPublicKey = "pk_test_6e485e016ddc8ebcb4d644653fc60ea83d9c9e4e";

  bool isTestType = true;
  bool loading = false;
  final plugin = PaystackPlugin();
  CheckoutMethod method = CheckoutMethod.card;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // await paymentListApiCall();

    if (paymentList.any((element) => element.type == PAYMENT_TYPE_PAYSTACK)) {
      plugin.initialize(publicKey: payStackPublicKey.validate());
    }
  }

  /// Get Payment Gateway Api Call
  // Future<void> paymentListApiCall() async {
  //   appStore.setLoading(true);
  //   await getPaymentList().then((value) {
  //     appStore.setLoading(false);
  //     paymentList.addAll(value.data!);
  //     selectedPaymentType = paymentList.first.type;
  //     if (paymentList.isNotEmpty) {
  //       paymentList.forEach((element) {
  //         if (element.type == PAYMENT_TYPE_PAYSTACK) {
  //           payStackPublicKey = element.isTest == 1
  //               ? "pk_test_6e485e016ddc8ebcb4d644653fc60ea83d9c9e4e"
  //               : "pk_test_6e485e016ddc8ebcb4d644653fc60ea83d9c9e4e";
  //         } else if (element.type == PAYMENT_TYPE_FLUTTERWAVE) {
  //           flutterWavePublicKey = element.isTest == 1
  //               ? element.testValue!.publicKey
  //               : element.liveValue!.publicKey;
  //           flutterWaveSecretKey = element.isTest == 1
  //               ? element.testValue!.secretKey
  //               : element.liveValue!.secretKey;
  //           flutterWaveEncryptionKey = element.isTest == 1
  //               ? element.testValue!.encryptionKey
  //               : element.liveValue!.encryptionKey;
  //         }
  //       });
  //     }
  //     setState(() {});
  //   }).catchError((error) {
  //     appStore.setLoading(false);
  //     log('${error.toString()}');
  //   });
  // }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!, toastLength: Toast.LENGTH_SHORT);
  //   paymentConfirm();
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message!, toastLength: Toast.LENGTH_SHORT);
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  // }

  Future<void> paymentConfirm(String ref) async {
    Map req = {
      "user_id": sharedPref.getInt(USER_ID),
      "type": "credit",
      "amount": widget.amount,
      // "transaction_type": "topup",
      "reference": ref,
      "currency": "NGN",
    };
    appStore.isLoading = true;
    await saveWallet(req).then((value) {
      widget.onCallback!();
      appStore.isLoading = false;
      Navigator.pop(context);
      // launchScreen(context, RiderDashBoardScreen(), isNewTask: true);
    }).catchError((error) {
      appStore.isLoading = false;

      log(error.toString());
    });
  }

  ///PayStack Payment
  void payStackPayment(BuildContext context) async {
    Charge charge = Charge()
      ..amount = (widget.amount! * 100).toInt() // In base currency
      ..email = sharedPref.getString(USER_EMAIL)
      ..currency = "NGN"; // Base currency code;

    charge.reference = _getReference();

    try {
      CheckoutResponse response = await plugin.checkout(context,
          method: method, charge: charge, fullscreen: false);
      payStackUpdateStatus(response.reference, response.message);
      if (response.message == 'Success') {
        String ref = response.reference!;
        paymentConfirm(ref);
      } else {
        toast(language.paymentFailed);
      }
    } catch (e) {
      payStackShowMessage(language.checkConsoleForError);
      rethrow;
    }
  }

  payStackUpdateStatus(String? reference, String message) {
    payStackShowMessage(message, const Duration(seconds: 7));
  }

  void payStackShowMessage(String message,
      [Duration duration = const Duration(seconds: 4)]) {
    toast(message);
    log(message);
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// FlutterWave Payment
  // void flutterWaveCheckout() async {
  //   final customer = Customer(
  //       name: sharedPref.getString(USER_NAME).validate(),
  //       phoneNumber: sharedPref.getString(CONTACT_NUMBER).validate(),
  //       email: sharedPref.getString(USER_EMAIL).validate());

  //   final Flutterwave flutterwave = Flutterwave(
  //     context: context,
  //     publicKey: flutterWavePublicKey.validate(),
  //     currency: appStore.currencyName.toLowerCase(),
  //     redirectUrl: "https://www.google.com",
  //     txRef: DateTime.now().millisecond.toString(),
  //     amount: widget.amount.toString(),
  //     customer: customer,
  //     paymentOptions: "card, payattitude",
  //     customization: Customization(title: "Test Payment"),
  //     isTestMode: isTestType,
  //   );
  //   final ChargeResponse response = await flutterwave.charge();
  //   if (response.status == 'successful') {
  //     paymentConfirm();
  //     print("${response.toJson()}");
  //   } else {
  //     FlutterwaveViewUtils.showToast(context, language.transactionFailed);
  //   }
  // }

  // /// Mercado Pago payment
  // void mercadoPagoPayment() async {
  //   var body = json.encode({
  //     "items": [
  //       {"title": "Vensemart Logistics", "description": "Vensemart Logistics", "quantity": 1, "currency_id": appStore.currencyName.toUpperCase(), "unit_price": widget.amount}
  //     ],
  //     "payer": {"email": sharedPref.getString(USER_EMAIL)}
  //   });
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('https://api.mercadopago.com/checkout/preferences?access_token=${mercadoPagoAccessToken.toString()}'),
  //       body: body,
  //       headers: {'Content-type': "application/json"},
  //     );
  //     String? preferenceId = json.decode(response.body)['id'];
  //     if (preferenceId != null) {
  //       PaymentResult result = await MercadoPagoMobileCheckout.startCheckout(
  //         mercadoPagoPublicKey!,
  //         preferenceId,
  //       );
  //       if (result.status == 'approved') {
  //         paymentConfirm();
  //       }
  //     } else {
  //       toast(json.decode(response.body)['message']);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.payment,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: paymentList.map((e) {
                return inkWellWidget(
                  onTap: () {
                    selectedPaymentType = e.type;
                    setState(() {});
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //backgroundColor: Colors.white,
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(
                          color: selectedPaymentType == e.type
                              ? primaryColor
                              : dividerColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Image.network(e.gatewayLogo!, width: 40, height: 40),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(e.title.validate(),
                              style: primaryTextStyle(), maxLines: 2),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Observer(builder: (context) {
          //   return Visibility(
          //     visible: appStore.isLoading,
          //     child: loaderWidget(),
          //   );
          // }),
          // !appStore.isLoading && paymentList.isEmpty
          //     ? emptyWidget()
          //     : SizedBox(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: Visibility(
          visible: paymentList.isNotEmpty,
          child: AppButtonWidget(
            text: language.pay,
            onTap: () {
              if (selectedPaymentType == PAYMENT_TYPE_PAYSTACK) {
                payStackPayment(context);
              } else {
                toast("Payment Gateway not available");
              }
              // } else if (selectedPaymentType == PAYMENT_TYPE_FLUTTERWAVE) {
              //   flutterWaveCheckout();
              // }
            },
          ),
        ),
      ),
    );
  }
}
