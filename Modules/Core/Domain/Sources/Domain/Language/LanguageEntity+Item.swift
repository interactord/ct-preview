import Foundation

extension LanguageEntity {

  public struct Item: Equatable, Hashable, Sendable {
    public let langCode: LangCode
    public let status: ProgressStatus

    public init(langCode: LangCode, status: ProgressStatus) {
      self.langCode = langCode
      self.status = status
    }
  }

  public enum LangCode: Equatable, Hashable, Sendable, CaseIterable {
    case english       // en_US
    case french        // fr_FR
    case german        // de_DE
    case japanese      // ja_JP
    case korean        // ko_KR
    case spanish       // es_ES
    case italian       // it_IT
    case portugueseBR  // pt_BR
    case chineseSimplified // zh_CN
  }

  public enum ProgressStatus: Equatable, Hashable, Sendable {
    case notInstalled
    case installed
    case notSupported
  }
}

extension LanguageEntity.Item: Identifiable {
  public var id: String {
    "\(langCode)"
  }
}

extension LanguageEntity.LangCode {
  public var locale: Locale {
    switch self {
    case .english: Locale(identifier: "en_US")
    case .french: Locale(identifier: "fr_FR")
    case .german: Locale(identifier: "de_DE")
    case .japanese: Locale(identifier: "ja_JP")
    case .korean: Locale(identifier: "ko_KR")
    case .spanish: Locale(identifier: "es_ES")
    case .italian: Locale(identifier: "it_IT")
    case .portugueseBR: Locale(identifier: "pt_BR")
    case .chineseSimplified: Locale(identifier: "zh_CN")
    }
  }

  public var modelName: String {
    switch self {
    case .english: "English"
    case .french: "French"
    case .german: "German"
    case .japanese: "Japanese"
    case .korean: "Korean"
    case .spanish: "Spanish"
    case .italian: "Italian"
    case .portugueseBR: "Portuguese (Brazil)"
    case .chineseSimplified: "Chinese (Simplified)"
    }
  }
}
