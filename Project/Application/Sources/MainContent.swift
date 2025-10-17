import Architecture
import LinkNavigatorSwiftUI
import DesignSystem
import SwiftUI

struct MainContent {
  @Binding var navigator: SingleNavigator
}

extension MainContent: View {

  var body: some View {
    SingleNavigation(
      navigator: navigator,
      rootLink: .init(
        path: Link.Dashboard.Path.splash.rawValue,
        items: .none)) {
        SystemColor.Background.Grouped.base.color
          .navigationToolBar()
      }
  }
}
