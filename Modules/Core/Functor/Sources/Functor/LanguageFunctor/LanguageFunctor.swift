import Foundation
import NaturalLanguage

// MARK: - LanguageFunctor

public enum LanguageFunctor { }

extension LanguageFunctor {
  public static func isRTL(string: String) -> Bool {
    let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
    tagger.string = String(string)
    guard let language = tagger.dominantLanguage else { return false }
    return ["ar", "he", "fa", "ps", "ur"].contains(language)
  }

  public static func isRTL(string: String) async -> Bool {
    await withCheckedContinuation { continuation in
      let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
      tagger.string = String(string)
      guard let language = tagger.dominantLanguage else { return continuation.resume(returning: false) }
      return continuation.resume(returning: ["ar", "he", "fa", "ps", "ur"].contains(language))
    }
  }

  public static func isRTLSupport(langCode: String) -> Bool {
    ["ar", "he", "fa", "ps", "ur"].contains(langCode.lowercased())
  }

  public static func isRTLSupport(langCode: String) async -> Bool {
    await withCheckedContinuation { continuation in
      continuation.resume(returning: ["ar", "he", "fa", "ps", "ur"].contains(langCode.lowercased()))
    }
  }

  public static func getLanguageCode(text: String, defaultLangCode: String) -> String {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)

    guard let language = recognizer.dominantLanguage else { return defaultLangCode }

    switch language {
    case .simplifiedChinese:
      return "zh-CN"
    case .traditionalChinese:
      return "zh-TW"
    default:
      return language.rawValue
    }
  }

  public static func convertCharactersFormat(text: String, langCode: String) -> String {
    switch langCode {
    case "zh-CN", "zh-TW":
      return convert(text: text, langCode: langCode)
    default:
      return text
    }

    func convert(text: String, langCode: String) -> String {
      let textLangCode = getLanguageCode(text: text, defaultLangCode: langCode)
      guard langCode != textLangCode else { return text }
      let transform = "\(textLangCode.convertCN())-\(langCode.convertCN())"
      let mutable = NSMutableString(string: text)
      CFStringTransform(mutable, nil, transform as CFString, false)
      return mutable as String
    }
  }
}

extension String {
  fileprivate func convertCN() -> String {
    lowercased() == "zh-cn" ? "Hans" : "Hant"
  }
}
