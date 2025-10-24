import SwiftUI

// MARK: - SearchBar

public struct SearchBar {
  public init(viewState: ViewState, text: Binding<String>) {
    self.viewState = viewState
    _text = text
  }

  @Binding var text: String

  private let viewState: ViewState

}

// MARK: View

extension SearchBar: View {
  public var body: some View {
    HStack(spacing: 4) {
      Image(.icSearch)
        .renderingMode(.template)
        .foregroundColor(SystemColor.Label.OnBG.Secondary.color)
        .padding(.leading, 8)

      TextField(viewState.ltSpkrSelLangSearchHint ?? "", text: $text)
        .font(.system(size: 14))
        .textFieldStyle(.plain)
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 10)
    .background(SystemColor.Overlay.Thin.default.color, in: RoundedRectangle(cornerRadius: 10))
    .padding(.init(top: 16, leading: 16, bottom: 8, trailing: 16))
  }
}

// MARK: SearchBar.ViewState

extension SearchBar {
  public struct ViewState: Equatable {
    public init(ltSpkrSelLangSearchHint: String?, ltSpkrChatEditCancelBtn: String?) {
      self.ltSpkrSelLangSearchHint = ltSpkrSelLangSearchHint
      self.ltSpkrChatEditCancelBtn = ltSpkrChatEditCancelBtn
    }

    let ltSpkrSelLangSearchHint: String?
    let ltSpkrChatEditCancelBtn: String?

  }
}
