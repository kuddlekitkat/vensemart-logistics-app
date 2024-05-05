import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:taxi_booking/screens/DashBoardScreen.dart';
import 'package:taxi_booking/screens/SignInScreen.dart';
// import 'package:taxi_booking/utils/validator.dart';
// import '../utils/Extensions/context_extension.dart';
// import '../utils/Extensions/StringExtensions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:taxi_booking/screens/WhatToDeliver.dart';
import 'package:taxi_booking/utils/Extensions/StringExtensions.dart';
import 'dart:io';
import '../../main.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import '../utils/images.dart';
import 'TermsConditionScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // AuthServices authService = AuthServices();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode confirmPass = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;

  String? deviceToken;

  var deviceInfo;
  String? device = '';

  // String countryCode = defaultCountryCode;

  @override
  void initState() {
    super.initState();
    deviceInfo = DeviceInfoPlugin();
    // try and print deviceInfo to see all required stuffs then get the device name and pass it to the registration function
    _getId();
    init();
  }

  void init() async {
    await saveOneSignalPlayerId().then((value) {
      // deviceToken = value;
      // print('deviceToken: $value.toString()');
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      device = iosDeviceInfo.identifierForVendor;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      device = androidDeviceInfo.id;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return device;
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      if (mIsCheck) {
        appStore.setLoading(true);
        // get device token from shared preference player id
        final deviceToken = await sharedPref.getString(PLAYER_ID);

        Map req = {
          'type': '1',
          'device_id': device!,
          'device_type': Platform.isIOS ? 'iPhone' : 'android',
          'device_name': deviceInfo.toString(),
          'device_token': deviceToken!,
          // 'device_token': deviceToken!,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'mobile': phoneController.text.trim(),
          'password': passController.text.trim(),
          'state': 'FCT',
          'town': 'Abuja'
        };

        log(req);

        await signUpApi(req).then((value) {
          appStore.setLoading(false);
          if (value != null) {
            if (value.status == 1) {
              toast(value.message);
              launchScreen(context, WhatToDeliver());
            } else {
              toast(value.message);
            }
          }
        }).catchError((error) {
          appStore.setLoading(false);
        });
      } else {
        toast("Please accept terms and conditions");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return const Color(0xff1456f1);
      }
      return Colors.grey;
    }

    return Scaffold(
      backgroundColor: const Color(0xff1456f1),
      // resizeToAvoidBottomInset: false,
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 12.0, bottom: 4.0),
              child: const Text(
                'Signup',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    color: Colors.white),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.59,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Observer(builder: (context) {
                    return Visibility(
                      visible: appStore.isLoading,
                      child: loaderWidget(),
                    );
                  }),
                  Container(
                    height: MediaQuery.of(context).size.height / 15,
                    margin: const EdgeInsets.all(12.0),
                    child: AppTextField(
                      controller: nameController,
                      focus: nameFocus,
                      nextFocus: emailFocus,
                      autoFocus: false,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: errorThisFieldRequired,
                      decoration: inputDecoration(
                        context,
                        label: 'Full Name',
                        hintText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_rounded),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),

                  Container(
                    height: MediaQuery.of(context).size.height / 15,
                    margin: const EdgeInsets.all(12.0),
                    child: AppTextField(
                      controller: emailController,
                      focus: emailFocus,
                      nextFocus: phoneFocus,
                      autoFocus: false,
                      textFieldType: TextFieldType.EMAIL,
                      keyboardType: TextInputType.emailAddress,
                      errorThisFieldRequired: errorThisFieldRequired,
                      decoration: inputDecoration(
                        context,
                        label: language.email,
                        hintText: 'email',
                        prefixIcon: const Icon(Icons.email_rounded),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),

                  Container(
                    height: MediaQuery.of(context).size.height / 15,
                    margin: const EdgeInsets.all(12.0),
                    child: AppTextField(
                      controller: phoneController,
                      textFieldType: TextFieldType.PHONE,
                      focus: phoneFocus,
                      nextFocus: passFocus,
                      decoration: inputDecoration(
                        context,
                        label: language.phoneNumber,
                        hintText: '08107463265',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Container(
                          height: 49,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(234, 234, 234, 3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 10),
                          child: Image.asset(
                            'assets/images/nigeria_flag.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.trim().isEmpty)
                          return errorThisFieldRequired;
                        return null;
                      },
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 15,
                    margin: const EdgeInsets.all(12.0),
                    child: AppTextField(
                      controller: passController,
                      focus: passFocus,
                      autoFocus: false,
                      textFieldType: TextFieldType.PASSWORD,
                      errorThisFieldRequired: errorThisFieldRequired,
                      decoration: inputDecoration(
                        context,
                        label: language.password,
                        hintText: 'password',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) return errorThisFieldRequired;
                        if (value.length < passwordLengthGlobal)
                          return language.passwordLength;
                        return null;
                      },
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height / 26.5,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          value: mIsCheck,
                          onChanged: (bool? value) {
                            setState(() {
                              mIsCheck = value!;
                              print(mIsCheck);
                            });
                          },
                        ),
                        const Text(
                          'By checking the box,agree to our ',
                          style: TextStyle(fontSize: 10),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context!,
                            //   MaterialPageRoute(
                            //     builder: (context) => TermsScreen(),
                            //   ),
                            // );
                          },
                          child: const Text(
                            'terms and conditions',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Center(
                    child: AppButtonWidget(
                      width: MediaQuery.of(context).size.width * 0.9,
                      text: language.signUp,
                      onTap: () async {
                        register();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  // const SizedBox(
                  //   height: 10.0,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText('Already have an account?',
                          style: primaryTextStyle().copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          )),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          ' Sign in',
                          style: primaryTextStyle().copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1456f1),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       SingleChildScrollView(
    //         padding: EdgeInsets.all(16),
    //         child: Form(
    //           key: formKey,
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               SizedBox(height: context.statusBarHeight + 16),
    //               ClipRRect(borderRadius: radius(50), child: Image.asset(ic_app_logo, width: 100, height: 100)),
    //               SizedBox(height: 16),
    //               Text(language.createAccount, style: boldTextStyle(size: 22)),
    //               RichText(
    //                 text: TextSpan(
    //                   children: [
    //                     TextSpan(text: 'Sign up to get started ', style: primaryTextStyle(size: 14)),
    //                     TextSpan(text: '🚗', style: primaryTextStyle(size: 20)),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(height: 32),
    //               Row(
    //                 children: [
    //                   Expanded(
    //                     child: AppTextField(
    //                       controller: firstController,
    //                       focus: firstNameFocus,
    //                       nextFocus: lastNameFocus,
    //                       autoFocus: false,
    //                       textFieldType: TextFieldType.NAME,
    //                       errorThisFieldRequired: errorThisFieldRequired,
    //                       decoration: inputDecoration(context, label: language.firstName),
    //                     ),
    //                   ),
    //                   SizedBox(width: 20),
    //                   Expanded(
    //                     child: AppTextField(
    //                       controller: lastNameController,
    //                       focus: lastNameFocus,
    //                       nextFocus: userNameFocus,
    //                       autoFocus: false,
    //                       textFieldType: TextFieldType.OTHER,
    //                       errorThisFieldRequired: errorThisFieldRequired,
    //                       decoration: inputDecoration(context, label: language.lastName),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               if (widget.socialLogin != true) SizedBox(height: 20),
    //               if (widget.socialLogin != true)
    //                 AppTextField(
    //                   controller: userNameController,
    //                   focus: userNameFocus,
    //                   nextFocus: emailFocus,
    //                   autoFocus: false,
    //                   textFieldType: TextFieldType.USERNAME,
    //                   errorThisFieldRequired: errorThisFieldRequired,
    //                   decoration: inputDecoration(context, label: language.userName),
    //                 ),
    //               SizedBox(height: 20),
    //               AppTextField(
    //                 controller: emailController,
    //                 focus: emailFocus,
    //                 nextFocus: phoneFocus,
    //                 autoFocus: false,
    //                 textFieldType: TextFieldType.EMAIL,
    //                 keyboardType: TextInputType.emailAddress,
    //                 errorThisFieldRequired: errorThisFieldRequired,
    //                 decoration: inputDecoration(context, label: language.email),
    //               ),
    //               if (widget.socialLogin != true) SizedBox(height: 20),
    //               if (widget.socialLogin != true)
    //                 AppTextField(
    //                   controller: phoneController,
    //                   textFieldType: TextFieldType.PHONE,
    //                   focus: phoneFocus,
    //                   nextFocus: passFocus,
    //                   decoration: inputDecoration(
    //                     context,
    //                     label: language.phoneNumber,
    //                     prefixIcon: IntrinsicHeight(
    //                       child: Row(
    //                         mainAxisSize: MainAxisSize.min,
    //                         children: [
    //                           CountryCodePicker(
    //                             padding: EdgeInsets.zero,
    //                             initialSelection: countryCode,
    //                             showCountryOnly: false,
    //                             dialogSize: Size(MediaQuery.of(context).size.width - 60, MediaQuery.of(context).size.height * 0.6),
    //                             showFlag: true,
    //                             showFlagDialog: true,
    //                             showOnlyCountryWhenClosed: false,
    //                             alignLeft: false,
    //                             textStyle: primaryTextStyle(),
    //                             dialogBackgroundColor: Theme.of(context).cardColor,
    //                             barrierColor: Colors.black12,
    //                             dialogTextStyle: primaryTextStyle(),
    //                             searchDecoration: InputDecoration(
    //                               iconColor: Theme.of(context).dividerColor,
    //                               enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
    //                               focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
    //                             ),
    //                             searchStyle: primaryTextStyle(),
    //                             onInit: (c) {
    //                               countryCode = c!.dialCode!;
    //                             },
    //                             onChanged: (c) {
    //                               countryCode = c.dialCode!;
    //                             },
    //                           ),
    //                           VerticalDivider(color: Colors.grey.withOpacity(0.5)),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   validator: (value) {
    //                     if (value!.trim().isEmpty) return errorThisFieldRequired;
    //                     return null;
    //                   },
    //                 ),
    //               if (widget.socialLogin != true) SizedBox(height: 20),
    //               if (widget.socialLogin != true)
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                       child: AppTextField(
    //                         controller: passController,
    //                         focus: passFocus,
    //                         autoFocus: false,
    //                         nextFocus: confirmPass,
    //                         textFieldType: TextFieldType.PASSWORD,
    //                         errorThisFieldRequired: errorThisFieldRequired,
    //                         decoration: inputDecoration(context, label: language.password),
    //                         validator: (String? value) {
    //                           if (value!.isEmpty) return errorThisFieldRequired;
    //                           if (value.length < passwordLengthGlobal) return language.passwordLength;
    //                           return null;
    //                         },
    //                       ),
    //                     ),
    //                     if (widget.socialLogin != true) SizedBox(width: 16),
    //                     if (widget.socialLogin != true)
    //                       Expanded(
    //                         child: AppTextField(
    //                           controller: confirmPassController,
    //                           focus: confirmPass,
    //                           autoFocus: false,
    //                           textFieldType: TextFieldType.PASSWORD,
    //                           errorThisFieldRequired: errorThisFieldRequired,
    //                           decoration: inputDecoration(context, label: language.confirmPassword),
    //                           validator: (String? value) {
    //                             if (value!.isEmpty) return errorThisFieldRequired;
    //                             if (value.length < passwordLengthGlobal) return language.passwordLength;
    //                             if (value.trim() != passController.text.trim()) return language.bothPasswordNotMatch;
    //                             return null;
    //                           },
    //                         ),
    //                       ),
    //                   ],
    //                 ),
    //               SizedBox(height: 16),
    //               Row(
    //                 children: [
    //                   SizedBox(
    //                     height: 18,
    //                     width: 18,
    //                     child: Checkbox(
    //                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //                       activeColor: primaryColor,
    //                       value: isAcceptedTc,
    //                       shape: RoundedRectangleBorder(borderRadius: radius(4)),
    //                       onChanged: (v) async {
    //                         isAcceptedTc = v!;
    //                         setState(() {});
    //                       },
    //                     ),
    //                   ),
    //                   SizedBox(width: 16),
    //                   Expanded(
    //                     child: RichText(
    //                       text: TextSpan(children: [
    //                         TextSpan(text: '${language.iAgreeToThe} ', style: secondaryTextStyle()),
    //                         TextSpan(
    //                           text: language.termsConditions,
    //                           style: boldTextStyle(color: primaryColor, size: 14),
    //                           recognizer: TapGestureRecognizer()
    //                             ..onTap = () {
    //                               if (widget.termsConditionUrl != null && widget.termsConditionUrl!.isNotEmpty) {
    //                                 launchScreen(context, TermsConditionScreen(title: language.termsConditions, subtitle: widget.termsConditionUrl), pageRouteAnimation: PageRouteAnimation.Slide);
    //                               } else {
    //                                 toast(language.txtURLEmpty);
    //                               }
    //                             },
    //                         ),
    //                         TextSpan(text: ' & ', style: secondaryTextStyle()),
    //                         TextSpan(
    //                           text: language.privacyPolicy,
    //                           style: boldTextStyle(color: primaryColor, size: 14),
    //                           recognizer: TapGestureRecognizer()
    //                             ..onTap = () {
    //                               if (widget.privacyPolicyUrl != null && widget.privacyPolicyUrl!.isNotEmpty) {
    //                                 launchScreen(context, TermsConditionScreen(title: language.privacyPolicy, subtitle: widget.privacyPolicyUrl), pageRouteAnimation: PageRouteAnimation.Slide);
    //                               } else {
    //                                 toast(language.txtURLEmpty);
    //                               }
    //                             },
    //                         ),
    //                       ]),
    //                       textAlign: TextAlign.left,
    //                     ),
    //                   )
    //                 ],
    //               ),
    //               SizedBox(height: 32),
    //               AppButtonWidget(
    //                 width: MediaQuery.of(context).size.width,
    //                 text: language.signUp,
    //                 onTap: () async {
    //                   register();
    //                 },
    //               ),
    //               SizedBox(height: 20),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Positioned(top: context.statusBarHeight + 4, child: BackButton()),
    // Observer(builder: (context) {
    //   return Visibility(
    //     visible: appStore.isLoading,
    //     child: loaderWidget(),
    //   );
    // })
    //     ],
    //   ),
    //   bottomNavigationBar: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       Align(
    //         alignment: Alignment.center,
    //         child: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Text(language.alreadyHaveAnAccount, style: primaryTextStyle()),
    //             SizedBox(width: 8),
    //             inkWellWidget(
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //               child: Text(language.logIn, style: boldTextStyle(color: primaryColor)),
    //             ),
    //           ],
    //         ),
    //       ),
    //       SizedBox(height: 16)
    //     ],
    //   ),
    // );
  }
}
