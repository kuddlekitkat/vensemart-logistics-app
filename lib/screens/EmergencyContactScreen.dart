import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';
import '../../model/ContactNumberListModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmergencyContactScreen extends StatefulWidget {
  @override
  EmergencyContactScreenState createState() => EmergencyContactScreenState();
}

class EmergencyContactScreenState extends State<EmergencyContactScreen> {
  ScrollController scrollController = ScrollController();

  final FlutterContactPicker _contactPicker = new FlutterContactPicker();
  Contact? _contact;

  int page = 1;
  int currentPage = 1;
  int totalPage = 1;

  List<ContactModel> contactNumber = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;

          appStore.setLoading(true);
          setState(() {});
          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  _launchWhatsapp() async {
    try {
      String phone = '+234 816 713 1445';
      String message = 'Hello, I need help';

//launchUrlString is method of url_launcher package and //phoneNoController.text is the number from phone number textfield
      await launchUrlString('whatsapp://send?phone=$phone&text=$message');
    } catch (e) {
      toast("We can’t open whatsapp app");
    }

    // var uri = Uri.parse('whatsapp://send?phone=$phone&text=$message');

    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // } else {
    //   toast("We can't open whatsapp app");
    //   throw 'Could not launch $uri';
    // }
  }

  _lauchEmail() async {
    try {
      String email = Uri.encodeComponent('info@vensemart.com');
      String subject = Uri.encodeComponent('Vensemart Support');
      String body = Uri.encodeComponent('Hello, I need help');

      // String uri = 'mailto:$email?subject=$subject&body=$body';
      await launchUrlString('mailto:$email?subject=$subject&body=$body');
    } catch (e) {
      toast("We can't open email app");
      print(e);
    }

    // if (await canLaunchUrl(uri)) {
    // } else {
    //   throw 'Could not launch $uri';
    // }
  }

