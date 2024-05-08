import UIKit
import Flutter
import GoogleMaps
import OneSignal

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
  
  // OneSignal initialization
    OneSignal.initWithLaunchOptions(launchOptions)
    OneSignal.setAppId("580dc8b3-a23b-4ef4-9ec9-fa1fd78c83bb")
    GMSServices.provideAPIKey("AIzaSyAg5nyQAzPupKmzUJKyM-Rp09gAmGJqzyc")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
