import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxi_booking/components/info_design_ui.dart';
import '../components/ImageSourceDialog.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';

import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_textfield.dart';
import 'DashBoardScreen.dart';

class EditProfileScreen extends StatefulWidget {
  final bool? isGoogle;

  EditProfileScreen({this.isGoogle = false});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? imageProfile;
  String countryCode = defaultCountryCode;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode firstnameFocus = FocusNode();
  FocusNode lastnameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    getUserDetails().then((value) {
      emailController.text = value.userdata!.email.validate();
      nameController.text = value.userdata!.name.validate();
      contactNumberController.text = value.userdata!.mobile.validate();

      appStore.setUserEmail(value.userdata!.email.validate());
      appStore.setUserName(value.userdata!.name.validate());

      sharedPref.setString(USER_EMAIL, value.userdata!.email.validate());
      sharedPref.setString(NAME, value.userdata!.name.validate());

      print(value.userdata!.name);

      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
      appStore.setLoading(false);
    });
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(File(imageProfile!.path),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              alignment: Alignment.center),
        ),
      );
    } else {
      if (sharedPref.getString(USER_PROFILE_PHOTO)!.isNotEmpty) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: commonCachedNetworkImage(
                sharedPref.getString(USER_PROFILE_PHOTO).validate(),
                fit: BoxFit.cover,
                height: 100,
                width: 100),
          ),
        );
      } else {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: commonCachedNetworkImage(
                  sharedPref.getString(USER_PROFILE_PHOTO).validate(),
                  height: 90,
                  width: 90),
            ),
          ),
        );
      }
    }
  }

  Future<void> saveProfile() async {
    hideKeyboard(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      appStore.setLoading(true);
      await updateProfile(
        file: imageProfile != null ? File(imageProfile!.path.validate()) : null,
        contactNumber: widget.isGoogle == true
            ? '$countryCode${contactNumberController.text.trim()}'
            : contactNumberController.text.trim(),
        name: nameController.text.trim(),
        userEmail: emailController.text.trim(),
      ).then((value) {
        appStore.setLoading(false);
        toast(language.profileUpdateMsg);
        sharedPref.setString(USER_PROFILE_PHOTO, value.userdata!.profileImage);
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Column(
    //     children: [
    //       Stack(
    //         children: <Widget>[
    //           Container(
    //             height: 109,
    //             // margin: EdgeInsets.only(top: 50.0),
    //             color: primaryColor, // Change color as desired
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 // back button
    //                 Container(
    //                   width: 34,
    //                   height: 34,
    //                   decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.circular(50.0),
    //                     color: Colors.white,
    //                   ),
    //                   // padding: EdgeInsets.all(5.0),
    //                   padding: EdgeInsets.only(left: 2.0, bottom: 4.0),
    //                   margin: EdgeInsets.only(left: 10.0),
    //                   child: IconButton(
    //                     icon: Icon(Icons.arrow_back_ios, color: Colors.black),
    //                     onPressed: () {
    //                       Navigator.pop(context);
    //                     },
    //                   ),
    //                 ),
    //                 // Text button
    //                 Container(
    //                   margin: EdgeInsets.only(right: 10.0),
    //                   child: TextButton(
    //                     onPressed: () {
    //                       // saveProfile();
    //                     },
    //                     child: Text(
    //                       'Edit',
    //                       style: primaryTextStyle(color: Colors.white),
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           Container(
    //             margin: EdgeInsets.only(top: 68.0, left: 168.0),
    //             decoration: BoxDecoration(
    //               // color: Colors.white,
    //               //  border for top left and bottom left
    //               borderRadius: BorderRadius.only(
    //                 topLeft: Radius.circular(80.0),
    //                 topRight: Radius.circular(80.0),
    //               ),
    //               border: Border(
    //                 top: BorderSide(color: Colors.white, width: 1.0),
    //               ),
    //             ),
    //             child: CircleAvatar(
    //               backgroundImage: NetworkImage(
    //                 "https://placehold.it/150", // Replace with your image URL
    //               ),
    //               radius: 30.0, // Adjust radius as needed
    //             ),
    //           ),

    //           // Container(
    //           //   alignment: Alignment.bottomLeft,
    //           //   height: 100,
    //           //   // margin: EdgeInsets.only(top: 40.0),
    //           //   child: Row(
    //           //     children: <Widget>[
    //           //       Expanded(child: Text(''), flex: 9),
    //           //       Expanded(
    //           //         child: ClipRRect(
    //           //           borderRadius: new BorderRadius.circular(80.0),
    //           //           child: Image.network('https://placehold.it/150'),
    //           //         ),
    //           //         flex: 6,
    //           //       ),
    //           //       Expanded(child: Text(''), flex: 9)
    //           //     ],
    //           //   ),
    //           // ),

    //           Padding(
    //             padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
    //             child: SelectionArea(
    //               child: Text(
    //                 'Name',
    //                 style: primaryTextStyle(
    //                   color: Colors.black,
    //                   size: 20,
    //                   weight: FontWeight.bold,
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       SizedBox(height: 10),
    //     ],
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text(language.editProfile,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      profileImage(),
                      // if (sharedPref.getString(LOGIN_TYPE) != LoginTypeGoogle)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 60, left: 60),
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: primaryColor),
                          child: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return ImageSourceDialog(
                                    onCamera: () async {
                                      Navigator.pop(context);
                                      imageProfile = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.camera,
                                              imageQuality: 100);
                                      setState(() {});
                                    },
                                    onGallery: () async {
                                      Navigator.pop(context);
                                      imageProfile = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 100);
                                      setState(() {});
                                    },
                                  );
                                },
                              );
                            },
                            icon:
                                Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                            child: SelectionArea(
                                child: Text(
                              'Name',
                              style: primaryTextStyle(
                                color: Colors.black,
                                size: 13,
                                weight: FontWeight.w500,
                              ),
                            )),
                          ),
                          AppTextField(
                            controller: nameController,
                            textFieldType: TextFieldType.NAME,
                            focus: firstnameFocus,
                            nextFocus: emailFocus,
                            decoration:
                                inputDecoration(context, hintText: "Full Name"),
                            errorThisFieldRequired: language.thisFieldRequired,
                          ),

                          // if (sharedPref.getString(LOGIN_TYPE) != 'mobile' &&
                          //     sharedPref.getString(LOGIN_TYPE) != null)
                          //   SizedBox(height: 16),
                          // if (sharedPref.getString(LOGIN_TYPE) != 'mobile' &&
                          //     sharedPref.getString(LOGIN_TYPE) != null)

                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                            child: SelectionArea(
                                child: Text(
                              'Email',
                              style: primaryTextStyle(
                                color: Colors.black,
                                size: 13,
                                weight: FontWeight.w500,
                              ),
                            )),
                          ),
                          AppTextField(
                            controller: emailController,
                            textFieldType: TextFieldType.EMAIL,
                            focus: emailFocus,
                            nextFocus: contactFocus,
                            decoration: inputDecoration(context,
                                hintText: "Email Address"),
                            errorThisFieldRequired: language.thisFieldRequired,
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                            child: SelectionArea(
                                child: Text(
                              'Contact Number',
                              style: primaryTextStyle(
                                color: Colors.black,
                                size: 13,
                                weight: FontWeight.w500,
                              ),
                            )),
                          ),
                          AppTextField(
                            controller: contactNumberController,
                            textFieldType: TextFieldType.PHONE,
                            focus: contactFocus,
                            nextFocus: addressFocus,
                            decoration: inputDecoration(context,
                                hintText: "Contact Number"),
                            errorThisFieldRequired: language.thisFieldRequired,
                          ),
                          SizedBox(height: 16),
                        ]),
                  ),
                ],
              ),
            ),
          ),
          Observer(
            builder: (_) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          text: language.updateProfile,
          textStyle: boldTextStyle(color: Colors.white),
          color: primaryColor,
          onTap: () {
            // if (sharedPref.getString(USER_EMAIL) == demoEmail) {
            //   toast(language.demoMsg);
            // } else {
            saveProfile();
            // }
          },
        ),
      ),
    );
  }
}
