import Architecture
import Dashboard
import DesignSystem
import Domain
import Functor
import LinkNavigatorSwiftUI
import Platform
import SwiftUI
#if os(iOS)
// Firebase is used on iOS only
import FirebaseCore
import UIKit
#endif
#if os(iOS)

#else
#endif

// MARK: - MainApp

@main
struct MainApp: App {
  #if os(iOS)
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  #endif

  @State var linkNavigator = SingleNavigator(
    dependency: AppSideEffect.generate(),
    routeBuilderList: AppRouterBuilderGroup().applicationBuilderList
  )

  var body: some Scene {
    WindowGroup {
      MainContent(navigator: $linkNavigator)
    }
  }
}

