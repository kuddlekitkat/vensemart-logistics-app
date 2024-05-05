import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../utils/Common.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../model/SettingModel.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';
import 'AboutScreen.dart';
import 'ChangePasswordScreen.dart';
import 'DeleteAccountScreen.dart';
import 'LanguageScreen.dart';
import 'TermsConditionScreen.dart';

class SettingScreen extends StatefulWidget {
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  SettingModel settingModel = SettingModel();
  String? privacyPolicy;
  String? termsCondition;
  String? mHelpAndSupport;

  bool? switchListTileValue1;
  bool? switchListTileValue2;
  bool? switchListTileValue3;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LiveStream().on(CHANGE_LANGUAGE, (p0) {
      setState(() {});
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
        title: Text(language.settings,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16, top: 16),
        child: Column(
          children: [
            Visibility(
              visible: appStore.isLoggedIn,
              child: settingItemWidget(
                  Ionicons.ios_lock_closed_outline, language.changePassword,
                  () {
                launchScreen(context, ChangePasswordScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              }),
            ),
            settingItemWidget(Ionicons.language_outline, language.language, () {
              launchScreen(context, LanguageScreen(),
                  pageRouteAnimation: PageRouteAnimation.Slide);
            }),
            if (appStore.privacyPolicy != null)
              settingItemWidget(
                  Ionicons.ios_document_outline, language.privacyPolicy, () {
                launchScreen(
                    context,
                    TermsConditionScreen(
                        title: language.privacyPolicy,
                        subtitle: appStore.privacyPolicy),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              }),
            if (appStore.mHelpAndSupport != null)
              settingItemWidget(Ionicons.help_outline, language.helpSupport,
                  () {
                if (mHelpAndSupport != null) {
                  launchUrl(Uri.parse(appStore.mHelpAndSupport!));
                } else {
                  toast(language.txtURLEmpty);
                }
              }),
            if (appStore.termsCondition != null)
              settingItemWidget(
                  Ionicons.document_outline, language.termsConditions, () {
                if (appStore.termsCondition != null) {
                  launchScreen(
                      context,
                      TermsConditionScreen(
                          title: language.termsConditions,
                          subtitle: appStore.termsCondition),
                      pageRouteAnimation: PageRouteAnimation.Slide);
                } else {
                  toast(language.txtURLEmpty);
                }
              }),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/images/logos_whatsapp-icon.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: SwitchListTile.adaptive(
                          value: switchListTileValue1 ??= true,
                          onChanged: (newValue) async {
                            setState(() => switchListTileValue1 = newValue!);
                          },
                          title: Text(
                            'Get updates on whatsapp',
                            style: primaryTextStyle(
                              color: Colors.black,
                              size: 13,
                              weight: FontWeight.normal,
                            ),
                          ),
                          // tileColor: Color(0xFFE0E0E0),
                          activeColor: Color(0xFF0ECBA1),
                          activeTrackColor: Color(0x3439D2C0),
                          dense: false,
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 10,
                  thickness: 1,
                  indent: 46,
                  color: Color(0x32808080),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/images/flat-color-icons_sms.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: SwitchListTile.adaptive(
                          value: switchListTileValue2 ??= true,
                          onChanged: (newValue) async {
                            setState(() => switchListTileValue2 = newValue!);
                          },
                          title: Text(
                            'SMS and Email notification',
                            style: primaryTextStyle(
                              color: Colors.black,
                              size: 13,
                              weight: FontWeight.normal,
                            ),
                          ),
                          // tileColor: Color(0xFFE0E0E0),
                          activeColor: Color(0xFF0ECBA1),
                          activeTrackColor: Color(0x3439D2C0),
                          dense: false,
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 10,
                  thickness: 1,
                  indent: 46,
                  color: Color(0x32808080),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/images/clarity_notification-solid-badged.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: SwitchListTile.adaptive(
                          value: switchListTileValue3 ??= true,
                          onChanged: (newValue) async {
                            setState(() => switchListTileValue3 = newValue!);
                          },
                          title: Text(
                            'Notification',
                            style: primaryTextStyle(
                              color: Colors.black,
                              size: 13,
                              weight: FontWeight.normal,
                            ),
                          ),
                          // tileColor: Color(0xFFE0E0E0),
                          activeColor: Color(0xFF0ECBA1),
                          activeTrackColor: Color(0x3439D2C0),
                          dense: false,
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // settingItemWidget(
            //   Ionicons.information,
            //   language.aboutUs,
            //   () {
            //     // launchScreen(context, AboutScreen(settingModel: appStore.settingModel), pageRouteAnimation: PageRouteAnimation.Slide);
            //   },
            // ),
            settingItemWidget(
                Ionicons.ios_trash_outline, language.deleteAccount, () {
              launchScreen(context, DeleteAccountScreen(),
                  pageRouteAnimation: PageRouteAnimation.Slide);
            }, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget settingItemWidget(IconData icon, String title, Function() onTap,
      {bool isLast = false, Widget? suffixIcon}) {
    return inkWellWidget(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 8),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  border: Border.all(color: dividerColor),
                  borderRadius: radius(defaultRadius)),
              child: Icon(icon, size: 20, color: primaryColor),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(title, style: primaryTextStyle())),
            suffixIcon != null
                ? suffixIcon
                : Icon(Icons.navigate_next, color: dividerColor),
          ],
        ),
      ),
    );
  }
}
