import Domain
import Foundation
import Functor
import SwiftUI

// MARK: - ListeningModePage.ContentItem

extension ListeningModePage {
  struct ContentItem {
    let focusItemList: [TranscriptionEntity.Item]
    let updateAction: (TranscriptionEntity.Item) -> Void
    let errorAction: (CompositeError) -> Void
  }
}

extension ListeningModePage.ContentItem {
  private var item: TranscriptionEntity.Item? {
    focusItemList.last
  }

  private var originFont: Font {
    item?.translation == nil
      ? Font.system(size: 16, weight: .bold, design: .default)
      : Font.system(size: 12, weight: .regular, design: .default)
  }
}

extension ListeningModePage.ContentItem: View {
  var body: some View {
    VStack {
      if let item {
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
              .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: .zero)
          }
        }
      }
    }
    .padding(8)
    .animation(.spring(), value: item)
    .task {
      guard item?.translation == .none else { return }
      await translation()
      await llmTranslation()
    }
  }

  @MainActor
  func translation() async {
    guard let item else { return }
    let endLocale = item.endLocale ?? item.startLocale
    let functor = TranslationFunctor(startLocale: item.startLocale, endLocale: endLocale)
    do {
      let result = try await functor.request(text: item.text.toString())
      var newItem = item
      newItem.translation = .init(id: item.id, locale: endLocale, text: result)
      updateAction(newItem)
    } catch {
      errorAction(error.serialized())
    }
  }

  @MainActor
  func llmTranslation() async {
    guard let item else { return }
    let llmFunctor = LanguageModelFunctor()
    guard await llmFunctor.checkAppleIntelligenceAvailability() else { return }
    let endLocale = item.endLocale ?? item.startLocale

    do {
      let history: [LanguageModelFunctor.SourceItem] = focusItemList.dropLast()
        .map { .init(locale: $0.startLocale, text: $0.text.toString()) }

      let translationItem = LanguageModelFunctor.TranslationItem(
        startItem: .init(locale: item.startLocale, text: item.text.toString()),
        endItem: .init(locale: endLocale, text: item.translation?.text ?? ""),
        historyItemList: history
      )
      let result = try await llmFunctor.correctAndTranslate(item: translationItem)

      var newItem = item
      newItem.text = .init(result.correctedText)
      newItem.translation = .init(id: item.id, locale: endLocale, text: result.translatedText)
      updateAction(newItem)
    } catch {
      errorAction(error.serialized())
    }
  }
}

extension AttributedString {
  fileprivate func toString() -> String {
    String(characters[...])
  }
}
