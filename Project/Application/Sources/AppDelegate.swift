import SwiftUI
#if canImport(UIKit)
import UIKit
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    return true
  }
}
#endif
