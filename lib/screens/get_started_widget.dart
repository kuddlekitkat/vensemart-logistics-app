import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taxi_booking/screens/SignInScreen.dart';
import 'package:taxi_booking/screens/SignUpScreen.dart';
import 'package:taxi_booking/utils/Extensions/app_common.dart';

class GetStartedWidget extends StatefulWidget {
  const GetStartedWidget({Key? key}) : super(key: key);

  @override
  _GetStartedWidgetState createState() => _GetStartedWidgetState();
}

class _GetStartedWidgetState extends State<GetStartedWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFFF3F5FA),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          // decoration: BoxDecoration(

          // ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(),
                child: Image.asset(
                  'assets/images/Rectangle_53.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(1, 0.9),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.42,
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F5FA),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                          child: SelectionArea(
                              child: Text(
                            'Welcome to vensemart',
                            style: primaryTextStyle(),
                          )),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                          child: InkWell(
                            onTap: () async {
                              // await Navigator.push(
                              //   context,
                              //   PageTransition(
                              //     type: PageTransitionType.fade,
                              //     duration: Duration(milliseconds: 200),
                              //     reverseDuration: Duration(milliseconds: 200),
                              //     child: SignWithEmailWidget(),
                              //   ),
                              // );
                              launchScreen(
                                context,
                                SignInScreen(),
                                pageRouteAnimation: PageRouteAnimation.Fade,
                                duration: Duration(milliseconds: 200),
                              );
                            },
                            child: Container(
                              width: 295,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Color(0xFF003399),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.mail_outline_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          15, 0, 0, 0),
                                      child: SelectionArea(
                                          child: Text(
                                        'Sign in with Email',
                                        style: primaryTextStyle().copyWith(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Rubik',
                                        ),

                                        // ),
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 295,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Color(0xFF1877F2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.facebookF,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      15, 0, 0, 0),
                                  child: SelectionArea(
                                      child: Text(
                                    'Sign in with Facebook',
                                    style: primaryTextStyle().copyWith(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Rubik',
                                    ),
                                    // style: FlutterFlowTheme.of(context)
                                    //     .bodyText1
                                    //     .override(
                                    //       fontFamily: 'Rubik',
                                    //       color: Colors.white,
                                    //       fontSize: 15,
                                    //       fontWeight: FontWeight.w500,
                                    //     ),
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.max,
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       SelectionArea(
                        //           child: Text(
                        //         'Don’t have an account?',
                        //         style: FlutterFlowTheme.of(context)
                        //             .bodyText1
                        //             .override(
                        //               fontFamily: 'Rubik',
                        //               color: Color(0xFF003399),
                        //               fontSize: 13,
                        //               fontWeight: FontWeight.normal,
                        //             ),
                        //       )),
                        //       InkWell(
                        //         onTap: () async {

                        //         },
                        //         child: SelectionArea(
                        //             child: Text(
                        //           ' SIGN UP',
                        //           style: FlutterFlowTheme.of(context)
                        //               .bodyText1
                        //               .override(
                        //                 fontFamily: 'Rubik',
                        //                 color: Color(0xFF003399),
                        //               ),
                        //         )),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // using text.rich
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                          child: InkWell(
                            onTap: () async {
                              // await Navigator.push(
                              //   context,
                              //   PageTransition(
                              //     type: PageTransitionType.topToBottom,
                              //     duration: Duration(milliseconds: 100),
                              //     reverseDuration: Duration(milliseconds: 100),
                              //     child: RegisterScreen(),
                              //   ),
                              // );
                              launchScreen(
                                context,
                                SignUpScreen(),
                                pageRouteAnimation:
                                    PageRouteAnimation.SlideBottomTop,
                                duration: Duration(milliseconds: 100),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Don’t have an account?',
                                    style: primaryTextStyle().copyWith(
                                      color: Color(0xFF003399),
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Rubik',
                                    ),
                                    // style: FlutterFlowTheme.of(context)
                                    //     .bodyText1
                                    //     .override(
                                    //       fontFamily: 'Rubik',
                                    //       color: Color(0xFF003399),
                                    //       fontSize: 13,
                                    //       fontWeight: FontWeight.normal,
                                    //     ),
                                  ),
                                  TextSpan(
                                    text: ' SIGN UP',
                                    style: primaryTextStyle().copyWith(
                                      color: Color(0xFF003399),
                                      fontFamily: 'Rubik',
                                    ),
                                    // style: FlutterFlowTheme.of(context)
                                    //     .bodyText1
                                    //     .override(
                                    //       fontFamily: 'Rubik',
                                    //       color: Color(0xFF003399),
                                    //     ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
