import Architecture
import DesignSystem
import LinkNavigatorSwiftUI
import SwiftUI

// MARK: - MainContent

struct MainContent {
  @Binding var navigator: SingleNavigator
}

// MARK: View

extension MainContent: View {

  var body: some View {
    SingleNavigation(
      navigator: navigator,
      rootLink: .init(
        path: Link.Dashboard.Path.splash.rawValue,
        items: .none
      )
    ) {
      SystemColor.Background.Grouped.base.color
        .navigationToolBar()
    }
  }
}
