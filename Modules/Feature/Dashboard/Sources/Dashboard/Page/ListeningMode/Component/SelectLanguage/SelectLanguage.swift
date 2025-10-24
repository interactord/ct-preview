import Domain
import Foundation
import SwiftUI
import Translation

// MARK: - SelectLanguage

struct SelectLanguage {

  let languageList: [LanguageEntity.Item]
  let disabled: Bool
  let onChangeStart: (LanguageEntity.Item?) -> Void
  let onChangeEnd: (LanguageEntity.Item?) -> Void
  let onError: (CompositeError) -> Void

  @State private var start: LanguageEntity.Item? = .init(langCode: .english, status: .installed)
  @State private var end: LanguageEntity.Item? = .init(langCode: .korean, status: .installed)
  @State private var configuration: TranslationSession.Configuration?
}

// MARK: View

extension SelectLanguage: View {

  var body: some View {
    HStack {
      Spacer()
      ListeningModePage.LanguagePicker(
        selectedLanguage: $start,
        itemList: languageList,
        disabled: disabled
      )

      Image(systemName: "arrow.right")

      ListeningModePage.LanguagePicker(
        selectedLanguage: $end,
        itemList: languageList,
        disabled: disabled
      )

      Spacer()
    }
    .translationTask(configuration) { session in
      Task {
        do {
          try await session.prepareTranslation()
          onChangeEnd(end)
        } catch {
          onError(error.serialized())
        }
      }
    }
    .onChange(of: start) { _, _ in
      guard !disabled else { return }
      onChangeStart(start)
      makeConfiguration()
    }
    .onChange(of: end) { _, _ in
      guard !disabled else { return }
      onChangeEnd(end)
      makeConfiguration()
    }
  }

  @MainActor
  func makeConfiguration() {
    guard let start, let end else { return }
    Task {
      try? await Task.sleep(for: .seconds(1))
      configuration = .init(
        source: start.langCode.locale.language,
        target: end.langCode.locale.language
      )
    }
  }
}
