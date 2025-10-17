import Architecture
import DesignSystem
import Domain
import Functor
import SwiftUI
import Platform
import LinkNavigatorSwiftUI
import Dashboard

// MARK: - MainApp

@main
struct MainApp: App {

  @State var linkNavigator = SingleNavigator(
    dependency: AppSideEffect.generate(),
    routeBuilderList: AppRouterBuilderGroup().applicationBuilderList)

  var body: some Scene {
    WindowGroup {
      MainContent(navigator: $linkNavigator)
    }
  }
}
