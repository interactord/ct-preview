import Foundation
import SwiftUI

// MARK: - PromptTextEditor

public struct PromptTextEditor: View {

  // MARK: Lifecycle

  public init(text: Binding<String>, height: CGFloat) {
    self.text = text
    self.height = height
  }

  // MARK: Public

  public var body: some View {
    TextEditor(text: text)
      .focused($isFocus)
//    .background {
//      Color.red
//      Rectangle()
//        .fill(.clear)
//        .stroke(.blue, lineWidth: 1)
//        .opacity(isFocus ? 1 : .zero)
//    }
  }

  // MARK: Internal

  let height: CGFloat

  // MARK: Private

  @FocusState private var isFocus: Bool

  private var text: Binding<String>

}
