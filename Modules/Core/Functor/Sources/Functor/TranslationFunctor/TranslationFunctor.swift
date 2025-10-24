import Foundation
import Translation

// MARK: - TranslationFunctor

public struct TranslationFunctor {
  public init(startLocale: Locale, endLocale: Locale) {
    self.startLocale = startLocale
    self.endLocale = endLocale
  }

  let startLocale: Locale
  let endLocale: Locale

}

@available(iOS 26.0, *) // Adjust to your actual minimum iOS version that includes Translation
extension TranslationFunctor {
  public func request(text: String) async throws -> String {
    guard startLocale != endLocale else { return text }

    let session = TranslationSession(
      installedSource: startLocale.language,
      target: endLocale.language
    )
    try await session.prepareTranslation()
    let result = try await session.translate(text)

    return result.targetText
  }
}
