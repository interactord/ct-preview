import Foundation
import SwiftUI

public struct SingleNavigation<Content: View>: View {

  // MARK: Lifecycle

  public init(navigator: SingleNavigator, rootLink: LinkItem, content: @escaping () -> Content) {
    self.navigator = navigator
    self.rootLink = rootLink
    self.content = content
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $navigator.routeList) {
      content()
        .task {
          await navigator.next(item: rootLink)
        }
        .navigationDestination(for: LinkItem.self) { (item: LinkItem) in
          navigator.open(item)
            .navigationBarBackButtonHidden()
        }
    }
  }

  // MARK: Internal

  @AppStorage("fontScale", store: .standard)
  var fontScale = 1.0

  @Bindable var navigator: SingleNavigator

  let rootLink: LinkItem
  let content: () -> Content
}
