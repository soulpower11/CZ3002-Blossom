import UIKit
import Flutter
import GoogleMaps  // Add this import

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let value = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API"] { GMSServices.provideAPIKey(value) }
    
    // NSString* mapsApiKey = [[NSProcessInfo processInfo] environment[@"GOOGLE_MAPS_API"];
    // GMSServices.provideAPIKey(mapsApiKey)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}