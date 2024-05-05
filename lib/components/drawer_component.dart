import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:taxi_booking/screens/AboutScreen.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../main.dart';
import '../network/RestApis.dart';
import '../screens/BankInfoScreen.dart';
import '../screens/EditProfileScreen.dart';
import '../screens/EmergencyContactScreen.dart';
import '../screens/RideListScreen.dart';
import '../screens/WalletScreen.dart';
import '../screens/SettingScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/images.dart';
import 'DrawerWidget.dart';

class DrawerComponent extends StatefulWidget {
  @override
  State<DrawerComponent> createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 77,
                // margin: EdgeInsets.only(top: 50.0),
                color: primaryColor, // Change color as desired
              ),
              Container(
                margin: EdgeInsets.only(top: 40.0, left: 20.0),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  //  border for top left and bottom left
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80.0),
                    topRight: Radius.circular(80.0),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 1.0),
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    sharedPref.getString(USER_PROFILE_PHOTO) != null
                        ? sharedPref.getString(USER_PROFILE_PHOTO).validate()
                        : "https://placehold.it/150",
                    // "https://placehold.it/150", // Replace with your image URL
                  ),
                  radius: 30.0, // Adjust radius as needed
                ),
              ),

              // Container(
              //   alignment: Alignment.bottomLeft,
              //   height: 100,
              //   // margin: EdgeInsets.only(top: 40.0),
              //   child: Row(
              //     children: <Widget>[
              //       Expanded(child: Text(''), flex: 9),
              //       Expanded(
              //         child: ClipRRect(
              //           borderRadius: new BorderRadius.circular(80.0),
              //           child: Image.network('https://placehold.it/150'),
              //         ),
              //         flex: 6,
              //       ),
              //       Expanded(child: Text(''), flex: 9)
              //     ],
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(right: 8, left: 13),
            child: Observer(builder: (context) {
              // return Text(
              //   "John Doe",
              //   style: boldTextStyle(
              //     size: 18,
              //     color: Color(0xFF252B64),
              //   ),
              // );

              return Text(
                  sharedPref.getString(NAME).validate().capitalizeFirstLetter(),
                  style: boldTextStyle());
            }),
          ),
          SizedBox(height: 44),
          DrawerWidget(
            title: 'Edit Profile',
            iconData: ic_profile,
            onTap: () {
              Navigator.pop(context);
              launchScreen(context, EditProfileScreen(),
                  pageRouteAnimation: PageRouteAnimation.Slide);
            },
          ),

          DrawerWidget(
              title: "Payment History",
              iconData: ic_wallet,
              onTap: () {
                Navigator.pop(context);
                launchScreen(context, WalletScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              }),

          DrawerWidget(
              title: "Book History",
              iconData: ic_wallet,
              onTap: () {
                Navigator.pop(context);
                launchScreen(context, RideListScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              }),
          DrawerWidget(
              title: "Contact Us",
              iconData: ic_call,
              onTap: () {
                Navigator.pop(context);
                launchScreen(context, EmergencyContactScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              }),
          DrawerWidget(
              title: "About Us",
              iconData: ic_info,
              onTap: () {
                Navigator.pop(context);
                launchScreen(context, AboutScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              }),
          // DrawerWidget(
          //     title: language.bankInfo,
          //     iconData: ic_update_bank_info,
          //     onTap: () {
          //       Navigator.pop(context);
          //       launchScreen(context, BankInfoScreen(),
          //           pageRouteAnimation: PageRouteAnimation.Slide);
          //     }),
          // DrawerWidget(
          //     title: language.emergencyContacts,
          //     iconData: ic_emergency_contact,
          //     onTap: () {
          //       Navigator.pop(context);
          //       launchScreen(context, EmergencyContactScreen(),
          //           pageRouteAnimation: PageRouteAnimation.Slide);
          //     }),
          DrawerWidget(
              title: language.settings,
              iconData: ic_setting,
              onTap: () {
                Navigator.pop(context);
                launchScreen(context, SettingScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              }),
          DrawerWidget(
              title: language.logOut,
              iconData: ic_logout,
              onTap: () async {
                await showConfirmDialogCustom(context,
                    primaryColor: primaryColor,
                    dialogType: DialogType.CONFIRMATION,
                    title: language.areYouSureYouWantToLogoutThisApp,
                    positiveText: language.yes,
                    negativeText: language.no, onAccept: (v) async {
                  await appStore.setLoggedIn(true);
                  await Future.delayed(Duration(milliseconds: 500));
                  await logout();
                });
              }),
        ],
      ),

      // Stack(
      //   children: [
      //     SingleChildScrollView(
      //       // padding: EdgeInsets.all(16),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Container(
      //             height: 77.0,
      //             color: primaryColor, // Change color as desired
      //           ),
      //           // Positioned avatar at bottom of container
      // Positioned(
      //   bottom: 20.0,
      //   right: 10.0, // Adjust right padding if needed
      //   child: CircleAvatar(
      //     backgroundImage: NetworkImage(
      //       "https://placehold.it/150", // Replace with your image URL
      //     ),
      //     radius: 30.0, // Adjust radius as needed
      //   ),
      // ),
      //           //

      // Padding(
      //   padding: EdgeInsets.only(right: 8),
      //   child: Observer(builder: (context) {
      //     return Row(
      //       children: [
      //         ClipRRect(
      //           borderRadius: radius(),
      //           child: commonCachedNetworkImage(
      //               appStore.userProfile.validate().validate(),
      //               height: 70,
      //               width: 70,
      //               fit: BoxFit.cover),
      //         ),
      //         SizedBox(width: 8),
      //         Expanded(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                 "John Doe",
      //                 style: boldTextStyle(size: 18),
      //               ),
      //               // Text(sharedPref.getString(FIRST_NAME).validate().capitalizeFirstLetter() + " " + sharedPref.getString(LAST_NAME).validate().capitalizeFirstLetter(),
      //               //     style: boldTextStyle()),
      //               SizedBox(height: 4),
      //               Text(appStore.userEmail,
      //                   style: secondaryTextStyle()),
      //             ],
      //           ),
      //         ),
      //       ],
      //     );
      //   }),
      // ),
      //           Divider(thickness: 1, height: 40),
      //       DrawerWidget(
      //         title: language.profile,
      //         iconData: ic_my_profile,
      //         onTap: () {
      //           Navigator.pop(context);
      //           launchScreen(context, EditProfileScreen(),
      //               pageRouteAnimation: PageRouteAnimation.Slide);
      //         },
      //       ),
      //       DrawerWidget(
      //           title: language.rides,
      //           iconData: ic_my_rides,
      //           onTap: () {
      //             Navigator.pop(context);
      //             launchScreen(context, RideListScreen(),
      //                 pageRouteAnimation: PageRouteAnimation.Slide);
      //           }),
      //       DrawerWidget(
      //           title: language.wallet,
      //           iconData: ic_my_wallet,
      //           onTap: () {
      //             Navigator.pop(context);
      //             launchScreen(context, WalletScreen(),
      //                 pageRouteAnimation: PageRouteAnimation.Slide);
      //           }),
      //       DrawerWidget(
      //           title: language.bankInfo,
      //           iconData: ic_update_bank_info,
      //           onTap: () {
      //             Navigator.pop(context);
      //             launchScreen(context, BankInfoScreen(),
      //                 pageRouteAnimation: PageRouteAnimation.Slide);
      //           }),
      //       DrawerWidget(
      //           title: language.emergencyContacts,
      //           iconData: ic_emergency_contact,
      //           onTap: () {
      //             Navigator.pop(context);
      //             launchScreen(context, EmergencyContactScreen(),
      //                 pageRouteAnimation: PageRouteAnimation.Slide);
      //           }),
      //       DrawerWidget(
      //           title: language.settings,
      //           iconData: ic_setting,
      //           onTap: () {
      //             Navigator.pop(context);
      //             launchScreen(context, SettingScreen(),
      //                 pageRouteAnimation: PageRouteAnimation.Slide);
      //           }),
      //       DrawerWidget(
      //           title: language.logOut,
      //           iconData: ic_logout,
      //           onTap: () async {
      //             await showConfirmDialogCustom(context,
      //                 primaryColor: primaryColor,
      //                 dialogType: DialogType.CONFIRMATION,
      //                 title: language.areYouSureYouWantToLogoutThisApp,
      //                 positiveText: language.yes,
      //                 negativeText: language.no, onAccept: (v) async {
      //               await appStore.setLoggedIn(true);
      //               await Future.delayed(Duration(milliseconds: 500));
      //               await logout();
      //             });
      //           }),
      //     ],
      //   ),
      // ),
      //   ],
      // ),
    );
  }
}
