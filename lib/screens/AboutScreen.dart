import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../main.dart';
import '../utils/images.dart';

class AboutScreen extends StatefulWidget {
  AboutScreen({Key? key}) : super(key: key);

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.aboutUs,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              child: Image.asset(ic_logo_white,
                  height: 150, width: 150, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            Text(mAppName, style: primaryTextStyle(size: 20)),
            SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, snap) {
                if (snap.hasData) {
                  // return Text('v${snap.data!.version}',
                  return Text('v1.0', style: secondaryTextStyle());
                }
                return SizedBox();
              },
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
              child: SizedBox(
                width: 298,
                height: 478,
                child: Text(
                    'Vensemart is a bespoke user friendly vendor and service providers solution, designed to easily connect tested, trusted, verified and certified professionalservice providers (freelancers, sme\'s and corporate companies) to daily personal,home and corporate service needs from personal grooming (barbing/hairdo, makeup,massage and dressing), electrical repairs, mechanical repairs, to general buildingconstruction and repairs. It is a guaranteed marketplace for person home and office daily consumptions shopping and a reliable logistic service delivery solution.\nIt\'s a one-stop spot that guarantees affordable, effective, efficient, safe and timely service delivery and products that takes the hassle of transporting home service needs to service outlets, inconveniences to cue at shopping mall and disappointment by logistics delivery agencies, and translates value for money.\nIt enables the end users to access closest and reliable services within 3 minutes of location proximity, book and manage appointments at convenience and avoid queuing at public outlet for service needs with a relaxed and first class user experience.\nVensemart Apps encourages business growth and curbs the increasing rate of job lost and global economic downturn, networknig onckexpon dingines%h realm economy (freelancing) to the corporate companies.',
                    softWrap: true,
                    style: secondaryTextStyle(),
                    maxLines: 6,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.visible),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
