import Domain
import SwiftUI

// MARK: - ListeningModePage.LanguagePicker

extension ListeningModePage {
  struct LanguagePicker {

    // MARK: Lifecycle

    init(
      title: String = "",
      selectedLanguage: Binding<String>,
      itemList: [String],
      disabled: Bool
    ) {
      self.title = title
      self.selectedLanguage = selectedLanguage
      self.itemList = itemList
      self.disabled = disabled
    }

    // MARK: Internal

    let title: String
    let selectedLanguage: Binding<String>
    let itemList: [String]
    let disabled: Bool

  }
}

extension ListeningModePage.LanguagePicker {
  private var modelList: [String] {
    LanguageEntity.LangCode.allCases.map(\.modelName)
  }

  private func stateImage(item: LanguageEntity.Item) -> String {
    switch item.status {
    case .notInstalled: "arrow.down.circle"
    case .installed: "checkmark.circle.fill"
    case .notSupported: "x.circle.fill"
    }
  }
}

extension ListeningModePage.LanguagePicker: View {

  var body: some View {
    Picker(.init(title), selection: selectedLanguage) {
      ForEach(itemList, id: \.self) { item in
        Text(item)
          .tag(item)
      }
    }
    .pickerStyle(.menu)
    .disabled(disabled)
  }
}