  void init() async {
    appStore.setLoading(true);
    await getSosList().then((value) {
      appStore.setLoading(false);
      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;

      if (currentPage == 1) {
        contactNumber.clear();
      }
      contactNumber.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);

      log(error.toString());
    });
  }

  Future<void> addContact({String? name, String? contactNumber}) async {
    appStore.setLoading(true);
    Map req = {
      "title": name,
      "contact_number": contactNumber,
    };
    await saveSOS(req).then((value) {
      appStore.setLoading(false);
      init();
      toast(value.message);
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> delete({required int id}) async {
    appStore.setLoading(true);
    await deleteSosList(id: id).then((value) {
      init();
      appStore.setLoading(false);
    }).catchError((error) {
      appStore.setLoading(false);

      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.emergencyContact,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 352,
                decoration: BoxDecoration(
                  color: Color(0xFF1456F1),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Image.asset(
                          'assets/images/image_32.png',
                          width: 228,
                          height: 228,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 9, 0, 0),
                        child: SelectionArea(
                            child: Text(
                          'For enquiries and complainsKindly reach out to us \nthrough any of the  contact information below',
                          textAlign: TextAlign.center,
                          // style:
                          //     FlutterFlowTheme.of(context).bodyText1.override(
                          //           fontFamily: 'Poppins',
                          //           color: Colors.white,
                          //           fontWeight: FontWeight.w500,
                          //         ),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Row(
                    //   mainAxisSize: MainAxisSize.max,
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Icon(
                    //       FFIcons.kvector3,
                    //       color: Color(0xFF1456F1),
                    //       size: 24,
                    //     ),
                    //     SelectionArea(
                    //         child: Text(
                    //       'Call us',
                    //       style:
                    //           FlutterFlowTheme.of(context).bodyText1.override(
                    //                 fontFamily: 'Poppins',
                    //                 color: Color(0xFF1456F1),
                    //                 fontSize: 15,
                    //               ),
                    //     )),
                    //   ],
                    // ),
                    SelectionArea(
                        child: TextButton(
                      onPressed: () async {
                        FlutterPhoneDirectCaller.callNumber(
                            '+234 816 713 1445');
                      },
                      child: Text(
                        '+234 816 713 1445',
                        // style: FlutterFlowTheme.of(context).bodyText1.override(
                        //       fontFamily: 'Poppins',
                        //       color: Colors.black,
                        //       fontSize: 13,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                      ),
                    )),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mail,
                          color: Color(0xFF1456F1),
                          size: 24,
                        ),
                        SelectionArea(
                            child: Text(
                          'Email us',
                          // style:
                          //     FlutterFlowTheme.of(context).bodyText1.override(
                          //           fontFamily: 'Poppins',
                          //           color: Color(0xFF1456F1),
                          //           fontSize: 15,
                          //         ),
                        )),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        _lauchEmail();
                      },
                      child: SelectionArea(
                          child: Text(
                        'info@vensemart.com',
                        // style: FlutterFlowTheme.of(context).bodyText1.override(
                        //       fontFamily: 'Poppins',
                        //       color: Colors.black,
                        //       fontSize: 13,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                      )),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectionArea(
                          child: Text(
                            'Message us on',
                            // style:
                            // FlutterFlowTheme.of(context).bodyText1.override(
                            //       fontFamily: 'Poppins',
                            //       color: Color(0xFF1456F1),
                            //       fontSize: 15,
                            //       fontWeight: FontWeight.w500,
                            // ),
                          ),
                        ),
                      ],
                    ),
                    inkWellWidget(
                      onTap: () async {
                        _launchWhatsapp();
                      },
                      child: Image.asset(
                        'assets/images/logos_whatsapp-icon.png',
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // body: Observer(builder: (context) {
      //   return Stack(
      //     children: [
      //       SingleChildScrollView(
      //         padding: EdgeInsets.all(16),
      //         child: ListView.separated(
      //           shrinkWrap: true,
      //           itemCount: contactNumber.length,
      //           itemBuilder: (_, index) {
      //             return Row(
      //               children: [
      //                 Container(
      //                   padding: EdgeInsets.all(16),
      //                   decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
      //                   child: Text(contactNumber[index].title![0], style: boldTextStyle(color: Colors.white)),
      //                 ),
      //                 SizedBox(width: 8),
      //                 Expanded(
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Text(contactNumber[index].title.validate(), style: boldTextStyle()),
      //                       SizedBox(height: 4),
      //                       Text(contactNumber[index].contactNumber.validate(), style: primaryTextStyle()),
      //                     ],
      //                   ),
      //                 ),
      //                 if (contactNumber[index].regionId == null)
      //                   inkWellWidget(
      //                     onTap: () async {
      //                       showConfirmDialogCustom(context, title: language.areYouSureYouWantDeleteThisNumber, positiveText: language.yes, negativeText: language.no, dialogType: DialogType.DELETE, onAccept: (c) async {
      //                         await delete(id: contactNumber[index].id!);
      //                       }, primaryColor: primaryColor);
      //                     },
      //                     child: Icon(MaterialIcons.delete_outline, color: primaryColor),
      //                   )
      //               ],
      //             );
      //           },
      //           separatorBuilder: (_, index) {
      //             return Divider();
      //           },
      //         ),
      //       ),
      //       Visibility(
      //         visible: appStore.isLoading,
      //         child: loaderWidget(),
      //       ),
      //       !appStore.isLoading && contactNumber.isEmpty ? emptyWidget() : SizedBox(),
      //     ],
      //   );
      // }),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.all(16),
      //   child: AppButtonWidget(
      //     width: MediaQuery.of(context).size.width,
      //     text: language.addContact,
      //     onTap: () async {
      //       Contact? contact = await _contactPicker.selectContact();
      //       setState(() {
      //         _contact = contact;
      //       });
      //       if (_contact != null) addContact(name: _contact!.fullName.validate(), contactNumber: _contact!.phoneNumbers!.first);
      //     },
      //   ),
      // ),
    );
  }
}
