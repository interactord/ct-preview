import Foundation
import Domain
import SwiftUI
import Functor

extension ListeningModePage {
  struct ContentItem {
    let item: TranscriptionEntity.Item
    let llmFunctor: LanguageModelFunctor
    var updateAction: (TranscriptionEntity.Item) -> Void
  }
}

extension ListeningModePage.ContentItem {
  var originFont: Font {
    item.translation == nil
    ? Font.system(size: 16, weight: .bold, design: .default)
    : Font.system(size: 12, weight: .regular, design: .default)
  }
}


extension ListeningModePage.ContentItem: View {
  var body: some View {
    VStack {
      HStack {
        Text(item.text)
          .font(originFont)
          .transition(.opacity)
        Spacer(minLength: .zero)
      }
      .opacity(item.translation == nil ? 1 : 0.8)
      .transition(.scale)

      Spacer(minLength: 8)

      if let translation = item.translation {
        HStack {
          Text(translation.text)
            .font(.system(size: 18, weight: .bold, design: .default))
            .foregroundStyle(Color.accentColor)
          Spacer(minLength: .zero)
        }
      }
    }
    .animation(.spring(), value: item)
    .task {
      await llmFunctor.checkAppleIntelligenceAvailability() ? llmTranslation() : translation()
    }
  }

  @MainActor
  func translation() async {
    let endLocale = item.endLocale ?? item.startLocale
    let functor = TranslationFunctor(startLocale: item.startLocale, endLocale: endLocale)
    do {
      let result = try await functor.request(text: item.text.toString())
      print(result)
      var newItem = item
      newItem.translation = .init(id: item.id, locale: endLocale, text: result)
      updateAction(newItem)
    } catch {
      print("[Error] \(error)")
    }
  }

  @MainActor
  func llmTranslation() async {
    guard await llmFunctor.checkAppleIntelligenceAvailability() else { return }
    let endLocale = item.endLocale ?? item.startLocale
    guard let result = await llmFunctor.correct(originalText: item.text.toString(), translationLocale: endLocale)
    else { return }

    var newItem = item
    newItem.text = .init(result.text)

    if endLocale.language.languageCode?.identifier == result.translatedLanguageCode {
      newItem.translation = .init(id: item.id, locale: endLocale, text: result.translationText)
    }
    updateAction(newItem)
  }
}

extension AttributedString {
  fileprivate func toString() -> String {
    String(self.characters[...])
  }
}
