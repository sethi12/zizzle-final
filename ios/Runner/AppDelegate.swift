 import Flutter
 import UIKit

 @main
 @objc class AppDelegate: FlutterAppDelegate {
   override func application(
     _ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
   ) -> Bool {
     GeneratedPluginRegistrant.register(with: self)
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
   }
 }
//import UIKit
//import Flutter
//import AVFoundation
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//  private let channelName = "wakeword_service/audio"
//
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    GeneratedPluginRegistrant.register(with: self)
//
//    if let controller = window?.rootViewController as? FlutterViewController {
//      let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
//      channel.setMethodCallHandler { call, result in
//        if call.method == "forceSpeaker" {
//          do {
//            let session = AVAudioSession.sharedInstance()
//            try session.overrideOutputAudioPort(.speaker)
//            result(nil)
//          } catch let error {
//            result(FlutterError(code: "UNAVAILABLE", message: "Cannot force speaker", details: "\(error)"))
//          }
//        } else {
//          result(FlutterMethodNotImplemented)
//        }
//      }
//    }
//
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//}
