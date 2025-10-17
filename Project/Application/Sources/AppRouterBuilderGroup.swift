import Architecture
import Dashboard
import LinkNavigatorSwiftUI
import SwiftUI

struct AppRouterBuilderGroup {
  @MainActor
  var applicationBuilderList: [RouteBuilderOf<SingleNavigator, AnyView>] {
    DashboardRouteBuilderGroup().release()
  }
}
