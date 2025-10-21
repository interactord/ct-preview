import Foundation
import Translation

public struct TranslationFunctor {
  let startLocale: Locale
  let endLocale: Locale

  public init(startLocale: Locale, endLocale: Locale) {
    self.startLocale = startLocale
    self.endLocale = endLocale
  }
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

  public func downloadIfNeeds() async {
    guard startLocale != endLocale else { return }
    let availability = LanguageAvailability()
    let status = await availability.status(from: startLocale.language, to: endLocale.language)

//    switch status {
//    case .installed:
//      print("✅ Model installed")
//      return false
//    case .supported:
//      print("⬇️ Model available to download")
//      return true
//    case .unsupported:
//      print("❌ Language pair not supported")
//      return false
//    default:
//      return false
//    }

    if status != .installed {
      do {
        let session = await TranslationSession(
          installedSource: .init(identifier: "ko"),
          target: .init(identifier: "en"))
        try await session.prepareTranslation()
      } catch {
        print("[TranslationFunctor][ERROR] \(error)")
      }
    }
  }

  public func downloadRequest() async {
    let session = try await TranslationSession(
      installedSource: startLocale.language,
      target: endLocale.language)
    do {
      try await session.prepareTranslation()
    } catch {
      print("[TranslationFunctor][ERROR] \(error)")
    }
  }
}
