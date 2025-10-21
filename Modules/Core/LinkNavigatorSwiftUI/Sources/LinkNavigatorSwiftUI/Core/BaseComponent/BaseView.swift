import SwiftUI

public struct BaseView<Content: View>: View {

  private var content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

}

extension BaseView {
  public var body: some View {
    content()
  }
}
