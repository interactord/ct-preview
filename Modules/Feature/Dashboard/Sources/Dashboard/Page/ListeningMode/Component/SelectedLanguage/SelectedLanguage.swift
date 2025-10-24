import Domain
import SwiftUI

extension ListeningModePage {
  struct SelectedLanguage {
    let title: String
    let noSelectDescription: String
    let selectedLanguage: Binding<LanguageEntity.Item?>
    let itemList: [LanguageEntity.Item]
    let disabled: Bool

    init(
      title: String = "",
      noSelectDescription: String = "언어를 선택해주세요",
      selectedLanguage: Binding<LanguageEntity.Item?>,
      itemList: [LanguageEntity.Item],
      disabled: Bool)
    {
      self.title = title
      self.noSelectDescription = noSelectDescription
      self.selectedLanguage = selectedLanguage
      self.itemList = itemList
      self.disabled = disabled
    }
  }
}

extension ListeningModePage.SelectedLanguage {
  private func stateImage(item: LanguageEntity.Item) -> String {
    switch item.status {
    case .notInstalled: "arrow.down.circle"
    case .installed: "checkmark.circle.fill"
    case .notSupported: "x.circle.fill"
    }
  }
}

extension ListeningModePage.SelectedLanguage: View {

  var body: some View {
    Picker(.init(title), selection: selectedLanguage) {
      Text(noSelectDescription)
        .tag(nil as LanguageEntity.Item?)

      ForEach(itemList) { item in
        HStack {
          Text(item.langCode.modelName)
          Spacer()
          Image(systemName: stateImage(item: item))
        }
        .tag(Optional(item))
      }
    }
    .disabled(disabled)
  }
}
