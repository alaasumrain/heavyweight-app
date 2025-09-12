import UIKit

import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    #if DEBUG
    // Force a visible background to confirm UIKit view paints
    if let win = self.window {
      win.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
      if let vc = win.rootViewController {
        vc.view.isOpaque = true
        vc.view.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        print("[HW iOS DEBUG] Set window/rootViewController background to green, isOpaque=true")
      }
    } else {
      print("[HW iOS DEBUG] Window is nil at launch")
    }
    #endif
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
