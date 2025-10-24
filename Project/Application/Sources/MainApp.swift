import Architecture
import Dashboard
import DesignSystem
import Domain
import Functor
import LinkNavigatorSwiftUI
import Platform
import SwiftUI

// MARK: - MainApp

@main
struct MainApp: App {

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
