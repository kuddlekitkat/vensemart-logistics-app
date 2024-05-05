import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:taxi_booking/model/UserDetailModel.dart';
import 'package:taxi_booking/screens/WhatToDeliver.dart';
// import 'package:taxi_booking/utils/validator.dart';
// import '../utils/Extensions/context_extension.dart';
// import '../model/LoginResponse.dart';
import '../utils/Extensions/StringExtensions.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../components/OTPDialog.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../screens/ForgotPasswordScreen.dart';
// import '../../service/AuthService1.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
// import '../service/AuthService.dart';
import '../utils/images.dart';
import 'SignUpScreen.dart';
import 'DashBoardScreen.dart';
// import 'TermsConditionScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserModel userModel = UserModel();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // AuthServices authService = AuthServices();
  // GoogleAuthServices googleAuthService = GoogleAuthServices();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;
  String? privacyPolicy;
  String? termsCondition;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // appSetting();
    await saveOneSignalPlayerId().then((value) {});
    mIsCheck = sharedPref.getBool(REMEMBER_ME) ?? false;
    if (mIsCheck) {
      emailController.text = sharedPref.getString(USER_EMAIL).validate();
      passController.text = sharedPref.getString(USER_PASSWORD).validate();
    }
  }

  String device = '';

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      device = iosDeviceInfo.identifierForVendor!;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      device = androidDeviceInfo.id;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return device;
  }

  late bool _passwordVisible;

  Future<void> logIn() async {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      appStore.setLoading(true);
      Map req = {
        'type': 1,
        'device_id': await _getId(),
        'device_type': Platform.isIOS ? 'ios' : 'android',
        'device_name': device,
        'device_token': sharedPref.getString(PLAYER_ID) ?? '',
        // 'device_token': 'no_token_yet',
        'username': emailController.text.trim(),
        'password': passController.text.trim(),
        // "player_id": sharedPref.getString(PLAYER_ID).validate(),
      };
      log(req);
      await logInApi(req).then((value) {
        userModel = value;
        if (value.status == 1) {
          launchScreen(context, WhatToDeliver());
        } else {
          toast(value.message);
        }

        // auth
        //     .signInWithEmailAndPassword(
        //         email: emailController.text, password: passController.text)
        //     .then((value) {
        //   sharedPref.setString(UID, value.user!.uid);
        //   updateProfileUid();
        //   appStore.setLoading(false);
        //   launchScreen(context, DashBoardScreen(),
        //       isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        // }).catchError((e) {
        //   if (e.toString().contains('user-not-found')) {
        //     authService.signUpWithEmailPassword(
        //       context,
        //       mobileNumber: userModel.contactNumber,
        //       email: userModel.email,
        //       fName: userModel.firstName,
        //       lName: userModel.lastName,
        //       userName: userModel.username,
        //       password: passController.text,
        //       userType: RIDER,
        //     );
        //   } else {
        //     launchScreen(context, DashBoardScreen(),
        //         isNewTask: true,
        //         pageRouteAnimation: PageRouteAnimation.Slide);
        //   }
        //   log(e.toString());
        // });

        appStore.setLoading(false);
      }).catchError((error) {
        appStore.isLoading = false;
        toast(error.toString());
      });
    }
  }

  // Future<void> appSetting() async {
  //   await getAppSettingApi().then((value) {
  //     if (value.privacyPolicyModel!.value != null)
  //       privacyPolicy = value.privacyPolicyModel!.value;
  //     if (value.termsCondition!.value != null)
  //       termsCondition = value.termsCondition!.value;
  //   }).catchError((error) {
  //     log(error.toString());
  //   });
  // }

  // void googleSignIn() async {
  //   hideKeyboard(context);
  //   appStore.setLoading(true);

  //   await googleAuthService.signInWithGoogle(context).then((value) async {
  //     appStore.setLoading(false);
  //   }).catchError((e) {
  //     appStore.setLoading(false);
  //     toast(e.toString());
  //     print(e.toString());
  //   });
  // }

  // appleLoginApi() async {
  //   hideKeyboard(context);
  //   appStore.setLoading(true);
  //   await appleLogIn().then((value) {
  //     appStore.setLoading(false);
  //   }).catchError((e) {
  //     appStore.setLoading(false);
  //     toast(e.toString());
  //   });
  // }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // key: scaffoldKey,
      backgroundColor: const Color(0xff1456f1),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: Image.asset(
                    'assets/images/re2ei_V.png',
                  ).image,
                ),
                gradient: LinearGradient(
                  colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
                  stops: [0, 1],
                  begin: AlignmentDirectional(0, 1),
                  end: AlignmentDirectional(0, -1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 250),
                child: SelectionArea(
                  child: Text(
                    'Welcome\nBack',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(1, 1),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.60,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                padding: EdgeInsetsDirectional.fromSTEB(15, 50, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Observer(builder: (context) {
                      return Visibility(
                        visible: appStore.isLoading,
                        child: loaderWidget(),
                      );
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: AutoSizeText(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 9,
                      child: AppTextField(
                        controller: emailController,
                        nextFocus: passFocus,
                        autoFocus: false,
                        textFieldType: TextFieldType.EMAIL,
                        keyboardType: TextInputType.emailAddress,
                        errorThisFieldRequired: language.thisFieldRequired,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            filled: true,
                            hintText: 'iaarondikko@gmail.com',
                            // prefixIcon: const Icon(Icons.email_rounded),
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey.withOpacity(0.4)),
                            fillColor: const Color.fromRGBO(246, 248, 254, 1)),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: AutoSizeText('Password'),
                    ),
                    AppTextField(
                      controller: passController,
                      focus: passFocus,
                      autoFocus: false,
                      textFieldType: TextFieldType.PASSWORD,
                      errorThisFieldRequired: language.thisFieldRequired,
                      decoration: inputDecoration(context,
                          label: language.password,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          hintText: '********'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 2.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot password?',
                              style: primaryTextStyle().copyWith(
                                  color: Color(0xff1456f1),
                                  fontSize: 1.5 *
                                      MediaQuery.of(context).size.height *
                                      0.01,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: AppButtonWidget(
                        width: MediaQuery.of(context).size.width * 0.8,
                        text: language.logIn,
                        onTap: () async {
                          logIn();
                          // launchScreen(context, DashBoardScreen());
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),

                    // GestureDetector(
                    //   onTap: () => signIn(context),
                    //   child: Consumer<ProviderServices>(
                    //     builder: (_, value, __) => Center(
                    //       child: Container(
                    //         height: screenHeight / 14.4,
                    //         width: screenWidth / 1.10,
                    //         decoration: BoxDecoration(
                    //           color: const Color(0xff1456f1),
                    //           borderRadius: BorderRadius.circular(90.0),
                    //         ),
                    //         child: value.isLoading == true
                    //             ? const SpinKitCircle(
                    //                 color: Colors.white,
                    //               )
                    //             : const Center(
                    //                 child: Text(
                    //                   'Sign in',
                    //                   style: TextStyle(
                    //                       color: Colors.white,
                    //                       fontSize: 20.0,
                    //                       fontWeight: FontWeight.bold),
                    //                 ),
                    //               ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 10.0,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AutoSizeText('Don\'t have an account? ',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 18.0)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Signup',
                            style: primaryTextStyle().copyWith(
                              color: Color(0xff1456f1),
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                            // style: TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 20.0,
                            //     color: Color(0xff1456f1)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       Form(
    //         key: formKey,
    //         child: SingleChildScrollView(
    //           padding: EdgeInsets.all(16.0),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               SizedBox(height: context.statusBarHeight + 16),
    //               ClipRRect(borderRadius: radius(50), child: Image.asset(ic_app_logo, width: 100, height: 100)),
    //               SizedBox(height: 16),

    //               Text(language.welcome, style: boldTextStyle(size: 22)),
    //               RichText(
    //                 text: TextSpan(
    //                   children: [
    //                     TextSpan(text: '${language.signContinue} ', style: primaryTextStyle(size: 14)),
    //                     TextSpan(text: '🚗', style: primaryTextStyle(size: 20)),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(height: 40),
    //               AppTextField(
    //                 controller: emailController,
    //                 nextFocus: passFocus,
    //                 autoFocus: false,
    //                 textFieldType: TextFieldType.EMAIL,
    //                 keyboardType: TextInputType.emailAddress,
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 decoration: inputDecoration(context, label: language.email),
    //               ),
    //               SizedBox(height: 16),
    //               AppTextField(
    //                 controller: passController,
    //                 focus: passFocus,
    //                 autoFocus: false,
    //                 textFieldType: TextFieldType.PASSWORD,
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 decoration: inputDecoration(context, label: language.password),
    //               ),
    //               SizedBox(height: 16),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       SizedBox(
    //                         height: 18.0,
    //                         width: 18.0,
    //                         child: Checkbox(
    //                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //                           activeColor: primaryColor,
    //                           value: mIsCheck,
    //                           shape: RoundedRectangleBorder(borderRadius: radius(4)),
    //                           onChanged: (v) async {
    //                             mIsCheck = v!;
    //                             if (!mIsCheck) {
    //                               sharedPref.remove(REMEMBER_ME);
    //                             } else {
    //                               await sharedPref.setBool(REMEMBER_ME, mIsCheck);
    //                               await sharedPref.setString(USER_EMAIL, emailController.text);
    //                               await sharedPref.setString(USER_PASSWORD, passController.text);
    //                             }

    //                             setState(() {});
    //                           },
    //                         ),
    //                       ),
    //                       SizedBox(width: 8),
    //                       inkWellWidget(
    //                         onTap: () async {
    //                           mIsCheck = !mIsCheck;
    //                           setState(() {});
    //                         },
    //                         child: Text(language.rememberMe, style: primaryTextStyle(size: 14)),
    //                       ),
    //                     ],
    //                   ),
    //                   inkWellWidget(
    //                     onTap: () {
    //                       launchScreen(context, ForgotPasswordScreen(), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
    //                     },
    //                     child: Text(language.forgotPassword, style: primaryTextStyle()),
    //                   ),
    //                 ],
    //               ),
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
    //                   SizedBox(width: 8),
    //                   Expanded(
    //                     child: RichText(
    //                       text: TextSpan(
    //                         children: [
    //                           TextSpan(text: language.iAgreeToThe + " ", style: primaryTextStyle(size: 12)),
    //                           TextSpan(
    //                             text: language.termsConditions.splitBefore(' &'),
    //                             style: boldTextStyle(color: primaryColor, size: 14),
    //                             recognizer: TapGestureRecognizer()
    //                               ..onTap = () {
    //                                 if (termsCondition != null && termsCondition!.isNotEmpty) {
    //                                   launchScreen(context, TermsConditionScreen(title: language.termsConditions, subtitle: termsCondition), pageRouteAnimation: PageRouteAnimation.Slide);
    //                                 } else {
    //                                   toast(language.txtURLEmpty);
    //                                 }
    //                               },
    //                           ),
    //                           TextSpan(text: ' & ', style: primaryTextStyle(size: 12)),
    //                           TextSpan(
    //                             text: language.privacyPolicy,
    //                             style: boldTextStyle(color: primaryColor, size: 14),
    //                             recognizer: TapGestureRecognizer()
    //                               ..onTap = () {
    //                                 if (privacyPolicy != null && privacyPolicy!.isNotEmpty) {
    //                                   launchScreen(context, TermsConditionScreen(title: language.privacyPolicy, subtitle: privacyPolicy), pageRouteAnimation: PageRouteAnimation.Slide);
    //                                 } else {
    //                                   toast(language.txtURLEmpty);
    //                                 }
    //                               },
    //                           ),
    //                         ],
    //                       ),
    //                       textAlign: TextAlign.left,
    //                     ),
    //                   )
    //                 ],
    //               ),
    //               SizedBox(height: 32),
    //               AppButtonWidget(
    //                 width: MediaQuery.of(context).size.width,
    //                 text: language.logIn,
    //                 onTap: () async {
    //                   logIn();
    //                 },
    //               ),
    //               SizedBox(height: 16),
    //               socialWidget(),
    //               SizedBox(height: 16),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Observer(
    //         builder: (context) {
    //           return Visibility(
    //             visible: appStore.isLoading,
    //             child: loaderWidget(),
    //           );
    //         },
    //       ),
    //     ],
    //   ),
    //   bottomNavigationBar: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       Align(
    //         alignment: Alignment.bottomCenter,
    //         child: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Text(language.donHaveAnAccount, style: primaryTextStyle()),
    //             SizedBox(width: 8),
    //             inkWellWidget(
    //               onTap: () {
    //                 hideKeyboard(context);
    //                 launchScreen(context, SignUpScreen(privacyPolicyUrl: privacyPolicy, termsConditionUrl: termsCondition));
    //               },
    //               child: Text(language.signUp, style: boldTextStyle()),
    //             ),
    //           ],
    //         ),
    //       ),
    //       SizedBox(height: 16),
    //     ],
    //   ),
    // );
  }
}
