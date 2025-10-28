import Domain
import Foundation
import SwiftUI
import Translation

// MARK: - SelectLanguage

struct SelectLanguage {

  let languageList: [LanguageEntity.Item]
  let disabled: Bool
  let onChangeStart: (LanguageEntity.Item) -> Void
  let onChangeEnd: (LanguageEntity.Item) -> Void
  let onError: (CompositeError) -> Void

  @State private var start: String = LanguageEntity.LangCode.english.modelName
  @State private var end: String = LanguageEntity.LangCode.korean.modelName
  @State private var configuration: TranslationSession.Configuration?
}

extension SelectLanguage {
  @MainActor
  private func selectLanguage(modelName: String, defaultItem: LanguageEntity.Item) -> LanguageEntity.Item {
    languageList.first(where: { $0.langCode.modelName == modelName }) ?? defaultItem
  }

}

// MARK: View

extension SelectLanguage: View {

  var body: some View {
    HStack {
      Rectangle()
        .fill(.clear)
        .frame(minWidth: .zero, maxWidth: .infinity)
        .overlay {
          HStack {
            Spacer(minLength: .zero)
            ListeningModePage.LanguagePicker(
              selectedLanguage: $start,
              itemList: languageList.map(\.langCode.modelName),
              disabled: disabled
            )
          }
        }
      Image(systemName: "guidepoint.vertical")
      Rectangle()
        .fill(.clear)
        .frame(minWidth: .zero, maxWidth: .infinity)
        .overlay {
          HStack {
            ListeningModePage.LanguagePicker(
              selectedLanguage: $end,
              itemList: languageList.map(\.langCode.modelName),
              disabled: disabled
            )
            Spacer(minLength: .zero)
          }
        }
    }
    .frame(height: 48)
    .translationTask(configuration) { session in
      Task {
        do {
          try await session.prepareTranslation()
          let pick = selectLanguage(modelName: end, defaultItem: .init(langCode: .english, status: .notInstalled))
          onChangeEnd(pick)
        } catch {
          onError(error.serialized())
        }
      }
    }
    .onChange(of: start) { _, _ in
      guard !disabled else { return }
      let pick = selectLanguage(modelName: start, defaultItem: .init(langCode: .english, status: .notInstalled))
      onChangeStart(pick)
      makeConfiguration()
    }
    .onChange(of: end) { _, _ in
      guard !disabled else { return }
      let pick = selectLanguage(modelName: end, defaultItem: .init(langCode: .english, status: .notInstalled))
      onChangeEnd(pick)
      makeConfiguration()
    }
  }

  @MainActor
  func makeConfiguration() {
    guard
      let start = languageList.first(where: { $0.langCode.modelName == start }),
      let end = languageList.first(where: { $0.langCode.modelName == end })
    else { return }
    Task {
      try? await Task.sleep(for: .seconds(1))
      configuration = .init(
        source: start.langCode.locale.language,
        target: end.langCode.locale.language
      )
    }
  }
}
