import Foundation
import SwiftUI

// MARK: - FlexTextEditor

public struct FlexTextEditor: View {

  // MARK: Lifecycle

  public init(
    text: Binding<String>,
    submitAction: @escaping () -> Void,
    cancelAction: @escaping () -> Void,
    cutAction: @escaping () -> Void = { },
    playAndStop: @escaping () -> Void = { }
  ) {
    self.text = text
    self.submitAction = submitAction
    self.cancelAction = cancelAction
    self.cutAction = cutAction
    self.playAndStop = playAndStop
  }

  // MARK: Public

  public var body: some View {
    TextField("", text: text, axis: .vertical)
      .textFieldStyle(.plain)
      .font(.system(size: 14))
      .lineLimit(4)
      .focused($isFocus)
      .onKeyPress(.return) {
        submitAction()
        isFocus = false
        return .handled
      }
      .scrollContentBackground(.hidden)
      .background(.clear)
      .onKeyPress { press in
        guard press.modifiers.contains(.shift) else { return .ignored }
        switch press.key {
        case .space:
          cutAction()
          return .handled

        case .return:
          playAndStop()
          return .handled

        default:
          return .ignored
        }
      }
      .onKeyPress(.escape) {
        cancelAction()
        isFocus = false
        return .handled
      }
      .frame(minHeight: 20, maxHeight: 72)
  }

  // MARK: Internal

  let submitAction: () -> Void
  let cancelAction: () -> Void
  let cutAction: () -> Void
  let playAndStop: () -> Void

  // MARK: Private

  @FocusState private var isFocus: Bool

  private var text: Binding<String>

}
