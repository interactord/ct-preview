import SwiftUI

// MARK: - BaseView

public struct BaseView<Content: View>: View {

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  private var content: () -> Content

}

extension BaseView {
  public var body: some View {
    content()
  }
}
