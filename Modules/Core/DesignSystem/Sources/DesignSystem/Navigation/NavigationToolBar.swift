import Foundation
import SwiftUI

extension View {
  public func navigationToolBar(
    isHideTitle: Bool = false,
    leadingContent: @escaping () -> some View = { EmptyView() },
    trailingContent: @escaping () -> some View = { EmptyView() })
    -> some View
  {
    modifier(
      NavigationToolBarModifier(
        isHideTitle: isHideTitle,
        leadingContent: leadingContent,
        trailingContent: trailingContent))
  }
}

// MARK: - NavigationToolBarModifier

public struct NavigationToolBarModifier<Leading: View, Trailing: View>: ViewModifier {

  // MARK: Public

  public func body(content: Content) -> some View {
    content
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbar {
        ToolbarItem(placement: .navigation) {
          leadingContent()
            .padding(.vertical, 20)
        }

        if !isHideTitle {
          ToolbarItem(placement: .principal) {
            Image(.icLogo)
              .renderingMode(.template)
              .foregroundStyle(SystemColor.Label.OnBG.primary.color)
              .padding(.vertical, 20)
          }
        }

        ToolbarItem(placement: .primaryAction) {
          trailingContent()
            .padding(.vertical, 20)
        }
      }
      .toolbarBackground(SystemColor.Background.Grouped.elevated.color, for: .automatic)
      
  }

  // MARK: Internal

  let isHideTitle: Bool
  let leadingContent: () -> Leading
  let trailingContent: () -> Trailing

}
