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
        path: Link.Dashboard.Path.listeningMode.rawValue,
        items: .none
      )
    ) {
      VStack {
        Rectangle()
          .fill(.background)
      }
    }
  }
}
